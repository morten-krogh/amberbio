import Foundation

//func csv_string_from(table table: [[String]]) -> String {
//        var result = ""
//        var first_field_in_row = true
//        for row in table {
//                for col in row {
//                        if !first_field_in_row {
//                                result += ","
//                        }
//                        first_field_in_row = false
//                        result += csv_field_contains_only_text_data(field: col) ? col : csv_escape(field: col)
//                }
//                result += "\r\n"
//                first_field_in_row = true
//        }
//        return result
//}
//
//func csv_field_contains_only_text_data(field field: String) -> Bool {
//        for ch in field.characters {
//                if ch == "," || ch == "\r" || ch == "\n" || ch == "\"" {
//                        return false
//                }
//        }
//        return true
//}
//
//func csv_escape (field field: String) -> String {
//        var result = "\""
//        for ch in field.characters {
//                if ch == "\"" {
//                        result += "\"\""
//                } else {
//                        result.append(ch)
//                }
//        }
//        result += "\""
//        return result
//}
//
//func csv_string_from(array array: [String]) -> String {
//        var table = [] as [[String]]
//        for record in array {
//                table.append([record])
//        }
//        return csv_string_from(table: table)
//}
//
//func csv_result_file_info(description description: String, project_name: String, data_set_name: String, user_name: String) -> String {
//        let info_array = result_file_info_array(description: description, project_name: project_name, data_set_name: data_set_name, user_name: user_name)
//        return csv_string_from(array: info_array)
//}
