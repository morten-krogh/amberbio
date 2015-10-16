import UIKit

class SingleMoleculeState: PageState {

        var molecule_number = 0

        var next_molecule_numbers = [] as [Int]
        var previous_molecule_numbers = [] as [Int]

        var values_for_molecule = [] as [Double]

        var selected_factor_id = 0        // 0 is sample_names, another value is a factor_id

        init(molecule_number: Int, next_molecule_numbers: [Int], previous_molecule_numbers: [Int], selected_factor_id: Int) {
                super.init()
                name = "single_molecule"
                title = astring_body(string: "Single molecule plot")
                info = "A plot of the values for a single molecule in the active data set.\n\nThe molecule name is written in text.\n\nIf a factor is chosen, the anova p-value for that factor is shown.\n\nThe next and previous buttons step through the molecules in the order of the table on the previous page."
                self.molecule_number = molecule_number
                self.next_molecule_numbers = next_molecule_numbers
                self.previous_molecule_numbers = previous_molecule_numbers
                self.selected_factor_id = selected_factor_id

                full_screen = .Full
                pdf_enabled = true
        }
}

class SingleMolecule: Component {

        var single_molecule_state: SingleMoleculeState!

        let scroll_view_segmented_control = UIScrollView()
        var segmented_control: UISegmentedControl?
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

                info_label.numberOfLines = 0
                info_label.textAlignment = .Center

                view.addSubview(scroll_view_segmented_control)

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

                var origin_y = top_margin

                if let segmented_control = segmented_control {
                        let segmented_rect = CGRect(x: 0, y: 0, width: width, height: segmented_control.frame.height + 2 * top_margin)
                        scroll_view_segmented_control.frame = layout_centered_frame(contentSize: segmented_control.frame.size, rect: segmented_rect)
                        scroll_view_segmented_control.contentSize = segmented_control.bounds.size
                        segmented_control.frame.origin = CGPoint.zero
                        origin_y += segmented_control.frame.height
                }

                origin_y += 15

                next_button.frame = CGRect(x: width - side_margin - next_button.frame.width, y: origin_y - 6, width: next_button.frame.width, height: next_button.frame.height)
                previous_button.frame = CGRect(x: side_margin, y: origin_y - 6, width: previous_button.frame.width, height: previous_button.frame.height)
                info_label.frame = CGRect(x: 2 * side_margin + previous_button.frame.width, y: origin_y, width: width - 4 * side_margin - previous_button.frame.width - next_button.frame.width, height: info_label.frame.height)

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
                single_molecule_state = state.page_state as! SingleMoleculeState

                if let segmented_control = segmented_control {
                        segmented_control.removeFromSuperview()
                }

                next_button.hidden = single_molecule_state.next_molecule_numbers.isEmpty
                previous_button.hidden = single_molecule_state.previous_molecule_numbers.isEmpty

                if !state.factor_ids.isEmpty {
                        segmented_control = UISegmentedControl(items: ["Samples"] + state.factor_names)
                        if single_molecule_state.selected_factor_id == 0 {
                                segmented_control!.selectedSegmentIndex = 0
                        } else if let selected_index = state.factor_ids.indexOf(single_molecule_state.selected_factor_id) {
                                segmented_control!.selectedSegmentIndex = selected_index + 1
                        }
                        segmented_control!.addTarget(self, action: "select_factor_action:", forControlEvents: .ValueChanged)
                        scroll_view_segmented_control.addSubview(segmented_control!)
                } else {
                        single_molecule_state.selected_factor_id = 0
                }

                let start_index = single_molecule_state.molecule_number * state.number_of_samples
                let end_index =  (single_molecule_state.molecule_number + 1) * state.number_of_samples
                let values_for_molecule = [Double](state.values[start_index ..< end_index])

                var single_plot_names = [] as [String]
                var single_plot_colors = [] as [[UIColor]]
                var single_plot_values = [] as [[Double]]

