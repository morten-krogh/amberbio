import UIKit

class LinearRegressionTableState: PageState {

        var factor_id = 0
        var factor_name = ""

        var x_values = [] as [[Double]]
        var y_values = [] as [[Double]]
        var slopes = [] as [Double]
        var intercepts = [] as [Double]
        var p_values = [] as [Double]
        var false_discovery_rates = [] as [Double]

        var sort_column = 0
        var sort_direction_increasing = true
        var filtered_search_rows = [] as [Int]
        var sorted_rows = [] as [Int]
        var spread_sheet_content_offset = CGPoint.zeroPoint

        init(factor_id: Int) {
                super.init()
                name = "linear_regression_table"
                title = astring_body(string: "Linear regression table")
                info = "Table of linear regressions.\n\nThe p-value tests the null hypothesis that the slope is zero.\n\nA low p-value means that there is a linear trend with a non-zero slope.\n\nSee the manual for a full description.\n\nTap a row to see a linear plot of the molecule values."
                self.factor_id = factor_id

                txt_enabled = true
                histogram_enabled = true
                select_enabled = true
                search_enabled = true

                prepared = false
        }

        override func prepare() {
                let factor_index = state.factor_ids.indexOf(factor_id)!
                factor_name = state.factor_names[factor_index]
                let level_names = state.level_names_by_factor_and_sample[factor_index]
                var level_values = [Double](count: level_names.count, repeatedValue: Double.NaN)
                for i in 0 ..< level_names.count {
                        let scanner = NSScanner(string: level_names[i])
                        var value = 0 as Double
                        if scanner.scanDouble(&value) {
                                level_values[i] = value
                        }
                }

                for i in 0 ..< state.number_of_molecules {
                        var x_values = [] as [Double]
                        var y_values = [] as [Double]
                        let offset = i * state.number_of_samples
                        for j in 0 ..< state.number_of_samples {
                                if !level_values[j].isNaN {
                                        let value = state.values[offset + j]
                                        if !value.isNaN {
                                                x_values.append(level_values[j])
                                                y_values.append(value)
                                        }
                                }
                        }

                        var intercept = 0 as Double
                        var slope = 0 as Double
                        var p_value = 0 as Double

                        linear_regression(x_values, y_values, x_values.count, &intercept, &slope, &p_value)

                        self.x_values.append(x_values)
                        self.y_values.append(y_values)
                        slopes.append(slope)
                        intercepts.append(intercept)
                        p_values.append(p_value)
                }

                false_discovery_rates = stat_false_discovery_rate(p_values: p_values)

                filtered_search_rows = [Int](0 ..< state.number_of_molecules)
                sort()

                prepared = true
        }

        func search(search_string search_string: String) {
                if search_string != self.search_string {
                        if search_string == "" {
                                filtered_search_rows = [Int](0 ..< state.number_of_molecules)
                        } else {
                                let potential_rows = search_string.rangeOfString(self.search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil ? filtered_search_rows : [Int](0 ..< state.number_of_molecules)
                                filtered_search_rows = filter_rows(search_string: search_string, potential_rows: potential_rows)
                        }
                        self.search_string = search_string
                        sort()
                }
        }

        func filter_rows(search_string search_string: String, potential_rows: [Int]) -> [Int] {
                var filtered_rows = [] as [Int]

                let columns_before_annotations = 7
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
                        let string = column == 1 ? state.molecule_names[row] : state.molecule_annotation_values[column - 7][row]
                        if string.rangeOfString(search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                                return true
                        }
                }
                return false
        }

        func sort() {
                if sort_column == 0 && sort_direction_increasing {
                        sorted_rows = filtered_search_rows
                } else if sort_column == 0 && !sort_direction_increasing {
                        sorted_rows = Array(filtered_search_rows.reverse())
                } else if sort_column == 4 && sort_direction_increasing {
                        sorted_rows = filtered_search_rows.sort {
                                self.slopes[$0] < self.slopes[$1]
                        }
                } else if sort_column == 4 && !sort_direction_increasing {
                        sorted_rows = filtered_search_rows.sort {
                                self.slopes[$0] > self.slopes[$1]
                        }
                } else if sort_column == 5 && sort_direction_increasing {
                        sorted_rows = filtered_search_rows.sort {
                                self.p_values[$0] < self.p_values[$1]
                        }
                } else if sort_column == 5 && !sort_direction_increasing {
                        sorted_rows = filtered_search_rows.sort {
                                self.p_values[$0] > self.p_values[$1]
                        }
                }
        }
}

class LinearRegressionTable: Component, UISearchBarDelegate, SpreadSheetDelegate {

        var linear_regression_table_state: LinearRegressionTableState!

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
                linear_regression_table_state = state.page_state as! LinearRegressionTableState

                let number_of_columns = 7 + state.molecule_annotation_names.count
                column_widths = [Int](0 ..< number_of_columns).map {
                        let astring = self.header_astring(column: $0)
                        return astring.size().width + 40
                }

