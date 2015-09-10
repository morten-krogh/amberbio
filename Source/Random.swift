import Foundation

func generate_random_id() -> String {
        return generate_random_id_of_length(20)
}

func generate_random_id_of_length(length: Int) -> String {
        var str = ""
        for var i = 0; i < length; ++i {
                str.append(random_unicode_scalar36())
        }
        return str
}

func random_unicode_scalar36() -> UnicodeScalar {
        let random_number = arc4random_uniform(36)
        switch random_number {
        case 0...9:
                return UnicodeScalar(random_number + 48)
        default:
                return UnicodeScalar(random_number + 87)
        }
}
