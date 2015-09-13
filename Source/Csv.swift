import Foundation

class Csv {

        class func string_from(table table: [[String]]) -> String {
                var result = ""
                var first_field_in_row = true
                for row in table {
                        for col in row {
                                if !first_field_in_row {
                                        result += ","
                                }
                                first_field_in_row = false
                                result += field_contains_only_text_data(field: col) ? col : escape(field: col)
                        }
                        result += "\r\n"
                        first_field_in_row = true
                }
                return result
        }

        class func field_contains_only_text_data(field field: String) -> Bool {
                for ch in field.characters {
                        if ch == "," || ch == "\r" || ch == "\n" || ch == "\"" {
                                return false
                        }
                }
                return true
        }

        class func escape (field field: String) -> String {
                var result = "\""
                for ch in field.characters {
                        if ch == "\"" {
                                result += "\"\""
                        } else {
                                result.append(ch)
                        }
                }
                result += "\""
                return result
        }

        class func string_from(array array: [String]) -> String {
                var table = [] as [[String]]
                for record in array {
                        table.append([record])
                }
                return Csv.string_from(table: table)
        }

        class func resultFileInfo(description description: String, project_name: String, data_set_name: String, user_name: String) -> String {
                let info_array = result_file_info_array(description: description, project_name: project_name, data_set_name: data_set_name, user_name: user_name)
                return Csv.string_from(array: info_array)
        }
}