import UIKit

class ImportDataState: PageState {

        override init() {
                super.init()
                name = "import_data"
                title = astring_body(string: "Import Data")
                info = "Imported files contain measurement values, sample names, factors, and molecule names and annotations.\n\nThe \"import new file\" button is used to import files from cloud based services.\n\nFiles can be imported from the Email app by opening an attachment with the Amberbio App.\n\nDelete a file by swiping to the left.\n\nSee the manual for a description of the file formats"
        }
}

class ImportData: Component, UITableViewDataSource, UITableViewDelegate {

        let table_view = UITableView()
        let import_button = UIButton(type: UIButtonType.System)

        var file_ids = [] as [Int]
        var file_names = [] as [String]
        var date_of_imports = [] as [String]
        var sizes = [] as [Int]

        var should_reload_data = true

        var selected_index_path: NSIndexPath?

        override func viewDidLoad() {
                super.viewDidLoad()

                import_button.setAttributedTitle(astring_body(string: "Import new file"), forState: .Normal)
                import_button.addTarget(self, action: "import_button_action", forControlEvents: UIControlEvents.TouchUpInside)

                table_view.registerClass(NameDateTableViewCell.self, forCellReuseIdentifier: "file cell")
                table_view.registerClass(ImportDataTableViewCell.self, forCellReuseIdentifier: "import data cell")
                table_view.registerClass(ImportProjectsTableViewCell.self, forCellReuseIdentifier: "import projects cell")

                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None

                view.addSubview(import_button)
                view.addSubview(table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let top_margin = 20 as CGFloat
                let middle_margin = 20 as CGFloat

                import_button.sizeToFit()
                import_button.center = CGPoint(x: view.frame.width / 2.0, y: top_margin + import_button.frame.height / 2.0)

                let table_view_origin_y = top_margin + import_button.frame.height + middle_margin
                table_view.frame = CGRect(x: 0, y: table_view_origin_y, width: view.frame.width, height: view.frame.height - table_view_origin_y)
        }

        override func render() {
                (file_ids, file_names, date_of_imports, sizes) = state.get_files(type: "imported")

                if should_reload_data {
                        table_view.reloadData()
                }
                should_reload_data = true
        }

        func import_button_action() {
                documentPickerImport.importFile(fromViewController: self, sourceView: import_button, importedFileHandler: { (file_name: String, data: NSData) -> Void in
                        state.insert_file(name: file_name, type: "imported", data: data)
                        self.render()
                        self.table_view.reloadData()
                })
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return file_names.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                if selected_index_path == indexPath {
                        let file_name = file_names[indexPath.row]
                        return file_name.hasSuffix("sqlite") || !state.active_data_set ? 140 : 200
                } else {
                        return 70
                }
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let row = indexPath.row
                let file_name = file_names[row]
                let date = date_from_sqlite_timestamp(timestamp: date_of_imports[row])
                if selected_index_path == indexPath {
                        if file_name.hasSuffix("sqlite") {
                                let cell = tableView.dequeueReusableCellWithIdentifier("import projects cell") as! ImportProjectsTableViewCell
                                cell.update(import_data: self, row: row, name: file_name, date: date)
                                return cell
                        } else {
                                let cell = tableView.dequeueReusableCellWithIdentifier("import data cell") as! ImportDataTableViewCell
                                cell.update(import_data: self, only_create_project: !state.active_data_set, row: row, name: file_name, date: date)
                                return cell
                        }
                } else {
                        let cell = tableView.dequeueReusableCellWithIdentifier("file cell", forIndexPath: indexPath) as! NameDateTableViewCell
                        cell.update_selected(name: file_name, date: date_from_sqlite_timestamp(timestamp: date_of_imports[indexPath.row]))

                        return cell
                }
        }

        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                if editingStyle == .Delete {
                        state.delete_file(file_id: file_ids[indexPath.row])
                        should_reload_data = false
                        state.render()
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                if selected_index_path == indexPath {
                        selected_index_path = nil
                } else {
                        selected_index_path = indexPath
                }
                table_view.reloadData()
        }

        func import_projects(row row: Int) {
                let file_id = file_ids[row]
                let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id)!
                let database_path = file_create_temp_path(content: file_data)
                let import_database = sqlite_open(database_path: database_path)!
                if let (_, type) = sqlite_info(database: import_database) where type == "exported database" {
                        sqlite_begin(database: state.database)
                        sqlite_begin(database: import_database)
                        let (new_projects, existing_projects) = sqlite_import_database(source_database: import_database, destination_database: state.database)
                        sqlite_end(database: state.database)
                        sqlite_end(database: import_database)
                        let message = "\(new_projects) new projects have been imported and \(existing_projects) have been updated (if necessary)"
                        alert(title: "The imported projects have been processed", message: message, view_controller: self)
                        let page_state = DataSetSelectionState()
                        state.navigate(page_state: page_state)
                        state.render()
                } else {
                        let message = "The file must be exported from this app on some device and imported here without changes"
                        alert(title: "\(file_name) is invalid", message: message, view_controller: self)
                }
        }

