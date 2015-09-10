import UIKit

class DataSetTableState: PageState {

        var txt_table = [] as [[String]]

        var filtered_search_rows = [] as [Int]
        var spread_sheet_content_offset = CGPoint.zero

        override init() {
                super.init()
                name = "data_set_table"
                title = astring_body(string: "Data Set Table")
                info = "A table of the active data set.\n\nTap a row to see a plot of the values."

                txt_enabled = true
                search_enabled = true

                prepared = false
        }

        override func prepare() {
                txt_table = data_set_table_txt_table_without_values(sample_names: state.sample_names, annotation_names: state.molecule_annotation_names, molecule_names: state.molecule_names, molecule_annotation_values: state.molecule_annotation_values, factor_names: state.factor_names, sample_level_names: state.level_names_by_factor_and_sample, values: state.values)

                filtered_search_rows = [Int](0 ..< txt_table.count - 1)

                prepared = true
        }
}

class DataSetTable: Component, SpreadSheetDelegate {

        var data_set_table_state: DataSetTableState!

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
                data_set_table_state = state.page_state as! DataSetTableState

                column_widths = data_set_table_state.txt_table[0].map { max(astring_body(string: $0).size().width, 30) }
                let margin = 20 as CGFloat
                column_widths = column_widths.map { $0 + 2 * margin }
                column_widths[0] += 70
                for i in 0 ..< state.molecule_annotation_names.count {
                        column_widths[1 + state.sample_names.count + i] += 170
                }

