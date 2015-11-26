import Foundation

protocol ParserSpreadsheetProtocol: class {

        var number_of_rows: Int {get}
        var number_of_columns: Int {get}

        func cell_string(row row: Int, column: Int) -> String
        func cell_values_row_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double]
        func cell_values_column_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double]
}

class ParserSpreadsheetTxt: ParserSpreadsheetProtocol {

        let data: NSData

        var number_of_rows = 0
        var number_of_columns = 0

        var separator_positions = [] as [Int]

        init(data: NSData) {
                self.data = data

                let separator = parse_find_separator(data.bytes, data.length)

                parse_number_of_rows_and_columns(data.bytes, data.length, separator, &number_of_rows, &number_of_columns)

                separator_positions = [Int](count: number_of_rows * number_of_columns, repeatedValue: -1)
                parse_separator_positions(data.bytes, data.length, separator, number_of_rows, number_of_columns, &separator_positions)
        }

        func cell_string(row row: Int, column: Int) -> String {
                let index = row * number_of_columns + column

                var position_0 = index > 0 ? separator_positions[index - 1] + 1 : 0
                let position_1 = separator_positions[index]
                if position_0 > position_1 {
                        position_0 = position_1
                }
                var cstring = [CChar](count: position_1 - position_0 + 1, repeatedValue: 0)
                parse_read_cstring(data.bytes, position_0, position_1, &cstring)

                let str = String.fromCString(cstring) ?? ""

                return str
        }

        func cell_values_row_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double] {
                var values = [Double](count: (row_1 - row_0 + 1) * (col_1 - col_0 + 1), repeatedValue: Double.NaN)
                parse_read_double_values(data.bytes, number_of_rows, number_of_columns, separator_positions, row_0, row_1, col_0, col_1, 1, &values)
                return values
        }

        func cell_values_column_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double] {
                var values = [Double](count: (row_1 - row_0 + 1) * (col_1 - col_0 + 1), repeatedValue: Double.NaN)
                parse_read_double_values(data.bytes, number_of_rows, number_of_columns, separator_positions, row_0, row_1, col_0, col_1, 0, &values)
                return values
        }
}

class ParserSpreadsheetXlsx: ParserSpreadsheetProtocol {

        let data: NSData

        var number_of_rows = 0
        var number_of_columns = 0

        var cells = [] as [[BRACell]]

        init(data: NSData) {
                self.data = data

                let url = file_create_temp_file_url(content: data)
                let path = url.path

                let spreadsheet = BRAOfficeDocumentPackage.open(path)
                let worksheets = spreadsheet.workbook.worksheets
                if !worksheets.isEmpty {
                        let worksheet = worksheets[0] as! BRAWorksheet
                        number_of_rows = worksheet.rows.count
                        for i in 0 ..< worksheet.rows.count {
                                var row_of_cells = [] as [BRACell]

                                let row = worksheet.rows[i] as! BRARow
                                for i in 0 ..< row.cells.count {
                                        let cell = row.cells[i] as! BRACell
                                        row_of_cells.append(cell)
                                }

                                if row_of_cells.count > number_of_columns {
                                        number_of_columns = row_of_cells.count
                                }

                                cells.append(row_of_cells)
                        }
                }
        }

        func cell_string(row row: Int, column: Int) -> String {
                let row_of_cells = cells[row]
                if column < row_of_cells.count {
                        let cell = row_of_cells[column]
                        return cell.stringValue()
                } else {
                        return ""
                }
        }

        func cell_values_row_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double] {
                var values = [Double](count: (row_1 - row_0 + 1) * (col_1 - col_0 + 1), repeatedValue: Double.NaN)

                for i in 0 ..< row_1 - row_0 + 1 {
                        for j in 0 ..< col_1 - col_0 + 1 {
                                let row_of_cells = cells[row_0 + i]
                                let col = col_0 + j
                                if col < row_of_cells.count {
                                        let cell = row_of_cells[col]
                                        let index = i * (col_1 - col_0 + 1) + j
                                        values[index] = cell_value(cell: cell)
                                }
                        }


                }

                return values
        }

        func cell_values_column_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double] {
                var values = [Double](count: (row_1 - row_0 + 1) * (col_1 - col_0 + 1), repeatedValue: Double.NaN)

                for j in 0 ..< col_1 - col_0 + 1 {
                        for i in 0 ..< row_1 - row_0 + 1 {
                                let row_of_cells = cells[row_0 + i]
                                let col = col_0 + j
                                if col < row_of_cells.count {
                                        let cell = row_of_cells[col]
                                        let index = j * (row_1 - row_0 + 1) + i
                                        values[index] = cell_value(cell: cell)
                                }
                        }
                }

                return values
        }

        func cell_value(cell cell: BRACell) -> Double {
                if cell.type == BRACellContentTypeNumber || cell.type == BRACellContentTypeUnknown {
                        return Double(cell.floatValue())
                } else {
                        let str = cell.stringValue()
                        var c_string = str.cStringUsingEncoding(NSUTF8StringEncoding) ?? []
                        let value = parse_parse_double(&c_string)
                        return value
                }
        }
}