        func create_project(row row: Int) {
                let file_id = file_ids[row]
                if let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id) {
                        let (sample_names, molecule_names, values, error) = parse_project_file(data: file_data)
                        if let error = error {
                                alert(title: "\(file_name) is invalid", message: error, view_controller: self)
                        } else {
                                alert_text_field(title: "Project title", message: "Choose a title for the new project", view_controller: self, placeholder: file_name.componentsSeparatedByString(".")[0], callback: { (project_name: String) in
                                        let corrected_project_name = project_name == "" ? "Project?" : project_name
                                        let project_id = state.insert_project(project_name: corrected_project_name, data_set_name: "Original data set", values: values!, sample_names: sample_names!, molecule_names: molecule_names!)

                                        let data_set_id = state.get_original_data_set_id(project_id: project_id)
                                        state.set_active_data_set(data_set_id: data_set_id)
                                        let data_set_selection_state = DataSetSelectionState()
                                        state.navigate(page_state: data_set_selection_state)
                                        state.render()
                                })
                        }
                }
        }

        func import_factors(row row: Int) {
                let file_id = file_ids[row]
                if let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id) {
                        let (_, current_sample_names) = state.get_samples(data_set_id: state.original_data_set_id)
                        let (factor_names, sample_levels, error) = parse_factor_file(data: file_data, current_sample_names: current_sample_names, current_factor_names: state.factor_names)
                        if let error = error {
                                alert(title: "\(file_name) is invalid", message: error, view_controller: self)
                        } else {
                                for i in 0 ..< factor_names.count {
                                        state.insert_factor(project_id: state.project_id, factor_name: factor_names[i], level_names_of_samples: sample_levels[i])
                                }

                                let message: String
                                if factor_names.isEmpty {
                                        message = "There were no new factors"
                                } else {
                                        message = (factor_names.count == 1 ? "One factor has" : "\(factor_names.count) factors have") + " been added to the active project"
                                }
                                alert(title: "The file is valid", message: message, view_controller: self)
                                self.selected_index_path = nil
                                self.table_view.reloadData()
                        }
                }
        }

        func import_annotations(row row: Int) {
                let file_id = file_ids[row]
                if let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id) {
                        let molecule_names = state.get_molecule_names(project_id: state.project_id)
                        let (annotation_names, annotation_values, error) = parse_annotation_file(data: file_data, molecule_names: molecule_names, current_annotation_names: state.molecule_annotation_names)

                        if let error = error {
                                alert(title: "\(file_name) is invalid", message: error, view_controller: self)
                        } else {
                                state.insert_molecule_annotations(project_id: state.project_id, molecule_annotation_names: annotation_names, molecule_annotation_values: annotation_values)

                                let message: String
                                if annotation_names.isEmpty {
                                        message = "There were no new annotations"
                                } else {
                                        message = (annotation_names.count == 1 ? "One molecule annotation has" : "\(annotation_names.count) molecule annotations have") + " been added to the active project"
                                }
                                alert(title: "The file is valid", message: message, view_controller: self)
                                self.selected_index_path = nil
                                self.table_view.reloadData()
                        }
                }
        }
}

class ImportDataTableViewCell: UITableViewCell {

        var import_data: ImportData!
        var row: Int!

        let inset_view = UIView()

        let name_label = UILabel()
        let date_label = UILabel()

