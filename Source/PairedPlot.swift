import UIKit

class PairedPlotState: PageState {

        var molecule_number = 0

        var next_molecule_numbers = [] as [Int]
        var previous_molecule_numbers = [] as [Int]

        var pairing_factor_id = 0
        var pairing_factor_name = ""
        var pairing_level_ids = [] as [Int]
        var pairing_level_names = [] as [String]
        var pairing_level_id_for_samples = [] as [Int]

        var comparison_factor_id = 0
        var comparison_factor_name = ""

        var comparison_level_ids = [] as [Int]
        var comparison_level_names = [] as [String]
        var comparison_level_colors = [] as [String]
        var comparison_level_id_for_samples = [] as [Int]
        var comparison_level_color_for_samples = [] as [String]

        var selected_level_ids = [] as [Int]

        init(molecule_number: Int, next_molecule_numbers: [Int], previous_molecule_numbers: [Int], pairing_factor_id: Int, comparison_factor_id: Int, selected_level_ids: [Int]) {
                super.init()
                name = "paired_plot"
                title = astring_body(string: "Paired test plot")
                info = "Samples with the same level of the pairing factor are plotted together.\n\nSelect and deselect comparison levels on the top bar."

                self.molecule_number = molecule_number
                self.next_molecule_numbers = next_molecule_numbers
                self.previous_molecule_numbers = previous_molecule_numbers
                self.pairing_factor_id = pairing_factor_id
                self.comparison_factor_id = comparison_factor_id
                self.selected_level_ids = selected_level_ids

                let pairing_factor_index = state.factor_ids.indexOf(pairing_factor_id)!
                pairing_factor_name = state.factor_names[pairing_factor_index]

                pairing_level_ids = state.level_ids_by_factor[pairing_factor_index]
                pairing_level_names = state.level_names_by_factor[pairing_factor_index]
                pairing_level_id_for_samples = state.level_ids_by_factor_and_sample[pairing_factor_index]

                let comparison_factor_index = state.factor_ids.indexOf(comparison_factor_id)!
                comparison_factor_name = state.factor_names[comparison_factor_index]

                comparison_level_ids = state.level_ids_by_factor[comparison_factor_index]
                comparison_level_names = state.level_names_by_factor[comparison_factor_index]
                comparison_level_colors = state.level_colors_by_factor[comparison_factor_index]
                comparison_level_id_for_samples = state.level_ids_by_factor_and_sample[comparison_factor_index]
                comparison_level_color_for_samples = state.level_colors_by_factor_and_sample[comparison_factor_index]

                full_screen = true
                pdf_enabled = true
        }
}

class PairedPlot: Component {

        var paired_plot_state: PairedPlotState!

        var molecule_name = ""
        var values_for_molecule = [] as [Double]

        let multi_segmented_scroll_view = MultiSegmentedScrollView()
        let next_button = UIButton(type: UIButtonType.System)
        let previous_button = UIButton(type: UIButtonType.System)
        let info_label = UILabel()

        let tiled_scroll_view = TiledScrollView(frame: CGRect.zero)
        var single_molecule_plot: SingleMoleculePlot?

        override func viewDidLoad() {
                super.viewDidLoad()

                next_button.addTarget(self, action: "next_action", forControlEvents: UIControlEvents.TouchUpInside)
                next_button.setAttributedTitle(astring_font_size_color(string: "next", font_size: 20 as CGFloat), forState: .Normal)
                next_button.sizeToFit()

                previous_button.addTarget(self, action: "previous_action", forControlEvents: UIControlEvents.TouchUpInside)
                previous_button.setAttributedTitle(astring_font_size_color(string: "previous", font_size: 20 as CGFloat), forState: .Normal)
                previous_button.sizeToFit()

                info_label.textAlignment = .Center

                multi_segmented_scroll_view.addTarget(self, action: "multi_segmented_action:", forControlEvents: .ValueChanged)
                view.addSubview(multi_segmented_scroll_view)

                view.addSubview(next_button)
                view.addSubview(previous_button)
                view.addSubview(info_label)

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                let top_margin = 20 as CGFloat
                let side_margin = 20 as CGFloat

                let segmented_rect = CGRect(x: 0, y: top_margin, width: width, height: 50)
                multi_segmented_scroll_view.frame = segmented_rect

                var origin_y = 90 as CGFloat

                next_button.frame = CGRect(x: width - side_margin - next_button.frame.width, y: origin_y - 6, width: next_button.frame.width, height: next_button.frame.height)
                previous_button.frame = CGRect(x: side_margin, y: origin_y - 6, width: previous_button.frame.width, height: previous_button.frame.height)
                info_label.frame = CGRect(x: 2 * side_margin + previous_button.frame.width, y: origin_y, width: width - 4 * side_margin - 2 * previous_button.frame.width, height: info_label.frame.height)

                origin_y += max(next_button.frame.height, info_label.frame.height) + top_margin

                if let single_molecule_plot = single_molecule_plot {
                        let single_molecule_rect = CGRect(x: side_margin, y: origin_y, width: width - 2 * side_margin, height: view.frame.height - origin_y)

                        let zoom_horizontal = max(0.2, min(1, single_molecule_rect.width / single_molecule_plot.content_size.width))
                        let zoom_vertical = max(0.2, min(1, single_molecule_rect.height / single_molecule_plot.content_size.height))

                        single_molecule_plot.minimum_zoom_scale = min(zoom_horizontal, zoom_vertical)

                        tiled_scroll_view.frame = single_molecule_rect
                        tiled_scroll_view.scroll_view.zoomScale = single_molecule_plot.minimum_zoom_scale
                }
        }