                spread_sheet.reload()
                spread_sheet.set_content_offset(content_offset: data_set_table_state.spread_sheet_content_offset)
        }

        func spread_sheet_header_height(spread_sheet spread_sheet: SpreadSheet) -> CGFloat {
                let height = astring_body(string: "Test string").size().height + 10
                return  height
        }

        func spread_sheet_row_heights(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                let height = astring_body(string: "Test string").size().height + 10
                return [CGFloat](count: data_set_table_state.filtered_search_rows.count, repeatedValue: height)
        }

        func spread_sheet_column_widths(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat] {
                return column_widths
        }

        func spread_sheet_header_astring(spread_sheet spread_sheet: SpreadSheet, column: Int) -> Astring {
                return astring_body(string: data_set_table_state.txt_table[0][column])
        }

        func spread_sheet_astring(spread_sheet spread_sheet: SpreadSheet, row: Int, column: Int) -> Astring {
                let astring: Astring

                let original_row = data_set_table_state.filtered_search_rows[row]

                if original_row < state.number_of_molecules && column > 0 && column < state.number_of_samples + 1 {
                        let value = state.values[original_row * state.number_of_samples + column - 1]
                        astring = decimal_astring(number: value, fraction_digits: 2)
                } else {
                        astring = astring_body(string: data_set_table_state.txt_table[original_row + 1][column])
                }

                return astring_shorten(string: astring, width: column_widths[column] - 10)
        }

        func spread_sheet_header_tapable(spread_sheet spread_sheet: SpreadSheet) -> Bool {
                return false
        }

        func spread_sheet_header_tapped(spread_sheet spread_sheet: SpreadSheet, column: Int) {}

        func spread_sheet_tapable(spread_sheet spread_sheet: SpreadSheet) -> Bool {
                return true
        }

        func spread_sheet_tapped(spread_sheet spread_sheet: SpreadSheet, row: Int, column: Int) {
                if state.root_component.full_page.search_bar.isFirstResponder() {
                        state.root_component.full_page.search_bar.resignFirstResponder()
                        return
                }

                let original_row = data_set_table_state.filtered_search_rows[row]

                if original_row < state.number_of_molecules {

                        let molecule_number = original_row

                        var previous_molecule_numbers = [] as [Int]

                        for i in 0 ..< row {
                                if data_set_table_state.filtered_search_rows[i] < state.number_of_molecules {
                                        previous_molecule_numbers.append(data_set_table_state.filtered_search_rows[i])
                                }
                        }

                        var next_molecule_numbers = [] as [Int]

                        for i in (row + 1) ..< data_set_table_state.filtered_search_rows.count {
                                if data_set_table_state.filtered_search_rows[i] < state.number_of_molecules {
                                        next_molecule_numbers.append(data_set_table_state.filtered_search_rows[i])
                                }
                        }
                        next_molecule_numbers = Array(next_molecule_numbers.reverse())

                        let selected_factor_id = 0

                        let single_molecule_state = SingleMoleculeState(molecule_number: molecule_number, next_molecule_numbers: next_molecule_numbers, previous_molecule_numbers: previous_molecule_numbers, selected_factor_id: selected_factor_id)
                        state.navigate(page_state: single_molecule_state)
                        state.render()
                }
        }

        func spread_sheet_did_scroll(spread_sheet spread_sheet: SpreadSheet, content_offset: CGPoint) {
                data_set_table_state.spread_sheet_content_offset = content_offset
        }

        override func search_action(search_string search_string: String) {
                if search_string != data_set_table_state.search_string {
                        if search_string == "" {
                                data_set_table_state.filtered_search_rows = [Int](0 ..< data_set_table_state.txt_table.count - 1)
                        } else {
                                let potential_rows = search_string.rangeOfString(data_set_table_state.search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil ? data_set_table_state.filtered_search_rows : [Int](0 ..< data_set_table_state.txt_table.count - 1)
                                data_set_table_state.filtered_search_rows = filter_rows(search_string: search_string, txt_table: data_set_table_state.txt_table, number_of_molecules: state.number_of_molecules, number_of_samples: state.number_of_samples, potential_rows: potential_rows)
                        }
                        data_set_table_state.search_string = search_string
                        spread_sheet.reload()
                }
        }

        func txt_action() {
                let file_name_stem = "data-set-table"
                let description = "Table of the data set"

                state.progress_indicator_info = "The txt file is being created"
                state.progress_indicator_progress = 0
                state.render_type = RenderType.progress_indicator
                state.render()

                let serial_queue = dispatch_queue_create("data set table txt file", DISPATCH_QUEUE_SERIAL)

                dispatch_async(serial_queue, {
                        data_set_table_insert_values_in_txt_table(txt_table: &self.data_set_table_state.txt_table, values: state.values, number_of_samples: state.number_of_samples)

                        dispatch_async(dispatch_get_main_queue(), {
                                state.insert_txt_result_file(file_name_stem: file_name_stem, description: description, table: self.data_set_table_state.txt_table)
                                state.render()
                        })
                })
        }

        func tap_action() {
                state.root_component.full_page.search_bar.resignFirstResponder()
        }
}

func filter_rows(search_string search_string: String, txt_table: [[String]], number_of_molecules: Int, number_of_samples: Int, potential_rows: [Int]) -> [Int] {
        var filtered_rows = [] as [Int]

        let columns_values = [0] + [Int]((1 + number_of_samples) ..< (txt_table[0].count))
        let columns_factors = [Int](0 ..< txt_table[0].count)

        for row in potential_rows {
                let columns = row < number_of_molecules ? columns_values : columns_factors
                if check_search_string_in_row(search_string: search_string, txt_table: txt_table, row: row, columns: columns) {
                        filtered_rows.append(row)
                }
        }

        return filtered_rows
}

func check_search_string_in_row(search_string search_string: String, txt_table: [[String]], row: Int, columns: [Int]) -> Bool {
        for column in columns {
                let string = txt_table[row + 1][column]
                if string.rangeOfString(search_string, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                        return true
                }
        }
        return false
}

