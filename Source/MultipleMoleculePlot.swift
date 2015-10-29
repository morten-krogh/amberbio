import UIKit

class MultipleMoleculePlotState: PageState {

        var selected_factor_id: Int?
        var dimension = 3
        var plot_symbol = "circles"
        var symbol_size = 1.0

        var selected_samples = [] as [Bool]
        var selected_sample_indices = [] as [Int]
        var selected_sample_names = [] as [String]
        var selected_sample_colors = [] as [UIColor]

        var missing_values_per_molecule = [] as [Int]
        var std_dev_per_molecule = [] as [Double]

        var level_names = [] as [String]
        var level_colors = [] as [String]

        var selected_molecule_indices = [0, 1, 2]
        var zoom_scale_2d = 1 as CGFloat

        var sorted_indices = [] as [Int]
        var filtered_indices = [] as [Int]

        override init() {
                super.init()
                name = "multiple_molecule_plot"
                title = astring_body(string: "Multiple molecule plot")
                info = "A simultaneous plot of two or three molecules.\n\nSelect the molecules to show in the plot.\n\nTap the plot to show and hide the control panel on narrow screens.\n\nThe colors represent levels for the selected factor.\n\nThe molecules are sorted according to variance with the most variable molecules on top.\n\nValues in the plot are zero centered."
                full_screen = .Full
                prepared = false
        }

        override func prepare() {
                selected_samples = [Bool](count: state.number_of_samples, repeatedValue: true)

                calculate_selected_sample_indices()
                calculate_levels_and_colors()
                calculate_missing_values_and_standard_deviations()

                let all_indices = [Int](0 ..< state.number_of_molecules)
                sorted_indices = all_indices.sort { self.std_dev_per_molecule[$1].isNaN || self.std_dev_per_molecule[$0] > self.std_dev_per_molecule[$1] }
                filtered_indices = sorted_indices
                selected_molecule_indices[0] = filtered_indices.count > 0 ? filtered_indices[0] : 0
                selected_molecule_indices[1] = filtered_indices.count > 1 ? filtered_indices[1] : 1
                selected_molecule_indices[2] = filtered_indices.count > 2 ? filtered_indices[2] : 2

                set_dimension(dimension: 3)

                prepared = true
        }

        func calculate_selected_sample_indices() {
                selected_sample_indices = []
                selected_sample_names = []
                for i in 0 ..< state.number_of_samples {
                        if selected_samples[i] {
                                selected_sample_indices.append(i)
                                selected_sample_names.append(state.sample_names[i])
                        }
                }
        }

        func calculate_levels_and_colors() {
                if let factor_id = selected_factor_id {
                        let factor_index = state.factor_ids.indexOf(factor_id)!
                        level_names = state.level_names_by_factor[factor_index]
                        level_colors = state.level_colors_by_factor[factor_index]

                        selected_sample_colors = []
                        for index in selected_sample_indices {
                                selected_sample_colors.append(color_from_hex(hex: state.level_colors_by_factor_and_sample[factor_index][index]))
                        }
                } else {
                        level_names = []
                        level_colors = []
                        selected_sample_colors = [UIColor](count: selected_sample_indices.count, repeatedValue: UIColor.blueColor())
                }
        }

        func calculate_missing_values_and_standard_deviations() {
                missing_values_per_molecule = [Int](count: state.number_of_molecules, repeatedValue: 0)
                std_dev_per_molecule = [Double](count: state.number_of_molecules, repeatedValue: 0)
                values_calculate_missing_values_and_std_devs(state.values, state.number_of_molecules, state.number_of_samples, &missing_values_per_molecule, &std_dev_per_molecule)
        }

        func set_dimension(dimension dimension: Int) {
                if dimension == 2 {
                        pdf_enabled = state.number_of_molecules >= 2
                        png_enabled = false
                } else {
                        pdf_enabled = false
                        png_enabled = state.number_of_molecules >= 3
                }
                
                self.dimension = dimension
        }

