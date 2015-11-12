import UIKit

class ImportDataState: PageState {

        override init() {
                super.init()
                name = "import_data"
                title = astring_body(string: "Import Data")
                info = "Downloaded files contain measurement values, sample names, factors, molecule names and molecule annotations.\n\nThe \"Download file\" button is used to download files from cloud based services.\n\nFiles can be downloaded from the Email app by opening an attachment with the Amberbio App.\n\nDelete a file by swiping to the left.\n\nSee the manual for a description of the file formats."
        }
}

class ImportData: Component, UITableViewDataSource, UITableViewDelegate {

        let info_label = UILabel()
        let table_view = UITableView()
        let download_button = UIButton(type: UIButtonType.System)

        var file_ids = [] as [Int]
        var file_names = [] as [String]
        var date_of_imports = [] as [String]
        var sizes = [] as [Int]

        var should_reload_data = true

        override func viewDidLoad() {
                super.viewDidLoad()

                info_label.text = "Importing data is a two step process. The first step is to download a file from cloud storage or open a file from another app such as Mail. The second step is to import the file. Read the manual for details."
                info_label.font = font_body
                info_label.textAlignment = .Center
                info_label.numberOfLines = 0

                download_button.setAttributedTitle(astring_font_size_color(string: "Download file", font: nil, font_size: 20, color: nil), forState: .Normal)
                download_button.addTarget(self, action: "download_action", forControlEvents: UIControlEvents.TouchUpInside)

                table_view.registerClass(ImportTableViewCell.self, forCellReuseIdentifier: "import table view cell")

                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None

                view.addSubview(info_label)
                view.addSubview(download_button)
                view.addSubview(table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let (width, height) = (view.frame.width, view.frame.height)

                var origin_y = 20 as CGFloat

                let info_label_size = info_label.sizeThatFits(CGSize(width: width - 40, height: 0))
                info_label.frame = CGRect(x: 20, y: origin_y, width: width - 40, height: info_label_size.height)

                origin_y = CGRectGetMaxY(info_label.frame) + 20

                download_button.sizeToFit()
                download_button.center = CGPoint(x: width / 2.0, y: origin_y + download_button.frame.height / 2.0)

                origin_y = CGRectGetMaxY(download_button.frame) + 20
                table_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height - origin_y)
        }

        override func render() {
                (file_ids, file_names, date_of_imports, sizes) = state.get_files(type: "imported")

                if should_reload_data {
                        table_view.reloadData()
                }
                should_reload_data = true
        }

        func download_action() {
                document_picker_import.import_file(from_view_controller: self, source_view: download_button, imported_file_handler: { (file_name: String, data: NSData) -> Void in
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
                return import_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let row = indexPath.row
                let file_name = file_names[row]
                let date = date_from_sqlite_timestamp(timestamp: date_of_imports[row])
                let cell = tableView.dequeueReusableCellWithIdentifier("import table view cell") as! ImportTableViewCell
                cell.update(name: file_name, date: date, import_action: {
                        if file_name.hasSuffix("sqlite") {
                                self.import_projects(row: row)
                        } else {
                                let page_state = ImportTableState(file_id: self.file_ids[row])
                                state.navigate(page_state: page_state)
                                state.render()
                        }
                })
                return cell
        }

        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                if editingStyle == .Delete {
                        state.delete_file(file_id: file_ids[indexPath.row])
                        should_reload_data = false
                        state.render()
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
        }

        func import_projects(row row: Int) {
                let file_id = file_ids[row]
                let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id)!
                let database_path = file_create_temp_file_url(content: file_data).path!
                let import_database = sqlite_open(database_path: database_path)!
                if let (_, type) = sqlite_get_info(database: import_database) where type == database_export_info_type {
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
                sqlite_close(database: import_database)
                file_remove(path: database_path)
        }

//        func create_project(row row: Int) {
//                let file_id = file_ids[row]
//                if let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id) {
//                        let (sample_names, molecule_names, values, error) = parse_project_file(data: file_data)
//                        if let error = error {
//                                alert(title: "\(file_name) is invalid", message: error, view_controller: self)
//                        } else {
//                                alert_text_field(title: "Project title", message: "Choose a title for the new project", view_controller: self, placeholder: file_name.componentsSeparatedByString(".")[0], callback: { (project_name: String) in
//                                        let corrected_project_name = project_name == "" ? "Project?" : project_name
//                                        let project_id = state.insert_project(project_name: corrected_project_name, data_set_name: "Original data set", values: values!, sample_names: sample_names!, molecule_names: molecule_names!)
//
//                                        let data_set_id = state.get_original_data_set_id(project_id: project_id)
//                                        state.set_active_data_set(data_set_id: data_set_id)
//                                        let data_set_selection_state = DataSetSelectionState()
//                                        state.navigate(page_state: data_set_selection_state)
//                                        state.render()
//                                })
//                        }
//                }
//        }

//        func import_factors(row row: Int) {
//                let file_id = file_ids[row]
//                if let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id) {
//                        let (_, current_sample_names) = state.get_samples(data_set_id: state.original_data_set_id)
//                        let (factor_names, sample_levels, error) = parse_factor_file(data: file_data, current_sample_names: current_sample_names, current_factor_names: state.factor_names)
//                        if let error = error {
//                                alert(title: "\(file_name) is invalid", message: error, view_controller: self)
//                        } else {
//                                for i in 0 ..< factor_names.count {
//                                        state.insert_factor(project_id: state.project_id, factor_name: factor_names[i], level_names_of_samples: sample_levels[i])
//                                }
//
//                                let message: String
//                                if factor_names.isEmpty {
//                                        message = "There were no new factors"
//                                } else {
//                                        message = (factor_names.count == 1 ? "One factor has" : "\(factor_names.count) factors have") + " been added to the active project"
//                                }
//                                alert(title: "The file is valid", message: message, view_controller: self)
//                                self.table_view.reloadData()
//                        }
//                }
//        }

//        func import_annotations(row row: Int) {
//                let file_id = file_ids[row]
//                if let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id) {
//                        let molecule_names = state.get_molecule_names(project_id: state.project_id)
//                        let (annotation_names, annotation_values, error) = parse_annotation_file(data: file_data, molecule_names: molecule_names, current_annotation_names: state.molecule_annotation_names)
//
//                        if let error = error {
//                                alert(title: "\(file_name) is invalid", message: error, view_controller: self)
//                        } else {
//                                state.insert_molecule_annotations(project_id: state.project_id, molecule_annotation_names: annotation_names, molecule_annotation_values: annotation_values)
//
//                                let message: String
//                                if annotation_names.isEmpty {
//                                        message = "There were no new annotations"
//                                } else {
//                                        message = (annotation_names.count == 1 ? "One molecule annotation has" : "\(annotation_names.count) molecule annotations have") + " been added to the active project"
//                                }
//                                alert(title: "The file is valid", message: message, view_controller: self)
//                                self.table_view.reloadData()
//                        }
//                }
//        }
}
