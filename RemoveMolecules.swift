import UIKit

class RemoveMoleculesState: PageState {

        var selected_rows = [] as Set<Int>

        var filtered_search_rows = [] as [Int]

        override init() {
                super.init()
                name = "remove_molecules"
                title = astring_body(string: "Remove molecules")
                info = "Create a new data set with fewer molecules.\n\nThe highlighted molecules will be removed.\n\nHighlight and dehighlight molecules by tapping."

                search_enabled = true

                filtered_search_rows = [Int](0 ..< state.number_of_molecules)
        }

        func search(search_string search_string: String) {
                if search_string != self.search_string {
                        if search_string == "" {
                                filtered_search_rows = [Int](0 ..< state.number_of_molecules)
                        } else {
                                let potential_rows = search_string.rangeOfString(self.search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil ? filtered_search_rows : [Int](0 ..< state.number_of_molecules)
                                filtered_search_rows = filter_rows(search_string: search_string, potential_rows: potential_rows)
                        }
                        self.search_string = search_string
                }
        }

        func filter_rows(search_string search_string: String, potential_rows: [Int]) -> [Int] {
                var filtered_rows = [] as [Int]

                for row in potential_rows {
                        let molecule_name = state.molecule_names[row]
                        if molecule_name.rangeOfString(search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                                filtered_rows.append(row)
                        }
                }

                return filtered_rows
        }
}

class RemoveMolecules: Component, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

        var remove_molecules_state: RemoveMoleculesState!

        let create_data_set_button = UIButton(type: .System)

        let select_all_button = UIButton(type: .System)
        let deselect_all_button = UIButton(type: .System)

        let table_view = UITableView()

        override func viewDidLoad() {
                super.viewDidLoad()

                create_data_set_button.setAttributedTitle(astring_body(string: "Create new data set"), forState: .Normal)
                create_data_set_button.addTarget(self, action: "create_data_set_action", forControlEvents: .TouchUpInside)
                create_data_set_button.sizeToFit()
                view.addSubview(create_data_set_button)

                select_all_button.setAttributedTitle(astring_body(string: "Select all"), forState: .Normal)
                select_all_button.addTarget(self, action: "select_all_action", forControlEvents: .TouchUpInside)
                view.addSubview(select_all_button)

                deselect_all_button.setAttributedTitle(astring_body(string: "Deselect all"), forState: .Normal)
                deselect_all_button.addTarget(self, action: "deselect_all_action", forControlEvents: .TouchUpInside)
                deselect_all_button.sizeToFit()
                view.addSubview(deselect_all_button)

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                view.addSubview(table_view)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let side_margin = 20 as CGFloat
                var origin_y = 25 as CGFloat

                create_data_set_button.frame = CGRect(x: (width - create_data_set_button.frame.width) / 2, y: origin_y, width: width, height: create_data_set_button.frame.height)
                origin_y += create_data_set_button.frame.height + 15

                select_all_button.sizeToFit()
                deselect_all_button.sizeToFit()
                select_all_button.frame.origin = CGPoint(x: width - side_margin - select_all_button.frame.width, y: origin_y)
                deselect_all_button.frame.origin = CGPoint(x: side_margin, y: origin_y)
                origin_y += select_all_button.frame.height

                table_view.frame = CGRect(x: 0, y: origin_y, width: width, height: view.frame.height - origin_y)
        }

        override func render() {
                remove_molecules_state = state.page_state as! RemoveMoleculesState
                render_create_data_set_button()
                table_view.dataSource = self
                table_view.delegate = self
        }

