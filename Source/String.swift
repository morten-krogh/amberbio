import UIKit

func index_of_first_occurence(string string: String, char: Character) -> Int? {
        var index = 0
        for ch in string.characters {
                if ch == char {
                        return index
                }
                index++
        }
        return nil
}

func trim(string string: String) -> String {
        return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
}
