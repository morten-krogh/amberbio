import UIKit

class SOMState: PageState {

        var sammon_points = [] as [Double]
        var number_of_molecules_without_missing_values = 0

        var number_of_rows = 10
        var number_of_columns = 10

        var selected_samples = [] as [Bool]
        var selected_factor_index: Int?
        var plot_symbol = "circles"

        var sample_indices = [] as [Int]
        var sample_names = [] as [String]
        var sample_colors = [] as [UIColor]

        var level_names = [] as [String]
        var level_colors = [] as [String]

        override init() {
                super.init()
                name = "som"
                title = astring_body(string: "Self organizing map")
                info = "Kohonen self organizing map.\n\nTap the plot to show and hide the control panel on narrow screens.\n\nThe Self organzing map is computed for the selected samples using the molecules that have no missing values for those samples.\n\nThe colors represent levels for the selected factor.\n\nSee the manual for a description of the self organizing map."

                pdf_enabled = true
                full_screen = .Conditional
                prepared = false
        }

        override func prepare() {
                selected_samples = [Bool](count: state.number_of_samples, repeatedValue: true)
                calculate_samples()
                calculate_levels()
                calculate_som_weights()
                calculate_som_nodes()

                prepared = true
        }

        func set_number_of_rows(number_of_rows number_of_rows: Int) {
                self.number_of_rows = number_of_rows
                calculate_som_weights()
                calculate_som_nodes()
        }

        func set_number_of_columns(number_of_columns number_of_columns: Int) {
                self.number_of_columns = number_of_columns
                calculate_som_weights()
                calculate_som_nodes()
        }

        func calculate_samples() {
                sample_indices = []
                sample_names = []
                for i in 0 ..< state.number_of_samples {
                        if selected_samples[i] {
                                sample_indices.append(i)
                                sample_names.append(state.sample_names[i])
                        }
                }
                calculate_som_weights()
                calculate_levels()
        }

        func calculate_levels() {
                if let factor_index = selected_factor_index {
                        level_names = state.level_names_by_factor[factor_index]
                        level_colors = state.level_colors_by_factor[factor_index]

                        sample_colors = []
                        for index in sample_indices {
                                sample_colors.append(color_from_hex(hex: state.level_colors_by_factor_and_sample[factor_index][index]))
                        }
                } else {
                        level_names = []
                        level_colors = []
                        sample_colors = [UIColor](count: sample_indices.count, repeatedValue: color_blue_circle_color)
                }
                calculate_som_nodes()
        }

        func calculate_som_weights() {

        }

        func calculate_som_nodes() {

        }
}

class SOM: Component, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SelectAllHeaderFooterViewDelegate {

        var som_state: SOMState!

        let scroll_view = UIScrollView()
        let left_view = UIView()
        let som_plot = Values2DPlot()
        let table_view = UITableView()
        let info_label = UILabel()

        var min_zoom = 1 as CGFloat

        var width = 0 as CGFloat
        var width_right = 300 as CGFloat
        var width_left = 0 as CGFloat

