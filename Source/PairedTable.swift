
import UIKit

class PairedTableState: PageState {

        var pairing_factor_id = 0
        var comparison_factor_id = 0
        var level_id_pairs = [] as [(Int, Int)]

        var pairing_factor_name = ""
        var pairing_level_ids = [] as [Int]
        var pairing_level_id_to_sample_data_set_offsets = [:] as [Int: [Int]]

        var comparison_factor_name = ""
        var comparison_level_ids = [] as [Int]
        var comparison_level_id_to_level_name = [:] as [Int: String]
        var comparison_level_id_to_sample_data_set_offsets = [:] as [Int: [Int]]

        var positive_pairs = [] as [[Int]]
        var negative_pairs = [] as [[Int]]
        var mean_values = [] as [[Double]]
        var fold_changes = [] as [[Double]]
        var t_statistics = [] as [[Double]]
        var t_test_p_values = [] as [[Double]]
        var t_test_fdrs = [] as [[Double]]

        var sort_column = 0
        var sort_direction_increasing = true
        var filtered_search_rows = [] as [Int]
        var sorted_rows = [] as [Int]
        var spread_sheet_content_offset = CGPoint.zero

        init(pairing_factor_id: Int, comparison_factor_id: Int, level_id_pairs: [(Int, Int)]) {
                super.init()
                name = "paired_table"
                title = astring_body(string: "Paired test table")
                info = "Table of paired tests.\n\nSee the manual for a description of the tests.\n\nTap a row to see a plot of the values for a molecule."
                self.pairing_factor_id = pairing_factor_id
                self.comparison_factor_id = comparison_factor_id
                self.level_id_pairs = level_id_pairs

                txt_enabled = true
                histogram_enabled = true
                select_enabled = true
                search_enabled = true

                prepared = false
        }

        override func prepare() {

                let pairing_factor_index = state.factor_ids.indexOf(pairing_factor_id)!
                pairing_factor_name = state.factor_names[pairing_factor_index]

                pairing_level_ids = state.level_ids_by_factor[pairing_factor_index]
                pairing_level_id_to_sample_data_set_offsets = [:]

                for level_id in pairing_level_ids {
                        pairing_level_id_to_sample_data_set_offsets[level_id] = []
                }

                for i in 0 ..< state.number_of_samples {
                        let level_id = state.level_ids_by_factor_and_sample[pairing_factor_index][i]
                        pairing_level_id_to_sample_data_set_offsets[level_id]?.append(i)
                }

                let comparison_factor_index = state.factor_ids.indexOf(comparison_factor_id)!
                comparison_factor_name = state.factor_names[comparison_factor_index]

                var comparison_level_id_set = Set<Int>()
                for (level_id_1, level_id_2) in level_id_pairs {
                        comparison_level_id_set.insert(level_id_1)
                        comparison_level_id_set.insert(level_id_2)
                }

                comparison_level_ids = [Int](comparison_level_id_set)
                comparison_level_id_to_level_name = [:]
                comparison_level_id_to_sample_data_set_offsets = [:]

                for level_id in comparison_level_ids {
                        let level_index = state.level_ids_by_factor[comparison_factor_index].indexOf(level_id)!
                        comparison_level_id_to_level_name[level_id] = state.level_names_by_factor[comparison_factor_index][level_index]
                        comparison_level_id_to_sample_data_set_offsets[level_id] = []
                }

                for i in 0 ..< state.number_of_samples {
                        let level_id = state.level_ids_by_factor_and_sample[comparison_factor_index][i]
                        if comparison_level_id_set.contains(level_id) {
                                comparison_level_id_to_sample_data_set_offsets[level_id]?.append(i)
                        }
                }

                positive_pairs = [[Int]](count: state.number_of_molecules, repeatedValue: [Int](count: level_id_pairs.count, repeatedValue: 0))
                negative_pairs = [[Int]](count: state.number_of_molecules, repeatedValue: [Int](count: level_id_pairs.count, repeatedValue: 0))
                mean_values = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                fold_changes = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                t_statistics = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                t_test_p_values = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))

                for i in 0 ..< level_id_pairs.count {
                        let (level_id_1, level_id_2) = level_id_pairs[i]
                        let sample_data_set_offset_set_1 = Set<Int>(comparison_level_id_to_sample_data_set_offsets[level_id_1]!)
                        let sample_data_set_offset_set_2 = Set<Int>(comparison_level_id_to_sample_data_set_offsets[level_id_2]!)

                        var pair_offsets_1 = [] as [Int]
                        var pair_offsets_2 = [] as [Int]

                        for pairing_level_id in pairing_level_ids {
                                let pairing_offset_set = Set<Int>(pairing_level_id_to_sample_data_set_offsets[pairing_level_id]!)
                                let offsets_1 = [Int](pairing_offset_set.intersect(sample_data_set_offset_set_1))
                                let offsets_2 = [Int](pairing_offset_set.intersect(sample_data_set_offset_set_2))
                                if offsets_1.count == 1 && offsets_2.count == 1 {
                                        pair_offsets_1.append(offsets_1[0])
                                        pair_offsets_2.append(offsets_2[0])
                                }
                        }

                        for row in 0 ..< state.number_of_molecules {
                                let total_offset = row * state.number_of_samples
                                let values1 = values_for_offsets(values: state.values, total_offset: total_offset, offsets: pair_offsets_1)
                                let values2 = values_for_offsets(values: state.values, total_offset: total_offset, offsets: pair_offsets_2)

                                var diff_values = [] as [Double]
                                for i in 0 ..< values1.count {
                                        let diff_value = values1[i] - values2[i]
                                        if !diff_value.isNaN {
                                                diff_values.append(diff_value)
                                        }
                                }

                                positive_pairs[row][i] = diff_values.filter({ $0 >= 0 }).count
                                negative_pairs[row][i] = diff_values.count - positive_pairs[row][i]
                                mean_values[row][i] = stat_mean(values: diff_values)
                                fold_changes[row][i] = pow(2, mean_values[row][i])

                                let (statistic, p_value) = stat_t_test(values: diff_values)
                                t_statistics[row][i] = statistic
                                t_test_p_values[row][i] = p_value
                        }
                }

                t_test_fdrs = [[Double]](count: state.number_of_molecules, repeatedValue: [Double](count: level_id_pairs.count, repeatedValue: 0))
                for i in 0 ..< level_id_pairs.count {
                        let p_values = t_test_p_values.map({ $0[i] })
                        let fdrs = stat_false_discovery_rate(p_values: p_values)
                        for row in 0 ..< state.number_of_molecules {
                                t_test_fdrs[row][i] = fdrs[row]
                        }
                }

                filtered_search_rows = [Int](0 ..< state.number_of_molecules)
                sorted_rows = filtered_search_rows

                prepared = true
        }
}

