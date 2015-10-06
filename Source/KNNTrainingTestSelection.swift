import UIKit

class KNNTrainingTestSelectionState: PageState {

        let knn: KNN

        init(knn: KNN) {
                self.knn = knn
                super.init()
                name = "knn_training_test_selection"
                title = astring_body(string: "k nearest neighbor classification")
                info = "Select the samples for the training set.\n\nThe numbers in parenthesis represent the number of samples in the training set and the total number of samples respectively for that level.\n\nSelecting a level from a factor leads to inclusion of all samples with that level.\n\nDeselecting a level removes all samples with that level from the training set.\n\nThe test set consists of all the samples that are not in the training set.\n\nTo continue, both the training and test set must contain at least one sample."
        }
}

class KNNTrainingTestSelection: Component, UITableViewDataSource, UITableViewDelegate, SelectAllHeaderFooterViewDelegate {

        var knn_training_test_selection_state: KNNTrainingTestSelectionState!

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "tappable-header")
                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(SelectAllHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "select-all-header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
        }

        override func render() {
                knn_training_test_selection_state = state.page_state as! KNNTrainingTestSelectionState
                table_view.dataSource = self
                table_view.delegate = self
                table_view.reloadData()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1 + state.factor_ids.count
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return section == 1 ? select_all_header_footer_view_height : centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                if section == 0 {
                        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("tappable-header") as! CenteredHeaderFooterView
                        let knn = knn_training_test_selection_state.knn
                        let selectable = knn.selected_sample_indices.count > 0 && knn.selected_sample_indices.count < knn.sample_indices.count
                        if selectable {
                                header.update_selectable_arrow(text: "Continue")
                        } else {
                                header.update_unselected(text: "Continue")
                        }
                        if header.tap_recognizer == nil {
                                header.addTapGestureRecognizer(target: self, action: "header_tap_action:")
                        }
                        return header
                } else if section == 1 {
                        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("select-all-header") as! SelectAllHeaderFooterView
                        let text = "Select training samples"
                        header.update(text: text, tag: 0, delegate: self)
                        return header
                } else {
                        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView
                        let factor_index = section_to_factor_index(section: section)
                        let factor_name = state.factor_names[factor_index]
                        header.update_normal(text: factor_name)
                        return header
                }


        }

        func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return section == 0 ? 20 : 0
        }

        func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier("footer")
                footer?.contentView.backgroundColor = UIColor.whiteColor()
                return footer
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                if section == 0 {
                        return knn_training_test_selection_state.knn.comparison_level_ids.count
                } else if section == 1 {
                        return knn_training_test_selection_state.knn.sample_indices.count
                } else {
                        let factor_index = section_to_factor_index(section: section)
                        return state.level_ids_by_factor[factor_index].count
                }
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let (section, row) = (indexPath.section, indexPath.row)
                let knn = knn_training_test_selection_state.knn

                if section == 0 {
                        let level_id = knn.comparison_level_ids[row]
                        let level_name = knn.comparison_level_names[row]
                        let number_of_samples = knn.number_of_samples_per_comparison_level_id[level_id]!
                        let number_of_training_samples = knn.number_of_training_samples_per_comparison_level_id[level_id]!

                        let text = level_name + " (\(number_of_training_samples) of \(number_of_samples))"

                        cell.update_unselected(text: text)

                } else if section == 1 {
                        let sample_index = knn.sample_indices[row]
                        let sample_name = knn.sample_names[row]
                        let level_name = knn.sample_comparison_level_names[row]
                        let training_set_sample = knn.selected_sample_indices.contains(sample_index)
                        
                        let text = sample_name + " (" + level_name + ")"
                        
                        if training_set_sample {
                                cell.update_selected_checkmark(text: text)
                        } else {
                                cell.update_unselected(text: text)
                        }
                } else {
                        let factor_index = section_to_factor_index(section: section)
                        let level_id = state.level_ids_by_factor[factor_index][row]
                        let level_name = state.level_names_by_factor[factor_index][row]
                        if knn.selected_level_ids.contains(level_id) {
                                cell.update_selected_checkmark(text: level_name)
                        } else {
                                cell.update_unselected(text: level_name)
                        }
                }

                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                
                let (section, row) = (indexPath.section, indexPath.row)
                let knn = knn_training_test_selection_state.knn

                if section == 1 {
                        let sample_index = knn.sample_indices[row]
                        knn.toggle_sample(sample_index: sample_index)
                        render()
                } else if section > 1 {
                        let factor_index = section_to_factor_index(section: section)
                        let level_id = state.level_ids_by_factor[factor_index][row]
                        knn.toggle_level(factor_index: factor_index, level_id: level_id)
                        render()
                }
        }

        func header_tap_action(sender: UITapGestureRecognizer) {
                let knn = knn_training_test_selection_state.knn
                if knn.selected_sample_indices.count > 0 && knn.selected_sample_indices.count < knn.sample_indices.count {
                        let page_state = KNNKSelectionState(knn: knn)
                        state.navigate(page_state: page_state)
                        state.render()
                }
        }
        
        func section_to_factor_index(section section: Int) -> Int {
                let comparison_factor_index = state.factor_ids.indexOf(knn_training_test_selection_state.knn.comparison_factor_id)!
                return section < comparison_factor_index + 2 ? section - 2 : section - 1
        }

        func select_all_action(tag tag: Int) {
                knn_training_test_selection_state.knn.select_all_samples()
                render()
        }

        func deselect_all_action(tag tag: Int) {
                knn_training_test_selection_state.knn.deselect_all_samples()
                render()
        }
}