        override func viewDidLoad() {
                super.viewDidLoad()

                scroll_view.scrollEnabled = false
                view.addSubview(scroll_view)

                som_plot.maximum_zoom_scale_multiplier = 50
                scroll_view.addSubview(som_plot)

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "centered-header")
                table_view.registerClass(SelectAllHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "select-all-header")
                table_view.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "text_field_table_view_cell")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "centered_cell")
                table_view.registerClass(SegmentedControlTableViewCell.self, forCellReuseIdentifier: "segmented_control_cell")
                table_view.registerClass(SliderTableViewCell.self, forCellReuseIdentifier: "slider_cell")
                table_view.registerClass(ColorSelectionTableViewCell.self, forCellReuseIdentifier: "color_selection_cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                scroll_view.addSubview(table_view)

                scroll_view.addSubview(left_view)

                info_label.text = "Calculating"
                info_label.font = UIFont(name: font_body.fontName, size: 22)
                info_label.textAlignment = .Center
                left_view.addSubview(info_label)

                let tap_recognizer_left_view = UITapGestureRecognizer(target: self, action: "tap_action")
                left_view.addGestureRecognizer(tap_recognizer_left_view)

                let tap_recognizer_som = UITapGestureRecognizer(target: self, action: "tap_action")
                som_plot.addGestureRecognizer(tap_recognizer_som)
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

                left_view.frame = CGRect(x: 0, y: 0, width: width_left, height: height)
                info_label.frame = CGRect(x: 0, y: 0, width: width_left, height: height)

                som_plot.frame = CGRect(x: 0, y: 0, width: width_left, height: height)

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
                som_state = state.page_state as! SOMState

                update_som_plot()
                table_view.dataSource = self
                table_view.delegate = self
                table_view.reloadData()
        }

        func render_after_sample_and_dimension_change() {
//                som_state.calculate_samples_and_levels()
//                values_2d_plot.hidden = true
//                values_3d_plot.hidden = true
//                left_view.hidden = state.number_of_samples < 200
//                info_label.text = "Calculating"
//                table_view.reloadData()
//                NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "render_after_sample_change_timer", userInfo: nil, repeats: false)
        }

        func render_after_sample_change_timer() {
//                som_state.calculate_sammon_map()
                state.render()
        }

        func render_after_factor_change() {
//                som_state.calculate_samples_and_levels()
                table_view.reloadData()
                update_som_plot()
        }

        func update_som_plot() {
//                if som_state.number_of_molecules_without_missing_values > 0 && som_state.sample_indices.count >= 3 {
//                        let points_x = [Double](som_state.sammon_points[0 ..< som_state.sample_indices.count])
//                        let points_y = [Double](som_state.sammon_points[som_state.sample_indices.count ..< 2 * som_state.sample_indices.count])
//                        let axis_titles = ["", ""]
//                        let names = som_state.plot_symbol == "circles" ? (nil as [String]?) : som_state.sample_names

//                        values_2d_plot.update(points_x: points_x, points_y: points_y, names: names, colors: som_state.sample_colors, axis_titles: axis_titles, symbol_size: som_state.symbol_size)
//                        values_2d_plot.hidden = false
//                        left_view.hidden = true
//                } else {
//                        values_2d_plot.hidden = true
//                        left_view.hidden = false
//                        if som_state.sample_indices.count < 3 {
//                                info_label.text = "There are too few samples"
//                        } else {
//                                info_label.text = "There are no molecules without missing values"
//                        }
//                }
//                view.setNeedsLayout()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 6
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return section == 5 ? select_all_header_footer_view_height : centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                if section < 5 {
                        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("centered-header") as! CenteredHeaderFooterView
                        switch section {
                        case 0:
                                header.update_normal(text: "Number of rows")
                        case 1:
                                header.update_normal(text: "Number of columns")
                        case 2:
                                header.update_normal(text: "Plot symbol")
                        case 3:
                                header.update_normal(text: "Factor for colors")
                        default:
                                header.update_normal(text: "Color scheme")
                        }
                        return header
                } else {
                        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("select-all-header") as! SelectAllHeaderFooterView
                        let text = "Samples"
                        header.update(text: text, tag: 0, delegate: self)
                        return header
                }
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                switch section {
                case let section where section < 3:
                        return 1
                case 3:
                        return state.factor_ids.count
                case 4:
                        return som_state.level_names.count
                default:
                        return state.number_of_samples
                }
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                switch indexPath.section {
                case 0, 1:
                        return text_field_table_view_cell_height
                case 2:
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
                        let cell = tableView.dequeueReusableCellWithIdentifier("text_field_table_view_cell") as! TextFieldTableViewCell
                        cell.update(text: "\(som_state.number_of_rows)", tag: 0, delegate: self)
                        return cell
                case 1:
                        let cell = tableView.dequeueReusableCellWithIdentifier("text_field_table_view_cell") as! TextFieldTableViewCell
                        cell.update(text: "\(som_state.number_of_rows)", tag: 1, delegate: self)
                        return cell
                case 2:
                        let cell = tableView.dequeueReusableCellWithIdentifier("segmented_control_cell") as! SegmentedControlTableViewCell
                        cell.update(items: ["Circles", "Sample names"], selected_segment_index: som_state.plot_symbol == "circles" ? 0 : 1, target: self, selector: "plot_symbol_action:")
                        return cell
                case 3:
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered_cell") as! CenteredTableViewCell
                        let text = state.factor_names[row]
                        if row == som_state.selected_factor_index {
                                cell.update_selected_checkmark(text: text)
                        } else {
                                cell.update_unselected(text: text)
                        }
                        return cell
                case 4:
                        let cell = tableView.dequeueReusableCellWithIdentifier("color_selection_cell", forIndexPath: indexPath) as! ColorSelectionTableViewCell
                        let level_name = som_state.level_names[row]
                        let level_color = color_from_hex(hex: som_state.level_colors[row])
                        cell.update(text: level_name, color: level_color)
                        return cell
                default:
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered_cell") as! CenteredTableViewCell
                        let text = state.sample_names[row]
                        if som_state.selected_samples[row] {
                                cell.update_selected_checkmark(text: text)
                        } else {
                                cell.update_unselected(text: text)
                        }
                        return cell
                }
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let row = indexPath.row

                if indexPath.section == 3 {
                        if som_state.selected_factor_index == row {
                                som_state.selected_factor_index = nil
                        } else {
                                som_state.selected_factor_index = row
                        }
                        render_after_factor_change()
                } else if indexPath.section == 5 {
                        som_state.selected_samples[row] = !som_state.selected_samples[row]
                        render_after_sample_and_dimension_change()
                }
        }

        func plot_symbol_action(sender: UISegmentedControl) {
                som_state.plot_symbol = sender.selectedSegmentIndex == 0 ? "circles" : "sample names"
                state.render()
        }

        func select_all_action(tag tag: Int) {
                for i in 0 ..< som_state.selected_samples.count {
                        som_state.selected_samples[i] = true
                }
                render_after_sample_and_dimension_change()
        }

        func deselect_all_action(tag tag: Int) {
                for i in 0 ..< som_state.selected_samples.count {
                        som_state.selected_samples[i] = false
                }
                render_after_sample_and_dimension_change()
        }

        func tap_action() {
                scroll_left_right()
        }

        func pdf_action() {
                let file_name_stem = "self-organizing-map"
                let description = "Kohonen self organizng map. Samples are assigned to the nearest unit."
                state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: som_plot.content_size, draw: som_plot.draw)
                state.render()
        }
}