                spread_sheet.reload()
                spread_sheet.set_content_offset(content_offset: linear_regression_table_state.spread_sheet_content_offset)
        }

        func header_string(column column: Int) -> String {
                if column == 0 {
                        return "Molecule number"
                } else if column == 1 {
                        return "Molecule name"
                } else if column == 2 {
                        return "Number of points"
                } else if column == 3 {
                        return "Intercept"
                } else if column == 4 {
                        return "Slope"
                } else if column == 5 {
                        return "p-value"
                } else if column == 6 {
                        return "false discovery rate"
                } else {
                        return state.molecule_annotation_names[column - 7]
                }
        }

        func header_astring(column column: Int) -> Astring {
                let string = header_string(column: column)
                if column == linear_regression_table_state.sort_column {
                        let string_with_arrow = string + (linear_regression_table_state.sort_direction_increasing ? " \u{25b2}" : " \u{25bc}")
                        return astring_font_size_color(string: string_with_arrow, font: nil, font_size: nil, color: UIColor.blueColor())
                } else if column == 0 || column == 4 || column == 5 {
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
                } else if column == 2 {
                        return Value.Count(linear_regression_table_state.x_values[row].count)
                } else if column == 3 {
                        return Value.Number(linear_regression_table_state.intercepts[row])
                } else if column == 4 {
                        return Value.Number(linear_regression_table_state.slopes[row])
                } else if column == 5 {
                        return Value.Pvalue(linear_regression_table_state.p_values[row])
                } else if column == 6 {
                        return Value.Pvalue(linear_regression_table_state.false_discovery_rates[row])
                } else {
                        return Value.Name(state.molecule_annotation_values[column - 7][row])
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

        func spread_sheet_header_height(spread_sheet spread_sheet: SpreadSheet) -> CGFloat {
                let height = astring_body(string: "Test string").size().height + 10
                return  height
        }

        func spread_sheet_row_heights(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                let height = astring_body(string: "Test string").size().height + 10
                return [CGFloat](count: linear_regression_table_state.sorted_rows.count, repeatedValue: height)
        }

        func spread_sheet_column_widths(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                return column_widths
        }

        func spread_sheet_header_astring(spread_sheet spread_sheet: SpreadSheet, column: Int) -> Astring {
                return header_astring(column: column)
        }

        func spread_sheet_astring(spread_sheet spread_sheet: SpreadSheet, row: Int, column: Int) -> Astring {
                let original_row = linear_regression_table_state.sorted_rows[row]

                let astring = cell_astring(row: original_row, column: column)

                return astring_shorten(string: astring, width: column_widths[column] - 10)
        }

        func spread_sheet_header_tapable(spread_sheet spread_sheet: SpreadSheet) -> Bool {
                return true
        }

        func spread_sheet_header_tapped(spread_sheet spread_sheet: SpreadSheet, column: Int) {
                if state.root_component.full_page.search_bar.isFirstResponder() {
                        state.root_component.full_page.search_bar.resignFirstResponder()
                } else if column == linear_regression_table_state.sort_column {
                        linear_regression_table_state.sort_direction_increasing = !linear_regression_table_state.sort_direction_increasing
                        linear_regression_table_state.sort()
                        spread_sheet.reload()
                } else if column == 0 || column == 4 || column == 5 {
                        linear_regression_table_state.sort_column = column
                        linear_regression_table_state.sort_direction_increasing = true
                        linear_regression_table_state.sort()
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
                                previous_molecule_numbers.append(linear_regression_table_state.sorted_rows[i])
                        }

                        var next_molecule_numbers = [] as [Int]

                        for i in (row + 1) ..< linear_regression_table_state.sorted_rows.count {
                                next_molecule_numbers.append(linear_regression_table_state.sorted_rows[i])
                        }
                        next_molecule_numbers = Array(next_molecule_numbers.reverse())

                        let molecule_number = linear_regression_table_state.sorted_rows[row]
                        let linear_regression_plot_state = LinearRegressionPlotState(factor_id: linear_regression_table_state.factor_id, molecule_number: molecule_number, next_molecule_numbers: next_molecule_numbers, previous_molecule_numbers: previous_molecule_numbers, x_values: linear_regression_table_state.x_values, y_values: linear_regression_table_state.y_values, slopes: linear_regression_table_state.slopes, intercepts: linear_regression_table_state.intercepts)
                        state.navigate(page_state: linear_regression_plot_state)
                        state.render()
                }
        }
        
        func spread_sheet_did_scroll(spread_sheet spread_sheet: SpreadSheet, content_offset: CGPoint) {
                linear_regression_table_state.spread_sheet_content_offset = content_offset
        }

        override func search_action(search_string search_string: String) {
                linear_regression_table_state.search(search_string: search_string)
                spread_sheet.reload()
        }

        func histogram_action() {
                let histogram_title = "Linear regression p-values"
                let p_value_histogram_state = PValueHistogramState(histogram_title: histogram_title, p_values: linear_regression_table_state.p_values)
                state.navigate(page_state: p_value_histogram_state)
                state.render()
        }

        func txt_action() {
                let file_name_stem = "linear-regression-table"
                let description = "Linear regression with factor = \(linear_regression_table_state.factor_name)"

                state.progress_indicator_info = "The txt file is being created"
                state.progress_indicator_progress = 0
                state.render_type = RenderType.progress_indicator
                state.render()

                let serial_queue = dispatch_queue_create("linear regression txt table", DISPATCH_QUEUE_SERIAL)

                dispatch_async(serial_queue, {
                        let txt_table = self.create_txt_table()

                        dispatch_async(dispatch_get_main_queue(), {
                                state.insert_txt_result_file(file_name_stem: file_name_stem, description: description, table: txt_table)
                                state.render()
                        })
                })
        }

        func create_txt_table() -> [[String]] {
                let number_of_columns = 7 + state.molecule_annotation_names.count
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

        override func molecule_range_create_data_set(index1 index1: Int, index2: Int) {
                let data_set_name = "Selected range from linear regression"

                var selected_molecule_indices = [Int](count: index2 + 1 - index1, repeatedValue: 0)
                var selected_values = [Double](count: state.number_of_samples * (index2 + 1 - index1), repeatedValue: 0)

                for i in 0 ..< index2 + 1 - index1 {
                        let original_row = linear_regression_table_state.sorted_rows[index1 + i]
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
