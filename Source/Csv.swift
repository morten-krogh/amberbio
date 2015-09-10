import Foundation

class Csv {

        class func stringFrom(table table: [[String]]) -> String {
                var result = ""
                var firstFieldInRow = true
                for row in table {
                        for col in row {
                                if !firstFieldInRow {
                                        result += ","
                                }
                                firstFieldInRow = false
                                result += fieldContainsOnlyTextData(col) ? col : escape(col)
                        }
                        result += "\r\n"
                        firstFieldInRow = true
                }
                return result
        }

        class func fieldContainsOnlyTextData(field: String) -> Bool {
                for ch in field.characters {
                        if ch == "," || ch == "\r" || ch == "\n" || ch == "\"" {
                                return false
                        }
                }
                return true
        }

        class func escape (field: String) -> String {
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

        class func stringFrom(array array: [String]) -> String {
                var table = [] as [[String]]
                for record in array {
                        table.append([record])
                }
                return Csv.stringFrom(table: table)
        }

        class func resultFileInfo(description description: String, project_name: String, data_set_name: String, user_name: String) -> String {
                let info_array = result_file_info_array(description: description, project_name: project_name, data_set_name: data_set_name, user_name: user_name)
                return Csv.stringFrom(array: info_array)
        }
}