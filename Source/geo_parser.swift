import Foundation

func string_from_data_range(data data: NSData, begin: Int, end: Int) -> String? {
        let range = NSRange(begin ..< end)
        let range_data = data.subdataWithRange(range)
        return String(data: range_data, encoding: NSUTF8StringEncoding)
}

func double_from_bytes(bytes bytes: UnsafePointer<UInt8>, begin: Int, end: Int) -> Double {
        var cstring = [Int8](count: end - begin + 1, repeatedValue: 0)
        for i in 0 ..< end - begin {
                cstring[i] = Int8(bytes[begin + i])
        }
        return parse_double(cstring, end - begin)
}

func find_location_of_data(data data: NSData, string: String, begin: Int) -> Int {
        let range = data.rangeOfData(string.dataUsingEncoding(NSUTF8StringEncoding)!, options: [], range: NSRange(begin ..< data.length))
        return range.location
}

func find_line(data data: NSData, begin: Int) -> String? {
        let location = find_location_of_data(data: data, string: "\n", begin: begin)
        return location == NSNotFound ? nil : string_from_data_range(data: data, begin: begin, end: location)
}

func find_start_of_next_line(data data: NSData, location: Int) -> Int {
        let location_newline = find_location_of_data(data: data, string: "\n", begin: location)
        return location_newline == NSNotFound ? NSNotFound : location_newline + 1
}

func split_and_trim(string string: String, separator: String) -> [String] {
        let comps = string.componentsSeparatedByString(separator)
        return comps.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }
}


class GDS {

        var valid = false
        var header = ""
        var number_of_molecules = 0
        var headers = [] as [String]
        var sample_column_min = -1
        var number_of_samples = 0
        var sample_names = [] as [String]
        var factor_value = [] as [String]
        var factor_src = [] as [String]
        var number_of_molecule_annotations = 0
        var molecule_annotation_names = [] as [String]
        var molecule_annotation_values = [] as [[String]]

        var values = [] as [Double]

        init(data: NSData) {

                if string_from_data_range(data: data, begin: data.length - 1, end: data.length) != "\n" { return }

                let location_dataset_title = find_location_of_data(data: data, string: "!dataset_title", begin: 0)
                if location_dataset_title == NSNotFound { return }

                let location_caret_after_dataset_title = find_location_of_data(data: data, string: "^", begin: location_dataset_title)
                if location_caret_after_dataset_title == NSNotFound { return }

                header = string_from_data_range(data: data, begin: location_dataset_title, end: location_caret_after_dataset_title) ?? ""

                let location_dataset_table_begin = find_location_of_data(data: data, string: "!dataset_table_begin", begin: location_caret_after_dataset_title)
                if location_dataset_table_begin == NSNotFound { return }

                let location_newline_after_header = find_location_of_data(data: data, string: "\n", begin: location_dataset_table_begin + 21)
                if location_newline_after_header == NSNotFound { return }

                if let header_line = string_from_data_range(data: data, begin: location_dataset_table_begin + 21, end: location_newline_after_header) {
                        headers = header_line.componentsSeparatedByString("\t")
                } else {
                        return
                }

                for i in 0 ..< headers.count {
                        if headers[i].hasPrefix("GSM") {
                                if sample_column_min == -1 {
                                        sample_column_min = i
                                }
                                sample_names.append(headers[i])
                        }
                }

                number_of_samples = sample_names.count

                var factors = [[], []] as [[String]]
                var location_factor_line = find_location_of_data(data: data, string: "#GSM", begin: 0)
                while (location_factor_line != NSNotFound) {
                        if let line = find_line(data: data, begin: location_factor_line) {
                                let parts = split_and_trim(string: line, separator: "=")
                                if parts.count == 2 {
                                        let comps = split_and_trim(string: parts[1], separator: ";")
                                        if comps.count == 2 {
                                                for i in 0 ..< 2 {
                                                        let elems = split_and_trim(string: comps[i], separator: ":")
                                                        if elems.count == 2 {
                                                                factors[i].append(elems[1])
                                                        }
                                                }
                                        }
                                }
                        }
                        location_factor_line = find_location_of_data(data: data, string: "#GSM", begin: location_factor_line + 3)
                }

                if factors[0].count != number_of_samples || factors[1].count != number_of_samples { return }

                factor_value = factors[0]
                factor_src = factors[1]

                var is_annotation = [Bool](count: headers.count, repeatedValue: false)
                for i in 0 ..< headers.count {
                        if i < sample_column_min {
                                is_annotation[i] = true
                                molecule_annotation_names.append(headers[i])
                        } else if i < sample_column_min + number_of_samples {
                                is_annotation[i] = false
                        } else if molecule_annotation_names.count < 8 {
                                is_annotation[i] = true
                                molecule_annotation_names.append(headers[i])
                        }
                }

                let location_dataset_table_end = find_location_of_data(data: data, string: "!dataset_table_end", begin: location_newline_after_header)
                if location_dataset_table_end == NSNotFound { return }

                molecule_annotation_values = [[String]](count: molecule_annotation_names.count, repeatedValue: [])

                var position_start = location_newline_after_header + 1
                var position = position_start
                var row = 0
                var col = 0
                let bytes = UnsafePointer<UInt8>(data.bytes)

                while position < location_dataset_table_end {
                        if bytes[position] == 9 || bytes[position] == 10 {
                                if col >= sample_column_min && col <= sample_column_min + number_of_samples - 1 {
                                        let value = double_from_bytes(bytes: bytes, begin: position_start, end: position)
                                        values.append(value)
                                } else if is_annotation[col] {
                                        let str = string_from_data_range(data: data, begin: position_start, end: position) ?? ""
                                        let index = col < sample_column_min ? col : col - number_of_samples
                                        molecule_annotation_values[index].append(str)
                                }

                                if bytes[position] == 9 {
                                        col++
                                } else {
                                        row++
                                        col = 0
                                }

                                position++
                                position_start = position
                        } else {
                                position++
                        }
                }

                number_of_molecules = molecule_annotation_values[0].count

                valid = true
        }
}

