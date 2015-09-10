import Foundation

func parse_create_cchar(buffer buffer: [CChar], length: Int) -> [CChar] {
        var start = 0
        for (; start < length; start++) {
                if buffer[start] != 32 {
                        break
                }
        }

        if start == length {
                return [CChar](count: 1, repeatedValue: 0)
        }

        var end = length - 1
        for (; end >= 0; end--) {
                if buffer[end] != 32 {
                        break
                }
        }

        let trimmed_length = end - start + 1
        var result = [CChar](count: trimmed_length, repeatedValue: 0)
        for i in 0 ..< trimmed_length {
                result[i] = buffer[start + i]
        }

        return result
}

func parse_import_data(data data: NSData, double_values: Bool) -> (header_names: [String], row_names: [String], values: [Double], number_of_present_values: Int, cells: [[String]], error: String?) {

        let data_bytes = UnsafePointer<CChar>(data.bytes)
        let data_length = data.length

        var number_of_lines = 0
        var max_row_length = 0

        c_parse_number_of_lines_and_longest_row_length(data_bytes, data_length, &number_of_lines, &max_row_length)

        var newlines = [Int](count: number_of_lines, repeatedValue: 0)

        c_parse_newlines(data_bytes, data_length, &newlines)

        let number_of_empty_rows_at_top = c_parse_number_of_empty_rows_at_top(data_bytes, data_length)

        if number_of_empty_rows_at_top == number_of_lines {
                let error = "All rows are empty in the file"
                return ([], [], [], 0, [], error)
        }

        let number_of_empty_rows_at_bottom = c_parse_number_of_empty_rows_at_bottom(data_bytes, data_length)

        var number_of_tokens = [Int](count: number_of_lines - number_of_empty_rows_at_top - number_of_empty_rows_at_bottom, repeatedValue: 0)
        for i in 0 ..< number_of_lines - number_of_empty_rows_at_top - number_of_empty_rows_at_bottom {
                let row = number_of_empty_rows_at_top + i
                number_of_tokens[i] = c_parse_number_of_tokens(data_bytes, row == 0 ? 0 : newlines[row - 1], newlines[row])
        }

        if Set<Int>(number_of_tokens).count > 1 {
                let error = "All rows do not have the same number of columns"
                return ([], [], [], 0, [], error)
        }

        let common_number_of_tokens = number_of_tokens[0]

        var buffer = [CChar](count: max_row_length, repeatedValue: CChar())

        var header_names = [] as [String]
        var start = number_of_empty_rows_at_top == 0 ? 0 : newlines[number_of_empty_rows_at_top - 1] + 1
        var token_length = 0
        while start < newlines[number_of_empty_rows_at_top] {
                c_parse_next_token(data_bytes, start, newlines[number_of_empty_rows_at_top], &buffer, &token_length)
                start += token_length + 1
                let token = NSString(bytes: buffer, length: token_length, encoding: NSUTF8StringEncoding) as? String ?? ""
                header_names.append(token.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        }

        header_names.removeAtIndex(0)
        let header_set = Set<String>(header_names)
        if header_set.count != header_names.count {
                let error = "There are duplicate column names"
                return ([], [], [], 0, [], error)
        }

        var row_names = [] as [String]
        for i in 1 ..< number_of_lines - number_of_empty_rows_at_top - number_of_empty_rows_at_bottom {
                let row = number_of_empty_rows_at_top + i
                c_parse_next_token(data_bytes, newlines[row - 1] + 1, newlines[row], &buffer, &token_length)
                let token = NSString(bytes: buffer, length: token_length, encoding: NSUTF8StringEncoding) as? String ?? ""
                row_names.append(token.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        }

        let row_name_set = Set<String>(row_names)
        if row_name_set.count != row_names.count {
                let error = "There are duplicate row names"
                return ([], [], [], 0, [], error)
        }

        if double_values {
                let number_of_doubles_per_row = common_number_of_tokens - 1

                var values = [Double](count: row_names.count * number_of_doubles_per_row, repeatedValue: Double.NaN)
                var number_of_present_values = 0

                for i in 1 ..< number_of_lines - number_of_empty_rows_at_top - number_of_empty_rows_at_bottom {
                        let row = number_of_empty_rows_at_top + i
                        let value_start = (i - 1) * number_of_doubles_per_row
                        let number_of_doubles_for_row = c_parse_doubles(data_bytes, newlines[row - 1] + 1, newlines[row], 1, &values, value_start)
                        number_of_present_values += number_of_doubles_for_row
                }

                return (header_names, row_names, values, number_of_present_values, [], nil)
        } else {
                var cells = [[String]](count: common_number_of_tokens - 1, repeatedValue: [])

                for i in 1 ..< number_of_lines - number_of_empty_rows_at_top - number_of_empty_rows_at_bottom {
                        let row = number_of_empty_rows_at_top + i
                        var start = newlines[row - 1] + 1
                        var token_length = 0
                        for j in 0 ..< common_number_of_tokens {
                                c_parse_next_token(data_bytes, start, newlines[row], &buffer, &token_length)
                                if j > 0 {
                                        if let token = NSString(bytes: buffer, length: token_length, encoding: NSUTF8StringEncoding) as? String {
                                                cells[j - 1].append(token.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                                        }
                                }
                                start += token_length + 1
                        }
                }
                
                return (header_names, row_names, [], 0, cells, nil)
        }
}
