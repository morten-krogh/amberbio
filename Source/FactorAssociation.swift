import UIKit

class FactorAssociationState: PageState {

        override init() {
                super.init()
                name = "factor_association"
                title = astring_body(string: "Factor Association")
                info = "A Chi-square p-value is calculated for all possible factor associations.\n\nTap a cell to see the corresponding contingency table.\n\nP-values < 0.05 are red\n\n"
        }
}

class FactorAssociation: Component {

        var p_values = [] as [[Double]]

        var failure_label = UILabel()
        let tiled_scroll_view = TiledScrollView(frame: CGRect.zero)
        var table_of_attributed_strings: TableOfAttributedStrings?

        override func viewDidLoad() {
                super.viewDidLoad()

                failure_label.attributedText = astring_body(string: "Association tables require at least 2 factors")
                failure_label.textColor = UIColor.redColor()
                failure_label.textAlignment = .Center
                failure_label.numberOfLines = 0
                view.addSubview(failure_label)

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                failure_label.sizeToFit()
                failure_label.center = CGPoint(x: width / 2, y: height / 2)

                tiled_scroll_view.frame = view.bounds
                if let table_of_atrributed_strings = table_of_attributed_strings {
                        let scale_x = width / table_of_atrributed_strings.content_size.width
                        let scale_y = height / table_of_atrributed_strings.content_size.height
                        let scale_min = min(1, scale_x, scale_y)
                        let scale_max = max(1, scale_x, scale_y)
                        table_of_atrributed_strings.minimum_zoom_scale = scale_min
                        table_of_atrributed_strings.maximum_zoom_scale = scale_max
                        tiled_scroll_view.delegate = table_of_atrributed_strings
                        tiled_scroll_view.scroll_view.zoomScale = max(0.7, scale_min)
                }
        }

        override func render() {

                p_values = [[Double]](count: state.factor_ids.count, repeatedValue: [Double](count: state.factor_ids.count, repeatedValue: Double.NaN))
                for i in 0 ..< state.factor_ids.count {
                        for j in 0 ..< i {
                                let statistics = chi_square_table_statistics(values1: state.level_ids_by_factor_and_sample[i], values2: state.level_ids_by_factor_and_sample[j])
                                p_values[i][j] = statistics.p_value
                                p_values[j][i] = statistics.p_value
                        }
                }

                if state.factor_ids.count < 2 {
                        failure_label.hidden = false
                        tiled_scroll_view.hidden = true
                } else {
                        failure_label.hidden = true
                        tiled_scroll_view.hidden = false

                        let (attributed_strings, horizontal_cells) = table_data_for_chi_square_table(factor_names: state.factor_names, p_values: p_values)
                        table_of_attributed_strings = TableOfAttributedStrings(attributed_strings: attributed_strings, horizontal_cells: horizontal_cells, tap_action: { [unowned self] (row: Int, col: Int) in
                                self.tap_action(row: row, col: col)
                                })
                }
        }

        func tap_action(row row: Int, col: Int) {
                if row != 0 && col != 0 && row != col {
                        let factor_id1 = state.factor_ids[row - 1]
                        let factor_id2 = state.factor_ids[col - 1]
                        let factor_contingency_table_state = FactorContingencyTableState(factor_id1: factor_id1, factor_id2: factor_id2)
                        state.navigate(page_state: factor_contingency_table_state)
                        state.render()
                }
        }
}

func table_data_for_chi_square_table(factor_names factor_names: [String], p_values: [[Double]]) -> (attributed_strings: [[Astring?]], horizontal_cells: [[Bool]]) {
        var attributed_strings = [] as [[Astring?]]
        var header = [nil] as [Astring?]
        for factor_name in factor_names {
                header.append(astring_body(string: factor_name))
        }
        attributed_strings.append(header)

        for i in 0 ..< factor_names.count {
                var row = [astring_body(string: factor_names[i])] as [Astring?]
                for j in 0 ..< factor_names.count {
                        if i == j {
                                row.append(nil)
                        } else {
                                let p_value = p_values[i][j]
                                row.append(astring_from_p_value(p_value: p_value, cutoff: 0.05))
                        }
                }
                attributed_strings.append(row)
        }

        let horizontal_row = [Bool](count: factor_names.count + 1, repeatedValue: true)
        var horizontal_cells = [[Bool]](count: factor_names.count + 1, repeatedValue: horizontal_row)
        for i in 0 ..< factor_names.count {
                horizontal_cells[0][i + 1] = false
        }

        return (attributed_strings, horizontal_cells)
}
