import UIKit

class SupervisedClassificationTrainingSelectionState: PageState {

        let supervised_classification: SupervisedClassification

        init(supervised_classification: SupervisedClassification) {
                self.supervised_classification = supervised_classification
                super.init()
                name = "supervised_classification_training_selection"
                switch supervised_classification.supervised_classification_type {
                case .KNN:
                        title = astring_body(string: "k nearest neighbor classifier")
                case .SVM:
                        title = astring_body(string: "support vector machine")
                }
                info = "Select the samples for the training set.\n\nThe numbers in parenthesis represent the number of samples in the training set and the total number of samples respectively for that level.\n\nSelecting a level from a factor leads to inclusion of all samples with that level.\n\nDeselecting a level removes all samples with that level from the training set.\n\nThe test set consists of all the samples that are not in the training set.\n\nTo continue, both the training and test set must contain at least one sample."
        }
}

class SupervisedClassificationTrainingSelection: Component, UITableViewDataSource, UITableViewDelegate, SelectAllHeaderFooterViewDelegate {

        var supervised_classification: SupervisedClassification!

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
                supervised_classification = (state.page_state as! SupervisedClassificationTrainingSelectionState).supervised_classification
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
                        let selectable = supervised_classification.training_sample_index_set.count > 0 && (supervised_classification.training_sample_index_set.count < supervised_classification.core_sample_indices.count || supervised_classification.additional_sample_indices.count > 0)
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
                        return supervised_classification.comparison_level_ids.count
                } else if section == 1 {
                        return supervised_classification.core_sample_indices.count
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

                if section == 0 {
                        let level_id = supervised_classification.comparison_level_ids[row]
                        let level_name = supervised_classification.comparison_level_names[row]
                        let number_of_samples = supervised_classification.number_of_samples_per_level_id[level_id]!
                        let number_of_training_samples = supervised_classification.training_number_of_samples_per_comparison_level_id[level_id]!

                        let text = level_name + " (\(number_of_training_samples) of \(number_of_samples))"

                        cell.update_unselected(text: text)

                } else if section == 1 {
                        let sample_index = supervised_classification.core_sample_indices[row]
                        let sample_name = supervised_classification.core_sample_names[row]
                        let level_name = supervised_classification.core_sample_level_names[row]
                        let training_set_sample = supervised_classification.training_sample_index_set.contains(sample_index)
                        
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
                        if supervised_classification.training_level_id_set.contains(level_id) {
                                cell.update_selected_checkmark(text: level_name)
                        } else {
                                cell.update_unselected(text: level_name)
                        }
                }

                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let (section, row) = (indexPath.section, indexPath.row)

                if section == 1 {
                        let sample_index = supervised_classification.core_sample_indices[row]
                        supervised_classification.toggle_sample(sample_index: sample_index)
                        render()
                } else if section > 1 {
                        let factor_index = section_to_factor_index(section: section)
                        let level_id = state.level_ids_by_factor[factor_index][row]
                        supervised_classification.toggle_level(factor_index: factor_index, level_id: level_id)
                        render()
                }
        }

        func header_tap_action(sender: UITapGestureRecognizer) {
                if supervised_classification.training_sample_index_set.count > 0 && (supervised_classification.training_sample_index_set.count < supervised_classification.core_sample_indices.count || supervised_classification.additional_sample_indices.count > 0) {
//                        let page_state = KNNKSelectionState(supervised_classification: supervised_classification)
//                        state.navigate(page_state: page_state)
                        state.render()
                }
        }
        
        func section_to_factor_index(section section: Int) -> Int {
                let comparison_factor_index = state.factor_ids.indexOf(supervised_classification.comparison_factor_id)!
                return section < comparison_factor_index + 2 ? section - 2 : section - 1
        }

        func select_all_action(tag tag: Int) {
                supervised_classification.select_all_samples()
                render()
        }

        func deselect_all_action(tag tag: Int) {
                supervised_classification.deselect_all_samples()
                render()
        }
}
