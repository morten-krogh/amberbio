import UIKit

enum RenderType {
        case full_page
        case progress_indicator
        case activity_indicator
}

class State {
        let database: Database
        let store: Store

        var rendering = false
        var render_type = RenderType.full_page
        let root_component = RootComponent()

        var activity_indicator_info = ""
        var progress_indicator_info = ""
        var progress_indicator_progress = 0 as Int

        var page_state: PageState!

        var back_pages = [] as [PageState]
        var forward_pages = [] as [PageState]

        var active_data_set = false
        var data_set_id = 0
        var demo_data_set = true
        var data_set_name = ""
        var project_id = 0
        var project_name = ""
        var original_data_set_id = 0
        var sample_ids = [] as [Int]
        var sample_names = [] as [String]
        var number_of_samples = 0
        var factor_ids = [] as [Int]
        var factor_names = [] as [String]
        var level_ids_by_factor = [] as [[Int]]
        var level_names_by_factor = [] as [[String]]
        var level_colors_by_factor = [] as [[String]]
        var level_ids_by_factor_and_sample = [] as [[Int]]
        var level_names_by_factor_and_sample = [] as [[String]]
        var level_colors_by_factor_and_sample = [] as [[String]]
        var molecule_indices = [] as [Int]
        var molecule_names = [] as [String]
        var number_of_molecules = 0
        var molecule_annotation_names = [] as [String]
        var molecule_annotation_values = [] as [[String]]
        var values = [] as [Double]
        var offsets_by_level_id = [:] as [Int: [Int]]

        var home_content_offset = CGPoint.zero
        var home_selected_index_path: NSIndexPath?

        var full_page_scroll_offset = 0 as CGFloat

        var molecule_web_search: MoleculeWebSearch!

        init(database: Database) {
                self.database = database
                store = Store(database: database)
                let active_data_set_id = get_active_data_set_id()
                data_set_id = -1
                if active_data_set_id == 0 && home_selected_index_path == nil, let (section, row) = home_page_name_to_section_row["data_set_selection"] {
                                home_selected_index_path = NSIndexPath(forRow: row, inSection: section)
                }
                set_active_data_set(data_set_id: active_data_set_id)
                molecule_web_search = MoleculeWebSearch()
        }

        func render() {
                if !rendering {
                        rendering = true
                        if render_type == RenderType.full_page && !state.page_state.prepared {
                                activity_indicator_info = "Calculating"
                                render_type = RenderType.activity_indicator

                                let serial_queue = dispatch_queue_create("state prepare", DISPATCH_QUEUE_SERIAL)
                                dispatch_async(serial_queue, {
                                        state.page_state.prepare()
                                        dispatch_async(dispatch_get_main_queue(), {
                                                self.render_type = RenderType.full_page
                                                self.render()
                                        })
                                })
                        }
                        root_component.render()
                        rendering = false
                }
        }

        func render_from_dispatch_queue() {
                dispatch_sync(dispatch_get_main_queue(), {
                        self.render()
                })
        }

        func progress_indicator_step(total total: Int, index: Int, min: Int, max: Int, step_size: Int) {
                let progress_indicator_progress = min + (max - min) * (index + 1) / total
                if progress_indicator_progress != self.progress_indicator_progress {
                        self.progress_indicator_progress = progress_indicator_progress
                        render_from_dispatch_queue()
                }
        }

        func set_active_data_set(data_set_id data_set_id: Int) {
                if self.data_set_id != data_set_id {
                        reset_data_set()
                        reset_history()

                        if data_set_id != 0 {
                                set_data_set(data_set_id: data_set_id)
                        } else {
                                self.data_set_id = 0
                        }
                }
        }

        func locked(page_name page_name: String) -> Bool {
                return !demo_data_set && store.locked_page_names.contains(page_name)
        }

        func reset_data_set() {
                reset_active_data_set_in_database()

                active_data_set = false
                data_set_id = 0
                data_set_name = ""
                project_id = 0
                project_name = ""
                original_data_set_id = 0
                sample_ids = [] as [Int]
                sample_names = [] as [String]
                number_of_samples = 0
                factor_ids = [] as [Int]
                factor_names = [] as [String]
                level_ids_by_factor = [] as [[Int]]
                level_names_by_factor = [] as [[String]]
                level_colors_by_factor = [] as [[String]]
                level_ids_by_factor_and_sample = [] as [[Int]]
                level_names_by_factor_and_sample = [] as [[String]]
                level_colors_by_factor_and_sample = [] as [[String]]
                molecule_indices = [] as [Int]
                molecule_names = [] as [String]
                number_of_molecules = 0
                molecule_annotation_names = [] as [String]
                molecule_annotation_values = [] as [[String]]
                values = [] as [Double]
                offsets_by_level_id = [:] as [Int: [Int]]
        }

        func get_active_data_set_id() -> Int {
                let statement = "select data_set_id from active_data_set"
                let query = Query(statement: statement, result_types: ["integer"])
                sqlite_execute(database: database, query: query)
                return query.result_integers[0].isEmpty ? 0 : query.result_integers[0][0]
        }

