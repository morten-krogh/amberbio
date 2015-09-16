import UIKit

class AnovaFactorSelectionState: PageState {

        var selected_level_ids = [] as Set<Int>

        override init() {
                super.init()
                name = "anova_factor_selection"
                title = astring_body(string: "Anova")
                info = "Tap a factor(blue) to obtain a table of Anova tests all molecules.\n\nSelect and deselect the levels of the factor that should be included by tapping.\n\nThere must be at least two selected levels."

                for level_ids_for_factor in state.level_ids_by_factor {
                        for level_id in level_ids_for_factor {
                                selected_level_ids.insert(level_id)
                        }
                }
        }
}

class AnovaFactorSelection: Component, UITableViewDataSource, UITableViewDelegate {

        var anova_factor_selection_state: AnovaFactorSelectionState!

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
        }

        override func render() {
                anova_factor_selection_state = state.page_state as! AnovaFactorSelectionState
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return state.factor_ids.count
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                var number_of_selected_levels = 0
                for level_id in state.level_ids_by_factor[section] {
                        if anova_factor_selection_state.selected_level_ids.contains(level_id) {
                                number_of_selected_levels++
                        }
                }

                let text = state.factor_names[section]
                if number_of_selected_levels >= 2 {
                        header.update_selectable_arrow(text: text)
                } else {
                        header.update_unselected(text: text)
                }
                header.tag = section

                if header.tap_recognizer == nil {
                        header.addTapGestureRecognizer(target: self, action: "header_tap_action:")
                }

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
                return state.level_ids_by_factor[section].count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let level_id = state.level_ids_by_factor[indexPath.section][indexPath.row]
                let level_name = state.level_names_by_factor[indexPath.section][indexPath.row]

                if anova_factor_selection_state.selected_level_ids.contains(level_id) {
                        cell.update_selected_checkmark(text: level_name)
                } else {
                        cell.update_unselected(text: level_name)
                }
                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let level_id = state.level_ids_by_factor[indexPath.section][indexPath.row]
                if anova_factor_selection_state.selected_level_ids.contains(level_id) {
                        anova_factor_selection_state.selected_level_ids.remove(level_id)
                } else {
                        anova_factor_selection_state.selected_level_ids.insert(level_id)
                }
                table_view.reloadData()
        }

        func header_tap_action(sender: UITapGestureRecognizer) {
                if let section = sender.view?.tag {
                        var selected_level_ids_in_section = [] as [Int]
                        for level_id in state.level_ids_by_factor[section] {
                                if anova_factor_selection_state.selected_level_ids.contains(level_id) {
                                        selected_level_ids_in_section.append(level_id)
                                }
                        }

                        if selected_level_ids_in_section.count < 2 {
                                alert(title: "Too few selected levels", message: "At least two levels must be selected", view_controller: self)
                        } else {
                                let selected_factor_id = state.factor_ids[section]
                                let selected_level_ids_for_factor = state.level_ids_by_factor[section].filter { self.anova_factor_selection_state.selected_level_ids.contains($0) }
                                let anova_table_state = AnovaTableState(factor_id: selected_factor_id, level_ids: selected_level_ids_for_factor)
                                state.navigate(page_state: anova_table_state)
                                state.render()
                        }
                }
        }
}
