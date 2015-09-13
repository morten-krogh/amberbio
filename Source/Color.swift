import UIKit

let color_home_button_enabled = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
let color_home_button_disabled = UIColor.grayColor()
let color_home_button_highlighted = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 0.2)

let color_header_view = UIColor(red: 0.97, green: 1.0, blue: 0.98, alpha: 1.0)

let color_gray = UIColor.grayColor()
let color_enabled = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
let color_disabled = UIColor.grayColor()

let color_blue_selectable = UIColor(red: 0.8, green: 0.8 + 0.2 * 0.478431, blue: 1, alpha: 1)
let color_blue_selectable_header = UIColor(red: 0.2, green: 0.2 + 0.8 * 0.478431, blue: 1, alpha: 1)

let color_green_selected = UIColor(red: 0.84, green: 0.9373, blue: 0.8180, alpha: 1)
let color_gray_unselected = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)

let circle_color_green = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1)
let circle_color_gray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)

let color_brewer_diverging_11_RdYlGn = ["a50026", "d73027", "f46d43", "fdae61", "fee08b", "ffffbf", "d9ef8b", "a6d96a", "66bd63", "1a9850", "006837"]
let color_brewer_qualitative_8_pastel1 = ["fbb4ae", "b3cde3", "ccebc5", "decbe4", "fed9a6", "ffffcc", "e5d8bd", "fddaec"]
let color_brewer_qualitative_9_Set1  = ["e41a1c", "377eb8", "4daf4a", "984ea3", "ff7f00", "ffff33", "a65628", "f781bf", "999999"]


func color_two_digit_hex(value value: Int) -> String {
        let hex = String(value, radix: 16)
        let prefix = hex.characters.count == 0 ? "00" : (hex.characters.count == 1 ? "0" : "")
        return prefix + hex
}

func color_cgfloat_to_int(value value: CGFloat) -> Int {
        return Int(round(value * 255.0))
}

func color_hex_to_cgfloat(hex hex: String) -> CGFloat {
        let scanner = NSScanner(string: hex)
        var i = 0 as UInt32
        scanner.scanHexInt(&i)
        return max(0, min(1, CGFloat(i) / CGFloat(255)))
}

func color_from_hex(hex hex: String) -> UIColor {
        let red = color_hex_to_cgfloat(hex: hex.substringWithRange(hex.startIndex ..< hex.startIndex.advancedBy(2)))
        let green = color_hex_to_cgfloat(hex: hex.substringWithRange(hex.startIndex.advancedBy(2) ..< hex.startIndex.advancedBy(4)))
        let blue = color_hex_to_cgfloat(hex: hex.substringWithRange(hex.startIndex.advancedBy(4) ..< hex.startIndex.advancedBy(6)))
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
}

func color_red_green_blue_alpha_cgfloat(color color: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var rgba = (red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) as (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
        color.getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha)
        return rgba
}

func color_red_green_blue_alpha_int(color color: UIColor) -> (red: Int, green: Int, blue: Int, alpha: Int) {
        let rgba = color_red_green_blue_alpha_cgfloat(color: color)
        return (red: color_cgfloat_to_int(value: rgba.red), green: color_cgfloat_to_int(value: rgba.green), blue: color_cgfloat_to_int(value: rgba.blue), alpha: color_cgfloat_to_int(value: (rgba.alpha)))
}

func color_to_hex_format(color color: UIColor) -> String {
        let rgba = color_red_green_blue_alpha_int(color: color)
        return color_two_digit_hex(value: rgba.red) + color_two_digit_hex(value: rgba.green) + color_two_digit_hex(value: rgba.blue)
}

func color_random_hex() -> String {
        let red = Int(arc4random_uniform(256))
        let green = Int(arc4random_uniform(256))
        let blue = Int(arc4random_uniform(256))
        return color_rgb_to_hex(red: red, green: green, blue: blue)
}

func color_rgb_to_hex(red red: Int, green: Int, blue: Int) -> String {
        return color_two_digit_hex(value: red) + color_two_digit_hex(value: green) + color_two_digit_hex(value: blue)
}

func color_palette(number_of_colors number_of_colors: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for i in 0...number_of_colors {
                let hue: CGFloat = CGFloat(i) / CGFloat(number_of_colors)
                colors.append(UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0))
        }
        return colors
}

func color_palette_hex(number_of_colors number_of_colors: Int) -> [String] {
        if number_of_colors <= color_brewer_qualitative_9_Set1.count {
                return [String](color_brewer_qualitative_9_Set1[0 ..< number_of_colors])
        } else {
                let colors = color_palette(number_of_colors: number_of_colors)
                return colors.map(color_to_hex_format)
        }
}
