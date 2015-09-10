import UIKit

class PairwiseTableState: PageState {

        var factor_id = 0
        var factor_name = ""
        var level_id_pairs = [] as [(Int, Int)]
        var level_ids = [] as [Int]
        var level_id_to_level_name = [:] as [Int: String]
        var level_id_to_sample_data_set_offsets = [:] as [Int: [Int]]

        var pair_mean_values = [] as [[Double]]
        var pair_fold_changes = [] as [[Double]]
        var pair_t_statistics = [] as [[Double]]
        var pair_t_test_p_values = [] as [[Double]]
        var pair_t_test_fdrs = [] as [[Double]]
        var pair_wilcoxon_p_values = [] as [[Double]]
        var pair_wilcoxon_fdrs = [] as [[Double]]

        var level_present_values = [] as [[Int]]
        var level_missing_values = [] as [[Int]]
        var level_mean_values = [] as [[Double]]
        var level_standard_deviations = [] as [[Double]]

        var sort_column = 0
        var sort_direction_increasing = true
        var filtered_search_rows = [] as [Int]
        var sorted_rows = [] as [Int]
        var spread_sheet_content_offset = CGPoint.zero

        init(factor_id: Int, level_id_pairs: [(Int, Int)]) {
                super.init()
                name = "pairwise_table"
                title = astring_body(string: "Pairwise test table")
                info = "Table of pairwise tests.\n\nSee the manual for a description of the tests.\n\nTap a row to see a plot of the molecule values."
                self.factor_id = factor_id
                self.level_id_pairs = level_id_pairs

                txt_enabled = true
                histogram_enabled = true
                select_enabled = true
                search_enabled = true

                prepared = false
        }

        override func prepare() {
                let factor_index = state.factor_ids.indexOf(factor_id)!
                factor_name = state.factor_names[factor_index]

                var level_id_set = Set<Int>()
                for (level_id1, level_id2) in level_id_pairs {
                        level_id_set.insert(level_id1)
                        level_id_set.insert(level_id2)
                }

                level_ids = [Int](level_id_set)
                level_id_to_level_name = [:]
                level_id_to_sample_data_set_offsets = [:]
                for level_id in level_ids {
                        let level_index = state.level_ids_by_factor[factor_index].indexOf(level_id)!
                        level_id_to_level_name[level_id] = state.level_names_by_factor[factor_index][level_index]
                        level_id_to_sample_data_set_offsets[level_id] = []
                }

                for i in 0 ..< state.number_of_samples {
                        let level_id = state.level_ids_by_factor_and_sample[factor_index][i]
                        if level_id_to_level_name[level_id] != nil {
                                level_id_to_sample_data_set_offsets[level_id]!.append(i)
                        }
                }

                pair_mean_values = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                pair_fold_changes = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                pair_t_statistics = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                pair_t_test_p_values = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                pair_wilcoxon_p_values = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))

                let mann_whitney = MannWhitney(n1_max: 15, n2_max: 15)

                for row in 0 ..< state.number_of_molecules {
                        for i in 0 ..< level_id_pairs.count {
                                let (level_id_1, level_id_2) = level_id_pairs[i]
                                let sample_data_set_offsets_1 = level_id_to_sample_data_set_offsets[level_id_1]!
                                let sample_data_set_offsets_2 = level_id_to_sample_data_set_offsets[level_id_2]!

                                let total_offset = row * state.number_of_samples
                                let values1 = present_values_for_offsets(values: state.values, total_offset: total_offset, offsets: sample_data_set_offsets_1)
                                let values2 = present_values_for_offsets(values: state.values, total_offset: total_offset, offsets: sample_data_set_offsets_2)

                                pair_mean_values[row][i] = stat_mean(values: values1) - stat_mean(values: values2)
                                pair_fold_changes[row][i] = pow(2, pair_mean_values[row][i])

                                let (t_statistic, t_test_p_value) = stat_t_test(values1: values1, values2: values2)

                                pair_t_statistics[row][i] = t_statistic
                                pair_t_test_p_values[row][i] = t_test_p_value

                                let wilcoxon_p_value = mann_whitney.two_sided_pvalue(values1: values1, values2: values2)
                                pair_wilcoxon_p_values[row][i] = Double(wilcoxon_p_value)
                        }
                }

                pair_t_test_fdrs = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                for i in 0 ..< level_id_pairs.count {
                        let p_values = pair_t_test_p_values.map({ $0[i] })
                        let fdrs = stat_false_discovery_rate(p_values: p_values)
                        for row in 0 ..< state.number_of_molecules {
                                pair_t_test_fdrs[row][i] = fdrs[row]
                        }
                }

                pair_wilcoxon_fdrs = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                for i in 0 ..< level_id_pairs.count {
                        let p_values = pair_wilcoxon_p_values.map({ $0[i] })
                        let fdrs = stat_false_discovery_rate(p_values: p_values)
                        for row in 0 ..< state.number_of_molecules {
                                pair_wilcoxon_fdrs[row][i] = fdrs[row]
                        }
                }

                level_present_values = [[Int]](count: state.number_of_molecules, repeatedValue: [Int](count: level_ids.count, repeatedValue: 0))
                level_missing_values = [[Int]](count: state.number_of_molecules, repeatedValue: [Int](count: level_ids.count, repeatedValue: 0))

                level_mean_values = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_ids.count, repeatedValue: 0))
                level_standard_deviations = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_ids.count, repeatedValue: 0))

                for row in 0 ..< state.number_of_molecules {
                        for i in 0 ..< level_ids.count {
                                let level_id = level_ids[i]
                                let sample_data_set_offsets = level_id_to_sample_data_set_offsets[level_id]!

                                let total_offset = row * state.number_of_samples
                                let current_values = present_values_for_offsets(values: state.values, total_offset: total_offset, offsets: sample_data_set_offsets)

                                level_present_values[row][i] = current_values.count
                                level_missing_values[row][i] = sample_data_set_offsets.count - current_values.count

                                level_mean_values[row][i] = stat_mean(values: current_values)
                                level_standard_deviations[row][i] = stat_standard_deviation(values: current_values)
                        }
                }

                filtered_search_rows = [Int](0 ..< state.number_of_molecules)
                sorted_rows = filtered_search_rows

                prepared = true
        }
}