        func reset_active_data_set_in_database() {
                let query = Query(statement: "delete from active_data_set")
                sqlite_execute(database: database, query: query)
        }

        func set_data_set(data_set_id data_set_id: Int) {
                sqlite_begin(database: database)
                set_data_set_in_database(data_set_id: data_set_id)

                active_data_set = true
                self.data_set_id = data_set_id
                data_set_name = get_data_set_name(data_set_id: data_set_id)
                (project_id, project_name) = get_project(data_set_id: data_set_id)
                original_data_set_id = get_original_data_set_id(project_id: project_id)
                (sample_ids, sample_names) = get_samples(data_set_id: data_set_id)
                number_of_samples = sample_ids.count
                set_factors_and_levels()
                molecule_indices = get_molecule_indices(data_set_id: data_set_id)
                number_of_molecules = molecule_indices.count

                set_molecule_annotations()

                values = get_values(data_set_id: data_set_id)

                sqlite_end(database: database)
        }

        func set_data_set_in_database(data_set_id data_set_id: Int) {
                let query = Query(statement: "insert into active_data_set (data_set_id) values (:integer0)", bind_integers: [data_set_id])
                sqlite_execute(database: database, query: query)
        }

        func set_offsets_by_level_id() {
                offsets_by_level_id = [:]
                for i in 0 ..< factor_ids.count {
                        for j in 0 ..< number_of_samples {
                                let level_id = level_ids_by_factor_and_sample[i][j]
                                if offsets_by_level_id[level_id] == nil {
                                        offsets_by_level_id[level_id] = []
                                }
                                offsets_by_level_id[level_id]?.append(j)
                        }
                }
        }

        func set_factors_and_levels() {
                (factor_ids, factor_names) = get_factors(project_id: project_id)
                (level_ids_by_factor, level_names_by_factor, level_colors_by_factor) = get_levels_by_factor(factor_ids: factor_ids)
                (level_ids_by_factor_and_sample, level_names_by_factor_and_sample, level_colors_by_factor_and_sample) = get_levels_for_samples(sample_ids: sample_ids, number_of_factors: factor_ids.count)
                set_offsets_by_level_id()
        }

        func set_molecule_annotations() {
                let (molecule_annotation_names_all, molecule_annotation_values_all) = get_molecule_annotations(project_id: project_id)
                molecule_annotation_names = []
                molecule_annotation_values = []

                for i in 0 ..< molecule_annotation_names_all.count {
                        var annotation_values = [] as [String]
                        for molecule_index in molecule_indices {
                                annotation_values.append(molecule_annotation_values_all[i][molecule_index])
                        }
                        if molecule_annotation_names_all[i] == "molecule name" {
                                molecule_names = annotation_values
                        } else {
                                molecule_annotation_names.append(molecule_annotation_names_all[i])
                                molecule_annotation_values.append(annotation_values)
                        }
                }
        }

        func set_page_state(page_state page_state: PageState) {
                self.page_state = page_state
                verify_page()
                prune_history()
                if let (section, row) = home_page_name_to_section_row[page_state.name] {
                        home_selected_index_path = NSIndexPath(forRow: row, inSection: section)
                }
        }

        func navigate(page_state page_state: PageState) {
                back_pages.append(self.page_state)
                forward_pages = []
                set_page_state(page_state: page_state)
        }

        func navigate_back() {
                if !back_pages.isEmpty {
                        let page_state = back_pages.removeLast()
                        forward_pages.append(self.page_state)
                        set_page_state(page_state: page_state)
                }
        }

        func navigate_forward() {
                if !forward_pages.isEmpty {
                        let page_state = forward_pages.removeLast()
                        back_pages.append(self.page_state)
                        set_page_state(page_state: page_state)
                }
        }

        func verify_page() {
                let page_names_without_active_data_set = ["home", "module_store", "manual", "feedback", "user", "data_set_selection", "import_data", "export_projects"]

                if !active_data_set {
                        if page_names_without_active_data_set.indexOf(page_state.name) == nil {
                                page_state = DataSetSelectionState()
                        }
                } else if locked(page_name: page_state.name) {
                        page_state = ModuleStoreState()
                }
        }

        func prune_history() {
                back_pages = prune_history(pages: back_pages)
                forward_pages = prune_history(pages: forward_pages)
        }

        func prune_history(pages pages: [PageState]) -> [PageState] {
                let maximum_size = 30
                let pruned_size = 15

                if pages.count <= maximum_size {
                        return pages
                }

                var pruned_pages = [] as [PageState]
                for i in 0 ..< pruned_size {
                        let index = pages.count - pruned_size + i
                        pruned_pages.append(pages[index])
                }

                return pruned_pages
        }

        func reset_history() {
                back_pages = []
                forward_pages = []
        }

        func get_user_name() -> String {
                let statement = "select user_name from user where user_id = 1"
                let query = Query(statement: statement, result_types: ["text"])
                sqlite_execute(database: database, query: query)
                return query.result_texts[0].isEmpty ? "" : query.result_texts[0][0]
        }

