import Foundation

func txt_result_file(name name: String, description: String, project_name: String, data_set_name: String, user_name: String, table: [[String]]) -> (file_name: String, content: NSData) {
        var txt_string = string_from_table(table: table) + "\n\n\n\n"

        for info in result_file_info_array(description: description, project_name: project_name, data_set_name: data_set_name, user_name: user_name) {
                txt_string += info + "\n"
        }

        let file_name = file_name_for_result_file(name: name, ext: "txt")

        let data = txt_string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) ?? NSData()

        return (file_name, data)
}

func string_from_table(table table: [[String]]) -> String {
        var result = ""
        var first_field_in_row = true
        for row in table {
                for col in row {
                        if !first_field_in_row {
                                result += "\t"
                        }
                        first_field_in_row = false
                        result += col
                }
                result += "\n"
                first_field_in_row = true
        }
        return result
}

func result_file_info_array(description description: String, project_name: String, data_set_name: String, user_name: String) -> [String] {
        var info = ["Description: \(description)", "Project: \(project_name)", "Data set: \(data_set_name)", "User name: \(user_name)"]

        let formattedDate = date_formatted_string(date: NSDate())
        info += ["Date of creation: \(formattedDate)", "Created by the Amberbio app"]

        return info
}
