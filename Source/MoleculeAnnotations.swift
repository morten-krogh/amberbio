import UIKit

class MoleculeAnnotationsState: PageState {

        override init() {
                super.init()
                name = "molecule_annotations"
                title = astring_body(string: "Molecule Annotations")
                info = "Tap a molecule annotation name to edit the name.\n\nSwipe a molecule annotation name to delete it.\n\nThe annotation values for the individual molecules can not be edited. They must be imported."
        }
}

class MoleculeAnnotations: Component, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

        let table_view = UITableView()
        var reload = true

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.dataSource = self
                table_view.delegate = self
                table_view.separatorStyle = UITableViewCellSeparatorStyle.None
                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "cell")

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func render() {
                if reload {
                        table_view.reloadData()
                }
                reload = true
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView
                let text = "Edit the molecule annotations"
                header.update_normal(text: text)
                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return state.molecule_annotation_names.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return text_field_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TextFieldTableViewCell

                cell.update(text: state.molecule_annotation_names[indexPath.row], tag: indexPath.row, delegate: self)

                return cell
        }

        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                if editingStyle == .Delete {
                        let molecule_annotation_name = state.molecule_annotation_names[indexPath.row]
                        state.delete_molecule_annotation(molecule_annotation_name: molecule_annotation_name)

                        reload = false
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        state.render()
                }
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textFieldDidEndEditing(textField: UITextField) {
                let row = textField.tag
                let suggested_molecule_annotation_name = trim(string: textField.text ?? "")

                let (valid, error_title, error_message) = update_molecule_annotation_name_at_row(row: row, suggested_molecule_annotation_name: suggested_molecule_annotation_name)

                if valid {
                        state.render()
                } else {
                        textField.text = state.molecule_annotation_names[row]
                        alert(title: error_title!, message: error_message!, view_controller: self)
                }
        }

        func update_molecule_annotation_name_at_row(row row: Int, suggested_molecule_annotation_name: String) -> (valid: Bool, error_title: String?, error_message: String?) {
                if suggested_molecule_annotation_name == "" {
                        return (false, "Empty molecula annotation name", "Molecule annotation names can not be empty")
                }

                if suggested_molecule_annotation_name == "molecule name" || suggested_molecule_annotation_name == "Molecule name" {
                        return (false, "Reserved name", "A molecule annotation name can not be \"molecule name\"")
                }

                let current_molecule_annotation_name = state.molecule_annotation_names[row]
                if suggested_molecule_annotation_name != current_molecule_annotation_name {
                        if state.molecule_annotation_names.filter({$0 == suggested_molecule_annotation_name}).isEmpty {
                                state.update_molecule_annotation(current_molecule_annotation_name: current_molecule_annotation_name, new_molecule_annotation_name: suggested_molecule_annotation_name)
                                return (true, nil, nil)
                        } else {
                                return (false, "Duplicate molecule annotation name", "\(suggested_molecule_annotation_name) already exists")
                        }
                } else {
                        return (true, nil, nil)
                }
        }

        func tap_action() {
                for i in 0 ..< state.molecule_annotation_names.count {
                        if let cell = table_view.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? TextFieldTableViewCell {
                                cell.text_field.resignFirstResponder()
                        }
                }
        }
}
