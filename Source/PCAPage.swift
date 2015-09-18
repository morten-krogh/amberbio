import UIKit

class PCAState: PageState {

        var selected_samples = [] as [Bool]
        var selected_factor_id: Int?
        var dimension = 3
        var plot_symbol = "circles"
        var symbol_size = 0.5 as Double

        var selected_sample_indices = [] as [Int]
        var selected_sample_names = [] as [String]
        var selected_sample_colors = [] as [UIColor]

        var component_matrix = [] as [[Double]]
        var variances = [] as [Double]

        var level_names = [] as [String]
        var level_colors = [] as [String]

        let maximum_number_of_components = 5
        var number_of_components = 0
        var selected_components = [0, 1, 2]
        var pca_2d_zoom_scale = 1 as CGFloat

        override init() {
                super.init()
                name = "pca"
                title = astring_body(string: "PCA")
                info = "Principal component analysis(PCA).\n\nTap the pca plot to show and hide the control panel on narrow screens.\n\nThe PCA is performed for the selected samples using the molecules that have no missing values for those samples.\n\nThe colors represent levels for the selected factor.\n\nSelect the number of dimensions and the principal components to show in the plot.\n\nThe number after a principal component(PC) is the fraction of the total variance explained by that component."

                full_screen = true
                prepared = false
        }

        override func prepare() {
                selected_samples = [Bool](count: state.number_of_samples, repeatedValue: true)

                calculate_selected_sample_indices()
                calculate_levels_and_colors()
                calculate_pca_components()
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

        func calculate_pca_components() {
                (component_matrix, variances) = pca_main(values: state.values, number_of_molecules: state.number_of_molecules, number_of_components: maximum_number_of_components, sample_indices: selected_sample_indices)

                number_of_components = component_matrix.count
                if !selected_components.filter({ $0 >= number_of_components }).isEmpty {
                        selected_components = dimension == 2 ? [0, 1] : [0, 1, 2]
                }
        }

        func set_dimension(dimension dimension: Int) {
                if dimension == 2 {
                        pdf_enabled = number_of_components >= 2
                        png_enabled = false
                        selected_components = [0, 1]
                } else {
                        pdf_enabled = false
                        png_enabled = number_of_components >= 3
                        selected_components = [0, 1, 2]
                }

                self.dimension = dimension
        }

        func text_number_for_component(index index: Int) -> (text: String, number: Int?) {
                let variance = decimal_string(number: variances[index], fraction_digits: 2)
                let text = "PC\(index + 1) - \(variance)"
                var number = nil as Int?
                if selected_components[0] == index {
                        number = 1
                } else if selected_components[1] == index {
                        number = 2
                } else if dimension == 3 && selected_components[2] == index {
                        number = 3
                }
                return (text, number)
        }
}

class PCA: Component, UITableViewDataSource, UITableViewDelegate, PCA2dDelegate, SelectAllHeaderFooterViewDelegate {

        var pca_state: PCAState!

        let scroll_view = UIScrollView()
        let tiled_scroll_view = TiledScrollView()
        let left_view = UIView()
        let pca3d_plot = PCA3dPlot(frame: CGRect.zero)
        var pca_2d_drawer: PCA2dPlot?
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

                scroll_view.addSubview(tiled_scroll_view)
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

                if let pca_2d_drawer = pca_2d_drawer {
                        min_zoom = min(width_left, height) / pca_2d_drawer.content_size.height
                        pca_2d_drawer.minimum_zoom_scale = max(1, min_zoom)
                        pca_2d_drawer.maximum_zoom_scale = max(2, 20 * pca_2d_drawer.minimum_zoom_scale)
                        tiled_scroll_view.frame = CGRect(x: 0, y: 0, width: width_left, height: height)
                        tiled_scroll_view.scroll_view.zoomScale = pca_state.pca_2d_zoom_scale
                }

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
                pca_state = state.page_state as! PCAState

                update_pca_plot()
                table_view.dataSource = self
                table_view.delegate = self
                table_view.reloadData()
        }