        let create_project_button = UIButton(type: .System)
        let factors_button = UIButton(type: .System)
        let annotations_button = UIButton(type: .System)

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.backgroundColor = UIColor.whiteColor()

                inset_view.layer.cornerRadius = 20
                inset_view.backgroundColor = UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 1.0)

                name_label.textAlignment = .Center
                name_label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

                date_label.textAlignment = .Center
                date_label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
                date_label.textColor = UIColor.lightGrayColor()

                create_project_button.setAttributedTitle(astring_body(string: "Create new project"), forState: .Normal)
                create_project_button.addTarget(self, action: "create_project_action", forControlEvents: .TouchUpInside)

                factors_button.setAttributedTitle(astring_body(string: "Import sample factors"), forState: .Normal)
                factors_button.addTarget(self, action: "factors_action", forControlEvents: .TouchUpInside)

                annotations_button.setAttributedTitle(astring_body(string: "Import molecule annotations"), forState: .Normal)
                annotations_button.addTarget(self, action: "annotations_action", forControlEvents: .TouchUpInside)

                contentView.addSubview(inset_view)
                inset_view.addSubview(name_label)
                inset_view.addSubview(date_label)
                inset_view.addSubview(create_project_button)
                inset_view.addSubview(factors_button)
                inset_view.addSubview(annotations_button)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                let top_margin = 5 as CGFloat
                let middle_margin = 20 as CGFloat

                inset_view.frame = CGRectInset(contentView.bounds, 10, 5)
                name_label.sizeToFit()
                date_label.sizeToFit()

                name_label.center = CGPoint(x: inset_view.frame.width / 2.0, y: top_margin + name_label.frame.height / 2.0)
                date_label.center = CGPoint(x: inset_view.frame.width / 2.0, y: top_margin + name_label.frame.height / 2.0 + middle_margin + date_label.frame.height / 2.0)

                create_project_button.sizeToFit()
                create_project_button.center = CGPoint(x: inset_view.frame.width / 2.0, y: CGRectGetMaxY(date_label.frame) + 2 * middle_margin)

                factors_button.sizeToFit()
                factors_button.center = CGPoint(x: inset_view.frame.width / 2.0, y: CGRectGetMaxY(create_project_button.frame) + middle_margin)

                annotations_button.sizeToFit()
                annotations_button.center = CGPoint(x: inset_view.frame.width / 2.0, y: CGRectGetMaxY(factors_button.frame) + middle_margin)
        }

        func update(import_data import_data: ImportData, only_create_project: Bool, row: Int, name: String, date: NSDate) {
                self.import_data = import_data
                self.row = row
                name_label.text = name
                date_label.text = date_formatted_string(date: date)
                factors_button.hidden = only_create_project
                annotations_button.hidden = only_create_project
        }

        func create_project_action() {
                import_data.create_project(row: row)
        }

        func factors_action() {
                import_data.import_factors(row: row)
        }

        func annotations_action() {
                import_data.import_annotations(row: row)
        }
}

class ImportProjectsTableViewCell: UITableViewCell {

        var import_data: ImportData!
        var row: Int!

        let inset_view = UIView()

        let name_label = UILabel()
        let date_label = UILabel()

        let import_projects_button = UIButton(type: .System)

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.backgroundColor = UIColor.whiteColor()

                inset_view.layer.cornerRadius = 20
                inset_view.backgroundColor = UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 1.0)

                name_label.textAlignment = .Center
                name_label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

                date_label.textAlignment = .Center
                date_label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
                date_label.textColor = UIColor.lightGrayColor()

                import_projects_button.setAttributedTitle(astring_body(string: "Import projects"), forState: .Normal)
                import_projects_button.addTarget(self, action: "import_projects_action", forControlEvents: .TouchUpInside)

                contentView.addSubview(inset_view)
                inset_view.addSubview(name_label)
                inset_view.addSubview(date_label)
                inset_view.addSubview(import_projects_button)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                let top_margin = 5 as CGFloat
                let middle_margin = 20 as CGFloat

                inset_view.frame = CGRectInset(contentView.bounds, 10, 5)
                name_label.sizeToFit()
                date_label.sizeToFit()

                name_label.center = CGPoint(x: inset_view.frame.width / 2.0, y: top_margin + name_label.frame.height / 2.0)
                date_label.center = CGPoint(x: inset_view.frame.width / 2.0, y: top_margin + name_label.frame.height / 2.0 + middle_margin + date_label.frame.height / 2.0)

                import_projects_button.sizeToFit()
                import_projects_button.center = CGPoint(x: inset_view.frame.width / 2.0, y: CGRectGetMaxY(date_label.frame) + 2 * middle_margin)
        }

        func update(import_data import_data: ImportData, row: Int, name: String, date: NSDate) {
                self.import_data = import_data
                self.row = row
                name_label.text = name
                date_label.text = date_formatted_string(date: date)
        }

        func import_projects_action() {
                import_data.import_projects(row: row)
        }
}

