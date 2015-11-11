import UIKit

typealias Astring = NSMutableAttributedString

let font_body = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
let font_headline = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
let font_footnote = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)

let attributes_body = [NSFontAttributeName: font_body]
let attributes_headline = [NSFontAttributeName: font_headline]
let attributes_footnote = [NSFontAttributeName: font_footnote]

let astring_empty = Astring(string: "")

func astring_font_size_color(string string: String, font: UIFont? = nil, font_size: CGFloat? = nil, color: UIColor? = nil) -> Astring {
        let actual_font = font ?? font_body
        let sized_font = font_size == nil ? actual_font : actual_font.fontWithSize(font_size!)
        if let color = color {
                return Astring(string: string, attributes: [NSFontAttributeName: sized_font, NSForegroundColorAttributeName: color])
        } else {
                return Astring(string: string, attributes: [NSFontAttributeName: sized_font])
        }
}

func astring_body(string string: String) -> Astring {
        return Astring(string: string, attributes: attributes_body)
}

func astring_headline(string string: String) -> Astring {
        return Astring(string: string, attributes: attributes_headline)
}

func astring_footnote(string string: String) -> Astring {
        return Astring(string: string, attributes: attributes_footnote)
}

func astring_centered_multi_line(strings strings: [String], fonts: [UIFont]? = nil, colors: [UIColor]? = nil) -> Astring {
        let result_string = Astring(string: "")

        for i in 0 ..< strings.count {
                let string = strings[i] + ((i < strings.count - 1) ? "\n" : "")
                result_string.appendAttributedString(astring_font_size_color(string: string, font: fonts?[i], font_size: nil, color: colors?[i]))
        }

        let paragraph_style = NSMutableParagraphStyle()
        paragraph_style.alignment = NSTextAlignment.Center

        let range = NSRange(0 ..< result_string.length)
        result_string.addAttribute(NSParagraphStyleAttributeName, value: paragraph_style, range: range)

        return result_string
}

func astring_change_color(string string: Astring, color: UIColor) -> Astring {
        let mutable_string = Astring(attributedString: string)

        let range = NSRange(0 ..< string.length)
        mutable_string.addAttribute(NSForegroundColorAttributeName, value: color, range: range)

        return mutable_string
}

func astring_change_font(string string: Astring, font: UIFont) -> Astring {
        let mutable_string = Astring(attributedString: string)

        let range = NSRange(0 ..< string.length)
        mutable_string.addAttribute(NSFontAttributeName, value: font, range: range)

        return mutable_string
}

func astring_shorten(string string: Astring, width: CGFloat) -> Astring {

        if string.size().width < width {
                return string
        }

        let width_per_char = astring_body(string: "abcdef").size().width / 6
        let number_of_chars = Int(floor(width / width_per_char))

        let str = string.string
        let position = min(number_of_chars, str.characters.count)
        let prefix = str.substringToIndex(str.startIndex.advancedBy(position))
        return astring_body(string: prefix)
}

func astring_shorten_footnote(string string: Astring, width: CGFloat) -> Astring {

        if string.size().width < width {
                return string
        }

        let width_per_char = astring_footnote(string: "abcdef").size().width / 6
        let number_of_chars = Int(floor(width / width_per_char))

        let str = string.string
        let position = min(number_of_chars, str.characters.count)
        let prefix = str.substringToIndex(str.startIndex.advancedBy(position))
        return astring_footnote(string: prefix)
}

func astring_max_width(astring astring: Astring, max_width: CGFloat) -> Astring {
        let current_width = astring.size().width
        if current_width > max_width {
                let font = astring.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as! UIFont
                let font_size = font.pointSize
                let new_font_size = font_size * max_width / current_width
                let new_font = font.fontWithSize(new_font_size)
                return astring_change_font(string: astring, font: new_font)
        } else {
                return astring
        }
}

func astring_max_width(string string: String, max_width: CGFloat) -> Astring {
        return astring_max_width(astring: astring_body(string: string), max_width: max_width)

}