class GSE {

        var valid = false
        var header = ""
        var number_of_molecules = 0
        var headers = [] as [String]
        var sample_column_min = -1
        var number_of_samples = 0
        var sample_names = [] as [String]
        var factor_names = [] as [String]
        var level_names_for_factor = [] as [[String]]
        var number_of_molecule_annotations = 0
        var molecule_annotation_names = [] as [String]
        var molecule_annotation_values = [] as [[String]]

        var values = [] as [Double]

        init(data: NSData) {
                let bytes = UnsafePointer<UInt8>(data.bytes)

                if string_from_data_range(data: data, begin: data.length - 1, end: data.length) != "\n" { return }

                let location_series = find_location_of_data(data: data, string: "^SERIES", begin: 0)
                if location_series == NSNotFound { return }

                let location_platform = find_location_of_data(data: data, string: "^PLATFORM", begin: location_series)
                if location_platform == NSNotFound { return }

                let location_series_relation = find_location_of_data(data: data, string: "!Series_relation", begin: location_series)
                if location_series == NSNotFound {
                        header = string_from_data_range(data: data, begin: location_series, end: location_platform) ?? ""
                } else {
                        header = string_from_data_range(data: data, begin: location_series, end: location_series_relation) ?? ""
                }

                let location_platform_table_begin = find_location_of_data(data: data, string: "!platform_table_begin", begin: location_platform)
                if location_platform_table_begin == NSNotFound { return }

                let location_platform_table_end = find_location_of_data(data: data, string: "!platform_table_end", begin: location_platform_table_begin)
                if location_platform_table_end == NSNotFound { return }

                let location_platform_table_begin_newline = find_location_of_data(data: data, string: "\n", begin: location_platform_table_begin)
                if location_platform_table_begin_newline == NSNotFound { return }

                let location_platform_header = location_platform_table_begin_newline + 1

                var platform_header = [] as [String]
                if let platform_header_line = find_line(data: data, begin: location_platform_header) {
                        platform_header = platform_header_line.componentsSeparatedByString("\t")
                }

                if platform_header.isEmpty { return }

                var molecule_annotation_columns = [0] as [Int]
                var molecule_annotation_names = [platform_header[0]] as [String]

                for name in ["GB_ACC", "Gene Title", "Gene Symbol", "ENTREZ_GENE_ID", "RefSeq Transcript ID"] {
                        if let index = platform_header.indexOf(name) where index != 0 {
                                molecule_annotation_columns.append(index)
                                molecule_annotation_names.append(platform_header[index])
                        }
                }

                let location_platform_newline = find_location_of_data(data: data, string: "\n", begin: location_platform_header)

                molecule_annotation_values = [[String]](count: molecule_annotation_names.count, repeatedValue: [])

                var position_start = location_platform_newline + 1
                var position = position_start
                var row = 0
                var col = 0


                while position < location_platform_table_end {
                        if bytes[position] == 9 || bytes[position] == 10 {
                                if let col_index = molecule_annotation_columns.indexOf(col) {
                                        let str = string_from_data_range(data: data, begin: position_start, end: position) ?? ""
                                        molecule_annotation_values[col_index].append(str)
                                }

                                if bytes[position] == 9 {
                                        col++
                                } else {
                                        row++
                                        col = 0
                                }

                                position++
                                position_start = position
                        } else {
                                position++
                        }
                }

                number_of_molecules = molecule_annotation_values[0].count

                var id_to_row = [:] as [String: Int]
                for i in 0 ..< molecule_annotation_values[0].count {
                        id_to_row[molecule_annotation_values[0][i]] = i
                }

                var values_for_samples = [] as [[Double]]

                let suggested_factor_names = ["Sample title", "Source name", "Organism",  "Treatment protocol", "Sample characteristics"]
                let factor_keys = ["Sample_title", "Sample_source_name", "Sample_organism", "Sample_treatment_protocol", "Sample_characteristics"]

                var levels = [[String]](count: suggested_factor_names.count, repeatedValue: [])

                var location_sample = find_location_of_data(data: data, string: "^SAMPLE", begin: location_platform_table_end)
                while location_sample != NSNotFound {
                        let sample_line = find_line(data: data, begin: location_sample) ?? ""
                        let sample_parts = split_and_trim(string: sample_line, separator: "=")
                        if sample_parts.count != 2 { return }
                        sample_names.append(sample_parts[1])
                        var current_values_for_samples = [Double](count: number_of_molecules, repeatedValue: Double.NaN)

                        for i in 0 ..< suggested_factor_names.count {
                                let location = find_location_of_data(data: data, string: factor_keys[i], begin: location_sample)
                                if location == NSNotFound { continue }
                                if let line = find_line(data: data, begin: location) {
                                        let parts = split_and_trim(string: line, separator: "=")
                                        if parts.count != 2 { continue }
                                        levels[i].append(parts[1])
                                }
                        }


                        let location_sample_table_begin = find_location_of_data(data: data, string: "!sample_table_begin", begin: location_sample)
                        if location_sample_table_begin == NSNotFound { return }

                        let location_sample_table_end = find_location_of_data(data: data, string: "!sample_table_end", begin: location_sample_table_begin)
                        if location_sample_table_end == NSNotFound { return }

                        let location_value_header = find_start_of_next_line(data: data, location: location_sample_table_begin)
                        let header_line = find_line(data: data, begin: location_value_header) ?? ""
                        let headers = header_line.componentsSeparatedByString("\t")
                        let col_value = headers.indexOf("VALUE")
                        if col_value == nil || col_value < 1 { return }

                        position_start = find_start_of_next_line(data: data, location: location_value_header)
                        position = position_start
                        row = 0
                        col = 0

                        var id = ""
                        var value = 0.0
                        while position < location_sample_table_end {
                                if bytes[position] == 9 || bytes[position] == 10 {
                                        if col == 0 {
                                                id = string_from_data_range(data: data, begin: position_start, end: position) ?? ""
                                        } else if col == col_value {
                                                value = double_from_bytes(bytes: bytes, begin: position_start, end: position)
                                        }

                                        if bytes[position] == 9 {
                                                col++
                                        } else {
                                                if let row = id_to_row[id] {
                                                        current_values_for_samples[row] = value
                                                }
                                                row++
                                                col = 0
                                        }

                                        position++
                                        position_start = position
                                } else {
                                        position++
                                }
                        }

                        values_for_samples.append(current_values_for_samples)
                        location_sample = find_location_of_data(data: data, string: "^SAMPLE", begin: location_sample_table_end)
                }

                number_of_samples = sample_names.count

                for i in 0 ..< suggested_factor_names.count {
                        var all_empty = true
                        for level in levels[i] {
                                if level != "" {
                                        all_empty = false
                                        break
                                }
                        }
                        if !all_empty {
                                factor_names.append(suggested_factor_names[i])
                                level_names_for_factor.append(levels[i])
                        }
                }

                values = [Double](count: number_of_molecules * number_of_samples, repeatedValue: Double.NaN)
                for col in 0 ..< number_of_samples {
                        for row in 0 ..< number_of_molecules {
                                let index = row * number_of_samples + col
                                let value = values_for_samples[col][row]
                                values[index] = value
                        }
                }

                valid = true
        }
}
