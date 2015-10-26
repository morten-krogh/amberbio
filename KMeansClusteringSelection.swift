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
        }

        override func render() {
                self.k_means = (state.page_state as! KMeansClusteringSelectionState).k_means
                table_view.dataSource = self
                table_view.delegate = self
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 2
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text: String
                switch section {
                case 0:
                        text = "Select the number of clusters"
                default:
                        text = "Select a factor for coloring"
                }

                header.update_normal(text: text)

                return header
        }

        func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return 20
        }

        func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier("footer")
                footer?.contentView.backgroundColor = UIColor.whiteColor()
                return footer
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return section == 0 ? 1 : state.factor_ids.count + 1
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return indexPath.section == 0 ? parameter_table_view_cell_height : centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let (section, row) = (indexPath.section, indexPath.row)

                if section == 0 {
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
                if indexPath.section == 1 {
                        k_means.selected_row = indexPath.row
                        tableView.reloadData()
                }
        }

//        func header_tap_action(sender: UITapGestureRecognizer) {
//                if let section = sender.view?.tag {
//                        var selected_level_ids_in_section = [] as [Int]
//                        for level_id in state.level_ids_by_factor[section] {
//                                if supervised_classification_factor_selection_state.selected_level_ids.contains(level_id) {
//                                        selected_level_ids_in_section.append(level_id)
//                                }
//                        }
//
//                        if selected_level_ids_in_section.count < 2 {
//                                //                                alert(title: "Too few selected levels", message: "At least two levels must be selected", view_controller: self)
//                        } else {
//                                let supervised_classification: SupervisedClassification
//                                switch supervised_classification_factor_selection_state.supervised_classification_type {
//                                case .KNN:
//                                        supervised_classification = KNN(comparison_factor_id: state.factor_ids[section], comparison_level_ids: selected_level_ids_in_section)
//                                case .SVM:
//                                        supervised_classification = SVM(comparison_factor_id: state.factor_ids[section], comparison_level_ids: selected_level_ids_in_section)
//                                }
//
//                                let supervised_classification_validation_selection_page_state = SupervisedClassificationValidationSelectionState(supervised_classification: supervised_classification)
//                                state.navigate(page_state: supervised_classification_validation_selection_page_state)
//                                state.render()
//                        }
//                }
//        }
}