class PairwiseTable: Component, UISearchBarDelegate, SpreadSheetDelegate {

        var pairwise_table_state: PairwiseTableState!

        let spread_sheet = SpreadSheet()

        var column_widths = [] as [CGFloat]

        override func viewDidLoad() {
                super.viewDidLoad()

                spread_sheet.delegate = self
                view.addSubview(spread_sheet)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                spread_sheet.frame = view.bounds
        }

        override func render() {
                pairwise_table_state = state.page_state as! PairwiseTableState

                let number_of_columns = 2 + 7 * pairwise_table_state.level_id_pairs.count + 4 * pairwise_table_state.level_ids.count + state.molecule_annotation_names.count
                column_widths = [Int](0 ..< number_of_columns).map {
                        let astring = self.header_astring(column: $0)
                        return astring.size().width + 40
                }

                column_widths[1] += 80
                for i in 0 ..< state.molecule_annotation_names.count {
                        column_widths[2 + 7 * pairwise_table_state.level_id_pairs.count + 4 * pairwise_table_state.level_ids.count + i] += 170
                }

                spread_sheet.reload()
                spread_sheet.set_content_offset(content_offset: pairwise_table_state.spread_sheet_content_offset)
        }

        func spread_sheet_header_height(spread_sheet spread_sheet: SpreadSheet) -> CGFloat {
                let height = astring_body(string: "Test string").size().height + 10
                return  height
        }

        func spread_sheet_row_heights(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                let height = astring_body(string: "Test string").size().height + 10
                return [CGFloat](count: pairwise_table_state.sorted_rows.count, repeatedValue: height)
        }

        func spread_sheet_column_widths(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                return column_widths
        }

        func spread_sheet_header_astring(spread_sheet spread_sheet: SpreadSheet, column: Int) -> Astring {
                return header_astring(column: column)
        }

        func spread_sheet_astring(spread_sheet spread_sheet: SpreadSheet, row: Int, column: Int) -> Astring {
                let original_row = pairwise_table_state.sorted_rows[row]

                let astring = cell_astring(row: original_row, column: column)

                return astring_shorten(string: astring, width: column_widths[column] - 10)
        }

        func spread_sheet_header_tapable(spread_sheet spread_sheet: SpreadSheet) -> Bool {
                return true
        }