class PairedTable: Component, UISearchBarDelegate, SpreadSheetDelegate {

        var paired_table_state: PairedTableState!

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
                paired_table_state = state.page_state as! PairedTableState

                let number_of_columns = 2 + 7 * paired_table_state.level_id_pairs.count + state.molecule_annotation_names.count
                column_widths = [Int](0 ..< number_of_columns).map {
                        let astring = self.header_astring(column: $0)
                        return astring.size().width + 40
                }

                column_widths[1] += 80
                for i in 0 ..< state.molecule_annotation_names.count {
                        column_widths[2 + 7 * paired_table_state.level_id_pairs.count + i] += 170
                }

                spread_sheet.reload()
                spread_sheet.set_content_offset(content_offset: paired_table_state.spread_sheet_content_offset)
        }

        func spread_sheet_header_height(spread_sheet spread_sheet: SpreadSheet) -> CGFloat {
                let height = astring_body(string: "Test string").size().height + 10
                return  height
        }

        func spread_sheet_row_heights(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                let height = astring_body(string: "Test string").size().height + 10
                return [CGFloat](count: paired_table_state.sorted_rows.count, repeatedValue: height)
        }

        func spread_sheet_column_widths(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                return column_widths
        }

        func spread_sheet_header_astring(spread_sheet spread_sheet: SpreadSheet, column: Int) -> Astring {
                return header_astring(column: column)
        }

        func spread_sheet_astring(spread_sheet spread_sheet: SpreadSheet, row: Int, column: Int) -> Astring {
                let original_row = paired_table_state.sorted_rows[row]

                let astring = cell_astring(row: original_row, column: column)

                return astring_shorten(string: astring, width: column_widths[column] - 10)
        }

        func spread_sheet_header_tapable(spread_sheet spread_sheet: SpreadSheet) -> Bool {
                return true
        }

        func spread_sheet_header_tapped(spread_sheet spread_sheet: SpreadSheet, column: Int) {
                if state.root_component.full_page.search_bar.isFirstResponder() {
                        state.root_component.full_page.search_bar.resignFirstResponder()
                } else if column == paired_table_state.sort_column {
                        paired_table_state.sort_direction_increasing = !paired_table_state.sort_direction_increasing
                        sort()
                        spread_sheet.reload()
                } else if column < 2 + 7 * paired_table_state.level_id_pairs.count && (column == 0 || [2, 5].indexOf((column - 2) % 7) != nil) {
                        paired_table_state.sort_column = column
                        paired_table_state.sort_direction_increasing = true
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
                                previous_molecule_numbers.append(paired_table_state.sorted_rows[i])
                        }

                        var next_molecule_numbers = [] as [Int]

                        for i in (row + 1) ..< paired_table_state.sorted_rows.count {
                                next_molecule_numbers.append(paired_table_state.sorted_rows[i])
                        }
                        next_molecule_numbers = Array(next_molecule_numbers.reverse())

                        let molecule_number = paired_table_state.sorted_rows[row]
                        let paired_plot_state = PairedPlotState(molecule_number: molecule_number, next_molecule_numbers: next_molecule_numbers, previous_molecule_numbers: previous_molecule_numbers, pairing_factor_id: paired_table_state.pairing_factor_id, comparison_factor_id: paired_table_state.comparison_factor_id, selected_level_ids: paired_table_state.comparison_level_ids)
                        state.navigate(page_state: paired_plot_state)
                        state.render()
                }
        }

        func spread_sheet_did_scroll(spread_sheet spread_sheet: SpreadSheet, content_offset: CGPoint) {
                paired_table_state.spread_sheet_content_offset = content_offset
        }

        override func search_action(search_string search_string: String) {
                if search_string != paired_table_state.search_string {
                        if search_string == "" {
                                paired_table_state.filtered_search_rows = [Int](0 ..< state.number_of_molecules)
                        } else {
                                let potential_rows = search_string.rangeOfString(paired_table_state.search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil ? paired_table_state.filtered_search_rows : [Int](0 ..< state.number_of_molecules)
                                paired_table_state.filtered_search_rows = filter_rows(search_string: search_string, potential_rows: potential_rows)
                        }
                        paired_table_state.search_string = search_string
                        sort()
                        spread_sheet.reload()
                }
        }

        func filter_rows(search_string search_string: String, potential_rows: [Int]) -> [Int] {
                var filtered_rows = [] as [Int]

                let columns_before_annotations = 2 + 7 * paired_table_state.level_id_pairs.count
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
                if paired_table_state.sort_column == 0 && paired_table_state.sort_direction_increasing {
                        paired_table_state.sorted_rows = paired_table_state.filtered_search_rows
                } else if paired_table_state.sort_column == 0 && !paired_table_state.sort_direction_increasing {
                        paired_table_state.sorted_rows = Array(paired_table_state.filtered_search_rows.reverse())
                } else {
                        let level_id_pair_index = (paired_table_state.sort_column - 2) / 7
                        if (paired_table_state.sort_column - 2) % 7 == 2 {
                                if paired_table_state.sort_direction_increasing {
                                        paired_table_state.sorted_rows = paired_table_state.filtered_search_rows.sort({
                                                self.paired_table_state.mean_values[$1][level_id_pair_index].isNaN || self.paired_table_state.mean_values[$0][level_id_pair_index] <= self.paired_table_state.mean_values[$1][level_id_pair_index]
                                        })
                                } else {
                                        paired_table_state.sorted_rows = paired_table_state.filtered_search_rows.sort({
                                                self.paired_table_state.mean_values[$1][level_id_pair_index].isNaN || self.paired_table_state.mean_values[$0][level_id_pair_index] > self.paired_table_state.mean_values[$1][level_id_pair_index]
                                        })
                                }
                        } else {
                                if paired_table_state.sort_direction_increasing {
                                        paired_table_state.sorted_rows = paired_table_state.filtered_search_rows.sort({
                                                self.paired_table_state.t_test_p_values[$1][level_id_pair_index].isNaN || self.paired_table_state.t_test_p_values[$0][level_id_pair_index] < self.paired_table_state.t_test_p_values[$1][level_id_pair_index]
                                        })
                                } else {
                                        paired_table_state.sorted_rows = paired_table_state.filtered_search_rows.sort({
                                                self.paired_table_state.t_test_p_values[$1][level_id_pair_index].isNaN || self.paired_table_state.t_test_p_values[$0][level_id_pair_index] > self.paired_table_state.t_test_p_values[$1][level_id_pair_index]
                                        })
                                }
                        }
                }
        }

        func txt_action() {
                let file_name_stem = "paired-test-table"
                let description = "Paired test with pairing factor = \(paired_table_state.pairing_factor_name) and comparison factor \(paired_table_state.comparison_factor_name)"

                state.progress_indicator_info = "The txt file is being created"
                state.progress_indicator_progress = 0
                state.render_type = RenderType.progress_indicator
                state.render()

                let serial_queue = dispatch_queue_create("paired table txt table", DISPATCH_QUEUE_SERIAL)

                dispatch_async(serial_queue, {
                        let txt_table = self.create_txt_table()

                        dispatch_async(dispatch_get_main_queue(), {
                                state.insert_txt_result_file(file_name_stem: file_name_stem, description: description, table: txt_table)
                                state.render()
                        })
                })
        }

        func create_txt_table() -> [[String]] {
                let number_of_columns = 2 + 7 * paired_table_state.level_id_pairs.count + state.molecule_annotation_names.count
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
                } else if column < 2 + 7 * paired_table_state.level_id_pairs.count {
                        let level_id_pair_index = (column - 2) / 7
                        let (level_id_1, level_id_2) = paired_table_state.level_id_pairs[level_id_pair_index]
                        let level_name_1 = paired_table_state.comparison_level_id_to_level_name[level_id_1]!
                        let level_name_2 = paired_table_state.comparison_level_id_to_level_name[level_id_2]!
                        let prefix = "\(level_name_1) - \(level_name_2) "
                        switch (column - 2) % 7 {
                        case 0:
                                return prefix + "number of positive_pairs"
                        case 1:
                                return prefix + "number of negative pairs"
                        case 2:
                                return prefix + "mean value"
                        case 3:
                                return prefix + "fold change"
                        case 4:
                                return prefix + "t-statistic"
                        case 5:
                                return prefix + "t-test p-value"
                        default:
                                return prefix + "t-test FDR"
                        }
                } else {
                        return state.molecule_annotation_names[column - 2 - 7 * paired_table_state.level_id_pairs.count]
                }
        }

        func header_astring(column column: Int) -> Astring {
                let string = header_string(column: column)
                if column == paired_table_state.sort_column {
                        let string_with_arrow = string + (paired_table_state.sort_direction_increasing ? " \u{25b2}" : " \u{25bc}")
                        return astring_font_size_color(string: string_with_arrow, font: nil, font_size: nil, color: UIColor.blueColor())
                } else if column < 2 + 7 * paired_table_state.level_id_pairs.count && (column == 0 || [2, 5].indexOf((column - 2) % 7) != nil) {
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
                } else if column < 2 + 7 * paired_table_state.level_id_pairs.count {
                        let level_id_pair_index = (column - 2) / 7
                        switch (column - 2) % 7 {
                        case 0:
                                return Value.Count(paired_table_state.positive_pairs[row][level_id_pair_index])
                        case 1:
                                return Value.Count(paired_table_state.negative_pairs[row][level_id_pair_index])
                        case 2:
                                return Value.Number(paired_table_state.mean_values[row][level_id_pair_index])
                        case 3:
                                return Value.Number(paired_table_state.fold_changes[row][level_id_pair_index])
                        case 4:
                                return Value.Statistic(paired_table_state.t_statistics[row][level_id_pair_index])
                        case 5:
                                return Value.Pvalue(paired_table_state.t_test_p_values[row][level_id_pair_index])
                        default:
                                return Value.Pvalue(paired_table_state.t_test_fdrs[row][level_id_pair_index])
                        }
                } else {
                        return Value.Name(state.molecule_annotation_values[column - 2 - 7 * paired_table_state.level_id_pairs.count][row])
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
                let pair_index = paired_table_state.sort_column < 2 ? 0 : (paired_table_state.sort_column - 2) / 7
                let column = 7 + 7 * pair_index

                let histogram_title = header_string(column: column)
                var p_values = [] as [Double]
                for i in 0 ..< paired_table_state.t_test_p_values.count {
                        p_values.append(paired_table_state.t_test_p_values[i][pair_index])
                }

                let p_value_histogram_state = PValueHistogramState(histogram_title: histogram_title, p_values: p_values)
                state.navigate(page_state: p_value_histogram_state)
                state.render()
        }

        override func molecule_range_create_data_set(index1 index1: Int, index2: Int) {
                let data_set_name = "Selected range from Paired test"

                var selected_molecule_indices = [Int](count: index2 + 1 - index1, repeatedValue: 0)
                var selected_values = [Double](count: state.number_of_samples * (index2 + 1 - index1), repeatedValue: 0)

                for i in 0 ..< index2 + 1 - index1 {
                        let original_row = paired_table_state.sorted_rows[index1 + i]
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
                let data_set_selection_state = DataSetSelectionState()
                state.navigate(page_state: data_set_selection_state)
                state.set_active_data_set(data_set_id: data_set_id)
                state.render()
        }

        func tap_action() {
                state.root_component.full_page.search_bar.resignFirstResponder()
        }
}

func values_for_offsets(values values: [Double], total_offset: Int, offsets: [Int]) -> [Double] {
        return offsets.map { values[total_offset + $0] }
}