        func set_user_name(user_name user_name: String) {
                let statement = "insert or replace into user (user_id, user_name) values (1, :text0)"
                let query = Query(statement: statement, bind_texts: [user_name])
                sqlite_execute(database: database, query: query)
        }

        func get_emails() -> [String] {
                let statement = "select email_address from email"
                let query = Query(statement: statement, result_types: ["text"])
                sqlite_execute(database: database, query: query)
                let emails = query.result_texts[0]
                return emails
        }

        func set_emails(emails emails: [String]) {
                sqlite_execute(database: database, query: Query(statement: "delete from email"))
                let statement = "insert into email (email_address) values (:text0)"
                for email in emails {
                        let query = Query(statement: statement, bind_texts: [email])
                        sqlite_execute(database: database, query: query)
                }
        }

        func insert_file_data(data data: NSData) -> Int {
                let statement = "insert into file_data (file_bytes) values (:blob0)"
                let query = Query(statement: statement, bind_blobs: [data])
                sqlite_execute(database: database, query: query)
                return sqlite_last_insert_rowid(database: database)
        }

        func insert_file(name name: String, type: String, data: NSData) -> Int {
                sqlite_begin(database: database)
                let file_data_id = insert_file_data(data: data)
                let statement = "insert into file (file_name, file_size, file_type, file_data_id) values (:text0, :integer0, :text1, :integer1)"
                let query = Query(statement: statement, bind_texts: [name, type], bind_integers: [data.length, file_data_id])
                sqlite_execute(database: database, query: query)
                let file_id = sqlite_last_insert_rowid(database: database)
                sqlite_end(database: database)
                return file_id
        }

        func insert_result_file(data_set_id data_set_id: Int, name: String, data: NSData) -> Int {
                sqlite_begin(database: database)
                let file_id = insert_file(name: name, type: "result", data: data)
                let statement = "insert into file_data_set (file_id, data_set_id) values (:integer0, :integer1)"
                sqlite_execute(database: database, query: Query(statement: statement, bind_integers: [file_id, data_set_id]))
                sqlite_end(database: database)
                return file_id
        }

        func get_data_set_name(data_set_id data_set_id: Int) -> String {
                let statement = "select data_set_name from data_set where data_set_id = :integer0"
                let query = Query(statement: statement, bind_integers: [data_set_id], result_types: ["text"])
                sqlite_execute(database: database, query: query)
                return query.result_texts[0][0]
        }

        func get_project(data_set_id data_set_id: Int) -> (project_id: Int, project_name: String) {
                let statement = "select project_id, project_name from data_set natural join project where data_set_id = :integer0"
                let query = Query(statement: statement, bind_integers: [data_set_id], result_types: ["integer", "text"])
                sqlite_execute(database: database, query: query)
                return (query.result_integers[0][0], query.result_texts[0][0])
        }

        func get_original_data_set_id(project_id project_id: Int) -> Int {
                let statement = "select data_set_id from data_set where project_id = :integer0 order by data_set_date_of_creation limit 1"
                let query = Query(statement: statement, bind_integers: [project_id], result_types: ["integer"])
                sqlite_execute(database: database, query: query)
                return query.result_integers[0][0]
        }

        func insert_samples(sample_names sample_names: [String]) -> [Int] {
                let statement = "insert into sample (sample_name) values (:text0)"
                var sample_ids = [] as [Int]
                for i in 0 ..< sample_names.count {
                        sqlite_execute(database: database, query: Query(statement: statement, bind_texts: [sample_names[i]]))
                        sample_ids.append(sqlite_last_insert_rowid(database: database))
                }
                return sample_ids
        }

        func get_molecule_names(project_id project_id: Int) -> [String] {
                let (molecule_annotation_names_all, molecule_annotation_values_all) = get_molecule_annotations(project_id: project_id)
                var index_molecule_name = 0
                for i in 0 ..< molecule_annotation_names_all.count {
                        if molecule_annotation_names_all[i] == "molecule name" {
                                index_molecule_name = i
                                break
                        }
                }
                return molecule_annotation_values_all[index_molecule_name]
        }

        func insert_molecule_annotation(project_id project_id: Int, molecule_annotation_name: String, molecule_annotation_values: [String]) {
                let statement = "insert into molecule_annotation (project_id, molecule_annotation_name, molecule_annotation_values) values (:integer0, :text0, :blob0)"
                let molecule_annotation_values_serialized = serialize_strings(strings: molecule_annotation_values)
                let query = Query(statement: statement, bind_texts: [molecule_annotation_name], bind_blobs: [molecule_annotation_values_serialized], bind_integers: [project_id])
                sqlite_execute(database: database, query: query)
        }

