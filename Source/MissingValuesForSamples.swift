import UIKit

class MissingValuesForSamplesState: PageState {

        var orderings = [] as [String]
        var missing_values = [] as [Int]
        var ordered_missing_values = [] as [Int]
        var ordered_labels = [] as [Astring]
        var colors = [] as [UIColor]
        var selected_order = 0
        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 1 as CGFloat
        var zoom_scale = 1 as CGFloat

        override init() {
                super.init()
                name = "missing_values_for_samples"
                title = astring_body(string: "Missing values per sample")
                info = "The number of missing values per sample in the active data set.\n\nThe ordering of the samples can be changed by tapping the top bar."

                pdf_enabled = true
                full_screen = true

                orderings = ["Decreasing", "Original"] + state.factor_names
                missing_values = missing_values_for_columns(matrix: state.values, number_of_rows: state.number_of_molecules, number_of_columns: state.number_of_samples)

                did_select_order(index: 0)
        }

        func did_select_order(index index: Int) {
                selected_order = index
                switch index {
                case 0:
                        order_decreasing()
                case 1:
                        order_original()
                default:
                        let factor_id = state.factor_ids[index - 2]
                        order_by_factor(factor_id: factor_id)
                }
        }

        func order_original() {
                ordered_missing_values = missing_values
                ordered_labels = state.sample_names.map { Astring(string: $0) }
                colors = [UIColor](count: state.sample_names.count, repeatedValue: color_blue)
        }

        func order_decreasing() {
                var indices = [Int](0 ..< state.sample_names.count)
                indices.sortInPlace { self.missing_values[$0] > self.missing_values[$1] }

                ordered_missing_values = []
                var ordered_sample_names = [] as [String]
                for index in indices {
                        ordered_missing_values.append(missing_values[index])
                        ordered_sample_names.append(state.sample_names[index])
                }
                ordered_labels = ordered_sample_names.map { Astring(string: $0) }
                colors = [UIColor](count: state.sample_names.count, repeatedValue: color_blue)
        }

        func order_by_factor(factor_id factor_id: Int) {
                let factor_index = state.factor_ids.indexOf(factor_id)!

                var missing_values_for_level_id = [:] as [Int: Int]
                var count_for_level_id = [:] as [Int: Int]
                for i in 0 ..< state.sample_ids.count {
                        let level_id = state.level_ids_by_factor_and_sample[factor_index][i]
                        if missing_values_for_level_id[level_id] == nil {
                                missing_values_for_level_id[level_id] = 0
                                count_for_level_id[level_id] = 0
                        }
                        missing_values_for_level_id[level_id]! += missing_values[i]
                        count_for_level_id[level_id]!++
                }

                var indices = [Int](0 ..< state.sample_ids.count)
                indices.sortInPlace {
                        let level_id0 = state.level_ids_by_factor_and_sample[factor_index][$0]
                        let level_id1 = state.level_ids_by_factor_and_sample[factor_index][$1]
                        if level_id0 == level_id1 {
                                return self.missing_values[$0] >= self.missing_values[$1]
                        } else {
                                let average0 = Double(missing_values_for_level_id[level_id0]!) / Double(count_for_level_id[level_id0]!)
                                let average1 = Double(missing_values_for_level_id[level_id1]!) / Double(count_for_level_id[level_id1]!)
                                if average0 != average1 {
                                        return average0 > average1
                                }
                                return level_id0 < level_id1
                        }
                }

                ordered_missing_values = []
                ordered_labels = []
                colors = []
                for index in indices {
                        let sample_name = state.sample_names[index]
                        let level_name = state.level_names_by_factor_and_sample[factor_index][index]
                        let color = color_from_hex(hex: state.level_colors_by_factor_and_sample[factor_index][index])
                        let missing_value = missing_values[index]

                        ordered_missing_values.append(missing_value)
                        colors.append(color)

                        let label = Astring(string: "\(sample_name)   (\(level_name))")
                        ordered_labels.append(label)
                        
                }
        }
}

