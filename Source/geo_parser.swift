import Foundation

func string_from_data_range(data data: NSData, begin: Int, end: Int) -> String? {
        let range = NSRange(begin ..< end)
        let range_data = data.subdataWithRange(range)
        return String(data: range_data, encoding: NSUTF8StringEncoding)
}

func find_range_of_data(data data: NSData, string: String, location: Int) -> Int {
        let range = data.rangeOfData(string.dataUsingEncoding(NSUTF8StringEncoding)!, options: [], range: NSRange(location ..< data.length))
        return range.location
}

class GDS {

        var valid = false
        var header = ""
        var number_of_molecules = 0
        var number_of_headers = ""
        var headers = [] as [String]
        var samples_column_min = -1
        var number_of_samples = 0
        var sample_names = [] as [String]
        var number_of_molecule_annotations = 0
        var molecule_annotation_names = [] as [String]
        var molecule_annotation_values = [] as [[String]]

        var values = [] as [Double]

        init(data: NSData) {

                if string_from_data_range(data: data, begin: data.length - 1, end: data.length) != "\n" { return }

                let location_dataset_title = find_range_of_data(data: data, string: "!dataset_title", location: 0)
                if location_dataset_title == NSNotFound { return }

                let location_caret_after_dataset_title = find_range_of_data(data: data, string: "^", location: location_dataset_title)
                if location_caret_after_dataset_title == NSNotFound { return }

                header = string_from_data_range(data: data, begin: location_dataset_title, end: location_caret_after_dataset_title) ?? ""

                let location_dataset_table_begin = find_range_of_data(data: data, string: "!dataset_table_begin", location: location_caret_after_dataset_title)
                if location_dataset_table_begin == NSNotFound { return }

                let location_newline_after_headers = find_range_of_data(data: data, string: "\n", location: location_dataset_table_begin + 21)
                if location_newline_after_headers == NSNotFound { return }

                




//
//                const char* position_headers = position_dataset_table_begin + 21;
//                if (position_headers - string > length - 1) return gds;
//                gds->number_of_headers = 1;
//                for (const char* c = position_headers; *c != '\n'; c++) {
//                        if (*c == '\t') gds->number_of_headers++;
//                }
//                gds->headers = malloc(gds->number_of_headers * sizeof(*gds->headers));
//                const char* position_header_start = position_headers;
//                for (long i = 0; i < gds->number_of_headers; i++) {
//                        const char* position;
//                        for (position = position_header_start; *position != '\t' && *position != '\n'; position++);
//                        long header_length = position - position_header_start;
//                        char* header = malloc(header_length + 1);
//                        memcpy(header, position_header_start, header_length);
//                        header[header_length] = '\0';
//                        gds->headers[i] = header;
//                        position_header_start = position + 1;
//                }
//
//
//        




                valid = true
        }


}


/*

struct gds* gds_new(const void* bytes, const long length)
{

        const char* position_of_feature_count = strnstr(position_of_dataset_title, "!dataset_feature_count", end - position_of_dataset_title);
        gds->number_of_molecules = strtol(position_of_feature_count + 25, NULL, 10);

        const char* position_dataset_table_begin = strnstr(position_of_caret_after_dataset_title, "!dataset_table_begin", end - position_of_caret_after_dataset_title);
        if (position_dataset_table_begin == NULL) return gds;
        const char* position_headers = position_dataset_table_begin + 21;
        if (position_headers - string > length - 1) return gds;
        gds->number_of_headers = 1;
        for (const char* c = position_headers; *c != '\n'; c++) {
                if (*c == '\t') gds->number_of_headers++;
        }
        gds->headers = malloc(gds->number_of_headers * sizeof(*gds->headers));
        const char* position_header_start = position_headers;
        for (long i = 0; i < gds->number_of_headers; i++) {
                const char* position;
                for (position = position_header_start; *position != '\t' && *position != '\n'; position++);
                long header_length = position - position_header_start;
                char* header = malloc(header_length + 1);
                memcpy(header, position_header_start, header_length);
                header[header_length] = '\0';
                gds->headers[i] = header;
                position_header_start = position + 1;
        }

        gds->sample_column_min = -1;
        gds->number_of_samples = 0;
        for (long i = 0; i < gds->number_of_headers; i++) {
                if (strstr(gds->headers[i], "GSM") == gds->headers[i]) {
                        if (gds->sample_column_min == -1) {
                                gds->sample_column_min = i;
                        }
                        gds->number_of_samples++;
                } else if (gds->sample_column_min != -1) {
                        break;
                }
        }

        gds->sample_names = malloc(gds->number_of_samples * sizeof(*gds->sample_names));
        for (long i = 0; i < gds->number_of_samples; i++) {
                gds->sample_names[i] = gds->headers[gds->sample_column_min + i];
        }

        const char* position_cells = strnstr(position_headers, "\n", end - position_headers - 1) + 1;

        const char* position_dataset_table_end = strnstr(position_cells, "!dataset_table_end", end - position_cells);
        if (position_dataset_table_end == NULL) return gds;

        if (gds->number_of_molecules == 0 || gds->number_of_samples == 0) return gds;

        gds->values = malloc(gds->number_of_samples * gds->number_of_molecules * sizeof(double));

        bool is_annotation[gds->number_of_headers];
        gds->number_of_molecule_annotations = 0;
        for (long i = 0; i < gds->number_of_headers; i++) {
                if (i < gds->sample_column_min) {
                        is_annotation[i] = true;
                        gds->number_of_molecule_annotations++;
                } else if (i < gds-> sample_column_min + gds->number_of_samples) {
                        is_annotation[i] = false;
                } else if (gds->number_of_molecule_annotations < 8) {
                        is_annotation[i] = true;
                        gds->number_of_molecule_annotations++;
                } else {
                        is_annotation[i] = false;
                }
        }

        gds->molecule_annotation_names = malloc(gds->number_of_molecule_annotations * sizeof(*gds->molecule_annotation_names));
        long counter = 0;
        for (long i = 0; i < gds->number_of_headers; i++) {
                if (is_annotation[i]) {
                        gds->molecule_annotation_names[counter] = gds->headers[i];
                        counter++;
                }
        }




        const char* position_start = position_cells;
        const char* position = position_start;
        long row = 0;
        long col = 0;
        while (position < position_dataset_table_end) {
                if (row >= gds->number_of_molecules || col >= gds->number_of_headers) return gds;
                if (*position == '\t' || *position == '\n') {
                        long cell_length = position - position_start;
                        if (col >= gds->sample_column_min  && col < gds->sample_column_min + gds->number_of_samples) {
                                char str[cell_length + 1];
                                memcpy(str, position_start, cell_length);
                                str[cell_length] = '\0';
                                char* endptr = str;

                                double value = strtod(str, &endptr);
                                if (endptr != str + cell_length) {
                                        value = nanf(NULL);
                                }

                                long index = row * gds->number_of_samples + col - gds->sample_column_min;
                                gds->values[index] = value;

                                if (row <= 1) {
                                        printf("%li, %li, %li, %f\n", row, col, cell_length, value);
                                }

                        }



                        if (*position == '\t') {
                                col++;
                        } else {
                                row++;
                                col = 0;
                        }

                        position++;
                        position_start = position;


                } else {
                        position++;
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
