import UIKit

class AnovaPlotState: PageState {

        var molecule_number = 0

        var next_molecule_numbers = [] as [Int]
        var previous_molecule_numbers = [] as [Int]

        var factor_id = 0
        var selected_level_ids = [] as [Int]

        var values_for_molecule = [] as [Double]

        var (level_ids, level_names, level_colors) = ([], [], []) as ([Int], [String], [String])

        init(molecule_number: Int, next_molecule_numbers: [Int], previous_molecule_numbers: [Int], factor_id: Int, selected_level_ids: [Int]) {
                super.init()
                name = "anova_plot"
                title = astring_body(string: "Single molecule plot")
                info = "Plot of the values for a single molecule.\n\nTap a level on the top bar to include and exclude levels.\n\nTap next or previous to see other molecules.\n\nTap the molecule name to conduct a web search."
                self.molecule_number = molecule_number
                self.next_molecule_numbers = next_molecule_numbers
                self.previous_molecule_numbers = previous_molecule_numbers
                self.factor_id = factor_id
                self.selected_level_ids = selected_level_ids

                full_screen = .Conditional
                pdf_enabled = true
        }
}

class AnovaPlot: Component {

        var anova_plot_state: AnovaPlotState!

        var molecule_name = ""
        var factor_name = ""
        var level_ids = [] as [Int]
        var level_names = [] as [String]
        var level_colors = [] as [String]
        var values_for_molecule = [] as [Double]

        let multi_segmented_scroll_view = MultiSegmentedScrollView()
        let next_button = UIButton(type: UIButtonType.System)
        let previous_button = UIButton(type: UIButtonType.System)
        let molecule_name_button = Button()
        let anova_label = UILabel()

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

                multi_segmented_scroll_view.addTarget(self, action: "multi_segmented_action:", forControlEvents: .ValueChanged)
                view.addSubview(multi_segmented_scroll_view)

                view.addSubview(next_button)
                view.addSubview(previous_button)

                molecule_name_button.addTarget(self, action: "molecule_name_action", forControlEvents: .TouchUpInside)
                view.addSubview(molecule_name_button)
                view.addSubview(anova_label)

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                let top_margin = 10 as CGFloat
                let side_margin = 20 as CGFloat

                let segmented_rect = CGRect(x: 0, y: top_margin, width: width, height: 50)
                multi_segmented_scroll_view.frame = segmented_rect

                var origin_y = 70 as CGFloat

                molecule_name_button.sizeToFit()

                next_button.sizeToFit()
                let origin_y_next = origin_y + (molecule_name_button.frame.height - next_button.frame.height) / 2
                next_button.frame.origin = CGPoint(x: width - side_margin - next_button.frame.width, y: origin_y_next)

                previous_button.sizeToFit()
                let origin_y_previous = origin_y + (molecule_name_button.frame.height - previous_button.frame.height) / 2
                previous_button.frame.origin = CGPoint(x: side_margin, y: origin_y_previous)

                molecule_name_button.frame.size.width = min(molecule_name_button.frame.width, width - 4 * side_margin - 2 * previous_button.frame.width)
                molecule_name_button.frame.origin = CGPoint(x: (width - molecule_name_button.frame.width) / 2, y: origin_y)

                origin_y = max(CGRectGetMaxY(molecule_name_button.frame), CGRectGetMaxY(next_button.frame), CGRectGetMaxY(previous_button.frame)) + 8

                anova_label.sizeToFit()
                anova_label.frame.size.width = min(anova_label.frame.width, width - 4 * side_margin - 2 * previous_button.frame.width)
                anova_label.frame.origin = CGPoint(x: (width - anova_label.frame.width) / 2, y: origin_y)

                origin_y += anova_label.frame.height + top_margin

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
                anova_plot_state = state.page_state as! AnovaPlotState

                let factor_index = state.factor_ids.indexOf(anova_plot_state.factor_id)!
                factor_name = state.factor_names[factor_index]
                level_ids = state.level_ids_by_factor[factor_index]
                level_names = state.level_names_by_factor[factor_index]
                level_colors = state.level_colors_by_factor[factor_index]

