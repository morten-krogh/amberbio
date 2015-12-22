import UIKit

class ProjectSettingsState: PageState {

        override init() {
                super.init()
                name = "project_settings"
                title = astring_body(string: "Project Settings")
                info = "The project settings are reused in several plots for this project."
        }
}

class ProjectSettings: Component, UITableViewDataSource, UITableViewDelegate {

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
        }

        override func render() {
                table_view.reloadData()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                header.update_normal(text: "Molecule id for plots")

                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return 1 + state.molecule_annotation_names.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let row = indexPath.row
                let text = row == 0 ? "molecule name" : state.molecule_annotation_names[row - 1]
                let selected = row == state.molecule_annotation_selected_index + 1

                if selected {
                        cell.update_selected_checkmark(text: text)
                } else {
                        cell.update_unselected(text: text)
                }

                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let row = indexPath.row
                if row != state.molecule_annotation_selected_index + 1 {
                        state.update_molecule_annotation_selected_index(index: row - 1)
                        render()
                }
        }
}