func parse_project_file(data data: NSData) -> (sample_names: [String]?, molecule_names: [String]?, values: [Double]?, error: String?) {
        let (table, error) = parse_data(data: data)

        if let table = table {
                var sample_names = table[0]
                sample_names.removeAtIndex(0)
                if let duplicate_element = find_duplicate_element(array: sample_names) {
                        let error = "\(duplicate_element) is a duplicated sample name"
                        return (nil, nil, nil, error)
                }

                var molecule_names = [] as [String]
                var values = [] as [Double]

                for var i = 1; i < table.count; ++i {
                        let row = table[i]
                        molecule_names.append(row[0])
                        for var j = 1; j < row.count; ++j {
                                if let value = string_to_double(string: row[j]) {
                                        values.append(value)
                                } else if is_missing_value(string: row[j]) {
                                        values.append(Double.NaN)
                                } else {
                                        let error = "\(row[j]) is not a valid measurement value"
                                        return (nil, nil, nil, error)
                                }
                        }
                }

                if let duplicate_element = find_duplicate_element(array: molecule_names) {
                        let error = "\(duplicate_element) is a duplicated molecule name"
                        return (nil, nil, nil, error)
                }

                return (sample_names, molecule_names, values, nil)
        } else {
                return (nil, nil, nil, error)
        }
}

func parse_factor_file(data data: NSData, current_sample_names: [String], current_factor_names: [String]) -> (factor_names: [String], sample_levels: [[String]], error: String?) {
        let (table, error) = parse_data(data: data)

        if let table = table {
                if table.isEmpty {
                        let error = "There are no rows in the file"
                        return ([], [], error)
                }

                if table.count == 1 {
                        let error = "There is only one row in the file"
                        return ([], [], error)
                }

                if table.count > 100 {
                        let error = "There are too many rows in the file"
                        return ([], [], error)
                }

                var sample_name_columns = [:] as [String: Int]
                for i in 1 ..< table[0].count {
                        sample_name_columns[table[0][i]] = i
                }

                for current_sample_name in current_sample_names {
                        if sample_name_columns[current_sample_name] == nil {
                                let error = "The sample \(current_sample_name) is absent in the file"
                                return ([], [], error)
                        }
                }

                var factor_names = [] as [String]
                var sample_levels = [] as [[String]]

                for var i = 1; i < table.count; ++i {
                        let factor_name = table[i][0]

                        if factor_name.isEmpty {
                                let error = "There is an empty factor name"
                                return ([], [], error)
                        }

                        if current_factor_names.indexOf(factor_name) != nil || factor_names.indexOf(factor_name) != nil {
                                continue
                        }

                        factor_names.append(factor_name)

                        var values: [String] = []
                        for current_sample_name in current_sample_names {
                                let column = sample_name_columns[current_sample_name]!
                                var value = table[i][column]
                                value = value.isEmpty ? "(empty value)" : value

                                values.append(value)
                        }
                        sample_levels.append(values)
                }

                return (factor_names, sample_levels, nil)
        } else {
                return ([], [], error)
        }
}