class MissingValuesForSamples: Component, MissingValueHistogramDelegate {

        var missing_values_for_samples_state: MissingValuesForSamplesState!

        let scroll_view_segmented_control = UIScrollView()
        var segmented_control: UISegmentedControl?

        let tiled_scroll_view_histogram = TiledScrollView(frame: CGRect.zero)
        var histogram_rect = CGRect.zero
        var histogram: MissingValueHistogram?

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(scroll_view_segmented_control)
                view.addSubview(tiled_scroll_view_histogram)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let side_margin = 20 as CGFloat
                let top_margin = 20 as CGFloat

                if let segmented_control = segmented_control, let histogram = histogram {
                        let segmented_rect = CGRect(x: 0, y: 0, width: view.frame.width, height: segmented_control.frame.height + 2 * top_margin)
                        scroll_view_segmented_control.frame = layout_centered_frame(contentSize: segmented_control.frame.size, rect: segmented_rect)
                        scroll_view_segmented_control.contentSize = segmented_control.bounds.size
                        segmented_control.frame.origin = CGPoint.zero

                        histogram_rect = CGRect(x: side_margin, y: segmented_rect.height, width: view.frame.width - 2 * side_margin, height: view.frame.height - segmented_rect.height)

                        let zoom_ratio_width = histogram_rect.width / histogram.content_size.width
                        let zoom_ratio_height = histogram_rect.height / histogram.content_size.height

                        let maximum_zoom_scale = max(1, min(zoom_ratio_width, zoom_ratio_height))
                        let minimum_zoom_scale = max(0.4, min(1, min(zoom_ratio_width, zoom_ratio_height)))

                        missing_values_for_samples_state.maximum_zoom_scale = maximum_zoom_scale
                        missing_values_for_samples_state.minimum_zoom_scale = minimum_zoom_scale
                        missing_values_for_samples_state.zoom_scale = maximum_zoom_scale > 1 ? (1 + maximum_zoom_scale) / 2 : minimum_zoom_scale

                        histogram.maximum_zoom_scale = maximum_zoom_scale
                        histogram.minimum_zoom_scale = minimum_zoom_scale
                        tiled_scroll_view_histogram.frame = histogram_rect
                        tiled_scroll_view_histogram.scroll_view.zoomScale = missing_values_for_samples_state.zoom_scale
                }
        }

        override func render() {
                missing_values_for_samples_state = state.page_state as! MissingValuesForSamplesState

                if let segmented_control = segmented_control {
                        segmented_control.removeFromSuperview()
                }

                segmented_control = UISegmentedControl(items: missing_values_for_samples_state.orderings)
                segmented_control!.selectedSegmentIndex = missing_values_for_samples_state.selected_order
                segmented_control!.addTarget(self, action: "order_action:", forControlEvents: .ValueChanged)
                scroll_view_segmented_control.addSubview(segmented_control!)

                setup_histogram()
        }

        func pdf_action() {
                let file_name_stem = "missing-value-for-samples"
                let description = "Histogram of missing values"

                if let histogram = histogram {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: histogram.content_size, draw: histogram.draw_histogram)
                }
                state.render()
        }

        func order_action(sender: UISegmentedControl) {
                missing_values_for_samples_state.did_select_order(index: sender.selectedSegmentIndex)
                setup_histogram()
        }

        func setup_histogram() {
                histogram = MissingValueHistogram(labels: missing_values_for_samples_state.ordered_labels, values: missing_values_for_samples_state.ordered_missing_values, colors: missing_values_for_samples_state.colors)
                histogram?.delegate = self
                histogram?.maximum_zoom_scale = missing_values_for_samples_state.maximum_zoom_scale
                histogram?.minimum_zoom_scale = missing_values_for_samples_state.minimum_zoom_scale
                tiled_scroll_view_histogram.delegate = histogram!
                tiled_scroll_view_histogram.scroll_view.zoomScale = missing_values_for_samples_state.zoom_scale
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {
                missing_values_for_samples_state.zoom_scale = zoom_scale
        }
}
