import UIKit

class EditProjectState: PageState {

        override init() {
                super.init()
                name = "edit_project"
                title = astring_body(string: "Edit the project")
                info = "Edit the name of the project or a data set by tapping the name.\n\nDelete the project or a data set by swiping left.\n\nThe original data set cannot be deleted."
        }
}

class EditProject: Component, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

        let table_view = UITableView()

        var data_set_ids = [] as [Int]
        var data_set_names = [] as [String]

        var reload = true

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                table_view.addGestureRecognizer(tap_recognizer)
        }

        override func render() {
                (data_set_ids, data_set_names, _) = state.get_data_sets(project_id: state.project_id)

                if reload {
                        table_view.reloadData()
                }
                reload = true
        }

        override func finish() {
                table_view.setEditing(false, animated: false)
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 2
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return 70
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text = section == 0 ? "Edit the project" : "Edit the data sets"
                header.update_normal(text: text)

                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return section == 0 ? 1 : data_set_ids.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return text_field_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TextFieldTableViewCell

                if indexPath.section == 0 {
                        cell.update(text: state.project_name, tag: 0, delegate: self)
                } else {
                        let id = data_set_ids[indexPath.row]
                        let name = data_set_names[indexPath.row]
                        cell.update(text: name, tag: id, delegate: self)
                }

                return cell
        }

        func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
                return indexPath.section == 0 || state.original_data_set_id != data_set_ids[indexPath.row]
        }

        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                if editingStyle == .Delete {
                        if indexPath.section == 0 {
                                delete_project_action()
                        } else {
                                let data_set_id = data_set_ids[indexPath.row]
                                if data_set_id == state.data_set_id {
                                        state.set_active_data_set(data_set_id: state.original_data_set_id)
                                }
                                state.delete_data_set(data_set_id: data_set_id)

                                reload = false
                                state.render()

                                CATransaction.begin()
                                tableView.beginUpdates()
                                CATransaction.setCompletionBlock(state.render)
                                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                tableView.endUpdates()
                                CATransaction.commit()
                        }
                }
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }
        
        func textFieldDidEndEditing(textField: UITextField) {
                let text = textField.text ?? ""
                if textField.tag == 0 {
                        if text != "" && text != state.project_name {
                                state.update_project_name(project_id: state.project_id, project_name: text)
                        }
                } else {
                        let data_set_id = textField.tag
                        if let index = data_set_ids.indexOf(data_set_id) {
                                if text != "" && text != data_set_names[index] {
                                        state.update_data_set_name(data_set_id: data_set_id, data_set_name: text)
                                }
                        }
                }
                state.render()
        }

        func delete_project_when_confirmed() {
                state.delete_project(project_id: state.project_id)
                state.set_page_state(page_state: DataSetSelectionState())
                state.render()
        }

        func delete_project_cancel() {
                table_view.setEditing(false, animated: false)
        }

        func delete_project_action() {
                alert_confirm(title: "Delete the project", message: "The entire project and all the data sets in the project will be deleted", view_controller: self, ok_callback: delete_project_when_confirmed, cancel_callback: delete_project_cancel)
        }

        func tap_action() {
                table_view.setEditing(false, animated: false)

                if let cell = table_view.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? TextFieldTableViewCell {
                        cell.text_field.resignFirstResponder()
                }

                for i in 0 ..< data_set_ids.count {
                        if let cell = table_view.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 1)) as? TextFieldTableViewCell {
                                cell.text_field.resignFirstResponder()
                        }
                }
        }
}
