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

let red_yellow_green_palette = [(165,0,38), (215,48,39), (244,109,67), (253,174,97), (254,224,139), (255,255,191), (217,239,139), (166,217,106), (102,189,99), (26,152,80), (0,104,55)]

let color_brewer_scheme = [(251,180,174), (179,205,227), (204,235,197), (222,203,228), (254,217,166), (255,255,204), (229,216,189), (253,218,236)]


func color_from_int(red red: Int, green: Int, blue: Int, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: CGFloat(red) / CGFloat(255), green: CGFloat(green) / CGFloat(255), blue: CGFloat(blue) / CGFloat(255), alpha: alpha)
}

func two_digit_hex(value value: Int) -> String {
        let hex = String(value, radix: 16)
        let prefix = hex.characters.count == 0 ? "00" : (hex.characters.count == 1 ? "0" : "")
        return prefix + hex
}

func cgfloat_to_int(value value: CGFloat) -> Int {
        return Int(round(value * 255.0))
}

func hex_to_cgfloat(hex hex: String) -> CGFloat {
        let scanner = NSScanner(string: hex)
        var i = 0 as UInt32
        scanner.scanHexInt(&i)
        return max(0, min(1, CGFloat(i) / CGFloat(255)))
}

func color_from_hex(hex hex: String) -> UIColor {
        let red = hex_to_cgfloat(hex: hex.substringWithRange(hex.startIndex ..< hex.startIndex.advancedBy(2)))
        let green = hex_to_cgfloat(hex: hex.substringWithRange(hex.startIndex.advancedBy(2) ..< hex.startIndex.advancedBy(4)))
        let blue = hex_to_cgfloat(hex: hex.substringWithRange(hex.startIndex.advancedBy(4) ..< hex.startIndex.advancedBy(6)))
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
}

func red_green_blue_alpha_cgfloat(color color: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var rgba = (red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) as (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
        color.getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha)
        return rgba
}

func red_green_blue_alpha_int(color color: UIColor) -> (red: Int, green: Int, blue: Int, alpha: Int) {
        let rgba = red_green_blue_alpha_cgfloat(color: color)
        return (red: cgfloat_to_int(value: rgba.red), green: cgfloat_to_int(value: rgba.green), blue: cgfloat_to_int(value: rgba.blue), alpha: cgfloat_to_int(value: (rgba.alpha)))
}

func color_to_hex_format(color color: UIColor) -> String {
        let rgba = red_green_blue_alpha_int(color: color)
        return two_digit_hex(value: rgba.red) + two_digit_hex(value: rgba.green) + two_digit_hex(value: rgba.blue)
}

func random_color() -> String {
        let red = Int(arc4random_uniform(256))
        let green = Int(arc4random_uniform(256))
        let blue = Int(arc4random_uniform(256))
        return two_digit_hex(value: red) + two_digit_hex(value: green) + two_digit_hex(value: blue)
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
        let colors = color_palette(number_of_colors: number_of_colors)
        return colors.map(color_to_hex_format)
}