        func insert_project(project_name project_name: String, data_set_name: String, values: [Double], sample_names: [String], molecule_names: [String]) -> Int {
                sqlite_begin(database: database)

                let statement_project = "insert into project (project_guid, project_name) values ((select lower(hex(randomblob(10)))), :text0)"
                let query_project = Query(statement: statement_project, bind_texts: [project_name])
                sqlite_execute(database: database, query: query_project)
                let project_id = sqlite_last_insert_rowid(database: database)

                let sample_ids = insert_samples(sample_names: sample_names)
                insert_molecule_annotation(project_id: project_id, molecule_annotation_name: "molecule name", molecule_annotation_values: molecule_names)

                let molecule_indices = [Int](0 ..< molecule_names.count)

                insert_data_set(data_set_name: data_set_name, project_id: project_id, values: values, sample_ids: sample_ids, molecule_indices: molecule_indices)
                sqlite_end(database: database)
                return project_id
        }

        func insert_molecule_annotations(project_id project_id: Int, molecule_annotation_names: [String], molecule_annotation_values: [[String]]) {
                sqlite_begin(database: database)
                for i in 0 ..< molecule_annotation_names.count {
                        insert_molecule_annotation(project_id: project_id, molecule_annotation_name: molecule_annotation_names[i], molecule_annotation_values: molecule_annotation_values[i])
                }
                sqlite_end(database: database)

                set_molecule_annotations()
                reset_history()
        }

        func delete_molecule_annotation(molecule_annotation_name molecule_annotation_name: String) {
                let statement = "delete from molecule_annotation where molecule_annotation_name = :text0"
                let query = Query(statement: statement, bind_texts: [molecule_annotation_name])
                sqlite_execute(database: database, query: query)

                set_molecule_annotations()
                reset_history()
        }

        func update_molecule_annotation(current_molecule_annotation_name current_molecule_annotation_name: String, new_molecule_annotation_name: String) {
                let statement = "update molecule_annotation set molecule_annotation_name = :text0 where molecule_annotation_name = :text1"
                let query = Query(statement: statement, bind_texts: [new_molecule_annotation_name, current_molecule_annotation_name])
                sqlite_execute(database: database, query: query)

                set_molecule_annotations()
                reset_history()
        }

        func insert_values(values values: [Double]) -> Int {
                let data = serialize_doubles(doubles: values)
                let statement = "insert into data_set_data (data_set_bytes) values (:blob0)"
                let query = Query(statement: statement, bind_blobs: [data])
                sqlite_execute(database: database, query: query)
                return sqlite_last_insert_rowid(database: database)
        }

        func insert_data_set(data_set_name data_set_name: String, project_id: Int, values: [Double], sample_ids: [Int], molecule_indices: [Int]) -> Int {
                let data_sample_ids = serialize_integers(integers: sample_ids)
                let data_molecule_indices = serialize_integers(integers: molecule_indices)

                sqlite_begin(database: database)

                let data_set_data_id = insert_values(values: values)

                let statement_data_set = "insert into data_set (data_set_guid, data_set_name, project_id, data_set_data_id, data_set_sample_ids, data_set_molecule_indices) values ((select lower(hex(randomblob(10)))), :text0, :integer0, :integer1, :blob0, :blob1)"
                let query_data_set = Query(statement: statement_data_set, bind_texts: [data_set_name], bind_blobs: [data_sample_ids, data_molecule_indices], bind_integers: [project_id, data_set_data_id])

                sqlite_execute(database: database, query: query_data_set)
                let data_set_id = sqlite_last_insert_rowid(database: database)

                sqlite_end(database: database)
                
                return data_set_id
        }

        func insert_factor(factor_name factor_name: String, project_id: Int) -> Int {
                let statement = "insert into factor (factor_name, project_id) values (:text0, :integer0)"
                let query = Query(statement: statement, bind_texts: [factor_name], bind_integers: [project_id])
                sqlite_execute(database: database, query: query)
                return sqlite_last_insert_rowid(database: database)
        }

        func insert_level(level_name level_name: String, color: String, factor_id: Int) -> Int {
                let statement = "insert into level (level_name, level_color, factor_id) values (:text0, :text1, :integer0)"
                let query = Query(statement: statement, bind_texts: [level_name, color], bind_integers: [factor_id])
                sqlite_execute(database: database, query: query)
                return sqlite_last_insert_rowid(database: database)
        }

        func insert_sample_level(sample_id sample_id: Int, level_id: Int) {
                let statement = "insert into sample_level (sample_id, level_id) values (:integer0, :integer1)"
                let query = Query(statement: statement, bind_integers: [sample_id, level_id])
                sqlite_execute(database: database, query: query)
        }

        func get_sample_ids(data_set_id data_set_id: Int) -> [Int] {
                let statement_sample_id = "select data_set_sample_ids from data_set where data_set_id = :integer0"
                let query_sample_id = Query(statement: statement_sample_id, bind_integers: [data_set_id], result_types: ["data"])
                sqlite_execute(database: database, query: query_sample_id)
                let data = query_sample_id.result_datas[0][0]
                let sample_ids = deserialize_integers(data: data)
                return sample_ids
        }

