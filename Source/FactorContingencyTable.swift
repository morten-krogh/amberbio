import UIKit

class FactorContingencyTableState: PageState {

        var factor_name1 = ""
        var factor_name2 = ""
        var p_value = 1 as Double
        var contingency_table_attributed_strings = [] as [[Astring?]]
        var contingency_table_horizontal_cells = [] as [[Bool]]

        init(factor_id1: Int, factor_id2: Int) {
                super.init()
                name = "factor_contingency_table"

                let factor_index1 = state.factor_ids.indexOf(factor_id1)!
                let factor_index2 = state.factor_ids.indexOf(factor_id2)!
                factor_name1 = state.factor_names[factor_index1]
                factor_name2 = state.factor_names[factor_index2]

                title = astring_body(string: "\(factor_name1) vs. \(factor_name2)")
                info = "A contingency table for two factors.\n\nThe cells contain the observed frequencies with the expected frequency in parentheses.\n\nRed colors are used for cells where the observed frequency deviates with more than 2 standard deviations from the expected frequency.\n\nOnly samples in the active data set are used."

                let statistics = chi_square_table_statistics(values1: state.level_ids_by_factor_and_sample[factor_index1], values2: state.level_ids_by_factor_and_sample[factor_index2])
                p_value = statistics.p_value

                var ordered_level_names_1 = [String](count: statistics.indices1.count, repeatedValue: "")
                for (level_id, index) in statistics.indices1 {
                        let level_index = state.level_ids_by_factor_and_sample[factor_index1].indexOf(level_id)!
                        ordered_level_names_1[index] = state.level_names_by_factor_and_sample[factor_index1][level_index]
                }

                var ordered_level_names_2 = [String](count: statistics.indices2.count, repeatedValue: "")
                for (level_id, index) in statistics.indices2 {
                        let level_index = state.level_ids_by_factor_and_sample[factor_index2].indexOf(level_id)!
                        ordered_level_names_2[index] = state.level_names_by_factor_and_sample[factor_index2][level_index]
                }

                (contingency_table_attributed_strings, contingency_table_horizontal_cells) = contingency_table_data(level_names1: ordered_level_names_1, level_names2: ordered_level_names_2, observed: statistics.observed, expected: statistics.expected, total1: statistics.total1, total2: statistics.total2, total: statistics.total)

                pdf_enabled = true
        }
}

class FactorContingencyTable: Component {

        var factor_contingency_table_state: FactorContingencyTableState!

        let message_label = UILabel()
        let tiled_scroll_view = TiledScrollView(frame: CGRect.zeroRect)
        var table_of_attributed_strings: TableOfAttributedStrings?

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(message_label)
                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                let top_margin = 20 as CGFloat
                let middle_margin = 15 as CGFloat

                message_label.sizeToFit()
                message_label.frame = CGRect(x: 0, y: top_margin, width: width, height: message_label.frame.height)

                let origin_y = CGRectGetMaxY(message_label.frame) + middle_margin

                let height_table = height - origin_y
                tiled_scroll_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height_table)

                if let table_of_attributed_strings = table_of_attributed_strings {
                        let scale_x = width / table_of_attributed_strings.content_size.width
                        let scale_y = height_table / table_of_attributed_strings.content_size.height
                        let scale_min = min(1, scale_x, scale_y)
                        let scale_max = max(1, scale_x, scale_y)
                        table_of_attributed_strings.minimum_zoom_scale = scale_min
                        table_of_attributed_strings.maximum_zoom_scale = scale_max
                        tiled_scroll_view.delegate = table_of_attributed_strings
                        tiled_scroll_view.scroll_view.zoomScale = max(0.7, scale_min)
                }
        }

        override func render() {
                factor_contingency_table_state = state.page_state as! FactorContingencyTableState

                let message_text = Astring(string: "\u{3c7}")
                message_text.appendAttributedString(Astring(string: "2", attributes: [String(kCTSuperscriptAttributeName): 1]))
                message_text.appendAttributedString(Astring(string: " p-value = "))
                message_text.appendAttributedString(astring_from_p_value(p_value: factor_contingency_table_state.p_value, cutoff: 0.05))
                message_label.attributedText = message_text
                message_label.textAlignment = .Center

                table_of_attributed_strings = TableOfAttributedStrings(attributed_strings: factor_contingency_table_state.contingency_table_attributed_strings, horizontal_cells: factor_contingency_table_state.contingency_table_horizontal_cells)
        }

        func pdf_action() {
                let file_name_stem = "factor-contingency-table"
                let description = "\(factor_contingency_table_state.factor_name1) vs. \(factor_contingency_table_state.factor_name2). Chi square p-value = \(factor_contingency_table_state.p_value)"

                if let table_of_attributed_strings = table_of_attributed_strings {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: table_of_attributed_strings.content_size, draw: table_of_attributed_strings.draw)
                }

                state.render()
        }
}

func contingency_table_data(level_names1 level_names1: [String], level_names2: [String], observed: [[Int]], expected: [[Double]], total1: [Int], total2: [Int], total: Int) -> (attributed_strings: [[Astring?]], horizontal_cells: [[Bool]]) {
        var attributed_strings = [] as [[Astring?]]
        var header = [nil] as [Astring?]
        for name in level_names2 {
                header.append(astring_body(string: name))
        }
        header.append(nil)
        attributed_strings.append(header)

        for i in 0 ..< level_names1.count {
                var row = [astring_body(string: level_names1[i])] as [Astring?]
                for j in 0 ..< level_names2.count {
                        var attributedString = Astring(attributedString: astring_body(string: String(observed[i][j])))
                        let formattedExpected = decimal_string(number: expected[i][j], fraction_digits: 1)
                        let expectedString = astring_footnote(string: " (\(formattedExpected))")
                        attributedString.appendAttributedString(expectedString)

                        let deviation = (Double(observed[i][j]) - expected[i][j]) / sqrt(expected[i][j])
                        if abs(deviation) > 2 {
                                attributedString = astring_change_color(string: attributedString, color: UIColor.redColor())
                        }

                        row.append(attributedString)
                }
                row.append(astring_body(string: String(total1[i])))
                attributed_strings.append(row)
        }

        var footer = [nil] as [Astring?]
        for columnTotal in total2 {
                footer.append(astring_body(string: String(columnTotal)))
        }
        footer.append(astring_body(string: String(total)))
        attributed_strings.append(footer)

        var horizontal_cells = constant_table(number_of_rows: level_names1.count + 2, number_of_columns: level_names2.count + 2, repeated_value: true)
        for i in 0 ..< level_names2.count {
                horizontal_cells[0][i + 1] = false
        }

        return (attributed_strings: attributed_strings, horizontal_cells: horizontal_cells)
}

func constant_table<T>(number_of_rows number_of_rows: Int, number_of_columns: Int, repeated_value: T) -> [[T]] {
        let row = [T](count: number_of_columns, repeatedValue: repeated_value)
        return [[T]](count: number_of_rows, repeatedValue: row)
}
