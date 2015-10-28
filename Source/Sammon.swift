import UIKit

class SammonState: PageState {

        var sammon_points = [] as [Double]
        var number_of_molecules_without_missing_values = 0

        var selected_samples = [] as [Bool]
        var selected_factor_index: Int?
        var dimension = 2
        var plot_symbol = "circles"
        var symbol_size = 0.5 as Double

        var sample_indices = [] as [Int]
        var sample_names = [] as [String]
        var sample_colors = [] as [UIColor]

        var level_names = [] as [String]
        var level_colors = [] as [String]

        var zoom_scale_2d = 1 as CGFloat

        override init() {
                super.init()
                name = "sammon"
                title = astring_body(string: "Sammon map")
                info = "2D and 3D Sammon projections.\n\nTap the plot to show and hide the control panel on narrow screens.\n\nThe Sammon projection is performed for the selected samples using the molecules that have no missing values for those samples.\n\nThe colors represent levels for the selected factor."

                full_screen = .Full
                prepared = false
        }

        override func prepare() {
                set_dimension(dimension: dimension)
                selected_samples = [Bool](count: state.number_of_samples, repeatedValue: true)
                calculate_samples_and_levels()
                calculate_sammon_map()

                prepared = true
        }

        func set_dimension(dimension dimension: Int) {
                pdf_enabled = dimension == 2
                png_enabled = dimension == 3
                self.dimension = dimension
        }

        func calculate_samples_and_levels() {
                sample_indices = []
                sample_names = []
                for i in 0 ..< state.number_of_samples {
                        if selected_samples[i] {
                                sample_indices.append(i)
                                sample_names.append(state.sample_names[i])
                        }
                }

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
        }
        
        func calculate_sammon_map() {
                sammon_points = [Double](count: dimension * sample_indices.count, repeatedValue: 0.0)
                number_of_molecules_without_missing_values = sammon_map(state.values, state.number_of_molecules, state.number_of_samples, sample_indices, sample_indices.count, dimension, &sammon_points)
        }
}

class Sammon: Component, UITableViewDataSource, UITableViewDelegate, PCA2dDelegate, SelectAllHeaderFooterViewDelegate {

        var sammon_state: SammonState!

        let scroll_view = UIScrollView()
        let left_view = UIView()
        let values_2d_plot = Values2DPlot()
        let pca3d_plot = PCA3dPlot(frame: CGRect.zero)
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