        func insert_factor(project_id project_id: Int, factor_name: String, level_names_of_samples: [String]) -> Int {
                sqlite_begin(database: database)
                let data_set_id = get_original_data_set_id(project_id: project_id)

                let sample_ids = get_sample_ids(data_set_id: data_set_id)

                var level_name_set = [] as Set<String>
                for level_name in level_names_of_samples {
                        level_name_set.insert(level_name)
                }

                let level_names_unsorted = [String](level_name_set)
                let level_names = sort_level_names(level_names: level_names_unsorted)

                let colors = color_palette_hex(number_of_colors: level_names.count)

                let factor_id = insert_factor(factor_name: factor_name, project_id: project_id)

                var level_ids = [] as [Int]
                for i in 0 ..< level_names.count {
                        let level_id = insert_level(level_name: level_names[i], color: colors[i], factor_id: factor_id)
                        level_ids.append(level_id)
                }
                
                for i in 0 ..< sample_ids.count {
                        let level_index = level_names.indexOf(level_names_of_samples[i])!
                        let level_id = level_ids[level_index]
                        insert_sample_level(sample_id: sample_ids[i], level_id: level_id)
                }
                sqlite_end(database: database)

                set_factors_and_levels()
                reset_history()
                
                return factor_id
        }

        func insert_factor(factor_name factor_name: String, temp_level_id_to_name: [Int: String], sample_id_to_temp_level_id: [Int: Int]) {
                let data_set_id = get_original_data_set_id(project_id: project_id)
                let sample_ids = get_sample_ids(data_set_id: data_set_id)
                var level_names_of_samples = [] as [String]
                for sample_id in sample_ids {
                        let level_name = temp_level_id_to_name[sample_id_to_temp_level_id[sample_id]!]!
                        level_names_of_samples.append(level_name)
                }

                insert_factor(project_id: project_id, factor_name: factor_name, level_names_of_samples: level_names_of_samples)
        }

        func insert_project_note(project_note_text project_note_text: String, project_note_type: String, project_note_user_name: String, project_id: Int) {
                let statement = "insert into project_note (project_note_text, project_note_type, project_note_user_name, project_id) values (:text0, :text1, :text2, :integer0)"
                let query = Query(statement: statement, bind_texts: [project_note_text, project_note_type, project_note_user_name], bind_integers: [project_id])
                sqlite_execute(database: database, query: query)
        }


        func update_project_note(project_note_id project_note_id: Int, project_note_text: String) {
                let statement = "update project_note set project_note_text = :text0 where project_note_id = :integer0"
                let query = Query(statement: statement, bind_texts: [project_note_text], bind_integers: [project_note_id])
                sqlite_execute(database: database, query: query)
        }

        func get_project_notes(project_id project_id: Int) -> (project_note_ids: [Int], project_note_dates: [String], project_note_texts: [String], project_note_types: [String], project_note_user_names: [String]) {
                let statement = "select project_note_id, project_note_date, project_note_text, project_note_type, project_note_user_name from project_note where project_id = :integer0 order by project_note_date desc"
                let query = Query(statement: statement, bind_integers: [project_id], result_types: ["integer", "text", "text", "text", "text"])
                sqlite_execute(database: database, query: query)
                return (query.result_integers[0], query.result_texts[0], query.result_texts[1], query.result_texts[2], query.result_texts[3])
        }

        func delete_project_note(project_note_id project_note_id: Int) {
                let statement = "delete from project_note where project_note_id = :integer0"
                let query = Query(statement: statement, bind_integers: [project_note_id])
                sqlite_execute(database: database, query: query)
        }

        func get_projects() -> (project_ids: [Int], project_names: [String], project_dates: [String]) {
                let statement = "select project_id, project_name, project_date_of_creation from project order by project_date_of_creation desc"
                let query = Query(statement: statement, result_types: ["integer", "text", "text"])
                sqlite_execute(database: database, query: query)
                return (query.result_integers[0], query.result_texts[0], query.result_texts[1])
        }

        func get_data_sets(project_id project_id: Int) -> (data_set_ids: [Int], data_set_names: [String], data_set_dates_of_creation: [String]) {
                let statement = "select data_set_id, data_set_name, data_set_date_of_creation from data_set where project_id = :integer0 order by data_set_date_of_creation desc"
                let query = Query(statement: statement, bind_integers: [project_id], result_types: ["integer", "text", "text"])
                sqlite_execute(database: database, query: query)
                return (query.result_integers[0], query.result_texts[0], query.result_texts[1])
        }

        func get_factors(project_id project_id: Int) -> (factor_ids: [Int], factor_names: [String]) {
                let statement = "select factor_id, factor_name from factor where project_id = :integer0 order by factor_id"
                let query = Query(statement: statement, bind_integers: [project_id], result_types: ["integer", "text"])
                sqlite_execute(database: database, query: query)
                return (query.result_integers[0], query.result_texts[0])
        }

        func get_sample_name(sample_id sample_id: Int) -> String {
                let statement = "select sample_name from sample where sample_id = :integer0"
                let query = Query(statement: statement, bind_integers: [sample_id], result_types: ["text"])
                sqlite_execute(database: database, query: query)
                return query.result_texts[0][0]
        }