func data_set_table_txt_table_without_values(sample_names sample_names: [String], annotation_names: [String], molecule_names: [String], molecule_annotation_values: [[String]], factor_names: [String], sample_level_names: [[String]], values: [Double]) -> [[String]] {

        let number_of_rows = 1 + molecule_names.count + 1 + (factor_names.count > 0 ? factor_names.count : 0)
        let number_of_columns = 1 + sample_names.count + annotation_names.count

        var txt_table = [[String]](count: number_of_rows, repeatedValue: [String](count: number_of_columns, repeatedValue: ""))

        txt_table[0][0] = "Molecule names"
        for i in 0 ..< sample_names.count {
                txt_table[0][1 + i] = sample_names[i]
        }

        for i in 0 ..< annotation_names.count {
                txt_table[0][1 + sample_names.count + i] = annotation_names[i]
        }

        for i in 0 ..< molecule_names.count {
                txt_table[1 + i][0] = molecule_names[i]

                for j in 0 ..< annotation_names.count {
                        txt_table[1 + i][1 + sample_names.count + j] = molecule_annotation_values[j][i]
                }
        }

        if factor_names.count > 0 {
                for i in 0 ..< factor_names.count {
                        txt_table[1 + molecule_names.count + 1 + i][0] = factor_names[i]
                        for j in 0 ..< sample_level_names[i].count {
                                txt_table[1 + molecule_names.count + 1 + i][1 + j] = sample_level_names[i][j]
                        }
                }
        }

        return txt_table
}

func data_set_table_insert_values_in_txt_table(inout txt_table txt_table: [[String]], values: [Double], number_of_samples: Int) {

        let number_of_molecules = values.count / number_of_samples

        for i in 0 ..< number_of_molecules {
                for j in 0 ..< number_of_samples {
                        txt_table[1 + i][1 + j] = "\(values[i * number_of_samples + j])"
                }
                state.progress_indicator_step(total: number_of_molecules, index: i, min: 0, max: 100, step_size: 100)
        }
}

func data_set_table_factors(factor_names factor_names: [String], sample_level_names: [[String]], annotation_names: [String]) -> (txt_factors: [[String]], table_factors: [[Astring]]) {

        if factor_names.isEmpty {
                return ([], [])
        }

        let number_of_columns = 1 + sample_level_names[0].count + annotation_names.count
        var txt_factors = [[String]](count: factor_names.count + 1, repeatedValue: [String](count: number_of_columns, repeatedValue: ""))

        for i in 0 ..< factor_names.count {
                txt_factors[1 + i][0] = factor_names[i]

                let sample_level_names_for_factor = sample_level_names[i]

                for j in 0 ..< sample_level_names_for_factor.count {
                        txt_factors[1 + i][1 + j] = sample_level_names_for_factor[j]
                }
        }

        let table_factors = txt_factors.map { (row: [String]) in row.map { astring_body(string: $0) } }

        return (txt_factors, table_factors)
}

func data_set_table_txt_table(txt_headers txt_headers: [String], molecule_names: [String], txt_factors: [[String]], molecule_annotation_values: [[String]], values: [Double]) -> [[String]] {

        let number_of_rows = 1 + molecule_names.count + 1 + (txt_factors.count > 0 ? txt_factors.count : 0)
        let number_of_columns = txt_headers.count
        var txt_table = [[String]](count: number_of_rows, repeatedValue: [String](count: number_of_columns, repeatedValue: ""))

        txt_table[0] = txt_headers

        for i in 0 ..< molecule_names.count {
                txt_table[1 + i][0] = molecule_names[i]
        }

        let number_of_samples = txt_headers.count - 1 - molecule_annotation_values.count
        var offset = 0
        for i in 0 ..< molecule_names.count {
                for j in 0 ..< number_of_samples {
                        let value = values[offset]
                        offset++
                        txt_table[1 + i][1 + j] = "\(value)"
                }
        }

        for i in 0 ..< molecule_annotation_values.count {
                for j in 0 ..< molecule_annotation_values[i].count {
                        txt_table[1 + j][1 + number_of_samples + i] = molecule_annotation_values[i][j]
                }
        }

        if txt_factors.count > 0 {
                for i in 0 ..< txt_factors.count {
                        txt_table[1 + molecule_names.count + i] = txt_factors[i]
                }
        }

	return txt_table
}
