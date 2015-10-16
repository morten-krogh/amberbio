import UIKit

class FactorChartState: PageState {

        override init() {
                super.init()
                name = "factor_chart"
                title = astring_body(string: "Factor Chart")
                info = "Chart of the samples and their factors.\n\nOnly samples in the active data set are included.\n\nThe original data set is guaranteed to have all samples in the project."

                full_screen = .Full
                pdf_enabled = true
                txt_enabled = true
        }
}

class FactorChart: Component, UIScrollViewDelegate {

        let tiled_scroll_view = TiledScrollView()
        var table_of_attributed_strings: TableOfAttributedStrings?
        var txt_table = [] as [[String]]

        override func viewDidLoad() {
                super.viewDidLoad()
                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                tiled_scroll_view.frame = view.bounds

                if let table_of_attributed_strings = table_of_attributed_strings {
                        let scale_x = width / table_of_attributed_strings.content_size.width
                        let scale_y = height / table_of_attributed_strings.content_size.height
                        let scale_min = min(1, scale_x, scale_y)
                        let scale_max = max(1, scale_x, scale_y)
                        table_of_attributed_strings.minimum_zoom_scale = scale_min
                        table_of_attributed_strings.maximum_zoom_scale = scale_max
                        tiled_scroll_view.delegate = table_of_attributed_strings
                        tiled_scroll_view.scroll_view.zoomScale = max(0.7, scale_min)
                }
        }

        override func render() {
                let (factor_chart_attributed_strings, factor_chart_circle_colors) = factor_chart_attributed_strings_and_colors(sample_names: state.sample_names, factor_names: state.factor_names, level_names: state.level_names_by_factor_and_sample, level_colors: state.level_colors_by_factor_and_sample)

                table_of_attributed_strings = TableOfAttributedStrings(attributed_strings: factor_chart_attributed_strings, circle_colors: factor_chart_circle_colors, margin_horizontal: 10, margin_vertical: 10)

                txt_table = factor_chart_make_txt_table(sample_names: state.sample_names, factor_names: state.factor_names, level_names: state.level_names_by_factor_and_sample, level_colors: state.level_colors_by_factor_and_sample)
        }

        func pdf_action () {
                let file_name_stem = "factor-chart"
                let description = "Table of factors and colors"
                if let table_of_attributed_strings = table_of_attributed_strings {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: table_of_attributed_strings.content_size, draw: table_of_attributed_strings.draw)
                }
                state.render()
        }

        func txt_action () {
                let file_name_stem = "factor-chart"
                let description = "Table of factors and colors"
                state.insert_txt_result_file(file_name_stem: file_name_stem, description: description, table: txt_table)
                state.render()
        }
}

func factor_chart_attributed_strings_and_colors(sample_names sample_names: [String], factor_names: [String], level_names: [[String]], level_colors: [[String]]) -> (attributed_strings: [[Astring?]], circle_colors: [[UIColor?]]) {

        var astrings = [] as [[Astring?]]
        var circle_colors = [] as [[UIColor?]]

        astrings.append([astring_headline(string: "Sample name")])
        circle_colors.append([nil])
        for i in 0 ..< sample_names.count {
                astrings[0].append(astring_headline(string: sample_names[i]))
                circle_colors[0].append(nil)
        }

        for i in 0 ..< factor_names.count {
                astrings.append([astring_headline(string: factor_names[i])])
                circle_colors.append([nil])
                for j in 0 ..< level_names[0].count {
                        astrings[i + 1].append(astring_body(string: level_names[i][j]))
                        circle_colors[i + 1].append(color_from_hex(hex: level_colors[i][j]))
                }
        }
        return (astrings, circle_colors)
}

func factor_chart_make_txt_table(sample_names sample_names: [String], factor_names: [String], level_names: [[String]], level_colors: [[String]]) -> [[String]] {
        var table = [["Sample name"] + sample_names]  as [[String]]

        for i in 0 ..< factor_names.count {
                let row = [factor_names[i]] + level_names[i]
                table.append(row)
        }

        table += [[], [], [], ["Colors are in RGB with hexadecimal numbers between 0 and 255"]]

        for i in 0 ..< factor_names.count {
                table += [[], [], [factor_names[i]], ["Level", "Color"]]
                var visited = [] as Set<String>
                for j in 0 ..< level_names[i].count {
                        if !visited.contains(level_names[i][j]) {
                                visited.insert(level_names[i][j])
                                table += [[level_names[i][j], level_colors[i][j]]]
                        }
                }
        }

        return table
}