                values_2d_plot.maximum_zoom_scale_multiplier = 5
                scroll_view.addSubview(values_2d_plot)
                scroll_view.addSubview(pca3d_plot)

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "centered-header")
                table_view.registerClass(SelectAllHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "select-all-header")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "centered_cell")
                table_view.registerClass(SegmentedControlTableViewCell.self, forCellReuseIdentifier: "segmented_control_cell")
                table_view.registerClass(SliderTableViewCell.self, forCellReuseIdentifier: "slider_cell")
                table_view.registerClass(ColorSelectionTableViewCell.self, forCellReuseIdentifier: "color_selection_cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                scroll_view.addSubview(table_view)

                scroll_view.addSubview(left_view)

                info_label.attributedText = astring_body(string: "Calculating PCA")
                info_label.sizeToFit()
                info_label.textAlignment = .Center
                left_view.addSubview(info_label)

                let tap_recognizer_left_view = UITapGestureRecognizer(target: self, action: "tap_action")
                tap_recognizer_left_view.numberOfTapsRequired = 1
                left_view.addGestureRecognizer(tap_recognizer_left_view)

                let tap_recognizer_2d = UITapGestureRecognizer(target: self, action: "tap_action")
                tap_recognizer_2d.numberOfTapsRequired = 1
                values_2d_plot.addGestureRecognizer(tap_recognizer_2d)

                let tap_recognizer_3d = UITapGestureRecognizer(target: self, action: "tap_action")
                tap_recognizer_3d.numberOfTapsRequired = 1
                pca3d_plot.addGestureRecognizer(tap_recognizer_3d)
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

                info_label.frame = CGRect(x: 0, y: (height - info_label.frame.height) / 2, width: width_left, height: info_label.frame.height)

                left_view.frame = CGRect(x: 0, y: 0, width: width_left, height: height)

                values_2d_plot.frame = CGRect(x: 0, y: 0, width: width_left, height: height)

//                if let pca_2d_drawer = pca_2d_drawer {
//                        min_zoom = min(width_left, height) / pca_2d_drawer.content_size.height
//                        pca_2d_drawer.minimum_zoom_scale = max(1, min_zoom)
//                        pca_2d_drawer.maximum_zoom_scale = max(2, 20 * pca_2d_drawer.minimum_zoom_scale)
//
//                        tiled_scroll_view.scroll_view.zoomScale = sammon_state.zoom_scale_2d
//                }

                pca3d_plot.frame = CGRect(x: 0, y: 0, width: width_left, height: height)

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
                sammon_state = state.page_state as! SammonState

                update_pca_plot()
                table_view.dataSource = self
                table_view.delegate = self
                table_view.reloadData()
        }

        func render_after_sample_change() {
                sammon_state.calculate_samples_and_levels()
                values_2d_plot.hidden = true
                pca3d_plot.hidden = true
                info_label.hidden = false
                info_label.attributedText = astring_body(string: "Calculating PCA")
                info_label.textAlignment = .Center
                table_view.reloadData()
                NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "render_after_sample_change_timer", userInfo: nil, repeats: false)
        }

        func render_after_sample_change_timer() {
                sammon_state.calculate_sammon_map()
                table_view.reloadData()
                update_pca_plot()
        }

        func render_after_factor_change() {
                sammon_state.calculate_samples_and_levels()
                table_view.reloadData()
                update_pca_plot()
        }

        func update_pca_plot() {
                if sammon_state.dimension == 2 {
                        update_2d_plot()
                } else {
                        update_3d_plot()
                }
        }

        func update_2d_plot() {
                pca3d_plot.hidden = true
                if sammon_state.number_of_molecules_without_missing_values > 0 && sammon_state.sample_indices.count >= 3 {
                        let points_x = [Double](sammon_state.sammon_points[0 ..< sammon_state.sample_indices.count])
                        let points_y = [Double](sammon_state.sammon_points[sammon_state.sample_indices.count ..< 2 * sammon_state.sample_indices.count])
                        let axis_titles = ["", ""]
                        let names = sammon_state.plot_symbol == "circles" ? (nil as [String]?) : sammon_state.sample_names
                        values_2d_plot.update(points_x: points_x, points_y: points_y, names: names, colors: sammon_state.sample_colors, axis_titles: axis_titles, symbol_size: sammon_state.symbol_size)
                        values_2d_plot.hidden = false
                        left_view.hidden = true
                } else {
                        values_2d_plot.hidden = true
                        left_view.hidden = false
                        if sammon_state.sample_indices.count < 3 {
                                info_label.attributedText = astring_body(string: "There are too few samples")
                        } else {
                                info_label.attributedText = astring_body(string: "There are no molecules without missing values")
                        }
                        info_label.textAlignment = .Center
                }
                view.setNeedsLayout()
        }

        func update_3d_plot() {
                values_2d_plot.hidden = true
                if sammon_state.number_of_molecules_without_missing_values > 0 && sammon_state.sample_indices.count >= 3 {
                        let points_x = [Double](sammon_state.sammon_points[0 ..< sammon_state.sample_indices.count])
                        let points_y = [Double](sammon_state.sammon_points[sammon_state.sample_indices.count ..< 2 * sammon_state.sample_indices.count])
                        let points_z = [Double](sammon_state.sammon_points[2 * sammon_state.sample_indices.count ..< 3 * sammon_state.sample_indices.count])
                        let axis_titles = ["", "", ""]
                        let names = sammon_state.sample_names
                        pca3d_plot.update(points_x: points_x, points_y: points_y, points_z: points_z, names: names, plot_symbol: sammon_state.plot_symbol, colors: sammon_state.sample_colors, axis_titles: axis_titles, symbol_size: sammon_state.symbol_size)
                        pca3d_plot.hidden = false
                        left_view.hidden = true
                } else {
                        pca3d_plot.hidden = true
                        left_view.hidden = false
                        if sammon_state.sample_indices.count < 3 {
                                info_label.attributedText = astring_body(string: "There are too few samples")
                        } else {
                                info_label.attributedText = astring_body(string: "There are no molecules without missing values")
                        }
                        info_label.textAlignment = .Center
                }
                view.setNeedsLayout()
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
                                header.update_normal(text: "Dimension")
                        case 1:
                                header.update_normal(text: "Plot symbol")
                        case 2:
                                header.update_normal(text: "Plot symbol size")
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
                        return sammon_state.level_names.count
                default:
                        return state.number_of_samples
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
                        cell.update(items: ["2D", "3D"], selected_segment_index: sammon_state.dimension == 2 ? 0 : 1, target: self, selector: "dimension_action:")
                        return cell
                case 1:
                        let cell = tableView.dequeueReusableCellWithIdentifier("segmented_control_cell") as! SegmentedControlTableViewCell
                        cell.update(items: ["Circles", "Sample names"], selected_segment_index: sammon_state.plot_symbol == "circles" ? 0 : 1, target: self, selector: "plot_symbol_action:")
                        return cell
                case 2:
                        let cell = tableView.dequeueReusableCellWithIdentifier("slider_cell") as! SliderTableViewCell
                        cell.update(minimum_value: 0, maximum_value: 1, value: sammon_state.symbol_size, target: self, selector: "plot_symbol_size_action:")
                        return cell
                case 3:
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered_cell") as! CenteredTableViewCell
                        let text = state.factor_names[row]
                        if row == sammon_state.selected_factor_index {
                                cell.update_selected_checkmark(text: text)
                        } else {
                                cell.update_unselected(text: text)
                        }
                        return cell
                case 4:
                        let cell = tableView.dequeueReusableCellWithIdentifier("color_selection_cell", forIndexPath: indexPath) as! ColorSelectionTableViewCell
                        let level_name = sammon_state.level_names[row]
                        let level_color = color_from_hex(hex: sammon_state.level_colors[row])
                        cell.update(text: level_name, color: level_color)
                        return cell
                default:
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered_cell") as! CenteredTableViewCell
                        let text = state.sample_names[row]
                        if sammon_state.selected_samples[row] {
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
                        if sammon_state.selected_factor_index == row {
                                sammon_state.selected_factor_index = nil
                        } else {
                                sammon_state.selected_factor_index = row
                        }
                        render_after_factor_change()
                } else if indexPath.section == 5 {
                        sammon_state.selected_samples[row] = !sammon_state.selected_samples[row]
                        render_after_sample_change()
                }
        }

        func dimension_action(sender: UISegmentedControl) {
                let dimension = sender.selectedSegmentIndex == 0 ? 2 : 3
                sammon_state.set_dimension(dimension: dimension)
                sammon_state.calculate_sammon_map()
                state.render()
        }

        func plot_symbol_action(sender: UISegmentedControl) {
                sammon_state.plot_symbol = sender.selectedSegmentIndex == 0 ? "circles" : "sample names"
                state.render()
        }

        func plot_symbol_size_action(sender: UISlider) {
                sammon_state.symbol_size = Double(sender.value)
                update_pca_plot()
        }

        func select_all_action(tag tag: Int) {
                for i in 0 ..< sammon_state.selected_samples.count {
                        sammon_state.selected_samples[i] = true
                }
                render_after_sample_change()
        }

        func deselect_all_action(tag tag: Int) {
                for i in 0 ..< sammon_state.selected_samples.count {
                        sammon_state.selected_samples[i] = false
                }
                render_after_sample_change()
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {
                sammon_state.zoom_scale_2d = zoom_scale
        }

        func tap_action() {
                scroll_left_right()
        }

        func pdf_action() {
                let file_name_stem = "sammon-map-2d"
                let description = "2D Sammon map of samples."
                state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: values_2d_plot.content_size, draw: values_2d_plot.draw)
                state.render()
        }
        
        func png_action() {
                let file_name_stem = "sammon-map-3d"
                let image = pca3d_plot.snapshot()
                if let file_data = UIImagePNGRepresentation(image) {
                        state.insert_png_result_file(file_name_stem: file_name_stem, file_data: file_data)
                        state.render()
                }
        }
}