        func spread_sheet_header_tapped(spread_sheet spread_sheet: SpreadSheet, column: Int) {
                if state.root_component.full_page.search_bar.isFirstResponder() {
                        state.root_component.full_page.search_bar.resignFirstResponder()
                } else if column == pairwise_table_state.sort_column {
                        pairwise_table_state.sort_direction_increasing = !pairwise_table_state.sort_direction_increasing
                        sort()
                        spread_sheet.reload()
                } else if column < 2 + 7 * pairwise_table_state.level_id_pairs.count && (column == 0 || [0, 3, 5].contains((column - 2) % 7)) {
                        pairwise_table_state.sort_column = column
                        pairwise_table_state.sort_direction_increasing = true
                        sort()
                        spread_sheet.reload()
                }
        }

        func spread_sheet_tapable(spread_sheet spread_sheet: SpreadSheet) -> Bool {
                return true
        }

        func spread_sheet_tapped(spread_sheet spread_sheet: SpreadSheet, row: Int, column: Int) {
                if state.root_component.full_page.search_bar.isFirstResponder() {
                        state.root_component.full_page.search_bar.resignFirstResponder()
                        return
                }

                if molecule_range_active {
                        state.root_component.full_page.molecule_range.select_index(index: row)
                } else {
                        var previous_molecule_numbers = [] as [Int]

                        for i in 0 ..< row {
                                previous_molecule_numbers.append(pairwise_table_state.sorted_rows[i])
                        }

                        var next_molecule_numbers = [] as [Int]

                        for i in (row + 1) ..< pairwise_table_state.sorted_rows.count {
                                next_molecule_numbers.append(pairwise_table_state.sorted_rows[i])
                        }
                        next_molecule_numbers = Array(next_molecule_numbers.reverse())

                        let molecule_number = pairwise_table_state.sorted_rows[row]

                        let anova_plot_state = AnovaPlotState(molecule_number: molecule_number, next_molecule_numbers: next_molecule_numbers, previous_molecule_numbers: previous_molecule_numbers, factor_id: pairwise_table_state.factor_id, selected_level_ids: pairwise_table_state.level_ids)
                        state.navigate(page_state: anova_plot_state)
                        state.render()
                }
        }

        func spread_sheet_did_scroll(spread_sheet spread_sheet: SpreadSheet, content_offset: CGPoint) {
                pairwise_table_state.spread_sheet_content_offset = content_offset
        }

