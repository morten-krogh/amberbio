import Foundation

func swift_parse_find_separator(string string: String) -> Character? {
        var current_index = string.startIndex
        var comma_found = false
        while current_index < string.endIndex {
                switch string[current_index] {
                case "\t":
                        return "\t"
                case ",":
                        comma_found = true
                        current_index = current_index.advancedBy(1)
                default:
                        current_index = current_index.advancedBy(1)
                }
        }
        return comma_found ? "," : nil
}

func parse_separator_separated_string(string string: String, separator: Character) -> [[String]] {
        var result = [] as [[String]]

        var current_row = [] as [String]
        var previous_index = string.startIndex
        var current_index = string.startIndex
        while current_index < string.endIndex {
                switch string[current_index] {
                case separator:
                        let cell = trim(string: string.substringWithRange(previous_index ..< current_index))
                        current_row.append(cell)
                        current_index = current_index.advancedBy(1)
                        previous_index = current_index
                case "\r", "\n", "\r\n":
                        let ch = string[current_index]
                        let cell = trim(string: string.substringWithRange(previous_index ..< current_index))
                        current_row.append(cell)
                        result.append(current_row)
                        current_row = []
                        current_index = current_index.advancedBy(1)
                        if ch == "\r" && current_index < string.endIndex && string[current_index] == "\n" {
                                current_index = current_index.advancedBy(1)
                        }
                        previous_index = current_index
                default:
                        current_index = current_index.advancedBy(1)
                }
        }

        if current_index > previous_index {
                let cell = trim(string: string.substringWithRange(previous_index ..< current_index))
                current_row.append(cell)
        }

        if !current_row.isEmpty {
                result.append(current_row)
        }

        return result
}

func parse_project_file(data data: NSData) -> (sample_names: [String]?, molecule_names: [String]?, values: [Double]?, error: String?) {
        let (table, error) = parse_data(data: data)

        if let table = table {
                var sample_names = table[0]
                sample_names.removeAtIndex(0)
                if let duplicate_element = find_duplicate_element(array: sample_names) {
                        let error = "\(duplicate_element) is a duplicated sample name"
                        return (nil, nil, nil, error)
                }

                var molecule_names = [] as [String]
                var values = [] as [Double]

                for var i = 1; i < table.count; ++i {
                        let row = table[i]
                        molecule_names.append(row[0])
                        for var j = 1; j < row.count; ++j {
                                if let value = string_to_double(string: row[j]) {
                                        values.append(value)
                                } else if is_missing_value(string: row[j]) {
                                        values.append(Double.NaN)
                                } else {
                                        let error = "\(row[j]) is not a valid measurement value"
                                        return (nil, nil, nil, error)
                                }
                        }
                }

                if let duplicate_element = find_duplicate_element(array: molecule_names) {
                        let error = "\(duplicate_element) is a duplicated molecule name"
                        return (nil, nil, nil, error)
                }

                return (sample_names, molecule_names, values, nil)
        } else {
                return (nil, nil, nil, error)
        }
}

func parse_factor_file(data data: NSData, current_sample_names: [String], current_factor_names: [String]) -> (factor_names: [String], sample_levels: [[String]], error: String?) {
        let (table, error) = parse_data(data: data)

        if let table = table {
                if table.isEmpty {
                        let error = "There are no rows in the file"
                        return ([], [], error)
                }

                if table.count == 1 {
                        let error = "There is only one row in the file"
                        return ([], [], error)
                }

                if table.count > 200 {
                        let error = "There are too many rows in the file"
                        return ([], [], error)
                }

                var sample_name_columns = [:] as [String: Int]
                for i in 1 ..< table[0].count {
                        sample_name_columns[table[0][i]] = i
                }

                for current_sample_name in current_sample_names {
                        if sample_name_columns[current_sample_name] == nil {
                                let error = "The sample \(current_sample_name) is absent in the file"
                                return ([], [], error)
                        }
                }

                var factor_names = [] as [String]
                var sample_levels = [] as [[String]]

                for var i = 1; i < table.count; ++i {
                        let factor_name = table[i][0]

                        if factor_name.isEmpty {
                                let error = "There is an empty factor name"
                                return ([], [], error)
                        }

                        if current_factor_names.indexOf(factor_name) != nil || factor_names.indexOf(factor_name) != nil {
                                continue
                        }

                        factor_names.append(factor_name)

                        var values: [String] = []
                        for current_sample_name in current_sample_names {
                                let column = sample_name_columns[current_sample_name]!
                                var value = table[i][column]
                                value = value.isEmpty ? "(empty value)" : value

                                values.append(value)
                        }
                        sample_levels.append(values)
                }

                return (factor_names, sample_levels, nil)
        } else {
                return ([], [], error)
        }
}

