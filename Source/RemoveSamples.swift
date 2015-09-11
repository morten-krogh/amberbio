import UIKit

class RemoveSamplesState: PageState {

        var missing_values = [] as [Int]
        var selected_rows = [] as Set<Int>

        override init() {
                super.init()
                name = "remove_samples"
                title = astring_body(string: "Remove samples")
                info = "Create a new data set with fewer samples by tapping the button.\n\nThe highlighted samples are removed.\n\nHighlight and dehighlight a sample by tapping.\n\nThe number of missing values for a sample name is written in gray after the sample name"
                missing_values = missing_values_for_columns(matrix: state.values, number_of_rows: state.number_of_molecules, number_of_columns: state.number_of_samples)
        }
}

class RemoveSamples: Component, UITableViewDataSource, UITableViewDelegate {

        var remove_samples_state: RemoveSamplesState!

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
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                view.addSubview(table_view)
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
                remove_samples_state = state.page_state as! RemoveSamplesState
                render_create_data_set_button()
        }

        func render_create_data_set_button() {
                if remove_samples_state.selected_rows.count == 0 {
                        let attributed_string = astring_font_size_color(string: "At least one sample must be removed", font: nil, font_size: nil, color: UIColor.blackColor())
                        create_data_set_button.setAttributedTitle(attributed_string, forState: .Disabled)
                        create_data_set_button.enabled = false
                } else if remove_samples_state.selected_rows.count == state.number_of_samples {
                        let attributed_string = astring_font_size_color(string: "At least one sample must be left", font: nil, font_size: nil, color: UIColor.blackColor())
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

                let text = "Select samples"
                view.update_normal(text: text)

                return view
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return state.number_of_samples
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let sample_name = state.sample_names[indexPath.row]
                let number_of_missing_values = remove_samples_state.missing_values[indexPath.row]
                let selected = remove_samples_state.selected_rows.contains(indexPath.row)
                let astring = astring_body(string: sample_name)
                astring.appendAttributedString(astring_font_size_color(string: " (\(number_of_missing_values))", font: font_footnote, color: color_gray))

                if selected {
                        cell.update_selected_checkmark(attributed_text: astring)
                } else {
                        cell.update_unselected(attributed_text: astring)
                }

                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                if remove_samples_state.selected_rows.contains(indexPath.row) {
                        remove_samples_state.selected_rows.remove(indexPath.row)
                } else {
                        remove_samples_state.selected_rows.insert(indexPath.row)
                }
                render_create_data_set_button()
                table_view.reloadData()
        }

        func select_all_action() {
                for i in 0 ..< state.number_of_samples {
                        remove_samples_state.selected_rows.insert(i)
                }
                render_create_data_set_button()
                table_view.reloadData()
        }

        func deselect_all_action() {
                remove_samples_state.selected_rows.removeAll()
                render_create_data_set_button()
                table_view.reloadData()
        }

        func create_data_set_action() {
                create_remove_samples_data_set(selected_samples: remove_samples_state.selected_rows)
        }
}

func create_remove_samples_data_set(selected_samples selected_samples: Set<Int>) {

        state.render_type = RenderType.progress_indicator
        state.progress_indicator_info =  "The data set is created"
        state.progress_indicator_progress = 0
        state.render()

        let serial_queue = dispatch_queue_create("remove samples", DISPATCH_QUEUE_SERIAL)

        dispatch_async(serial_queue, {

                var new_sample_indices = [] as [Int]
                var new_sample_ids = [] as [Int]

                for i in 0 ..< state.number_of_samples {
                        if !selected_samples.contains(i) {
                                new_sample_indices.append(i)
                                new_sample_ids.append(state.sample_ids[i])
                        }
                }

                var new_values = [Double](count: state.number_of_molecules * new_sample_ids.count, repeatedValue: 0)

                var index_counter = 0
                for i in 0 ..< state.number_of_molecules {
                        let offset = i * state.number_of_samples
                        for sample_index in new_sample_indices {
                                let value = state.values[offset + sample_index]
                                new_values[index_counter] = value
                                index_counter++
                        }
                        state.progress_indicator_step(total: state.number_of_molecules, index: i, min: 0, max: 90, step_size: 1_000)
                }

                let data_set_name = "Data set with removed samples"

                dispatch_async(dispatch_get_main_queue(), {

                        let data_set_id = state.insert_data_set(data_set_name: data_set_name, project_id: state.project_id, values: new_values, sample_ids: new_sample_ids, molecule_indices: state.molecule_indices)

                        let number_of_removed_samples = state.number_of_samples - new_sample_ids.count
                        let remove_text = number_of_removed_samples == 1 ? "one sample" : "\(number_of_removed_samples) samples"
                        let project_note_text = "Creation of data set \"\(data_set_name)\" by removal of \(remove_text)."
                        state.insert_project_note(project_note_text: project_note_text, project_note_type: "auto", project_note_user_name: state.get_user_name(), project_id: state.project_id)

                        state.set_active_data_set(data_set_id: data_set_id)

                        let data_set_selection_state = DataSetSelectionState()
                        state.navigate(page_state: data_set_selection_state)
                        state.render_type = RenderType.full_page
                        state.render()
                })
        })
}
