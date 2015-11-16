import Foundation

func string_from_data_range(data data: NSData, begin: Int, end: Int) -> String? {
        let range = NSRange(begin ..< end)
        let range_data = data.subdataWithRange(range)
        return String(data: range_data, encoding: NSUTF8StringEncoding)
}

func double_from_data(data data: NSData, begin: Int, end: Int) -> Double {
        let string = string_from_data_range(data: data, begin: begin, end: end) ?? ""
        let scanner = NSScanner(string: string)
        var result = 0.0
        let success = scanner.scanDouble(&result)
        return success && scanner.atEnd ? result : Double.NaN
}

func find_location_of_data(data data: NSData, string: String, begin: Int) -> Int {
        let range = data.rangeOfData(string.dataUsingEncoding(NSUTF8StringEncoding)!, options: [], range: NSRange(begin ..< data.length))
        return range.location
}

func find_line(data data: NSData, begin: Int) -> String? {
        let location = find_location_of_data(data: data, string: "\n", begin: begin)
        return location == NSNotFound ? nil : string_from_data_range(data: data, begin: begin, end: location)
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
                                        let value = double_from_data(data: data, begin: position_start, end: position)
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

                print(sample_names)
                print(molecule_annotation_names)
                print(molecule_annotation_values[7][0])
                print(values[0], values[8])

                print(number_of_molecules)
                print(values[values.count - 2])

                valid = true
        }


}


/*

struct gds* gds_new(const void* bytes, const long length)
{

        const char* position_of_feature_count = strnstr(position_of_dataset_title, "!dataset_feature_count", end - position_of_dataset_title);
        gds->number_of_molecules = strtol(position_of_feature_count + 25, NULL, 10);





        const char* position_cells = strnstr(position_headers, "\n", end - position_headers - 1) + 1;

        const char* position_dataset_table_end = strnstr(position_cells, "!dataset_table_end", end - position_cells);
        if (position_dataset_table_end == NULL) return gds;

        if (gds->number_of_molecules == 0 || gds->number_of_samples == 0) return gds;

        gds->values = malloc(gds->number_of_samples * gds->number_of_molecules * sizeof(double));



        gds->molecule_annotation_names = malloc(gds->number_of_molecule_annotations * sizeof(*gds->molecule_annotation_names));
        long counter = 0;
        for (long i = 0; i < gds->number_of_headers; i++) {
                if (is_annotation[i]) {
                        gds->molecule_annotation_names[counter] = gds->headers[i];
                        counter++;
                }
        }
















        //
        //        long position_of_dataset_table_begin = -1;
        //
        //        for (long i = 0; i < length - 19; i++) {
        //                if (strncmp(string + i, "!dataset_table_begin", 20) == 0) {
        //                        position_of_dataset_table_begin = i;
        //                        break;
        //                }
        //        }
        
        
        
        
        
        //        if (position_of_dataset_table_begin == 1) return;
        
        //        long header_length = position_of_dataset_table_begin - 1;
        
        
        
        
        //        long result_length = cstring_max_length > header_length ? header_length : cstring_max_length;
        //        memcpy(cstring, bytes, result_length);
        //        cstring[result_length + 1] = '\0';
        
        gds->valid = true;
        
        return gds;
}

*/
