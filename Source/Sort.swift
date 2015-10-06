import Foundation

func sort_level_names(level_names level_names: [String]) -> [String] {

        var is_numeric = true

        for level_name in level_names {
                if string_to_double(string: level_name) == nil {
                        is_numeric = false
                        break
                }
        }

        if is_numeric {
                return level_names.sort({
                        let value0 = string_to_double(string: $0)!
                        let value1 = string_to_double(string: $1)!
                        return value0 <= value1
                })
        } else {
                return level_names.sort()
        }
}