        func get_samples(data_set_id data_set_id: Int) -> (sample_ids: [Int], sample_names: [String]) {
                let sample_ids = get_sample_ids(data_set_id: data_set_id)
                var sample_names = [] as [String]
                for sample_id in sample_ids {
                        let sample_name = get_sample_name(sample_id: sample_id)

                        sample_names.append(sample_name)
                }
                return (sample_ids, sample_names)
        }

        func get_molecule_indices(data_set_id data_set_id: Int) -> [Int] {
                let statement_sample_id = "select data_set_molecule_indices from data_set where data_set_id = :integer0"
                let query_sample_id = Query(statement: statement_sample_id, bind_integers: [data_set_id], result_types: ["data"])
                sqlite_execute(database: database, query: query_sample_id)
                let data = query_sample_id.result_datas[0][0]
                let molecule_indices = deserialize_integers(data: data)
                return molecule_indices
        }

        func get_molecule_annotations(project_id project_id: Int) -> (molecule_annotation_names: [String], molecule_annotation_values: [[String]]) {
                let statement = "select molecule_annotation_name, molecule_annotation_values from molecule_annotation where project_id = :integer0"
                let query = Query(statement: statement, bind_integers: [project_id], result_types: ["text", "data"])
                sqlite_execute(database: database, query: query)
                let molecule_annotation_names = query.result_texts[0]
                var molecule_annotation_values = [] as [[String]]
                for molecule_annotation_values_serialized in query.result_datas[0] {
                        let annotation_values = deserialize_strings(data: molecule_annotation_values_serialized)
                        molecule_annotation_values.append(annotation_values)
                }
                return (molecule_annotation_names, molecule_annotation_values)
        }

        func get_values(data_set_id data_set_id: Int) -> [Double] {
                let statement = "select data_set_bytes from data_set_data natural join data_set where data_set_id = :integer0"
                let query = Query(statement: statement, bind_integers: [data_set_id], result_types: ["data"])
                sqlite_execute(database: database, query: query)
                let data = query.result_datas[0][0]
                let values = deserialize_doubles(data: data)
                return values
        }

        func get_values_for_molecule(index index: Int) -> [Double] {
                let offset = index * number_of_samples
                let range = offset ..< offset + number_of_samples as Range
                return [Double](values[range])
        }

        func update_sample_name(sample_index sample_index: Int, sample_name: String) {
                let sample_id = sample_ids[sample_index]
                let statement = "update sample set sample_name = :text0 where sample_id = :integer0"
                let query = Query(statement: statement, bind_texts: [sample_name], bind_integers: [sample_id])
                sqlite_execute(database: database, query: query)
                sample_names[sample_index] = sample_name
                reset_history()
        }

        func get_levels(factor_id factor_id: Int) -> (level_ids: [Int], level_names: [String], level_colors: [String]) {
                let statement = "select level_id, level_name, level_color from level where factor_id = :integer0 order by level_name"
                let query = Query(statement: statement, bind_integers: [factor_id], result_types: ["integer", "text", "text"])
                sqlite_execute(database: database, query: query)
                return (query.result_integers[0], query.result_texts[0], query.result_texts[1])
        }

        func get_levels_by_factor(factor_ids factor_ids: [Int]) -> (level_ids_by_factor: [[Int]], level_name_by_factor: [[String]], level_colors_by_factor: [[String]]) {
                var (level_ids_by_factor, level_names_by_factor, level_colors_by_factor) = ([], [], []) as ([[Int]], [[String]], [[String]])
                for factor_id in factor_ids {
                        let (level_ids, level_names, level_colors) = get_levels(factor_id: factor_id)
                        level_ids_by_factor.append(level_ids)
                        level_names_by_factor.append(level_names)
                        level_colors_by_factor.append(level_colors)
                }
                return (level_ids_by_factor, level_names_by_factor, level_colors_by_factor)
        }

        func get_levels_for_sample(sample_id sample_id: Int) -> (level_ids: [Int], level_names: [String], level_colors: [String], factor_ids: [Int]) {
                let statement = "select level_id, level_name, level_color, factor_id from sample_level natural join level where sample_id = :integer0 order by factor_id"
                let query = Query(statement: statement, bind_integers: [sample_id], result_types: ["integer", "text", "text", "integer"])
                sqlite_execute(database: database, query: query)
                return (query.result_integers[0], query.result_texts[0], query.result_texts[1], query.result_integers[1])
        }

        func get_levels_for_samples(sample_ids sample_ids: [Int], number_of_factors: Int) -> (level_ids_by_factor_and_sample: [[Int]], level_names_by_factor_and_sample: [[String]], level_colors_by_factor_and_sample: [[String]]) {
                var level_ids_by_factor_and_sample = [[Int]](count: number_of_factors, repeatedValue: [])
                var level_names_by_factor_and_sample = [[String]](count: number_of_factors, repeatedValue: [])
                var level_colors_by_factor_and_sample = [[String]](count: number_of_factors, repeatedValue: [])

                for sample_id in sample_ids {
                        let (level_ids, level_names, level_colors, _) = get_levels_for_sample(sample_id: sample_id)
                        for i in 0 ..< number_of_factors {
                                level_ids_by_factor_and_sample[i].append(level_ids[i])
                                level_names_by_factor_and_sample[i].append(level_names[i])
                                level_colors_by_factor_and_sample[i].append(level_colors[i])
                        }
                }

                return (level_ids_by_factor_and_sample, level_names_by_factor_and_sample, level_colors_by_factor_and_sample)
        }

