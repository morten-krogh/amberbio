import UIKit

class KMeansClusteringSelectionState: PageState {

        let k_means = KMeans()

        override init() {
                super.init()
                name = "k_means_clustering_selection"
                title = astring_body(string: "k means clustering")
                info = "Select the number of clusters k.\n\nSelect a factor for coloring the samples."
        }
}

class KMeansClusteringSelection: Component, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

        var k_means: KMeans!

        let table_view = UITableView()

        var editing_text_field: UITextField?

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.registerClass(ParameterTableViewCell.self, forCellReuseIdentifier: "parameter cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                tap_recognizer.cancelsTouchesInView = false
                view.addGestureRecognizer(tap_recognizer)
        }

        override func render() {
                self.k_means = (state.page_state as! KMeansClusteringSelectionState).k_means
                table_view.dataSource = self
                table_view.delegate = self
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 3
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                switch section {
                case 0:
                        let text = "Perform clustering"
                        header.update_selectable_arrow(text: text)

                        if header.tap_recognizer == nil {
                                header.addTapGestureRecognizer(target: self, action: "header_tap_action:")
                        }
                case 0:
                        let text = "Select the number of clusters"
                        header.update_normal(text: text)
                default:
                        let text = "Select a factor for coloring"
                        header.update_normal(text: text)
                }

                return header
        }

        func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return section == 0 ? 0 : 10
        }

        func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier("footer")
                footer?.contentView.backgroundColor = UIColor.whiteColor()
                return footer
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return section == 0 ? 0 : (section == 1 ? 1 : state.factor_ids.count + 1)
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return indexPath.section == 1 ? parameter_table_view_cell_height : centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let (section, row) = (indexPath.section, indexPath.row)

                if section == 1 {
                        let cell = tableView.dequeueReusableCellWithIdentifier("parameter cell") as! ParameterTableViewCell

                        let text = "Number of clusters"
                        let short_text = "k = "
                        let parameter = String(k_means.k)
                        cell.update(text: text, short_text: short_text, parameter: parameter, tag: section, delegate: self)
                        return cell
                } else {
                        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell
                        let text = row == 0 ? "No coloring" : state.factor_names[row - 1]
                        if k_means.selected_row == row {
                                cell.update_selected_checkmark(text: text)
                        } else {
                                cell.update_unselected(text: text)
                        }
                        return cell
                }
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                if indexPath.section == 2 {
                        k_means.selected_row = indexPath.row
                        tableView.reloadData()
                }
        }

        func textFieldDidBeginEditing(textField: UITextField) {
                editing_text_field = textField
        }

        func textFieldDidEndEditing(textField: UITextField) {
                read_text_fields()
                editing_text_field = nil
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
                if range.length != 0 && string.isEmpty {
                        return true
                }

                return Int(string) != nil
        }

        func read_text_fields() {
                if let cell = table_view.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? ParameterTableViewCell {
                        let text_field = cell.text_field
                        let text = text_field.text ?? ""
                        if let number = Int(text) {
                                if number < 1 {
                                        text_field.text = "1"
                                        k_means.set_k(k: 1)
                                } else if number > k_means.max_k() {
                                                text_field.text = "\(k_means.max_k())"
                                                k_means.set_k(k: k_means.max_k())
                                        } else {
                                                k_means.set_k(k: number)
                                        }
                                } else {
                                        text_field.text = "1"
                                        k_means.set_k(k: 1)
                                }
                        }
        }

        func header_tap_action(sender: UITapGestureRecognizer) {
                editing_text_field?.resignFirstResponder()
                read_text_fields()
                let page_state = KMeansClusteringResultState(k_means: k_means)
                state.navigate(page_state: page_state)
                state.render()
        }
        
        func tap_action() {
                editing_text_field?.resignFirstResponder()
        }
}