        func perform_search(search_string search_string: String) {
                if search_string != self.search_string {
                        if search_string == "" {
                                filtered_indices = sorted_indices
                        } else {
                                let potential_indices = search_string.rangeOfString(self.search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil ? filtered_indices : sorted_indices
                                filtered_indices = []
                                for index in potential_indices {
                                        let molecule_name = state.molecule_names[index]
                                        if molecule_name.rangeOfString(search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                                                filtered_indices.append(index)
                                        }
                                }
                        }
                        self.search_string = search_string
                }
        }

        func select_row(row row: Int) -> Bool {
                return select_molecule(index: filtered_indices[row])
        }

        func select_molecule(index index: Int) -> Bool {
                if dimension == 2 {
                        if selected_molecule_indices[0] == index || selected_molecule_indices[1] == index {
                                return false
                        } else {
                                selected_molecule_indices = [selected_molecule_indices[1], index, selected_molecule_indices[0]]
                                return true
                        }
                } else {
                        if selected_molecule_indices.indexOf(index) == nil {
                                selected_molecule_indices = [selected_molecule_indices[1], selected_molecule_indices[2], index]
                                return true
                        } else {
                                return false
                        }
                }
        }

        func get_axis_title() -> [String] {
                var titles = [state.molecule_names[selected_molecule_indices[0]], state.molecule_names[selected_molecule_indices[1]]]
                if dimension == 3 {
                        titles.append(state.molecule_names[selected_molecule_indices[2]])
                }
                return titles
        }

        func content_for_cell(row row: Int) -> (text: String, number: Int?) {
                let index = filtered_indices[row]
                let text = state.molecule_names[index]
                var number = nil as Int?
                if selected_molecule_indices[0] == index {
                        number = 1
                } else if selected_molecule_indices[1] == index {
                        number = 2
                } else if dimension == 3 && selected_molecule_indices[2] == index {
                        number = 3
                }
                return (text, number)
        }

        func points_2d() -> (names: [String], colors: [UIColor], points_x: [Double], points_y: [Double], axis_titles: [String]) {
                let values1 = state.get_values_for_molecule(index: selected_molecule_indices[0])
                let values2 = state.get_values_for_molecule(index: selected_molecule_indices[1])
                var (names, colors, points_x, points_y) = ([], [], [], []) as ([String], [UIColor], [Double], [Double])
                for i in 0 ..< state.number_of_samples {
                        if !values1[i].isNaN && !values2[i].isNaN {
                                names.append(selected_sample_names[i])
                                colors.append(selected_sample_colors[i])
                                points_x.append(values1[i])
                                points_y.append(values2[i])
                        }
                }
                (points_x, points_y) = (stat_subtract_mean(values: points_x), stat_subtract_mean(values: points_y))
                let axis_titles = [state.molecule_names[selected_molecule_indices[0]], state.molecule_names[selected_molecule_indices[1]]]
                return (names, colors, points_x, points_y, axis_titles)
        }

        func points_3d() -> (names: [String], colors: [UIColor], points_x: [Double], points_y: [Double], points_z: [Double], axis_titles: [String]) {
                let values1 = state.get_values_for_molecule(index: selected_molecule_indices[0])
                let values2 = state.get_values_for_molecule(index: selected_molecule_indices[1])
                let values3 = state.get_values_for_molecule(index: selected_molecule_indices[2])
                var (names, colors, points_x, points_y, points_z) = ([], [], [], [], []) as ([String], [UIColor], [Double], [Double], [Double])
                for i in 0 ..< state.number_of_samples {
                        if !values1[i].isNaN && !values2[i].isNaN && !values3[i].isNaN {
                                names.append(selected_sample_names[i])
                                colors.append(selected_sample_colors[i])
                                points_x.append(values1[i])
                                points_y.append(values2[i])
                                points_z.append(values3[i])
                        }
                }
                (points_x, points_y, points_z) = (stat_subtract_mean(values: points_x), stat_subtract_mean(values: points_y), stat_subtract_mean(values: points_z))
                let axis_titles = [state.molecule_names[selected_molecule_indices[0]], state.molecule_names[selected_molecule_indices[1]], state.molecule_names[selected_molecule_indices[2]]]
                return (names, colors, points_x, points_y, points_z, axis_titles)
        }
}

class MultipleMoleculePlot: Component, UITableViewDataSource, UITableViewDelegate, PCA2dDelegate, UISearchBarDelegate {