func parse_annotation_file(data data: NSData, molecule_names: [String], current_annotation_names: [String]) -> (annotation_names: [String], annotation_values: [[String]], error: String?) {
        let (table, error) = parse_data(data: data)

        if let table = table {
                if table.isEmpty {
                        let error = "The table is empty"
                        return ([], [], error)
                }

                if table[0].count == 1 {
                        let error = "There is only one column in the file"
                        return ([], [], error)
                }

                var molecule_name_rows = [:] as [String: Int]
                for i in 1 ..< table.count {
                        molecule_name_rows[table[i][0]] = i
                }

                for molecule_name in molecule_names {
                        if molecule_name_rows[molecule_name] == nil {
                                let error = "The molecule name \(molecule_name) is absent"
                                return ([], [], error)
                        }
                }

                var annotation_names = [] as [String]
                var annotation_values = [] as [[String]]

                for var i = 1; i < table[0].count; ++i {
                        let annotation_name = table[0][i]

                        if annotation_name.isEmpty {
                                let error = "There is an empty annotation name in the first row"
                                return ([], [], error)
                        }

                        if current_annotation_names.indexOf(annotation_name) != nil || annotation_names.indexOf(annotation_name) != nil {
                                continue
                        }

                        var values = [] as [String]
                        for molecule_name in molecule_names {
                                let row = molecule_name_rows[molecule_name]!
                                let value = table[row][i]
                                values.append(value)
                        }

                        annotation_names.append(annotation_name)
                        annotation_values.append(values)
                }
                return (annotation_names, annotation_values, nil)
        } else {
                return ([], [], error)
        }
}

func parse_data(data data: NSData) -> (table: [[String]]?, error: String?) {
        if let string = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                if let separator = parse_find_separator(string: string) {
                        let table = parse_separator_separated_string(string: string, separator: separator)
                        return extract_rectangular_table(table: table)
                } else {
                        return (nil, "no separator")
                }
        } else {
                return (nil, "The file can not be read")
        }
}

func parse_find_separator(string string: String) -> Character? {
        var current_index = string.startIndex
        var comma_found = false
        while current_index < string.endIndex {
                switch string[current_index] {
                case "\t":
                        return "\t"
                case ",":
                        comma_found = true
                        current_index = advance(current_index, 1)
                default:
                        current_index = advance(current_index, 1)
                }
        }
        return comma_found ? "," : nil
}

func parse_separator_separated_string(string string: String, separator: Character) -> [[String]] {
        var result = [] as [[String]]

        var current_row = [] as [String]
        var previous_index = string.startIndex
        var current_index = string.startIndex
        var charIsCarriageReturn = false
        while current_index < string.endIndex {
                switch string[current_index] {
                case separator:
                        let cell = trim(string: string.substringWithRange(previous_index ..< current_index))
                        current_row.append(cell)
                        current_index = advance(current_index, 1)
                        previous_index = current_index
                        charIsCarriageReturn = false
                case "\r":
                        let cell = trim(string: string.substringWithRange(previous_index ..< current_index))
                        current_row.append(cell)
                        current_index = advance(current_index, 1)
                        previous_index = current_index
                        charIsCarriageReturn = true
                case "\n":
                        if !charIsCarriageReturn {
                                let cell = trim(string: string.substringWithRange(previous_index ..< current_index))
                                current_row.append(cell)
                        }
                        result.append(current_row)
                        current_row = []
                        current_index = advance(current_index, 1)
                        previous_index = current_index
                        charIsCarriageReturn = false
                default:
                        current_index = advance(current_index, 1)
                }
        }

        if current_index > previous_index {
                let cell = trim(string: string.substringWithRange(previous_index ..< current_index))
                current_row.append(cell)
        }

        if !current_row.isEmpty {
                result.append(current_row)
        }

        return result
}

func extract_rectangular_table(table table: [[String]]) -> (table: [[String]]?, error: String?) {
        var result = [] as [[String]]

        func is_row_empty (row row: [String]) -> Bool {
                for str in row {
                        if str != "" {
                                return false
                        }
                }
                return true
        }

        for row in table {
                if is_row_empty(row: row) {
                        if !result.isEmpty {
                                return (result, nil)
                        }
                } else {
                        if let last_row = result.last {
                                if row.count != last_row.count {
                                        return (nil, "The rows do not all have the same number of columns")
                                }
                        }
                        result.append(row)
                }
        }
        
        return (result, nil)
}

func find_duplicate_element<T: Hashable>(array array: [T]) -> T? {
        var set = [] as Set<T>
        
        for element in array {
                if set.contains(element) {
                        return element
                } else {
                        set.insert(element)
                }
        }
        return nil
}
