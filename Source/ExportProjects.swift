import UIKit
import MessageUI

class ExportProjectsState: PageState {

        override init() {
                super.init()
                name = "export_projects"
                title = astring_body(string: "Export Projects")
                info = "Select any number of projects for export to a file.\n\nSend the file by email or export it to a cloud storage.\n\nThe exported file can be imported into any device running this app.\n\n"
        }
}

class ExportProjects: Component, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {

        let email_button = UIButton(type: UIButtonType.System)
        let export_button = UIButton(type: UIButtonType.System)

        let select_all_button = UIButton(type: .System)
        let deselect_all_button = UIButton(type: .System)

        let table_view = UITableView()

        var (project_ids, project_names, project_dates) = ([], [], []) as ([Int], [String], [String])

        var selected_rows = [] as Set<Int>

        override func viewDidLoad() {
                super.viewDidLoad()

                email_button.setAttributedTitle(astring_body(string: "Email"), forState: .Normal)
                email_button.setAttributedTitle(astring_font_size_color(string: "Email", color: color_disabled), forState: .Disabled)
                email_button.addTarget(self, action: "email_action", forControlEvents: UIControlEvents.TouchUpInside)
                view.addSubview(email_button)

                export_button.setAttributedTitle(astring_body(string: "Export"), forState: .Normal)
                export_button.setAttributedTitle(astring_font_size_color(string: "Export", color: color_disabled), forState: .Disabled)
                export_button.addTarget(self, action: "export_action", forControlEvents: UIControlEvents.TouchUpInside)
                view.addSubview(export_button)

                select_all_button.setAttributedTitle(astring_body(string: "Select all"), forState: .Normal)
                select_all_button.addTarget(self, action: "select_all_action", forControlEvents: .TouchUpInside)
                view.addSubview(select_all_button)

                deselect_all_button.setAttributedTitle(astring_body(string: "Deselect all"), forState: .Normal)
                deselect_all_button.addTarget(self, action: "deselect_all_action", forControlEvents: .TouchUpInside)
                view.addSubview(deselect_all_button)
                
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                view.addSubview(table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height
                let side_margin = 20 as CGFloat

                var origin_y = 15 as CGFloat

                email_button.sizeToFit()
                email_button.frame = CGRect(x: 0, y: origin_y, width: width, height: email_button.frame.height)
                origin_y += email_button.frame.height + 15

                export_button.sizeToFit()
                export_button.frame = CGRect(x: 0, y: origin_y, width: width, height: export_button.frame.height)
                origin_y += export_button.frame.height + 15

                select_all_button.sizeToFit()
                deselect_all_button.sizeToFit()
                select_all_button.frame.origin = CGPoint(x: width - side_margin - select_all_button.frame.width, y: origin_y)
                deselect_all_button.frame.origin = CGPoint(x: side_margin, y: origin_y)
                origin_y += select_all_button.frame.height + 15

                table_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height - origin_y)
        }

        override func render() {
                (project_ids, project_names, project_dates) = state.get_projects()
                selected_rows = Set<Int>(0 ..< project_ids.count)
                render_after_change()
        }

        func render_after_change() {
                email_button.enabled = !selected_rows.isEmpty
                export_button.enabled = !selected_rows.isEmpty
                table_view.reloadData()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return project_ids.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let text = project_names[indexPath.row]
                if selected_rows.contains(indexPath.row) {
                        cell.update_selected_checkmark(text: text)
                } else {
                        cell.update_unselected(text: text)
                }

                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                if selected_rows.contains(indexPath.row) {
                        selected_rows.remove(indexPath.row)
                } else {
                        selected_rows.insert(indexPath.row)
                }
                render_after_change()
        }

        func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
                controller.dismissViewControllerAnimated(true, completion: nil)
        }

        func email_action() {
                let file_name = create_file_name()
                let file_data = create_export_database()
                send_email(file_name: file_name, file_data: file_data, emails: state.get_emails(), view_controller: self, mail_compose_delegate: self)
        }

        func export_action() {
                let file_name = create_file_name()
                let file_data = create_export_database()
                documentPickerExport.exportResultFile(fileName: file_name, fileData: file_data, fromViewController: self, sourceView: self.view)
        }

        func select_all_action() {
                for i in 0 ..< project_ids.count {
                        selected_rows.insert(i)
                }
                render_after_change()
        }

        func deselect_all_action() {
                selected_rows.removeAll()
                render_after_change()
        }

        func create_file_name() -> String {
                return file_name_for_result_file(name: "amberbio-projects", ext: "sqlite")
        }

        func create_export_database() -> NSData {
                let selected_project_ids = [Int](selected_rows).map { project_ids[$0] }

                let export_database_path = file_create_temp_path()
                let export_database = sqlite_open(database_path: export_database_path)!

                sqlite_begin(database: state.database)
                sqlite_begin(database: export_database)

                sqlite_exported_tables(database: export_database)

                let (version, _) = sqlite_get_info(database: state.database)
                sqlite_set_info(database: export_database, version: version, type: database_export_info_type)

                for project_id in selected_project_ids {
                        sqlite_export_project(source_database: state.database, destination_database: export_database, project_id: project_id)

                }

                sqlite_end(database: export_database)
                sqlite_end(database: state.database)
                sqlite_close(database: export_database)

                let file_manager = NSFileManager.defaultManager()
                if let content = file_manager.contentsAtPath(export_database_path) {
                        do {
                                try file_manager.removeItemAtPath(export_database_path)
                        } catch _ {}
                        return content
                } else {
                        return NSData()
                }
        }
}
