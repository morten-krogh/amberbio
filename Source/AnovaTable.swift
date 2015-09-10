import UIKit

class AnovaTableState: PageState {

        var factor_id = 0
        var level_ids = [] as [Int]

        var factor_name = ""
        var level_names = [] as [String]

        var f_statistics = [] as [Double]
        var p_values = [] as [Double]
        var false_discovery_rates = [] as [Double]
        var present_values = [] as [[Int]]
        var missing_values = [] as [[Int]]
        var mean_values = [] as [[Double]]
        var standard_deviations = [] as [[Double]]

        var sort_column = 0
        var sort_direction_increasing = true
        var filtered_search_rows = [] as [Int]
        var sorted_rows = [] as [Int]
        var spread_sheet_content_offset = CGPoint.zeroPoint

        init(factor_id: Int, level_ids: [Int]) {
                super.init()
                name = "anova_table"
                info = "Tap a row to see a plot of the values for that molecule.\n\nSort the table by tapping a header."
                self.factor_id = factor_id
                self.level_ids = level_ids
                let factor_index = state.factor_ids.indexOf(factor_id)!
                factor_name = state.factor_names[factor_index]
                title = astring_body(string: "Anova table for \(factor_name)")
                level_names = []
                for level_id in level_ids {
                        let level_index = state.level_ids_by_factor[factor_index].indexOf(level_id)!
                        level_names.append(state.level_names_by_factor[factor_index][level_index])
                }
                txt_enabled = true
                histogram_enabled = true
                select_enabled = true
                search_enabled = true

                prepared = false
        }

        override func prepare() {

                var level_id_sample_offsets = [] as [[Int]]
                for level_id in level_ids {
                        level_id_sample_offsets.append(state.offsets_by_level_id[level_id] ?? [] as [Int])
                }

                f_statistics = []
                p_values = []
                present_values = []
                missing_values = []
                mean_values = []
                standard_deviations = []

                for i in 0 ..< state.number_of_molecules {
                        let anova = Anova(values: state.values, offset: i * state.number_of_samples, indices_for_levels: level_id_sample_offsets)
                        f_statistics.append(anova.f_statistics)
                        p_values.append(anova.p_value)
                        present_values.append(anova.number_of_present_values)
                        missing_values.append(anova.number_of_missing_values)
                        mean_values.append(anova.means)
                        standard_deviations.append(anova.standard_deviations)
                }

                false_discovery_rates = stat_false_discovery_rate(p_values: p_values)

                filtered_search_rows = [Int](0 ..< state.number_of_molecules)
                sorted_rows = filtered_search_rows

                prepared = true
        }
}

class AnovaTable: Component, SpreadSheetDelegate {

        var column_widths = [] as [CGFloat]

        var anova_table_state: AnovaTableState!

        let spread_sheet = SpreadSheet()

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
                anova_table_state = state.page_state as! AnovaTableState

                let number_of_columns = 5 + 4 * anova_table_state.level_ids.count + state.molecule_annotation_names.count
                column_widths = [Int](0 ..< number_of_columns).map {
                        let astring = self.header_astring(column: $0)
                        return astring.size().width + 40
                }
                column_widths[1] += 80
                for i in 0 ..< state.molecule_annotation_names.count {
                        column_widths[5 + 4 * anova_table_state.level_ids.count + i] += 170
                }