func parse_annotation_file(data data: NSData, molecule_names: [String], current_annotation_names: [String]) -> (annotation_names: [String], annotation_values: [[String]], error: String?) {
        let (table, error) = parse_data(data: data)

        if let table = table {
                if table.isEmpty {
                        let error = "The table is empty"
                        return ([], [], error)
                }

                if table[0].count == 1 {
                        let error = "There is only one column in the file"
                        return ([], [], error)
                }

                var molecule_name_rows = [:] as [String: Int]
                for i in 1 ..< table.count {
                        molecule_name_rows[table[i][0]] = i
                }

                for molecule_name in molecule_names {
                        if molecule_name_rows[molecule_name] == nil {
                                let error = "The molecule name \(molecule_name) is absent"
                                return ([], [], error)
                        }
                }

                var annotation_names = [] as [String]
                var annotation_values = [] as [[String]]

                for var i = 1; i < table[0].count; ++i {
                        let annotation_name = table[0][i]

                        if annotation_name.isEmpty {
                                let error = "There is an empty annotation name in the first row"
                                return ([], [], error)
                        }

                        if current_annotation_names.indexOf(annotation_name) != nil || annotation_names.indexOf(annotation_name) != nil {
                                continue
                        }

                        var values = [] as [String]
                        for molecule_name in molecule_names {
                                let row = molecule_name_rows[molecule_name]!
                                let value = table[row][i]
                                values.append(value)
                        }

                        annotation_names.append(annotation_name)
                        annotation_values.append(values)
                }
                return (annotation_names, annotation_values, nil)
        } else {
                return ([], [], error)
        }
}

func parse_data(data data: NSData) -> (table: [[String]]?, error: String?) {
        if let string = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                if let separator = swift_parse_find_separator(string: string) {
                        let table = parse_separator_separated_string(string: string, separator: separator)
                        return parse_extract_rectangular_table(table: table)
                } else {
                        return (nil, "no separator")
                }
        } else {
                return (nil, "The file can not be read")
        }
}




func parse_extract_rectangular_table(table table: [[String]]) -> (table: [[String]]?, error: String?) {
        var result = [] as [[String]]

        func is_row_empty (row row: [String]) -> Bool {
                for str in row {
                        if str != "" {
                                return false
                        }
                }
                return true
        }

        for row in table {
                if is_row_empty(row: row) {
                        if !result.isEmpty {
                                return (result, nil)
                        }
                } else {
                        if let last_row = result.last {
                                if row.count != last_row.count {
                                        return (nil, "The rows do not all have the same number of columns")
                                }
                        }
                        result.append(row)
                }
        }
        
        return (result, nil)
}

func find_duplicate_element<T: Hashable>(array array: [T]) -> T? {
        var set = [] as Set<T>
        
        for element in array {
                if set.contains(element) {
                        return element
                } else {
                        set.insert(element)
                }
        }
        return nil
}

func is_missing_value (string string: String) -> Bool {
        switch string {
        case "", "NA", "na", "NaN", "NAN", "nan":
                return true
        default:
                return false
        }
}

func string_to_double (string string: String) -> Double? {
        let scanner = NSScanner(string: string)
        var result = 0.0
        let success = scanner.scanDouble(&result)
        if success && scanner.atEnd {
                return result
        }

        let comma_scanner = NSScanner(string: string)
        comma_scanner.locale = NSLocale(localeIdentifier: "eu")
        var comma_result = 0.0
        let comma_success = comma_scanner.scanDouble(&comma_result)
        if comma_success && comma_scanner.atEnd {
                return comma_result
        }

        return nil
}

func trim(string string: String) -> String {
        return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
}
