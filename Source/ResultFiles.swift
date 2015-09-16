import UIKit
import MessageUI

class ResultFilesState: PageState {

        override init() {
                super.init()
                name = "result_files"
                title = astring_body(string: "Result Files")
                info = "The result files for the project sorted according to data set.\n\nDelete a result file by swiping.\n\nA result file can be sent by email, exported to a cloud storage, or opened in another app."
        }
}

class ResultFiles: Component, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {

        let table_view = UITableView()

        var (data_set_ids, data_set_names, file_ids, file_names, file_dates) = ([], [], [], [], []) as ([Int], [String], [[Int]], [[String]], [[String]])

        var should_reload_data = true

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(ResultFilesTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.allowsSelection = false
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = UITableViewCellSeparatorStyle.None

                table_view.dataSource = self
                table_view.delegate = self
        }

        override func render() {
                (data_set_ids, data_set_names, file_ids, file_names, file_dates) = state.get_result_files(project_id: state.project_id)

                if should_reload_data {
                        table_view.reloadData()
                }
                should_reload_data = true
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return data_set_ids.count
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return file_ids[section].count
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return 0.0
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header_view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                header_view.update_normal(text: data_set_names[section])

                return header_view
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return 100.0
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ResultFilesTableViewCell

                cell.name_label.text = file_names[indexPath.section][indexPath.row]
                cell.date_label.text = date_formatted_string(timestamp: file_dates[indexPath.section][indexPath.row])

                cell.result_file_id = file_ids[indexPath.section][indexPath.row]

                cell.email_button.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.email_button.addTarget(self, action: "email_action:", forControlEvents: .TouchUpInside)

                cell.export_button.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.export_button.addTarget(self, action: "export_action:", forControlEvents: .TouchUpInside)

                cell.open_button.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.open_button.addTarget(self, action: "open_action:", forControlEvents: .TouchUpInside)

                return cell
        }

        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                if editingStyle == .Delete {
                        let last_file_in_section = file_ids[indexPath.section].count == 1

                        let result_file_id = file_ids[indexPath.section][indexPath.row]
                        state.delete_result_file(result_file_id: result_file_id)

                        should_reload_data = false
                        state.render()

                        if last_file_in_section {
                                tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                        } else {
                                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        }
                }
        }

        func email_action(sender: UIButton) {
                let file_id = (sender.superview!.superview!.superview! as! ResultFilesTableViewCell).result_file_id
                let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id)!
                send_email(file_name: file_name, file_data: file_data, emails: state.get_emails(), view_controller: self, mail_compose_delegate: self)
        }

        func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
                controller.dismissViewControllerAnimated(true, completion: nil)
        }

        func export_action(sender: UIButton) {
                let file_id = (sender.superview!.superview!.superview! as! ResultFilesTableViewCell).result_file_id
                let (file_name, file_content) = state.select_file_name_and_file_data(file_id: file_id)!
                document_picker_export.export_result_file(file_name: file_name, file_content: file_content, from_view_controller: self, source_view: sender)
        }

        func open_action(sender: UIButton) {
                let file_id = (sender.superview!.superview!.superview! as! ResultFilesTableViewCell).result_file_id
                let (file_name, file_content) = state.select_file_name_and_file_data(file_id: file_id)!
                document_interaction_open.open_result_file(file_name: file_name, file_content: file_content, inRect: sender.frame, inView: view)
        }
}

class ResultFilesTableViewCell: UITableViewCell {

        var result_file_id = 0
        let inset_view = UIView()

        let name_label = UILabel()
        let date_label = UILabel()
        let email_button = UIButton(type: UIButtonType.System)
        let export_button = UIButton(type: UIButtonType.System)
        let open_button = UIButton(type: UIButtonType.System)

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                inset_view.backgroundColor = UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 1.0)
                inset_view.layer.cornerRadius = 20

                name_label.textAlignment = .Center
                name_label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

                date_label.textAlignment = .Center
                date_label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
                date_label.textColor = UIColor.lightGrayColor()

                contentView.addSubview(inset_view)
                inset_view.addSubview(name_label)
                inset_view.addSubview(date_label)
                inset_view.addSubview(email_button)
                inset_view.addSubview(export_button)
                inset_view.addSubview(open_button)

                email_button.setAttributedTitle(astring_body(string: "Email"), forState: .Normal)
                export_button.setAttributedTitle(astring_body(string: "Export"), forState: .Normal)
                open_button.setAttributedTitle(astring_body(string: "Open"), forState: .Normal)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                inset_view.frame = CGRectInset(contentView.bounds, 10, 5)

                let margin = 5 as CGFloat
                let side_width = 55 as CGFloat
                let label_width = inset_view.frame.width - side_width - 2.0 * margin
                let label_height = inset_view.frame.height / 2.0
                name_label.frame = CGRect(x: margin, y: 0, width: label_width, height: label_height)
                date_label.frame = CGRect(x: margin, y: label_height, width: label_width, height: label_height)

                let button_height = 30 as CGFloat
                let button_x = inset_view.frame.width - side_width
                email_button.sizeToFit()
                email_button.frame.origin = CGPoint(x: button_x, y: 0)
                export_button.sizeToFit()
                export_button.frame.origin = CGPoint(x: button_x, y: button_height)
                open_button.sizeToFit()
                open_button.frame.origin = CGPoint(x: button_x, y: 2.0 * button_height)
        }
}
