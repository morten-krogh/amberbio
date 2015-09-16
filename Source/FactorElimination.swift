import UIKit

class FactorEliminationState: PageState {

        override init() {
                super.init()
                name = "factor_elimination"
                title = astring_body(string: "Factor elimination")
                info = "Select a factor by tapping.\n\nCreate a new data set by tapping \"create new data set\".\n\nThe created data set has no variation from the elimianted factor.\n\nFor each molecule, the mean values of the samples across levels are forced to be equal.\n\nFactor elimination can be used to correct for systematic differences such as experimental batches."
        }
}

class FactorElimination: Component, UITableViewDataSource, UITableViewDelegate {

        var selected_factor_index: Int?

        let create_data_set_button = UIButton(type: .System)
        let table_view = UITableView()

        override func viewDidLoad() {
                super.viewDidLoad()

                create_data_set_button.setAttributedTitle(astring_body(string: "Create new data set"), forState: .Normal)
                let title_disabled = astring_font_size_color(string: "Select a factor to eliminate", font: nil, font_size: nil, color: UIColor.blackColor())
                create_data_set_button.setAttributedTitle(title_disabled, forState: .Disabled)
                create_data_set_button.addTarget(self, action: "create_data_set_action", forControlEvents: .TouchUpInside)
                create_data_set_button.sizeToFit()
                view.addSubview(create_data_set_button)

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
                var origin_y = 20 as CGFloat

                create_data_set_button.frame = CGRect(x: (width - create_data_set_button.frame.width) / 2, y: origin_y, width: width, height: create_data_set_button.frame.height)
                origin_y += create_data_set_button.frame.height + 20

                table_view.frame = CGRect(x: 0, y: origin_y, width: width, height: view.frame.height - origin_y)
        }

        override func render() {
                render_create_data_set_button()
                table_view.reloadData()
        }

        func render_create_data_set_button() {
                create_data_set_button.enabled = selected_factor_index != nil
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return state.factor_ids.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let text = state.factor_names[indexPath.row]
                if selected_factor_index == indexPath.row {
                        cell.update_selected_checkmark(text: text)
                } else {
                        cell.update_unselected(text: text)
                }

                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                if selected_factor_index != indexPath.row {
                        selected_factor_index = indexPath.row
                        render()
                }
        }

        func create_data_set_action() {
                if let selected_factor_index = selected_factor_index {
                        create_factor_elimination_data_set(factor_index: selected_factor_index)
                }
        }
}

func create_factor_elimination_data_set(factor_index factor_index: Int) {

        state.render_type = RenderType.activity_indicator
        state.activity_indicator_info = "The data set is created"
        state.render()

        let serial_queue = dispatch_queue_create("factor elimination", DISPATCH_QUEUE_SERIAL)

        dispatch_async(serial_queue, {
                let factor_name = state.factor_names[factor_index]

                let sample_level_ids = state.level_ids_by_factor_and_sample[factor_index]

                var sample_level = [Int](count: state.number_of_samples, repeatedValue: -1)
                var counter = 0
                var level_id_to_level_counter = [:] as [Int: Int]
                for i in 0 ..< state.number_of_samples {
                        let level_id = sample_level_ids[i]
                        if let level_counter = level_id_to_level_counter[level_id] {
                                sample_level[i] = level_counter
                        } else {
                                level_id_to_level_counter[level_id] = counter
                                sample_level[i] = counter
                                counter++
                        }
                }

                var values_eliminated = [Double](count: state.values.count, repeatedValue: 0)

                calculate_factor_elimination(state.values, state.number_of_molecules, state.number_of_samples, sample_level, counter, &values_eliminated)

                let data_set_name = "Data set with eliminated: \(factor_name)"
                let project_note_text = "Creation of data set \"\(data_set_name)\" by elimination of \(factor_name)."

                dispatch_async(dispatch_get_main_queue(), {
                        let data_set_id = state.insert_data_set(data_set_name: data_set_name, project_id: state.project_id, values: values_eliminated, sample_ids: state.sample_ids, molecule_indices: state.molecule_indices)
                        state.insert_project_note(project_note_text: project_note_text, project_note_type: "auto", project_note_user_name: state.get_user_name(), project_id: state.project_id)

                        let data_set_selection_state = DataSetSelectionState()
                        state.navigate(page_state: data_set_selection_state)
                        state.set_active_data_set(data_set_id: data_set_id)
                        state.render_type = RenderType.full_page
                        state.render()
                })
        })
}
