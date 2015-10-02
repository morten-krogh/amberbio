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

let color_blue_circle_color = UIColor(red: CGFloat(8.0 / 255.0), green: CGFloat(81.0 / 255.0), blue: CGFloat(156.0 / 255.0), alpha: 1)
let circle_color_green = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1)
let circle_color_gray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)

let color_brewer_diverging_11_RdYlGn = ["a50026", "d73027", "f46d43", "fdae61", "fee08b", "ffffbf", "d9ef8b", "a6d96a", "66bd63", "1a9850", "006837"]
let color_brewer_qualitative_9_pastel1 = ["fbb4ae", "b3cde3", "ccebc5", "decbe4", "fed9a6", "ffffcc", "e5d8bd", "fddaec", "f2f2f2"]
let color_brewer_qualitative_9_Set1  = ["e41a1c", "377eb8", "4daf4a", "984ea3", "ff7f00", "ffff33", "a65628", "f781bf", "999999"]
let color_brewer_qualitative_12_Set3 = ["8dd3c7", "ffffb3", "bebada", "fb8072", "80b1d3", "fdb462", "b3de69", "fccde5", "d9d9d9", "bc80bd", "ccebc5", "ffed6f"]
let color_brewer_qualitative_10_Paired = ["a6cee3", "1f78b4", "b2df8a", "33a02c", "fb9a99", "e31a1c", "fdbf6f", "ff7f00", "cab2d6", "6a3d9a"]

let color_blue = color_from_hex(hex: color_brewer_qualitative_9_Set1[1])

func color_two_digit_hex(value value: Int) -> String {
        let hex = String(value, radix: 16)
        let prefix = hex.characters.count == 0 ? "00" : (hex.characters.count == 1 ? "0" : "")
        return prefix + hex
}

func color_cgfloat_to_int(value value: CGFloat) -> Int {
        return Int(round(value * 255.0))
}

func color_hex_to_int(hex hex: String) -> Int {
        let scanner = NSScanner(string: hex)
        var i = 0 as UInt32
        scanner.scanHexInt(&i)
        return Int(i)
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

func color_hex_to_rgb(hex hex: String) -> (red: Int, green: Int, blue: Int) {
        let red = color_hex_to_int(hex: hex.substringWithRange(hex.startIndex ..< hex.startIndex.advancedBy(2)))
        let green = color_hex_to_int(hex: hex.substringWithRange(hex.startIndex.advancedBy(2) ..< hex.startIndex.advancedBy(4)))
        let blue = color_hex_to_int(hex: hex.substringWithRange(hex.startIndex.advancedBy(4) ..< hex.startIndex.advancedBy(6)))
        return (red, green, blue)
}

func color_average(hex1 hex1: String, hex2: String, weight: Double) -> String {
        let (red1, green1, blue1) = color_hex_to_rgb(hex: hex1)
        let (red2, green2, blue2) = color_hex_to_rgb(hex: hex2)
        let red = Int(round(weight * Double(red1) + (1 - weight) * Double(red2)))
        let green = Int(round(weight * Double(green1) + (1 - weight) * Double(green2)))
        let blue = Int(round(weight * Double(blue1) + (1 - weight) * Double(blue2)))
        return color_two_digit_hex(value: red) + color_two_digit_hex(value: green) + color_two_digit_hex(value: blue)
}

func color_palette(number_of_colors number_of_colors: Int) -> [UIColor] {
        let palette = color_palette_hex(number_of_colors: number_of_colors)
        return palette.map { color_from_hex(hex: $0) }
}

func color_palette_hex(number_of_colors number_of_colors: Int) -> [String] {
        if number_of_colors <= color_brewer_qualitative_9_Set1.count {
                return [String](color_brewer_qualitative_9_Set1[0 ..< number_of_colors])
        } else if number_of_colors <= color_brewer_qualitative_10_Paired.count {
                return [String](color_brewer_qualitative_10_Paired[0 ..< number_of_colors])
        } else if number_of_colors <= color_brewer_qualitative_12_Set3.count {
                return [String](color_brewer_qualitative_12_Set3[0 ..< number_of_colors])
        } else {
                var colors = [] as [String]
                for i in 0 ..< number_of_colors {
                        let position = Double(i * 11) / Double(number_of_colors - 1)
                        let lower = floor(position)
                        let higher = ceil(position)
                        let weight = higher - position
                        let lower_color = color_brewer_qualitative_12_Set3[Int(lower)]
                        let higher_color = color_brewer_qualitative_12_Set3[Int(higher)]
                        let color = color_average(hex1: lower_color, hex2: higher_color, weight: weight)
                        colors.append(color)
                }
                return colors
        }
}
