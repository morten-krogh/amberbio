import Foundation

func set_user_name(database database: Database, user_name: String) {
        let statement = "insert or replace into user (user_id, user_name) values (1, :text0)"
        let query = Query(statement: statement, bind_texts: [user_name])
        sqlite_execute(database: database, query: query)
}

func set_email(database database: Database, email: String) {
        let statement = "insert into email (email_address) values (:text0)"
        let query = Query(statement: statement, bind_texts: [email])
        sqlite_execute(database: database, query: query)
}

func insert_file_data(database database: Database, data: NSData) -> Int {
        let statement = "insert into file_data (file_bytes) values (:blob0)"
        let query = Query(statement: statement, bind_blobs: [data])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_file(database database: Database, name: String, type: String, data: NSData) -> Int {
        let file_data_id = insert_file_data(database: database, data: data)
        let statement = "insert into file (file_name, file_size, file_type, file_data_id) values (:text0, :integer0, :text1, :integer1)"
        let query = Query(statement: statement, bind_texts: [name, type], bind_integers: [data.length, file_data_id])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_samples(database database: Database, sample_names: [String]) -> [Int] {
        let statement = "insert into sample (sample_name) values (:text0)"
        var sample_ids = [] as [Int]
        for i in 0 ..< sample_names.count {
                sqlite_execute(database: database, query: Query(statement: statement, bind_texts: [sample_names[i]]))
                sample_ids.append(sqlite_last_insert_rowid(database: database))
        }
        return sample_ids
}

func insert_molecule_annotation(database database: Database, project_id: Int, molecule_annotation_name: String, molecule_annotation_values: [String]) {
        let statement = "insert into molecule_annotation (project_id, molecule_annotation_name, molecule_annotation_values) values (:integer0, :text0, :blob0)"
        let molecule_annotation_values_serialized = serialize_strings(strings: molecule_annotation_values)
        let query = Query(statement: statement, bind_texts: [molecule_annotation_name], bind_blobs: [molecule_annotation_values_serialized], bind_integers: [project_id])
        sqlite_execute(database: database, query: query)
}


func insert_values(database database: Database, values: [Double]) -> Int {
        let data = serialize_doubles(doubles: values)
        let statement = "insert into data_set_data (data_set_bytes) values (:blob0)"
        let query = Query(statement: statement, bind_blobs: [data])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_data_set(database database: Database, data_set_name: String, project_id: Int, values: [Double], sample_ids: [Int], molecule_indices: [Int]) -> Int {
        let data_sample_ids = serialize_integers(integers: sample_ids)
        let data_molecule_indices = serialize_integers(integers: molecule_indices)

        sqlite_begin(database: database)

        let data_set_data_id = insert_values(database: database, values: values)

        let statement_data_set = "insert into data_set (data_set_guid, data_set_name, project_id, data_set_data_id, data_set_sample_ids, data_set_molecule_indices) values ((select lower(hex(randomblob(10)))), :text0, :integer0, :integer1, :blob0, :blob1)"
        let query_data_set = Query(statement: statement_data_set, bind_texts: [data_set_name], bind_blobs: [data_sample_ids, data_molecule_indices], bind_integers: [project_id, data_set_data_id])

        sqlite_execute(database: database, query: query_data_set)
        let data_set_id = sqlite_last_insert_rowid(database: database)

        sqlite_end(database: database)
        
        return data_set_id
}

func insert_factor(database database: Database, factor_name: String, project_id: Int) -> Int {
        let statement = "insert into factor (factor_name, project_id) values (:text0, :integer0)"
        let query = Query(statement: statement, bind_texts: [factor_name], bind_integers: [project_id])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_level(database database: Database, level_name: String, color: String, factor_id: Int) -> Int {
        let statement = "insert into level (level_name, level_color, factor_id) values (:text0, :text1, :integer0)"
        let query = Query(statement: statement, bind_texts: [level_name, color], bind_integers: [factor_id])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_sample_level(database database: Database, sample_id: Int, level_id: Int) {
        let statement = "insert into sample_level (sample_id, level_id) values (:integer0, :integer1)"
        let query = Query(statement: statement, bind_integers: [sample_id, level_id])
        sqlite_execute(database: database, query: query)
}

func insert_factor(database database: Database, project_id: Int, sample_ids: [Int], factor_name: String, level_names_of_samples: [String]) -> Int {
        var level_names = [] as [String]
        var index_of_level_name = [:] as [String: Int]
        var level_set = [] as Set<String>
        for level_name in level_names_of_samples {
                if !level_set.contains(level_name) {
                        index_of_level_name[level_name] = level_names.count
                        level_names.append(level_name)
                        level_set.insert(level_name)
                }
        }

        let colors = color_palette_hex(number_of_colors: level_names.count)

        let factor_id = insert_factor(database: database, factor_name: factor_name, project_id: project_id)

        var level_ids = [] as [Int]
        for i in 0 ..< level_names.count {
                let level_id = insert_level(database: database, level_name: level_names[i], color: colors[i], factor_id: factor_id)
                level_ids.append(level_id)
        }

        for i in 0 ..< sample_ids.count {
                let level_index = index_of_level_name[level_names_of_samples[i]]!
                let level_id = level_ids[level_index]
                insert_sample_level(database: database, sample_id: sample_ids[i], level_id: level_id)
        }

        return factor_id
}

func insert_project_note(database database: Database, project_note_text: String, project_note_type: String, project_note_user_name: String, project_id: Int) {
        let statement = "insert into project_note (project_note_text, project_note_type, project_note_user_name, project_id) values (:text0, :text1, :text2, :integer0)"
        let query = Query(statement: statement, bind_texts: [project_note_text, project_note_type, project_note_user_name], bind_integers: [project_id])
        sqlite_execute(database: database, query: query)
}

func insert_project(database database: Database, project_name: String, data_set_name: String, values: [Double], sample_names: [String], molecule_names: [String], factor_names: [String], level_names_of_samples_array: [[String]], molecule_annotation_names: [String], molecule_annotation_values_array: [[String]], project_note_texts: [String], project_note_types: [String], project_note_user_names: [String]) -> Int {

        let statement_project = "insert into project (project_guid, project_name) values ((select lower(hex(randomblob(10)))), :text0)"
        let query_project = Query(statement: statement_project, bind_texts: [project_name])
        sqlite_execute(database: database, query: query_project)
        let project_id = sqlite_last_insert_rowid(database: database)

        let sample_ids = insert_samples(database: database, sample_names: sample_names)
        insert_molecule_annotation(database: database, project_id: project_id, molecule_annotation_name: "molecule name", molecule_annotation_values: molecule_names)

        let molecule_indices = [Int](0 ..< molecule_names.count)

        insert_data_set(database: database, data_set_name: data_set_name, project_id: project_id, values: values, sample_ids: sample_ids, molecule_indices: molecule_indices)

        for i in 0 ..< factor_names.count {
                insert_factor(database: database, project_id: project_id, sample_ids: sample_ids, factor_name: factor_names[i], level_names_of_samples: level_names_of_samples_array[i])
        }

        for i in 0 ..< molecule_annotation_names.count {
                insert_molecule_annotation(database: database, project_id: project_id, molecule_annotation_name: molecule_annotation_names[i], molecule_annotation_values: molecule_annotation_values_array[i])
        }

        for i in 0 ..< project_note_texts.count {
                insert_project_note(database: database, project_note_text: project_note_texts[i], project_note_type: project_note_types[i], project_note_user_name: project_note_user_names[i], project_id: project_id)
        }

        return project_id
}

func import_data(database database: Database, stem: String, project_name: String) -> Int {

        var values = [] as [Double]
        var sample_names = [] as [String]
        var molecule_names = [] as [String]
        var factor_names = [] as [String]
        var level_names_of_samples_array = [] as [[String]]
        var molecule_annotation_names = [] as [String]
        var molecule_annotation_values_array = [] as [[String]]

        let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("\(stem)-values", ofType: "txt")!)!

        let parsed_project_data = parse_project_file(data: data)
        sample_names = parsed_project_data.sample_names!
        molecule_names = parsed_project_data.molecule_names!
        values = parsed_project_data.values!

        if let file_content = NSBundle.mainBundle().pathForResource("\(stem)-annotations", ofType: "txt"), let data = NSData(contentsOfFile: file_content) {
                let parsed_annotation_data = parse_annotation_file(data: data, molecule_names: molecule_names, current_annotation_names: [])
                molecule_annotation_names = parsed_annotation_data.annotation_names
                molecule_annotation_values_array = parsed_annotation_data.annotation_values
        }

        if let file_content = NSBundle.mainBundle().pathForResource("\(stem)-factors", ofType: "txt"), let data = NSData(contentsOfFile: file_content) {
                let parsed_factor_data = parse_factor_file(data: data, current_sample_names: sample_names, current_factor_names: [])
                factor_names = parsed_factor_data.factor_names
                level_names_of_samples_array = parsed_factor_data.sample_levels
        }

        return insert_project(database: database, project_name: project_name, data_set_name: "Original data set", values: values, sample_names: sample_names, molecule_names: molecule_names, factor_names: factor_names, level_names_of_samples_array: level_names_of_samples_array, molecule_annotation_names: molecule_annotation_names, molecule_annotation_values_array: molecule_annotation_values_array, project_note_texts: [], project_note_types: [], project_note_user_names: [])
}

func database_populate(database database: Database) {

        set_user_name(database: database, user_name: "Morten Krogh")
        set_email(database: database, email: "m@amberbio.com")

        let iris_project_id = import_data(database: database, stem: "iris", project_name: "Iris flowers")
        let iris_project_note_text = "The iris data set is a classic data set that is often used in machine learning. Four features were measured for 150 iris flowers. The 150 flowers belonged to three species, Iris setosa, Iris virginica and Iris versicolor, with 50 flowers from each species. The four measured features were the length and the width of the sepals and petals in centimetres. The data set is availabel at http://archive.ics.uci.edu/ml/datasets/Iris"
        insert_project_note(database: database, project_note_text: iris_project_note_text, project_note_type: "auto", project_note_user_name: "Demo", project_id: iris_project_id)

        let brain_stem_cells_project_id = import_data(database: database, stem: "brain-stem-cells", project_name: "Brain stem cells")
        let brain_stem_cell_project_note_text = "The brain stem cells project is published" 




        //        import_data(database: database, stem: "brca", project_name: "brca srm")
//        import_data(database: database, stem: "sox", project_name: "sox cell lines")
//        import_data(database: database, stem: "ovarian", project_name: "Ovarian cancer")
//        import_data(database: database, stem: "mouse_brain", project_name: "mouse brain")
//        import_data(database: database, stem: "paired", project_name: "paired")
//        import_data(database: database, stem: "xintela", project_name: "xintela", include_factors: false)
//        import_data(database: database, stem: "xintela_special", project_name: "xintela_special", include_factors: false, include_annotations: false)

//        import_data(database: database, stem: "nci60", project_name: "NCI60 cell lines")
        import_data(database: database, stem: "breast-cancer", project_name: "Breast cancer")

}