        func render_after_sample_change() {
                pca_state.calculate_selected_sample_indices()
                pca_state.calculate_levels_and_colors()
                tiled_scroll_view.hidden = true
                pca3d_plot.hidden = true
                info_label.hidden = false
                info_label.attributedText = astring_body(string: "Calculating PCA")
                info_label.textAlignment = .Center
                table_view.reloadData()
                NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "render_after_sample_change_timer", userInfo: nil, repeats: false)
        }

        func render_after_sample_change_timer() {
                pca_state.calculate_pca_components()
                table_view.reloadData()
                update_pca_plot()
        }

        func render_after_factor_change() {
                pca_state.calculate_levels_and_colors()
                update_pca_plot()
                table_view.reloadData()
        }

        func render_after_components_change() {
                update_pca_plot()
                table_view.reloadData()
        }

        func update_pca_plot() {
                if pca_state.dimension == 2 {
                        update_pca2d_plot()
                } else {
                        update_pca3d_plot()
                }
        }

        func update_pca2d_plot() {
                pca3d_plot.hidden = true
                let ordered_components = pca_state.selected_components.sort()
                let axis_titles = ["PC\(ordered_components[0] + 1)", "PC\(ordered_components[1] + 1)"]
                if pca_state.number_of_components >= 2 {
                        let points_x = pca_state.component_matrix[ordered_components[0]]
                        let points_y = pca_state.component_matrix[ordered_components[1]]
                        let names = pca_state.plot_symbol == "circles" ? (nil as [String]?) : pca_state.selected_sample_names
                        let pca_2d_drawer = PCA2dPlot()
                        pca_2d_drawer.delegate = self
                        pca_2d_drawer.update(points_x: points_x, points_y: points_y, names: names, colors: pca_state.selected_sample_colors, axis_titles: axis_titles, symbol_size: pca_state.symbol_size)
                        pca_2d_drawer.minimum_zoom_scale = max(1, min_zoom)
                        pca_2d_drawer.maximum_zoom_scale = 3 * pca_2d_drawer.minimum_zoom_scale
                        self.pca_2d_drawer = pca_2d_drawer
                        tiled_scroll_view.delegate = pca_2d_drawer
                        tiled_scroll_view.scroll_view.zoomScale = pca_state.pca_2d_zoom_scale
                        tiled_scroll_view.hidden = false
                        left_view.hidden = true
                } else {
                        tiled_scroll_view.hidden = true
                        left_view.hidden = false
                        info_label.attributedText = astring_body(string: "There are less than 2 principal components")
                        info_label.textAlignment = .Center
                }
                view.setNeedsLayout()
        }

        func update_pca3d_plot() {
                tiled_scroll_view.hidden = true
                if pca_state.number_of_components >= 3 {
                        let ordered_components = pca_state.selected_components.sort()
                        let axis_titles = ["PC\(ordered_components[0] + 1)", "PC\(ordered_components[1] + 1)", "PC\(ordered_components[2] + 1)"]
                        let points_x = pca_state.component_matrix[ordered_components[0]]
                        let points_y = pca_state.component_matrix[ordered_components[1]]
                        let points_z = pca_state.component_matrix[ordered_components[2]]
                        let names = pca_state.selected_sample_names
                        pca3d_plot.update(points_x: points_x, points_y: points_y, points_z: points_z, names: names, plot_symbol: pca_state.plot_symbol, colors: pca_state.selected_sample_colors, axis_titles: axis_titles, symbol_size: pca_state.symbol_size)
                        pca3d_plot.hidden = false
                        left_view.hidden = true
                } else {
                        pca3d_plot.hidden = true
                        left_view.hidden = false
                        info_label.attributedText = astring_body(string: "There are less than 3 principal components")
                        info_label.textAlignment = .Center
                }
                view.setNeedsLayout()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 7
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return section == 6 ? select_all_header_footer_view_height : centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                if section < 6 {
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
                        case 4:
                                header.update_normal(text: "Color scheme")
                        default:
                                header.update_normal(text: "Components")
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
                        return pca_state.level_names.count
                case 5:
                        return pca_state.number_of_components
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
                        cell.update(items: ["2D", "3D"], selected_segment_index: pca_state.dimension == 2 ? 0 : 1, target: self, selector: "dimension_action:")
                        return cell
                case 1:
                        let cell = tableView.dequeueReusableCellWithIdentifier("segmented_control_cell") as! SegmentedControlTableViewCell
                        cell.update(items: ["Circles", "Sample names"], selected_segment_index: pca_state.plot_symbol == "circles" ? 0 : 1, target: self, selector: "plot_symbol_action:")
                        return cell
                case 2:
                        let cell = tableView.dequeueReusableCellWithIdentifier("slider_cell") as! SliderTableViewCell
                        cell.update(minimum_value: 0, maximum_value: 1, value: pca_state.symbol_size, target: self, selector: "plot_symbol_size_action:")
                        return cell
                case 3:
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered_cell") as! CenteredTableViewCell
                        let text = state.factor_names[row]
                        if state.factor_ids[row] == pca_state.selected_factor_id {
                                cell.update_selected_checkmark(text: text)
                        } else {
                                cell.update_unselected(text: text)
                        }
                        return cell
                case 4:
                        let cell = tableView.dequeueReusableCellWithIdentifier("color_selection_cell", forIndexPath: indexPath) as! ColorSelectionTableViewCell
                        let level_name = pca_state.level_names[row]
                        let level_color = color_from_hex(hex: pca_state.level_colors[row])
                        cell.update(text: level_name, color: level_color)
                        return cell
                case 5:
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered_cell") as! CenteredTableViewCell
                        let (text, number) = pca_state.text_number_for_component(index: row)
                        if let number = number {
                                cell.update_selected_number(text: text, number: number)
                        } else {
                                cell.update_unselected(text: text)
                        }
                        return cell
                default:
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered_cell") as! CenteredTableViewCell
                        let text = state.sample_names[row]
                        if pca_state.selected_samples[row] {
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
                        let factor_id = state.factor_ids[row]
                        if pca_state.selected_factor_id == factor_id {
                                pca_state.selected_factor_id = nil
                        } else {
                                pca_state.selected_factor_id = factor_id
                        }
                        render_after_factor_change()
                } else if indexPath.section == 5 {
                        if pca_state.selected_components.indexOf(row) == nil {
                                pca_state.selected_components = pca_state.dimension == 2 ? [pca_state.selected_components[1], row] : [pca_state.selected_components[1], pca_state.selected_components[2], row]
                                render_after_components_change()
                        }
                } else if indexPath.section == 6 {
                        pca_state.selected_samples[row] = !pca_state.selected_samples[row]
                        render_after_sample_change()
                }
        }

        func dimension_action(sender: UISegmentedControl) {
                let dimension = sender.selectedSegmentIndex == 0 ? 2 : 3
                pca_state.set_dimension(dimension: dimension)
                state.render()
        }

        func plot_symbol_action(sender: UISegmentedControl) {
                pca_state.plot_symbol = sender.selectedSegmentIndex == 0 ? "circles" : "sample names"
                state.render()
        }

        func plot_symbol_size_action(sender: UISlider) {
                pca_state.symbol_size = Double(sender.value)
                update_pca_plot()
        }

        func select_all_action(tag tag: Int) {
                for i in 0 ..< pca_state.selected_samples.count {
                        pca_state.selected_samples[i] = true
                }
                render_after_sample_change()
        }

        func deselect_all_action(tag tag: Int) {
                for i in 0 ..< pca_state.selected_samples.count {
                        pca_state.selected_samples[i] = false
                }
                render_after_sample_change()
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {
                pca_state.pca_2d_zoom_scale = zoom_scale
        }

        func tap_action() {
                scroll_left_right()
        }

        func pdf_action() {
                let file_name_stem = "pca-2d"
                let description = "2D principal component plot of samples."
                if let pca_2d_drawer = pca_2d_drawer {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: pca_2d_drawer.content_size, draw: pca_2d_drawer.draw)
                        state.render()
                }
        }

        func png_action() {
                let file_name_stem = "pca-3d"
                let image = pca3d_plot.snapshot()
                if let file_data = UIImagePNGRepresentation(image) {
                        state.insert_png_result_file(file_name_stem: file_name_stem, file_data: file_data)
                        state.render()
                }
        }
}
