import UIKit

class SingleMoleculePlotTableState: PageState {

        var potential_rows_full = [] as [Int]
        var filtered_search_rows = [] as [Int]
        var selected_segment_index = 0

        override init() {
                super.init()
                name = "single_molecule_plot_table"
                title = astring_body(string: "Single Molecule Plots")
                info = "Plots of the values for all molecules.\n\nScroll through the molecules.\n\nChange the grouping in the plots by tapping the top bar."

                potential_rows_full = [Int](0 ..< state.molecule_names.count)
                filtered_search_rows = potential_rows_full

                search_enabled = true
                full_screen = .Conditional
        }
}

class SingleMoleculePlotTable: Component, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

        var single_molecule_plot_table_state: SingleMoleculePlotTableState!

        var factor_name: String?
        var single_plot_names = [] as [String]
        var single_plot_colors = [] as [[UIColor]]
        var plot_indices = [] as [Int]

        let scroll_view_segmented_control = UIScrollView()
        var segmented_control: UISegmentedControl?

        let table_view = UITableView()

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(scroll_view_segmented_control)

                table_view.registerClass(SingleMoleculeTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                table_view.allowsSelection = false
                view.addSubview(table_view)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                var origin_y = 0 as CGFloat

                if let segmented_control = segmented_control {
                                let segmented_rect = CGRect(x: 0, y: origin_y, width: width, height: segmented_control.frame.height)
                                scroll_view_segmented_control.frame = layout_centered_frame(contentSize: segmented_control.frame.size, rect: segmented_rect)
                                scroll_view_segmented_control.contentSize = segmented_control.bounds.size
                                segmented_control.frame.origin = CGPoint.zero

                                origin_y += segmented_control.frame.height + 5
                }

                origin_y += 5

                table_view.frame = CGRect(x: 0, y: origin_y, width: width, height: view.frame.height - origin_y)
        }

        override func render() {
                single_molecule_plot_table_state = state.page_state as! SingleMoleculePlotTableState

                update_selected_segment_index(index: single_molecule_plot_table_state.selected_segment_index)

                if let segmented_control = segmented_control {
                        segmented_control.removeFromSuperview()
                }

                if !state.factor_ids.isEmpty {
                        segmented_control = UISegmentedControl(items: ["Samples"] + state.factor_names)
                        segmented_control!.selectedSegmentIndex = single_molecule_plot_table_state.selected_segment_index
                        segmented_control!.addTarget(self, action: "select_factor_action:", forControlEvents: .ValueChanged)
                        scroll_view_segmented_control.addSubview(segmented_control!)
                }

                table_view.dataSource = self
                table_view.delegate = self

                table_view.reloadData()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return single_molecule_plot_table_state.filtered_search_rows.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return single_molecule_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! SingleMoleculeTableViewCell

                let index = single_molecule_plot_table_state.filtered_search_rows[indexPath.row]
                let molecule_name = state.molecule_names[index]

                var molecule_annotation_values = [] as [String]
                for i in 0 ..< state.molecule_annotation_names.count {
                        let value = state.molecule_annotation_values[i][index]
                        molecule_annotation_values.append(value)
                }

                let start_index = index * state.number_of_samples
                let end_index = (index + 1) * state.number_of_samples
                let values_for_molecule = [Double](state.values[start_index ..< end_index])

                var single_plot_values = [] as [[Double]]

                if single_molecule_plot_table_state.selected_segment_index == 0 {
                        single_plot_values = values_for_molecule.map({ [$0] })
                } else {
                        for i in 0 ..< plot_indices.count {
                                let plot_index = plot_indices[i]
                                let value = values_for_molecule[i]
                                if plot_index >= single_plot_values.count {
                                        single_plot_values.append([])
                                }
                                single_plot_values[plot_index].append(value)
                        }
                }
                
                cell.update(molecule_name: molecule_name, factor_name: factor_name, annotation_names: state.molecule_annotation_names, molecule_annotation_values: molecule_annotation_values, single_plot_names: single_plot_names, single_plot_colors: single_plot_colors, single_plot_values: single_plot_values)

                return cell
        }

        func select_factor_action(segmented_control: UISegmentedControl) {
                if single_molecule_plot_table_state.selected_segment_index != segmented_control.selectedSegmentIndex {
                        update_selected_segment_index(index: segmented_control.selectedSegmentIndex)
                        table_view.reloadData()
                }
        }

        func update_selected_segment_index(index index: Int) {
                single_molecule_plot_table_state.selected_segment_index = index

                if index == 0 {
                        factor_name = nil
                        single_plot_names = state.sample_names
                        single_plot_colors = [[UIColor]](count: state.sample_ids.count, repeatedValue: [color_blue_circle_color])
                } else {
                        single_plot_names = []
                        single_plot_colors = []
                        plot_indices = []

                        factor_name = state.factor_names[index - 1]

                        let level_ids = state.level_ids_by_factor_and_sample[index - 1]
                        let level_names = state.level_names_by_factor_and_sample[index - 1]
                        let level_colors = state.level_colors_by_factor_and_sample[index - 1]

                        var level_id_to_plot_index = [:] as [Int: Int]
                        var plot_index_counter = 0

                        for i in 0 ..< level_ids.count {
                                let level_id = level_ids[i]
                                let color = color_from_hex(hex: level_colors[i])
                                if let plot_index = level_id_to_plot_index[level_id] {
                                        single_plot_colors[plot_index].append(color)
                                        plot_indices.append(plot_index)
                                } else {
                                        level_id_to_plot_index[level_id] = plot_index_counter
                                        single_plot_names.append(level_names[i])
                                        single_plot_colors.append([color])
                                        plot_indices.append(plot_index_counter)
                                        plot_index_counter++
                                }
                        }
                }
        }

        override func search_action(search_string search_string: String) {
                if search_string != single_molecule_plot_table_state.search_string {
                        if search_string == "" {
                                single_molecule_plot_table_state.filtered_search_rows = single_molecule_plot_table_state.potential_rows_full
                        } else {
                                let potential_rows = search_string.rangeOfString(single_molecule_plot_table_state.search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil ? single_molecule_plot_table_state.filtered_search_rows : single_molecule_plot_table_state.potential_rows_full
                                single_molecule_plot_table_state.filtered_search_rows = single_molecule_selection_filter_rows(search_string: search_string, molecule_names: state.molecule_names, molecule_annotation_values: state.molecule_annotation_values, potential_rows: potential_rows)
                        }
                        single_molecule_plot_table_state.search_string = search_string
                        table_view.reloadData()
                }
        }

        func tap_action() {
                state.root_component.full_page.search_bar.resignFirstResponder()
        }
}

func single_molecule_selection_filter_rows(search_string search_string: String, molecule_names: [String], molecule_annotation_values: [[String]], potential_rows: [Int]) -> [Int] {
        var filtered_rows = [] as [Int]

        for row in potential_rows {
                if single_molecule_selection_check_search_string_in_row(search_string: search_string, molecule_names: molecule_names, molecule_annotation_values: molecule_annotation_values, row: row) {
                        filtered_rows.append(row)
                }
        }

        return filtered_rows
}

func single_molecule_selection_check_search_string_in_row(search_string search_string: String, molecule_names: [String], molecule_annotation_values: [[String]], row: Int) -> Bool {
        for column in 0 ..< molecule_annotation_values.count + 1 {
                let string = column == 0 ? molecule_names[row] : molecule_annotation_values[column - 1][row]
                if string.rangeOfString(search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                        return true
                }
        }
        return false
}