        override func render() {
                paired_plot_state = state.page_state as! PairedPlotState

                var selected_segments = [] as [Int]
                for selected_level_id in paired_plot_state.selected_level_ids {
                        if let index = paired_plot_state.comparison_level_ids.indexOf(selected_level_id) {
                                selected_segments.append(index)
                        }
                }

                multi_segmented_scroll_view.render(names: paired_plot_state.comparison_level_names, selected_segments: selected_segments)

                next_button.hidden = paired_plot_state.next_molecule_numbers.isEmpty
                previous_button.hidden = paired_plot_state.previous_molecule_numbers.isEmpty

                molecule_name = state.molecule_names[paired_plot_state.molecule_number]

                let start_index = paired_plot_state.molecule_number * state.number_of_samples
                let end_index = (paired_plot_state.molecule_number + 1) * state.number_of_samples
                values_for_molecule = [Double](state.values[start_index ..< end_index])

                var single_plot_names = [] as [String]
                var single_plot_colors = [] as [[UIColor]]
                var single_plot_values = [] as [[Double]]

                var pairing_level_id_to_index = [:] as [Int: Int]
                for i in 0 ..< paired_plot_state.pairing_level_ids.count {
                        pairing_level_id_to_index[paired_plot_state.pairing_level_ids[i]] = i
                        single_plot_names.append(paired_plot_state.pairing_level_names[i])
                        single_plot_values.append([])
                        single_plot_colors.append([])
                }

                for i in 0 ..< paired_plot_state.comparison_level_id_for_samples.count {
                        if paired_plot_state.selected_level_ids.indexOf(paired_plot_state.comparison_level_id_for_samples[i]) != nil {
                                if let index = pairing_level_id_to_index[paired_plot_state.pairing_level_id_for_samples[i]] {
                                        let value = values_for_molecule[i]
                                        let color = color_from_hex(hex: paired_plot_state.comparison_level_color_for_samples[i])
                                        single_plot_values[index].append(value)
                                        single_plot_colors[index].append(color)
                                }
                        }
                }

                single_molecule_plot = SingleMoleculePlot(names: single_plot_names, colors: single_plot_colors, values: single_plot_values)
                tiled_scroll_view.delegate = single_molecule_plot

                info_label.attributedText = astring_body(string: molecule_name)
                info_label.sizeToFit()
        }

        func pdf_action() {
                let file_name_stem = "paired-plot"

                var description = "Plot of molecule \(molecule_name).\n The pairing factor is \(paired_plot_state.pairing_factor_name).\n The comparison factor is \(paired_plot_state.comparison_factor_name).\n"

                for selected_level_id in paired_plot_state.selected_level_ids {
                        if let index = paired_plot_state.comparison_level_ids.indexOf(selected_level_id) {
                                let level_name = paired_plot_state.comparison_level_names[index]
                                let color = paired_plot_state.comparison_level_colors[index]
                                description += " Level: \(level_name), Color: \(color)\n"
                        }
                }

                if let single_molecule_plot = single_molecule_plot {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: single_molecule_plot.content_size, draw: single_molecule_plot.draw)
                }
                state.render()
        }

        func next_action() {
                paired_plot_state.previous_molecule_numbers.append(paired_plot_state.molecule_number)
                paired_plot_state.molecule_number = paired_plot_state.next_molecule_numbers.removeLast()
                state.render()
        }

        func previous_action() {
                paired_plot_state.next_molecule_numbers.append(paired_plot_state.molecule_number)
                paired_plot_state.molecule_number = paired_plot_state.previous_molecule_numbers.removeLast()
                state.render()
        }

        func multi_segmented_action(sender: MultiSegmentedScrollView) {
                paired_plot_state.selected_level_ids = sender.selected_segments.map { self.paired_plot_state.comparison_level_ids[$0] }
                state.render()
        }
}