        func render_create_data_set_button() {
                if remove_molecules_state.selected_rows.count == 0 {
                        let attributed_string = astring_font_size_color(string: "At least one molecule must be removed", font: nil, font_size: nil, color: UIColor.blackColor())
                        create_data_set_button.setAttributedTitle(attributed_string, forState: .Disabled)
                        create_data_set_button.enabled = false
                } else if remove_molecules_state.selected_rows.count == state.number_of_molecules {
                        let attributed_string = astring_font_size_color(string: "At least one molecule must be left", font: nil, font_size: nil, color: UIColor.blackColor())
                        create_data_set_button.setAttributedTitle(attributed_string, forState: .Disabled)
                        create_data_set_button.enabled = false
                } else {
                        create_data_set_button.enabled = true
                }
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height - 10
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text = "Select molecules"
                view.update_normal(text: text)

                return view
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return remove_molecules_state.filtered_search_rows.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let original_row = remove_molecules_state.filtered_search_rows[indexPath.row]
                let molecule_name = state.molecule_names[original_row]
                let selected = remove_molecules_state.selected_rows.contains(original_row)
                let astring = astring_body(string: molecule_name)

                if selected {
                        cell.update_selected_checkmark(attributed_text: astring)
                } else {
                        cell.update_unselected(attributed_text: astring)
                }

                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let original_row = remove_molecules_state.filtered_search_rows[indexPath.row]

                if remove_molecules_state.selected_rows.contains(original_row) {
                        remove_molecules_state.selected_rows.remove(original_row)
                } else {
                        remove_molecules_state.selected_rows.insert(original_row)
                }
                render_create_data_set_button()
                table_view.reloadData()
        }

        func select_all_action() {
                for row in remove_molecules_state.filtered_search_rows {
                        remove_molecules_state.selected_rows.insert(row)
                }
                render_create_data_set_button()
                table_view.reloadData()
        }

        func deselect_all_action() {
                for row in remove_molecules_state.filtered_search_rows {
                        remove_molecules_state.selected_rows.remove(row)
                }
                render_create_data_set_button()
                table_view.reloadData()
        }

        override func search_action(search_string search_string: String) {
                remove_molecules_state.search(search_string: search_string)
                table_view.reloadData()
        }

        func create_data_set_action() {
                create_remove_molecules_data_set(selected_molecules: remove_molecules_state.selected_rows)
        }

        func tap_action() {
                state.root_component.full_page.search_bar.resignFirstResponder()
        }
}

func create_remove_molecules_data_set(selected_molecules selected_molecules: Set<Int>) {

        state.render_type = RenderType.progress_indicator
        state.progress_indicator_info =  "The data set is created"
        state.progress_indicator_progress = 0
        state.render()

        let serial_queue = dispatch_queue_create("remove molecules", DISPATCH_QUEUE_SERIAL)

        dispatch_async(serial_queue, {

                var new_molecule_indices = [] as [Int]

                for i in 0 ..< state.number_of_molecules {
                        if !selected_molecules.contains(i) {
                                new_molecule_indices.append(state.molecule_indices[i])
                        }
                }

                var new_values = [Double](count: new_molecule_indices.count * state.number_of_samples, repeatedValue: 0)

                var counter = 0
                for i in 0 ..< state.number_of_molecules {
                        if !selected_molecules.contains(i) {
                                let offset = i * state.number_of_samples
                                let new_offset = counter * state.number_of_samples
                                for j in 0 ..< state.number_of_samples {
                                        new_values[new_offset + j] = state.values[offset + j]
                                }
                                counter++
                        }
                        state.progress_indicator_step(total: state.number_of_molecules, index: i, min: 0, max: 90, step_size: 1_000)
                }

                let data_set_name = "Data set with removed molecules"
                let number_of_removed_molecules = state.number_of_molecules - new_molecule_indices.count
                let remove_text = number_of_removed_molecules == 1 ? "one molecule" : "\(number_of_removed_molecules) molecules"
                let project_note_text = "Creation of data set \"\(data_set_name)\" by removal of \(remove_text)."

                dispatch_async(dispatch_get_main_queue(), {

                        let data_set_id = state.insert_data_set(data_set_name: data_set_name, project_id: state.project_id, values: new_values, sample_ids: state.sample_ids, molecule_indices: new_molecule_indices)

                        state.insert_project_note(project_note_text: project_note_text, project_note_type: "auto", project_note_user_name: state.get_user_name(), project_id: state.project_id)

                        let data_set_selection_state = DataSetSelectionState()
                        state.navigate(page_state: data_set_selection_state)
                        state.render_type = RenderType.full_page
                        state.set_active_data_set(data_set_id: data_set_id)
                        state.render()
                })
        })
}
