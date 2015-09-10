import UIKit

class SamplesNamesState: PageState {

        override init() {
                super.init()
                name = "sample_names"
                title = astring_body(string: "Sample Names")
                info = "Tap a sample name to edit it.\n\nAll sample names for the active project are listed, not just those for the active data set.\n\nSample names must be unique and non-empty."
        }
}

class SampleNames: Component, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = UITableViewCellSeparatorStyle.None
                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "cell")

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func render() { }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView
                let text = "Edit the sample names"
                header.update_normal(text: text)
                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return state.number_of_samples
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return text_field_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TextFieldTableViewCell

                cell.update(text: state.sample_names[indexPath.row], tag: indexPath.row, delegate: self)

                return cell
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textFieldDidEndEditing(textField: UITextField) {
                let row = textField.tag
                let suggested_sample_name = trim(string: textField.text ?? "")

                let (valid, error_title, error_message) = update_sample_name_at_row(row: row, suggested_sample_name: suggested_sample_name)

                if valid {
                        textField.text = suggested_sample_name
                } else {
                        textField.text = state.sample_names[row]
                        alert(title: error_title!, message: error_message!, view_controller: self)
                }
        }

        func update_sample_name_at_row(row row: Int, suggested_sample_name: String) -> (valid: Bool, error_title: String?, error_message: String?) {
                if suggested_sample_name == "" {
                        return (false, "Empty sample name", "Sample names can not be empty")
                }

                let current_sample_name = state.sample_names[row]
                if suggested_sample_name != current_sample_name {
                        if state.sample_names.filter({$0 == suggested_sample_name}).isEmpty {
                                state.update_sample_name(sample_index: row, sample_name: suggested_sample_name)
                                return (true, nil, nil)
                        } else {
                                return (false, "Duplicate sample name", "\(suggested_sample_name) already exists")
                        }
                } else {
                        return (true, nil, nil)
                }
        }

        func tap_action() {
                for i in 0 ..< state.number_of_samples {
                        if let cell = table_view.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? TextFieldTableViewCell {
                                cell.text_field.resignFirstResponder()
                        }
                }
        }
}