                if single_molecule_state.selected_factor_id == 0 {
                        single_plot_names = state.sample_names
                        single_plot_colors = [[UIColor]](count: state.number_of_samples, repeatedValue: [color_blue_circle_color])
                        single_plot_values = values_for_molecule.map({ [$0] })
                        let info_string = "\(state.molecule_names[single_molecule_state.molecule_number])"
                        info_label.attributedText = astring_font_size_color(string: info_string, font_size: 17)
                } else {
                        let factor_index = state.factor_ids.indexOf(single_molecule_state.selected_factor_id)!
                        let level_ids = state.level_ids_by_factor_and_sample[factor_index]
                        let level_names = state.level_names_by_factor_and_sample[factor_index]
                        let level_colors = state.level_colors_by_factor_and_sample[factor_index]

                        var indices_for_levels = [] as [[Int]]
                        var index_for_level_id_dict = [:] as [Int: Int]
                        for i in 0 ..< level_ids.count {
                                let level_id = level_ids[i]
                                let value = values_for_molecule[i]
                                if let index = index_for_level_id_dict[level_id] {
                                        indices_for_levels[index].append(i)
                                        single_plot_values[index].append(value)
                                        single_plot_colors[index].append(color_from_hex(hex: level_colors[i]))
                                } else {
                                        index_for_level_id_dict[level_id] = indices_for_levels.count
                                        single_plot_names.append(level_names[i])
                                        single_plot_colors.append([color_from_hex(hex: level_colors[i])])
                                        single_plot_values.append([value])
                                        indices_for_levels.append([i])
                                }
                        }

                        let p_value = Anova(values: values_for_molecule, offset: 0, indices_for_levels: indices_for_levels).p_value
                        let info_astring = astring_font_size_color(string: "\(state.molecule_names[single_molecule_state.molecule_number])\nAnova: ", font_size: 17)
                        info_astring.appendAttributedString(astring_from_p_value(p_value: p_value, cutoff: 0))
                        let paragraph_style = NSMutableParagraphStyle()
                        paragraph_style.lineSpacing = 6 as CGFloat
                        paragraph_style.alignment = .Center
                        info_astring.addAttribute(NSParagraphStyleAttributeName, value: paragraph_style, range: NSMakeRange(0, info_astring.length))
                        info_label.attributedText = info_astring
                }

                info_label.sizeToFit()

                single_molecule_plot = SingleMoleculePlot(names: single_plot_names, colors: single_plot_colors, values: single_plot_values)
                tiled_scroll_view.delegate = single_molecule_plot
        }

        func pdf_action() {
                let file_name_stem = "single-molecule-plot"

                var description = "Plot of molecule \(state.molecule_names[single_molecule_state.molecule_number])."
                if single_molecule_state.selected_factor_id != 0 {
                        let selected_index = state.factor_ids.indexOf(single_molecule_state.selected_factor_id)!
                        let factor_name = state.factor_names[selected_index]
                        description += " The factor is \(factor_name)."
                }

                if let single_molecule_plot = single_molecule_plot {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: single_molecule_plot.content_size, draw: single_molecule_plot.draw)
                }
                state.render()
        }

        func next_action() {
                single_molecule_state.previous_molecule_numbers.append(single_molecule_state.molecule_number)
                single_molecule_state.molecule_number = single_molecule_state.next_molecule_numbers.removeLast()
                state.render()
        }

        func previous_action() {
                single_molecule_state.next_molecule_numbers.append(single_molecule_state.molecule_number)
                single_molecule_state.molecule_number = single_molecule_state.previous_molecule_numbers.removeLast()
                state.render()
        }

        func select_factor_action(sender: UISegmentedControl) {
                let new_selected_factor_id = sender.selectedSegmentIndex == 0 ? 0 : state.factor_ids[sender.selectedSegmentIndex - 1]
                if single_molecule_state.selected_factor_id != new_selected_factor_id {
                        single_molecule_state.selected_factor_id = new_selected_factor_id
                        state.render()
                }
        }
}
