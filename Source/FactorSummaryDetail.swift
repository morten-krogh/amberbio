import UIKit

class FactorSummaryDetailState: PageState {

        var factor_name = ""
        var level_colors = [] as [UIColor]
        var pie_chart_names = [] as [String]
        var pie_chart_values = [] as [Double]

        init(factor_id: Int) {
                super.init()
                name = "factor_summary_detail"
                info = "Only samples present in the active data set are included."

                let factor_index = state.factor_ids.indexOf(factor_id)!
                factor_name = state.factor_names[factor_index]
                title = astring_body(string: "Pie chart for \(factor_name)")

                let level_names = state.level_names_by_factor[factor_index]
                level_colors = state.level_colors_by_factor[factor_index].map { color_from_hex(hex: $0) }
                var level_frequencies = [Int](count: state.level_ids_by_factor[factor_index].count, repeatedValue: 0)
                for level_id in state.level_ids_by_factor_and_sample[factor_index] {
                        let level_index = state.level_ids_by_factor[factor_index].indexOf(level_id)!
                        level_frequencies[level_index]++
                }

                let number_of_samples = state.number_of_samples

                pie_chart_names = []
                for  i in 0 ..< level_names.count {
                        let level_name = level_names[i]
                        let level_frequency = level_frequencies[i]
                        let level_percentage = Int(round(Double(100 * level_frequency) / Double(number_of_samples)))
                        let pie_chart_name = "\(level_name) (\(level_frequency), \(level_percentage)%)"
                        pie_chart_names.append(pie_chart_name)
                }

                pie_chart_values = level_frequencies.map { Double($0) }

                pdf_enabled = true
        }
}

class FactorSummaryDetail: Component {

        var factor_summary_detail_state: FactorSummaryDetailState!

        let tiled_scroll_view = TiledScrollView(frame: CGRect.zeroRect)
        var pie_chart: PieChart?

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                tiled_scroll_view.frame = view.bounds

                let width = view.frame.width
                let height = view.frame.height

                if let pie_chart = pie_chart {
                        let scale_x = width / pie_chart.content_size.width
                        let scale_y = height / pie_chart.content_size.height
                        let scale_min = min(1, scale_x, scale_y)
                        let scale_max = max(1, scale_x, scale_y)

                        pie_chart.minimum_zoom_scale = scale_min
                        pie_chart.maximum_zoom_scale = scale_max
                        tiled_scroll_view.delegate = pie_chart
                        tiled_scroll_view.scroll_view.zoomScale = scale_min
                }
        }

        override func render() {
                factor_summary_detail_state = state.page_state as! FactorSummaryDetailState

                pie_chart = PieChart(names: factor_summary_detail_state.pie_chart_names, colors: factor_summary_detail_state.level_colors, values: factor_summary_detail_state.pie_chart_values)
        }

        func pdf_action() {
                let file_name_stem = "factor-pie-chart"
                let description = "Pie chart for \(factor_summary_detail_state.factor_name)"

                if let pie_chart = pie_chart {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: pie_chart.content_size, draw: pie_chart.draw)
                }

                state.render()
        }
}