        func get_result_files(data_set_id data_set_id: Int) -> (file_ids: [Int], file_names: [String], file_dates: [String]) {
                let statement = "select file_id, file_name, file_date from file natural join file_data_set where data_set_id = :integer0 order by file_date desc"
                let query = Query(statement: statement, bind_integers: [data_set_id], result_types: ["integer", "text", "text"])
                sqlite_execute(database: database, query: query)
                return (query.result_integers[0], query.result_texts[0], query.result_texts[1])
        }

        func get_result_files(project_id project_id: Int) -> (data_set_ids: [Int], data_set_names: [String], file_ids: [[Int]], file_names: [[String]], file_dates: [[String]]) {
                let (data_set_ids, data_set_names, _) = get_data_sets(project_id: project_id)
                var data_set_ids_non_emtpy = [] as [Int]
                var data_set_names_non_empty = [] as [String]
                var file_ids = [] as [[Int]]
                var file_names = [] as [[String]]
                var file_dates = [] as [[String]]
                for i in 0 ..< data_set_ids.count {
                        let data_set_id = data_set_ids[i]
                        let (file_ids_data_set, file_names_data_set, file_dates_data_set) = get_result_files(data_set_id: data_set_id)
                        if !file_ids_data_set.isEmpty {
                                data_set_ids_non_emtpy.append(data_set_id)
                                data_set_names_non_empty.append(data_set_names[i])
                                file_ids.append(file_ids_data_set)
                                file_names.append(file_names_data_set)
                                file_dates.append(file_dates_data_set)
                        }
                }

                return (data_set_ids_non_emtpy, data_set_names_non_empty, file_ids, file_names, file_dates)
        }

        func delete_result_file(result_file_id result_file_id: Int) {
                let statement = "delete from file_data_set where file_id = :integer0"
                sqlite_execute(database: database, query: Query(statement: statement, bind_integers: [result_file_id]))
        }

        func select_file_name_and_file_data(file_id file_id: Int) -> (file_name: String, file_data: NSData)? {
                let statement = "select file_name, file_bytes from file natural join file_data where file_id = :integer0"
                let query = Query(statement: statement, bind_integers: [file_id], result_types: ["text", "data"])
                sqlite_execute(database: database, query: query)
                return query.result_texts[0].isEmpty ? nil : (query.result_texts[0][0], query.result_datas[0][0])
        }

        func get_files(type type: String) -> (ids: [Int], file_names: [String], date_of_imports: [String], sizes: [Int])  {
                let statement = "select file_id, file_name, file_date, file_size from file where file_type = :text0 order by file_date desc"
                let query = Query(statement: statement, bind_texts: [type], result_types: ["integer", "text", "text", "integer"])
                sqlite_execute(database: database, query: query)
                return (query.result_integers[0], query.result_texts[0], query.result_texts[1], query.result_integers[1])
        }

        func delete_file(file_id file_id: Int) {
                sqlite_execute(database: database, query: Query(statement: "delete from file where file_id = :integer0", bind_integers: [file_id]))
        }

        func update_level_color(level_id level_id: Int, level_color: String) {
                let statement = "update level set level_color = :text0 where level_id = :integer0"
                let query = Query(statement: statement, bind_texts: [level_color], bind_integers: [level_id])
                sqlite_execute(database: database, query: query)
                set_factors_and_levels()
                reset_history()
        }

        func delete_factor(factor_id factor_id: Int) {
                let statement = "delete from factor where factor_id = :integer0"
                let query = Query(statement: statement, bind_integers: [factor_id])
                sqlite_execute(database: database, query: query)
                set_factors_and_levels()
                reset_history()
        }