        override func search_action(search_string search_string: String) {
                if search_string != pairwise_table_state.search_string {
                        if search_string == "" {
                                pairwise_table_state.filtered_search_rows = [Int](0 ..< state.number_of_molecules)
                        } else {
                                let potential_rows = search_string.rangeOfString(pairwise_table_state.search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil ? pairwise_table_state.filtered_search_rows : [Int](0 ..< state.number_of_molecules)
                                pairwise_table_state.filtered_search_rows = filter_rows(search_string: search_string, potential_rows: potential_rows)
                        }
                        pairwise_table_state.search_string = search_string
                        sort()
                        spread_sheet.reload()
                }
        }

        func filter_rows(search_string search_string: String, potential_rows: [Int]) -> [Int] {
                var filtered_rows = [] as [Int]

                let columns_before_annotations = 2 + 7 * pairwise_table_state.level_id_pairs.count + 4 * pairwise_table_state.level_ids.count
                let columns = [1] + [Int]( columns_before_annotations ..< (columns_before_annotations + state.molecule_annotation_names.count) )

                for row in potential_rows {
                        if check_search_string_in_row(search_string: search_string, row: row, columns: columns) {
                                filtered_rows.append(row)
                        }
                }

                return filtered_rows
        }

        func check_search_string_in_row(search_string search_string: String, row: Int, columns: [Int]) -> Bool {
                for column in columns {
                        let string = cell_string(row: row, column: column)
                        if string.rangeOfString(search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                                return true
                        }
                }
                return false
        }

        func sort() {
                if pairwise_table_state.sort_column == 0 && pairwise_table_state.sort_direction_increasing {
                        pairwise_table_state.sorted_rows = pairwise_table_state.filtered_search_rows
                        state.root_component.full_page.histogram_button.enabled = false
                } else if pairwise_table_state.sort_column == 0 && !pairwise_table_state.sort_direction_increasing {
                        pairwise_table_state.sorted_rows = Array(pairwise_table_state.filtered_search_rows.reverse())
                        state.root_component.full_page.histogram_button.enabled = false
                } else {
                        let level_id_pair_index = (pairwise_table_state.sort_column - 2) / 7
                        state.root_component.full_page.histogram_button.enabled = true
                        if (pairwise_table_state.sort_column - 2) % 7 == 0 {
                                state.root_component.full_page.histogram_button.enabled = false
                                if pairwise_table_state.sort_direction_increasing {
                                        pairwise_table_state.sorted_rows = pairwise_table_state.filtered_search_rows.sort({
                                                self.pairwise_table_state.pair_mean_values[$1][level_id_pair_index].isNaN || self.pairwise_table_state.pair_mean_values[$0][level_id_pair_index] < self.pairwise_table_state.pair_mean_values[$1][level_id_pair_index]
                                        })
                                } else {
                                        pairwise_table_state.sorted_rows = pairwise_table_state.filtered_search_rows.sort({
                                                self.pairwise_table_state.pair_mean_values[$1][level_id_pair_index].isNaN || self.pairwise_table_state.pair_mean_values[$0][level_id_pair_index] > self.pairwise_table_state.pair_mean_values[$1][level_id_pair_index]
                                        })
                                }
                        } else if (pairwise_table_state.sort_column - 2) % 7 == 3 {
                                state.root_component.full_page.histogram_button.enabled = true
                                if pairwise_table_state.sort_direction_increasing {
                                        pairwise_table_state.sorted_rows = pairwise_table_state.filtered_search_rows.sort({
                                                self.pairwise_table_state.pair_t_test_p_values[$1][level_id_pair_index].isNaN || self.pairwise_table_state.pair_t_test_p_values[$0][level_id_pair_index] < self.pairwise_table_state.pair_t_test_p_values[$1][level_id_pair_index]
                                        })
                                } else {
                                        pairwise_table_state.sorted_rows = pairwise_table_state.filtered_search_rows.sort({
                                                self.pairwise_table_state.pair_t_test_p_values[$1][level_id_pair_index].isNaN || self.pairwise_table_state.pair_t_test_p_values[$0][level_id_pair_index] > self.pairwise_table_state.pair_t_test_p_values[$1][level_id_pair_index]
                                        })
                                }
                        } else {
                                state.root_component.full_page.histogram_button.enabled = true
                                if pairwise_table_state.sort_direction_increasing {
                                        pairwise_table_state.sorted_rows = pairwise_table_state.filtered_search_rows.sort({
                                                self.pairwise_table_state.pair_wilcoxon_p_values[$1][level_id_pair_index].isNaN || self.pairwise_table_state.pair_wilcoxon_p_values[$0][level_id_pair_index] < self.pairwise_table_state.pair_wilcoxon_p_values[$1][level_id_pair_index]
                                        })
                                } else {
                                        pairwise_table_state.sorted_rows = pairwise_table_state.filtered_search_rows.sort({
                                                self.pairwise_table_state.pair_wilcoxon_p_values[$1][level_id_pair_index].isNaN || self.pairwise_table_state.pair_wilcoxon_p_values[$0][level_id_pair_index] > self.pairwise_table_state.pair_wilcoxon_p_values[$1][level_id_pair_index]
                                        })
                                }
                        }
                }
        }

        func txt_action() {
                let file_name_stem = "pairwise-test-table"
                let description = "Pairwise test for \(pairwise_table_state.factor_name)"

                state.progress_indicator_info = "The txt file is being created"
                state.progress_indicator_progress = 0
                state.render_type = RenderType.progress_indicator
                state.render()

                let serial_queue = dispatch_queue_create("logarithmic transformation", DISPATCH_QUEUE_SERIAL)

                dispatch_async(serial_queue, {
                        let txt_table = self.create_txt_table()

                        dispatch_async(dispatch_get_main_queue(), {
                                state.insert_txt_result_file(file_name_stem: file_name_stem, description: description, table: txt_table)
                                state.render()
                        })
                })
        }

        func create_txt_table() -> [[String]] {
                let number_of_columns = 2 + 7 * pairwise_table_state.level_id_pairs.count + 4 * pairwise_table_state.level_ids.count + state.molecule_annotation_names.count
                var txt_table = [[String]](count: 1 + state.number_of_molecules, repeatedValue: [String](count: number_of_columns, repeatedValue: ""))

                for column in 0 ..< number_of_columns {
                        txt_table[0][column] = header_string(column: column)
                }

                for row in 0 ..< state.number_of_molecules {
                        for column in 0 ..< number_of_columns {
                                txt_table[row + 1][column] = cell_string(row: row, column: column)
                        }
                        state.progress_indicator_step(total: state.number_of_molecules, index: row, min: 0, max: 100, step_size: 100)
                }

                return txt_table
        }

        func header_string(column column: Int) -> String {
                if column == 0 {
                        return "Molecule number"
                } else if column == 1 {
                        return "Molecule name"
                } else if column < 2 + 7 * pairwise_table_state.level_id_pairs.count {
                        let level_id_pair_index = (column - 2) / 7
                        let (level_id_1, level_id_2) = pairwise_table_state.level_id_pairs[level_id_pair_index]
                        let level_name_1 = pairwise_table_state.level_id_to_level_name[level_id_1]!
                        let level_name_2 = pairwise_table_state.level_id_to_level_name[level_id_2]!
                        let prefix = "\(level_name_1) - \(level_name_2) "
                        switch (column - 2) % 7 {
                        case 0:
                                return prefix + "mean value"
                        case 1:
                                return prefix + "fold change"
                        case 2:
                                return prefix + "t-statistic"
                        case 3:
                                return prefix + "t-test p-value"
                        case 4:
                                return prefix + "t-test FDR"
                        case 5:
                                return prefix + "Wilcoxon p-value"
                        default:
                                return prefix + "Wilcoxon FDR"
                        }
                } else if column < 2 + 7 * pairwise_table_state.level_id_pairs.count + 4 * pairwise_table_state.level_ids.count {
                        let level_id_index = (column - 2 - 7 * pairwise_table_state.level_id_pairs.count) / 4
                        let level_name = pairwise_table_state.level_id_to_level_name[pairwise_table_state.level_ids[level_id_index]]!
                        let prefix = "\(level_name) "
                        switch (column - 7 * pairwise_table_state.level_id_pairs.count) % 4 {
                        case 0:
                                return prefix + "present values"
                        case 1:
                                return prefix + "missing values"
                        case 2:
                                return prefix + "mean value"
                        default:
                                return prefix + "standard deviation"
                        }
                } else {
                        return state.molecule_annotation_names[column - 2 - 7 * pairwise_table_state.level_id_pairs.count - 4 * pairwise_table_state.level_ids.count]
                }
        }

        func header_astring(column column: Int) -> Astring {
                let string = header_string(column: column)
                if column == pairwise_table_state.sort_column {
                        let string_with_arrow = string + (pairwise_table_state.sort_direction_increasing ? " \u{25b2}" : " \u{25bc}")
                        return astring_font_size_color(string: string_with_arrow, font: nil, font_size: nil, color: UIColor.blueColor())
                } else if column < 2 + 7 * pairwise_table_state.level_id_pairs.count && (column == 0 ||  [0, 3, 5].contains((column - 2) % 7)) {
                        return astring_body(string: string + " \u{25b2}")
                } else {
                        return astring_body(string: string)
                }
        }

        enum Value {
                case Name(String)
                case Count(Int)
                case Pvalue(Double)
                case Statistic(Double)
                case Number(Double)
        }

        func cell_value(row row: Int, column: Int) -> Value {
                        if column == 0 {
                                return Value.Count(row + 1)
                        } else if column == 1 {
                                return Value.Name(state.molecule_names[row])
                        } else if column < 2 + 7 * pairwise_table_state.level_id_pairs.count {
                                let level_id_pair_index = (column - 2) / 7
                                switch (column - 2) % 7 {
                                case 0:
                                        return Value.Number(pairwise_table_state.pair_mean_values[row][level_id_pair_index])
                                case 1:
                                        return Value.Number(pairwise_table_state.pair_fold_changes[row][level_id_pair_index])
                                case 2:
                                        return Value.Statistic(pairwise_table_state.pair_t_statistics[row][level_id_pair_index])
                                case 3:
                                        return Value.Pvalue(pairwise_table_state.pair_t_test_p_values[row][level_id_pair_index])
                                case 4:
                                        return Value.Pvalue(pairwise_table_state.pair_t_test_fdrs[row][level_id_pair_index])
                                case 5:
                                        return Value.Pvalue(pairwise_table_state.pair_wilcoxon_p_values[row][level_id_pair_index])
                                default:
                                        return Value.Pvalue(pairwise_table_state.pair_wilcoxon_fdrs[row][level_id_pair_index])
                                }
                        } else if column < 2 + 7 * pairwise_table_state.level_id_pairs.count + 4 * pairwise_table_state.level_ids.count {
                                let level_id_index = (column - 2 - 7 * pairwise_table_state.level_id_pairs.count) / 4
                                switch (column - 7 * pairwise_table_state.level_id_pairs.count) % 4 {
                                case 0:
                                        return Value.Count(pairwise_table_state.level_present_values[row][level_id_index])
                                case 1:
                                        return Value.Count(pairwise_table_state.level_missing_values[row][level_id_index])
                                case 2:
                                        return Value.Number(pairwise_table_state.level_mean_values[row][level_id_index])
                                default:
                                        return Value.Number(pairwise_table_state.level_standard_deviations[row][level_id_index])
                                }
                        } else {
                                let col = column - 2 - 7 * pairwise_table_state.level_id_pairs.count - 4 * pairwise_table_state.level_ids.count
                                return Value.Name(state.molecule_annotation_values[col][row])
                        }
        }

        func cell_string(row row: Int, column: Int) -> String {
                switch cell_value(row: row, column: column) {
                case .Name(let name):
                        return name
                case .Count(let count):
                        return "\(count)"
                case .Pvalue(let p_value):
                        return "\(p_value)"
                case .Statistic(let statistic):
                        return "\(statistic)"
                case .Number(let number):
                        return "\(number)"
                }
        }

        func cell_astring(row row: Int, column: Int) -> Astring {
                switch cell_value(row: row, column: column) {
                case .Name(let name):
                        return astring_body(string: name)
                case .Count(let count):
                        return astring_body(string: "\(count)")
                case .Pvalue(let p_value):
                        return astring_from_p_value(p_value: p_value, cutoff: 0.05)
                case .Statistic(let statistic):
                        return decimal_astring(number: statistic, fraction_digits: 2)
                case .Number(let number):
                        return decimal_astring(number: number, fraction_digits: 3)
                }
        }

        func histogram_action() {
                let corrected_column = pairwise_table_state.sort_column < 2 ? 5 : pairwise_table_state.sort_column
                let histogram_title = header_string(column: corrected_column)
                let level_id_pair_index = (corrected_column - 2) / 7
                var p_values = [] as [Double]
                if (corrected_column - 2) % 7 == 3 {
                        for i in 0 ..< pairwise_table_state.pair_t_test_p_values.count {
                                p_values.append(pairwise_table_state.pair_t_test_p_values[i][level_id_pair_index])
                        }
                } else {
                        for i in 0 ..< pairwise_table_state.pair_wilcoxon_p_values.count {
                                p_values.append(pairwise_table_state.pair_wilcoxon_p_values[i][level_id_pair_index])
                        }
                }

                let p_value_histogram_state = PValueHistogramState(histogram_title: histogram_title, p_values: p_values)
                state.navigate(page_state: p_value_histogram_state)
                state.render()
        }

        override func molecule_range_create_data_set(index1 index1: Int, index2: Int) {
                let data_set_name = "Selected range from Pairwise test"

                var selected_molecule_indices = [Int](count: index2 + 1 - index1, repeatedValue: 0)
                var selected_values = [Double](count: state.number_of_samples * (index2 + 1 - index1), repeatedValue: 0)
                for i in 0 ..< index2 + 1 - index1 {
                        let original_row = pairwise_table_state.sorted_rows[index1 + i]
                        let molecule_index = state.molecule_indices[original_row]
                        selected_molecule_indices[i] = molecule_index
                        let offset_old = original_row * state.number_of_samples
                        let offset_new = i * state.number_of_samples
                        for j in 0 ..< state.number_of_samples {
                                selected_values[offset_new + j] = state.values[offset_old + j]
                        }
                }

                let project_note_text = "Creation of data set \"\(data_set_name)\" by selecting \(selected_molecule_indices.count) molecules."

                let data_set_id = state.insert_data_set(data_set_name: data_set_name, project_id: state.project_id, values: selected_values, sample_ids: state.sample_ids, molecule_indices: selected_molecule_indices)
                state.insert_project_note(project_note_text: project_note_text, project_note_type: "auto", project_note_user_name: state.get_user_name(), project_id: state.project_id)
                state.set_active_data_set(data_set_id: data_set_id)
                let data_set_selection_state = DataSetSelectionState()
                state.navigate(page_state: data_set_selection_state)
                state.render()
        }

        func tap_action() {
                state.root_component.full_page.search_bar.resignFirstResponder()
        }
}

func present_values_for_offsets(values values: [Double], total_offset: Int, offsets: [Int]) -> [Double] {
        var extracted_values = [] as [Double]
        for offset in offsets {
                let value = values[total_offset + offset]
                if !value.isNaN {
                        extracted_values.append(value)
                }
        }
        return extracted_values
}