                spread_sheet.reload()
                spread_sheet.set_content_offset(content_offset: anova_table_state.spread_sheet_content_offset)
        }

        func spread_sheet_header_height(spread_sheet spread_sheet: SpreadSheet) -> CGFloat {
                let height = astring_body(string: "Test string").size().height + 10
                return  height
        }

        func spread_sheet_row_heights(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                let height = astring_body(string: "Test string").size().height + 10
                return [CGFloat](count: anova_table_state.sorted_rows.count, repeatedValue: height)
        }

        func spread_sheet_column_widths(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                return column_widths
        }

        func spread_sheet_header_astring(spread_sheet spread_sheet: SpreadSheet, column: Int) -> Astring {
                return header_astring(column: column)
        }

        func spread_sheet_astring(spread_sheet spread_sheet: SpreadSheet, row: Int, column: Int) -> Astring {
                let original_row = anova_table_state.sorted_rows[row]

                let astring = cell_astring(row: original_row, column: column)

                return astring_shorten(string: astring, width: column_widths[column] - 10)
        }

        func spread_sheet_header_tapable(spread_sheet spread_sheet: SpreadSheet) -> Bool {
                return true
        }

        func spread_sheet_header_tapped(spread_sheet spread_sheet: SpreadSheet, column: Int) {
                if state.root_component.full_page.search_bar.isFirstResponder() {
                        state.root_component.full_page.search_bar.resignFirstResponder()
                } else if column == anova_table_state.sort_column {
                        anova_table_state.sort_direction_increasing = !anova_table_state.sort_direction_increasing
                        sort()
                        spread_sheet.reload()
                } else if column == 0 || column == 3 {
                        anova_table_state.sort_column = column
                        anova_table_state.sort_direction_increasing = true
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
                                previous_molecule_numbers.append(anova_table_state.sorted_rows[i])
                        }

                        var next_molecule_numbers = [] as [Int]

                        for i in (row + 1) ..< anova_table_state.sorted_rows.count {
                                next_molecule_numbers.append(anova_table_state.sorted_rows[i])
                        }
                        next_molecule_numbers = Array(next_molecule_numbers.reverse())

                        let molecule_number = anova_table_state.sorted_rows[row]

                        let anova_plot_state = AnovaPlotState(molecule_number: molecule_number, next_molecule_numbers: next_molecule_numbers, previous_molecule_numbers: previous_molecule_numbers, factor_id: anova_table_state.factor_id, selected_level_ids: anova_table_state.level_ids)
                        state.navigate(page_state: anova_plot_state)
                        state.render()
                }
        }

        func spread_sheet_did_scroll(spread_sheet spread_sheet: SpreadSheet, content_offset: CGPoint) {
                anova_table_state.spread_sheet_content_offset = content_offset
        }

        override func search_action(search_string search_string: String) {
                if search_string != anova_table_state.search_string {
                        if search_string == "" {
                                anova_table_state.filtered_search_rows = [Int](0 ..< state.number_of_molecules)
                        } else {
                                let potential_rows = search_string.rangeOfString(anova_table_state.search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil ? anova_table_state.filtered_search_rows : [Int](0 ..< state.number_of_molecules)
                                anova_table_state.filtered_search_rows = filter_rows(search_string: search_string, potential_rows: potential_rows)
                        }
                        anova_table_state.search_string = search_string
                        sort()
                        spread_sheet.reload()
                }
        }

        func filter_rows(search_string search_string: String, potential_rows: [Int]) -> [Int] {
                var filtered_rows = [] as [Int]

                var columns = [1]
                for i in 0 ..< state.molecule_annotation_names.count {
                        let column = 5 + 4 * anova_table_state.level_ids.count + i
                        columns.append(column)
                }

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
                if anova_table_state.sort_column == 0 && anova_table_state.sort_direction_increasing {
                        anova_table_state.sorted_rows = anova_table_state.filtered_search_rows
                } else if anova_table_state.sort_column == 0 && !anova_table_state.sort_direction_increasing {
                        anova_table_state.sorted_rows = Array(anova_table_state.filtered_search_rows.reverse())
                } else if anova_table_state.sort_direction_increasing {
                        anova_table_state.sorted_rows = anova_table_state.filtered_search_rows.sort({
                                self.anova_table_state.p_values[$1].isNaN || self.anova_table_state.p_values[$0] < self.anova_table_state.p_values[$1]
                        })
                } else {
                        anova_table_state.sorted_rows = anova_table_state.filtered_search_rows.sort({
                                self.anova_table_state.p_values[$1].isNaN || self.anova_table_state.p_values[$0] > self.anova_table_state.p_values[$1]
                        })
                }
        }

        func txt_action() {
                let file_name_stem = "anova-table"
                let description = "Anova table for \(anova_table_state.factor_name)"

                state.progress_indicator_info = "The txt file is being created"
                state.progress_indicator_progress = 0
                state.render_type = RenderType.progress_indicator
                state.render()

                let serial_queue = dispatch_queue_create("anova table txt file", DISPATCH_QUEUE_SERIAL)

                dispatch_async(serial_queue, {
                        let txt_table = self.create_txt_table()

                        dispatch_async(dispatch_get_main_queue(), {
                                state.insert_txt_result_file(file_name_stem: file_name_stem, description: description, table: txt_table)
                                state.render()
                        })
                })
        }

        func create_txt_table() -> [[String]] {
                let number_of_columns = 5 + 4 * anova_table_state.level_names.count + state.molecule_annotation_names.count
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
                if column < 5 {
                        return ["Molecule number", "Molecule name", "F-statistics", "p-value", "False discovery rate"][column]
                } else if column < 5 + 4 * anova_table_state.level_names.count {
                        let level_name = anova_table_state.level_names[(column - 5) / 4]
                        switch (column - 5) % 4 {
                        case 0:
                                return "\(level_name) present values"
                        case 1:
                                return "\(level_name) missing values"
                        case 2:
                                return "\(level_name) mean value"
                        default:
                                return "\(level_name) standard deviation"
                        }
                } else {
                        return state.molecule_annotation_names[column - 5 - 4 * anova_table_state.level_names.count]
                }
        }

        func header_astring(column column: Int) -> Astring {
                let string = header_string(column: column)
                if column == anova_table_state.sort_column {
                        let string_with_arrow = string + (anova_table_state.sort_direction_increasing ? " \u{25b2}" : " \u{25bc}")
                        return astring_font_size_color(string: string_with_arrow, font: nil, font_size: nil, color: UIColor.blueColor())
                } else if column == 0 || column == 3 {
                        return astring_body(string: string + " \u{25b2}")
                } else {
                        return astring_body(string: string)
                }
        }

        func cell_string(row row: Int, column: Int) -> String {
                if column == 0 {
                        return "\(row + 1)"
                } else if column == 1 {
                        return state.molecule_names[row]
                } else if column == 2 {
                        return "\(anova_table_state.f_statistics[row])"
                } else if column == 3 {
                        return "\(anova_table_state.p_values[row])"
                } else if column == 4 {
                        return "\(anova_table_state.false_discovery_rates[row])"
                } else if column < 5 + 4 * anova_table_state.level_names.count {
                        let level_index = (column - 5) / 4
                        switch (column - 5) % 4 {
                        case 0:
                                return "\(anova_table_state.present_values[row][level_index])"
                        case 1:
                                return "\(anova_table_state.missing_values[row][level_index])"
                        case 2:
                                return "\(anova_table_state.mean_values[row][level_index])"
                        default:
                                return "\(anova_table_state.standard_deviations[row][level_index])"
                        }
                } else {
                        return state.molecule_annotation_values[column - 5 - 4 * anova_table_state.level_names.count][row]
                }
        }

        func cell_astring(row row: Int, column: Int) -> Astring {
                let original_row = row

                if column == 2 {
                      return decimal_astring(number: anova_table_state.f_statistics[original_row], fraction_digits: 2)
                } else if column == 3 {
                        return astring_from_p_value(p_value: anova_table_state.p_values[original_row], cutoff: 0.05)
                } else if column == 4 {
                        return astring_from_p_value(p_value: anova_table_state.false_discovery_rates[original_row], cutoff: 0.05)
                } else if column < 5 + 4 * anova_table_state.level_names.count {
                        let level_index = (column - 5) / 4
                        switch (column - 5) % 4 {
                        case 2:
                                return decimal_astring(number: anova_table_state.mean_values[row][level_index], fraction_digits: 1)
                        case 3:
                                return decimal_astring(number: anova_table_state.standard_deviations[row][level_index], fraction_digits: 1)
                        default:
                                return astring_body(string: cell_string(row: row, column: column))
                        }
                } else {
                        return astring_body(string: cell_string(row: row, column: column))
                }
        }

        func histogram_action() {
                let histogram_title = "Anova p-values"
                let p_value_histogram_state = PValueHistogramState(histogram_title: histogram_title, p_values: anova_table_state.p_values)
                state.navigate(page_state: p_value_histogram_state)
                state.render()
        }

        override func molecule_range_create_data_set(index1 index1: Int, index2: Int) {
                let data_set_name = "Selected range from Anova"

                var selected_molecule_indices = [Int](count: index2 + 1 - index1, repeatedValue: 0)
                var selected_values = [Double](count: state.number_of_samples * (index2 + 1 - index1), repeatedValue: 0)
                for i in 0 ..< index2 + 1 - index1 {
                        let original_row = anova_table_state.sorted_rows[index1 + i]
                        let molecule_index = state.molecule_indices[original_row]
                        selected_molecule_indices[i] = molecule_index
                        let offset_old = original_row * state.number_of_samples
                        let offset_new = i * state.number_of_samples
                        for j in 0 ..< state.number_of_samples {
                                selected_values[offset_new + j] = state.values[offset_old + j]
                        }
                }

                let project_note_text = "Creation of data set \"\(data_set_name)\" by selecting \(index2 + 1 - index1) molecules."

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
