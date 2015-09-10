import Foundation

func serialize_strings(strings strings: [String]) -> NSData {
        var cchars = [[CChar]](count: strings.count, repeatedValue: [])
        var size = 0
        for i in 0 ..< strings.count {
                let c_string = strings[i].cStringUsingEncoding(NSUTF8StringEncoding) ?? []
                cchars[i] = c_string
                size += c_string.count
        }

        var buffer = [CChar](count: size, repeatedValue: CChar())

        var buffer_counter = 0;

        for i in 0 ..< cchars.count {
                let c_string = cchars[i]
                for j in 0 ..< c_string.count {
                        buffer[buffer_counter] = c_string[j]
                        buffer_counter++
                }
        }

        let data = NSData(bytes: buffer, length: size)

        return data
}

func deserialize_strings(data data: NSData) -> [String] {
        var buffer_length = 100
        var buffer = [CChar](count: buffer_length, repeatedValue: 0)

        var chars = [CChar](count: data.length, repeatedValue: 0)
        data.getBytes(&chars, length: data.length)

        var result = [] as [String]

        var previous_index = 0
        var current_index = 0
        while current_index < chars.count {
                if chars[current_index] == 0 {
                        let str_length = current_index - previous_index
                        if str_length > buffer_length {
                                buffer_length = str_length
                                buffer = [CChar](count: buffer_length, repeatedValue: 0)
                        }
                        for j in 0 ..< str_length {
                                buffer[j] = chars[previous_index + j]
                        }
                        let str = NSString(bytes: buffer, length: str_length, encoding: NSUTF8StringEncoding) as? String ?? ""
                        result.append(str)
                        previous_index = current_index + 1
                }
                current_index++
        }

        return result
}

func serialize_integers(integers integers: [Int]) -> NSData {
        let strings = integers.map { "\($0)" }
        return serialize_strings(strings: strings)
}

func deserialize_integers(data data: NSData) -> [Int] {
        let strings = deserialize_strings(data: data)
        return strings.map { Int($0) ?? 0 }
}

func serialize_doubles(doubles doubles: [Double]) -> NSData {
        return NSData(bytes: doubles, length: doubles.count * sizeof(Double))
}

func deserialize_doubles(data data: NSData) -> [Double] {
        var values = [Double](count: data.length / sizeof(Double), repeatedValue: 0)
        data.getBytes(&values, length: data.length)
        return values
}