        var multiple_molecule_plot_state: MultipleMoleculePlotState!

        let scroll_view = UIScrollView()
        let left_view = UIView()
        let values_2d_plot = Values2DPlot()
        let values_3d_plot = Values3DPlot()
        let table_view = UITableView()
        let info_label = UILabel()
        var search_bar: UISearchBar?

        var min_zoom = 1 as CGFloat

        var width = 0 as CGFloat
        var width_right = 300 as CGFloat
        var width_left = 0 as CGFloat

        override func viewDidLoad() {
                super.viewDidLoad()

                scroll_view.scrollEnabled = false
                view.addSubview(scroll_view)

                values_2d_plot.maximum_zoom_scale_multiplier = 50
                scroll_view.addSubview(values_2d_plot)
                scroll_view.addSubview(values_3d_plot)

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "centered_cell")
                table_view.registerClass(SegmentedControlTableViewCell.self, forCellReuseIdentifier: "segmented_control_cell")
                table_view.registerClass(SliderTableViewCell.self, forCellReuseIdentifier: "slider_cell")
                table_view.registerClass(ColorSelectionTableViewCell.self, forCellReuseIdentifier: "color_selection_cell")
                table_view.registerClass(SearchTableViewCell.self, forCellReuseIdentifier: "search_bar_cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                scroll_view.addSubview(table_view)

                scroll_view.addSubview(left_view)

                left_view.addSubview(info_label)

                let tap_recognizer_left_view = UITapGestureRecognizer(target: self, action: "tap_action")
                left_view.addGestureRecognizer(tap_recognizer_left_view)

                let tap_recognizer_2d = UITapGestureRecognizer(target: self, action: "tap_action")
                values_2d_plot.addGestureRecognizer(tap_recognizer_2d)

                let tap_recognizer_3d = UITapGestureRecognizer(target: self, action: "tap_action")
                values_3d_plot.addGestureRecognizer(tap_recognizer_3d)

                let tap_recognizer_table_view = UITapGestureRecognizer(target: self, action: "tap_action_table_view")
                tap_recognizer_table_view.cancelsTouchesInView = false
                table_view.addGestureRecognizer(tap_recognizer_table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                scroll_view.frame = view.bounds

                width = view.frame.width
                let height = view.frame.height

                width_right = min(300, width - 100)
                width_left = max(width - width_right, min(width, height))
                scroll_view.contentSize = CGSize(width: width_left + width_right, height: height)
                scroll_view.contentOffset = CGPoint(x: width_left + width_right - width, y: 0)

                info_label.sizeToFit()
                info_label.frame = CGRect(x: 0, y: (height - info_label.frame.height) / 2, width: width_left, height: info_label.frame.height)

                left_view.frame = CGRect(x: 0, y: 0, width: width_left, height: height)

                values_2d_plot.frame = CGRect(x: 0, y: 0, width: width_left, height: height)

                values_3d_plot.frame = CGRect(x: 0, y: 0, width: width_left, height: height)

                let origin_y = 0 as CGFloat
                table_view.frame = CGRect(x: width_left, y: origin_y, width: width_right, height: height - origin_y)
        }

        func scroll_left_right() {
                let spacing = width_left + width_right - width
                if spacing > 0 {
                        let content_offset_x = scroll_view.contentOffset.x
                        if content_offset_x > spacing / 2 {
                                scroll_view.contentOffset = CGPoint.zero
                        } else {
                                scroll_view.contentOffset = CGPoint(x: spacing, y: 0)
                        }
                }
        }

        override func render() {
                multiple_molecule_plot_state = state.page_state as! MultipleMoleculePlotState

                update_plot()
                table_view.dataSource = self
                table_view.delegate = self
                table_view.reloadData()
        }

        func render_after_factor_change() {
                multiple_molecule_plot_state.calculate_levels_and_colors()
                table_view.reloadData()
                update_plot()
        }

        func render_after_molecule_change() {
                table_view.reloadData()
                update_plot()
        }

        func update_plot() {
                if multiple_molecule_plot_state.dimension == 2 {
                        update_2d_plot()
                } else {
                        update_3d_plot()
                }
        }

        func update_2d_plot() {
                values_3d_plot.hidden = true
                if state.number_of_molecules >= 2 {
                        let (names, colors, points_x, points_y, axis_titles) = multiple_molecule_plot_state.points_2d()
                        let names_or_nil = (multiple_molecule_plot_state.plot_symbol == "circles" ? nil : names) as [String]?

                        values_2d_plot.update(points_x: points_x, points_y: points_y, names: names_or_nil, colors: colors, axis_titles: axis_titles, symbol_size: multiple_molecule_plot_state.symbol_size)
                        values_2d_plot.hidden = false
                        left_view.hidden = true
                } else {
                        values_2d_plot.hidden = true
                        left_view.hidden = false
                        info_label.attributedText = astring_body(string: "There are less than 2 molecules")
                        info_label.textAlignment = .Center
                }
                view.setNeedsLayout()
        }

        func update_3d_plot() {
                values_2d_plot.hidden = true
                if state.number_of_molecules >= 3 {
                        let (names, colors, points_x, points_y, points_z, axis_titles) = multiple_molecule_plot_state.points_3d()
                        values_3d_plot.update(points_x: points_x, points_y: points_y, points_z: points_z, names: names, plot_symbol: multiple_molecule_plot_state.plot_symbol, colors: colors, axis_titles: axis_titles, symbol_size: multiple_molecule_plot_state.symbol_size)
                        values_3d_plot.hidden = false
                        left_view.hidden = true
                } else {
                        values_3d_plot.hidden = true
                        left_view.hidden = false
                        info_label.attributedText = astring_body(string: "There are less than 3 molecules")
                        info_label.textAlignment = .Center
                }
                view.setNeedsLayout()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 7
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView
                switch section {
                case 0:
                        header.update_normal(text: "Number of dimensions")
                case 1:
                        header.update_normal(text: "Plot symbol")
                case 2:
                        header.update_normal(text: "Plot symbol size")
                case 3:
                        header.update_normal(text: "Select a factor for colors")
                case 4:
                        header.update_normal(text: "Color scheme")
                case 5:
                        header.update_normal(text: "Search molecules")
                default:
                        let number_of_molecules = multiple_molecule_plot_state.dimension == 2 ? "two" : "three"
                        header.update_normal(text: "Select \(number_of_molecules) molecules")
                }
                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                switch section {
                case let section where section < 3:
                        return 1
                case 3:
                        return state.factor_ids.count
                case 4:
                        return multiple_molecule_plot_state.level_names.count
                case 5:
                        return 1
                default:
                        return multiple_molecule_plot_state.filtered_indices.count
                }
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                switch indexPath.section {
                case 0, 1:
                        return segmented_control_table_view_cell_height
                default:
                        return centered_table_view_cell_height
                }
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let section = indexPath.section
                let row = indexPath.row

                switch section {
                case 0:
                        let cell = tableView.dequeueReusableCellWithIdentifier("segmented_control_cell") as! SegmentedControlTableViewCell
                        cell.update(items: ["2D", "3D"], selected_segment_index: multiple_molecule_plot_state.dimension == 2 ? 0 : 1, target: self, selector: "dimension_action:")
                        return cell
                case 1:
                        let cell = tableView.dequeueReusableCellWithIdentifier("segmented_control_cell") as! SegmentedControlTableViewCell
                        cell.update(items: ["Circles", "Sample names"], selected_segment_index: multiple_molecule_plot_state.plot_symbol == "circles" ? 0 : 1, target: self, selector: "plot_symbol_action:")
                        return cell
                case 2:
                        let cell = tableView.dequeueReusableCellWithIdentifier("slider_cell") as! SliderTableViewCell
                        cell.update(minimum_value: 0, maximum_value: 1, value: multiple_molecule_plot_state.symbol_size, target: self, selector: "plot_symbol_size_action:")
                        return cell
                case 3:
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered_cell") as! CenteredTableViewCell
                        let text = state.factor_names[row]
                        if state.factor_ids[row] == multiple_molecule_plot_state.selected_factor_id {
                                cell.update_selected_checkmark(text: text)
                        } else {
                                cell.update_unselected(text: text)
                        }
                        return cell
                case 4:
                        let cell = tableView.dequeueReusableCellWithIdentifier("color_selection_cell", forIndexPath: indexPath) as! ColorSelectionTableViewCell
                        let level_name = multiple_molecule_plot_state.level_names[row]
                        let level_color = color_from_hex(hex: multiple_molecule_plot_state.level_colors[row])
                        cell.update(text: level_name, color: level_color)
                        return cell
                case 5:
                        let cell = tableView.dequeueReusableCellWithIdentifier("search_bar_cell") as! SearchTableViewCell
                        search_bar = cell.search_bar
                        search_bar?.text = multiple_molecule_plot_state.search_string
                        search_bar?.delegate = self
                        return cell
                default:
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered_cell") as! CenteredTableViewCell
                        let (text, number) = multiple_molecule_plot_state.content_for_cell(row: row)
                        if let number = number {
                                cell.update_selected_number(text: text, number: number)
                        } else {
                                cell.update_unselected(text: text)
                        }
                        return cell
                }
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let row = indexPath.row

                if indexPath.section == 3 {
                        let factor_id = state.factor_ids[row]
                        if multiple_molecule_plot_state.selected_factor_id == factor_id {
                                multiple_molecule_plot_state.selected_factor_id = nil
                        } else {
                                multiple_molecule_plot_state.selected_factor_id = factor_id
                        }
                        render_after_factor_change()
                } else if indexPath.section == 6 {
                        if multiple_molecule_plot_state.select_row(row: row) {
                                render_after_molecule_change()
                        }
                }
        }

        func dimension_action(sender: UISegmentedControl) {
                let dimension = sender.selectedSegmentIndex == 0 ? 2 : 3
                multiple_molecule_plot_state.set_dimension(dimension: dimension)
                state.render()
        }

        func plot_symbol_action(sender: UISegmentedControl) {
                multiple_molecule_plot_state.plot_symbol = sender.selectedSegmentIndex == 0 ? "circles" : "sample names"
                state.render()
        }

        func plot_symbol_size_action(sender: UISlider) {
                multiple_molecule_plot_state.symbol_size = Double(sender.value)
                update_plot()
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {
                multiple_molecule_plot_state.zoom_scale_2d = zoom_scale
        }

        func tap_action() {
                search_bar?.resignFirstResponder()
                scroll_left_right()
        }

        func tap_action_table_view() {
                search_bar?.resignFirstResponder()
        }

        func searchBarSearchButtonClicked(searchBar: UISearchBar) {
                searchBar.resignFirstResponder()
        }

        func searchBarTextDidEndEditing(searchBar: UISearchBar) {
                let search_string = searchBar.text ?? ""
                multiple_molecule_plot_state.perform_search(search_string: search_string)
                table_view.reloadData()
        }

        func pdf_action() {
                let file_name_stem = "multiple-molecule-2d"
                let description = "Plot of samples for two molecules."
                state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: values_2d_plot.content_size, draw: values_2d_plot.draw)
                state.render()
        }
        
        func png_action() {
                let file_name_stem = "multiple-molecule-3d"
                let image = values_3d_plot.snapshot()
                if let file_data = UIImagePNGRepresentation(image) {
                        state.insert_png_result_file(file_name_stem: file_name_stem, file_data: file_data)
                        state.render()
                }
        }
}