                var selected_segments = [] as [Int]
                var level_id_to_level_name = [:] as [Int: String]
                for selected_level_id in anova_plot_state.selected_level_ids {
                        if let index = level_ids.indexOf(selected_level_id) {
                                selected_segments.append(index)
                                level_id_to_level_name[selected_level_id] = level_names[index]
                        }
                }

                multi_segmented_scroll_view.render(names: level_names, selected_segments: selected_segments)

                next_button.hidden = anova_plot_state.next_molecule_numbers.isEmpty
                previous_button.hidden = anova_plot_state.previous_molecule_numbers.isEmpty

                molecule_name = state.molecule_names[anova_plot_state.molecule_number]

                let start_index = anova_plot_state.molecule_number * state.number_of_samples
                let end_index = (anova_plot_state.molecule_number + 1) * state.number_of_samples
                values_for_molecule = [Double](state.values[start_index ..< end_index])

                var single_plot_names = [] as [String]
                var single_plot_colors = [] as [[UIColor]]
                var single_plot_values = [] as [[Double]]

                var level_id_to_index = [:] as [Int: Int]
                for i in 0 ..< anova_plot_state.selected_level_ids.count {
                        level_id_to_index[anova_plot_state.selected_level_ids[i]] = i
                        single_plot_names.append(level_id_to_level_name[anova_plot_state.selected_level_ids[i]]!)
                        single_plot_values.append([])
                        single_plot_colors.append([])
                }

                let sample_level_ids = state.level_ids_by_factor_and_sample[factor_index]
                let sample_level_colors = state.level_colors_by_factor_and_sample[factor_index]

                for i in 0 ..< sample_level_ids.count {
                        if anova_plot_state.selected_level_ids.indexOf(sample_level_ids[i]) != nil {
                                if let index = level_id_to_index[sample_level_ids[i]] {
                                        let value = values_for_molecule[i]
                                        let color = color_from_hex(hex: sample_level_colors[i])
                                        single_plot_values[index].append(value)
                                        single_plot_colors[index].append(color)
                                }
                        }
                }

                single_molecule_plot = SingleMoleculePlot(names: single_plot_names, colors: single_plot_colors, values: single_plot_values)
                tiled_scroll_view.delegate = single_molecule_plot

                let (_, p_value) = stat_anova(values: single_plot_values)

                molecule_name_button.update(text: molecule_name, font_size: 20)

                let anova_astring = astring_font_size_color(string: "Anova: ", font_size: 17)
                anova_astring.appendAttributedString(astring_from_p_value(p_value: p_value, cutoff: 0))
                anova_label.attributedText = anova_astring

                view.setNeedsLayout()
        }

        func pdf_action() {
                let file_name_stem = "single-molecule-plot"

                var description = "Plot of molecule \(molecule_name).\n The factor is \(factor_name).\n"

                for selected_level_id in anova_plot_state.selected_level_ids {
                        if let index = level_ids.indexOf(selected_level_id) {
                                let level_name = level_names[index]
                                let color = level_colors[index]
                                description += " Level: \(level_name), Color: \(color)\n"
                        }
                }

                if let single_molecule_plot = single_molecule_plot {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: single_molecule_plot.content_size, draw: single_molecule_plot.draw)
                }
                state.render()
        }

        func next_action() {
                anova_plot_state.previous_molecule_numbers.append(anova_plot_state.molecule_number)
                anova_plot_state.molecule_number = anova_plot_state.next_molecule_numbers.removeLast()
                state.render()
        }

        func previous_action() {
                anova_plot_state.next_molecule_numbers.append(anova_plot_state.molecule_number)
                anova_plot_state.molecule_number = anova_plot_state.previous_molecule_numbers.removeLast()
                state.render()
        }
        
        func multi_segmented_action(sender: MultiSegmentedScrollView) {
                anova_plot_state.selected_level_ids = sender.selected_segments.map { self.level_ids[$0] }
                state.render()
        }

        func molecule_name_action() {
                state.molecule_web_search.open_url(molecule_index: anova_plot_state.molecule_number)
        }
}