        func update_factor(factor_id factor_id: Int, factor_name: String, temp_level_id_to_name: [Int: String], temp_level_id_to_level_id: [Int: Int], sample_id_to_temp_level_id: [Int: Int]) {
                let factor_index = factor_ids.indexOf(factor_id)!

                sqlite_begin(database: database)
                if factor_name != factor_names[factor_index] {
                        let statement_factor = "update factor set factor_name = :text0 where factor_id = :integer0"
                        let query_factor = Query(statement: statement_factor, bind_texts: [factor_name], bind_integers: [factor_id])
                        sqlite_execute(database: database, query: query_factor)
                }

                var temp_level_id_to_level_id_copy = temp_level_id_to_level_id

                for (temp_level_id, level_name) in temp_level_id_to_name {
                        if let level_id = temp_level_id_to_level_id[temp_level_id] {
                                let statement = "update level set level_name = :text0 where level_id = :integer0"
                                let query = Query(statement: statement, bind_texts: [level_name], bind_integers: [level_id])
                                sqlite_execute(database: database, query: query)
                        } else {
                                let color = color_random_hex()
                                let statement = "insert into level (level_name, level_color, factor_id) values (:text0, :text1, :integer0)"
                                let query = Query(statement: statement, bind_texts: [level_name, color], bind_integers: [factor_id])
                                sqlite_execute(database: database, query: query)
                                let level_id = sqlite_last_insert_rowid(database: database)
                                temp_level_id_to_level_id_copy[temp_level_id] = level_id
                        }
                }

                for i in 0 ..< sample_ids.count {
                        let sample_id = sample_ids[i]
                        let current_level_id = level_ids_by_factor_and_sample[factor_index][i]
                        let new_level_id = temp_level_id_to_level_id_copy[sample_id_to_temp_level_id[sample_id]!]!
                        if new_level_id != current_level_id {
                                let statement_delete = "delete from sample_level where sample_id = :integer0 and level_id = :integer1"
                                let query_delete = Query(statement: statement_delete, bind_integers: [sample_id, current_level_id])
                                let statement_insert = "insert into sample_level (sample_id, level_id) values (:integer0, :integer1)"
                                let query_insert = Query(statement: statement_insert, bind_integers: [sample_id, new_level_id])
                                sqlite_execute(database: database, queries: [query_delete, query_insert])
                        }
                }

                let current_level_ids = level_ids_by_factor[factor_index]
                for level_id in current_level_ids {
                        if temp_level_id_to_level_id_copy.values.indexOf(level_id) == nil {
                                let statement = "delete from level where level_id = :integer0"
                                let query = Query(statement: statement, bind_integers: [level_id])
                                sqlite_execute(database: database, query: query)
                        }
                }
                sqlite_end(database: database)

                set_factors_and_levels()
                reset_history()
        }

        func update_project_name(project_id project_id: Int, project_name: String) {
                let statement = "update project set project_name = :text0 where project_id = :integer0"
                let query = Query(statement: statement, bind_integers: [project_id], bind_texts: [project_name])
                sqlite_execute(database: database, query: query)
                if active_data_set && self.project_id == project_id {
                        self.project_name = project_name
                }
                reset_history()
        }

        func update_data_set_name(data_set_id data_set_id: Int, data_set_name: String) {
                let statement = "update data_set set data_set_name = :text0 where data_set_id = :integer0"
                let query = Query(statement: statement, bind_integers: [data_set_id], bind_texts: [data_set_name])
                sqlite_execute(database: database, query: query)
                if active_data_set && self.data_set_id == data_set_id {
                        self.data_set_name = data_set_name
                }
                reset_history()
        }

        func delete_data_set(data_set_id data_set_id: Int) {
                let query = Query(statement: "delete from data_set where data_set_id = :integer0", bind_integers: [data_set_id])
                sqlite_execute(database: database, query: query)
        }

        func delete_project(project_id project_id: Int) {
                let original_data_set_id = get_original_data_set_id(project_id: project_id)
                let sample_ids = get_sample_ids(data_set_id: original_data_set_id)
                sqlite_begin(database: database)
                for sample_id in sample_ids {
                        let query = Query(statement: "delete from sample where sample_id = :integer0", bind_integers: [sample_id])
                        sqlite_execute(database: database, query: query)
                }
                let query = Query(statement: "delete from project where project_id = :integer0", bind_integers: [project_id])
                sqlite_execute(database: database, query: query)
                set_active_data_set(data_set_id: 0)
                sqlite_end(database: database)
        }

        func insert_txt_result_file(file_name_stem file_name_stem: String, description: String, table: [[String]]) {
                let (file_name, data) = txt_result_file(name: file_name_stem, description: description, project_name: state.project_name, data_set_name: state.data_set_name, user_name: state.get_user_name(), table: table)
                insert_result_file(data_set_id: data_set_id, name: file_name, data: data)
                let result_files_state = ResultFilesState()
                navigate(page_state: result_files_state)
                render_type = RenderType.full_page
        }

        func insert_pdf_result_file(file_name_stem file_name_stem: String, description: String, content_size: CGSize, draw: (context: CGContext, rect: CGRect) -> ()) {
                let (file_name, data) =  pdf_result_file(name: file_name_stem, description: description, project_name: state.project_name, data_set_name: state.data_set_name, user_name: state.get_user_name(), content_size: content_size, draw: draw)
                insert_result_file(data_set_id: data_set_id, name: file_name, data: data)
                let result_files_state = ResultFilesState()
                navigate(page_state: result_files_state)
                render_type = RenderType.full_page
        }

        func insert_png_result_file(file_name_stem file_name_stem: String, file_data: NSData) {
                let file_name = file_name_for_result_file(name: file_name_stem, ext: "png")
                insert_result_file(data_set_id: data_set_id, name: file_name, data: file_data)
                let result_files_state = ResultFilesState()
                navigate(page_state: result_files_state)
                render_type = RenderType.full_page
        }
}
