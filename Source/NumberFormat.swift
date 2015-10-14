import UIKit

func decimal_string(number number: Double, significant_digits: Int) -> String {
        let number_formatter = NSNumberFormatter()
        number_formatter.numberStyle = .DecimalStyle
        number_formatter.maximumSignificantDigits = significant_digits
//        number_formatter.minimumFractionDigits = fraction_digits
//        number_formatter.maximumFractionDigits = fraction_digits
        number_formatter.decimalSeparator = "."
        return number_formatter.stringFromNumber(number) ?? ""
}

func decimal_string(number number: Double, fraction_digits: Int) -> String {
        let number_formatter = NSNumberFormatter()
        number_formatter.numberStyle = .DecimalStyle
        number_formatter.minimumFractionDigits = fraction_digits
        number_formatter.maximumFractionDigits = fraction_digits
        number_formatter.decimalSeparator = "."
        return number_formatter.stringFromNumber(number) ?? ""
}

func decimal_astring(number number: Double, fraction_digits: Int) -> Astring {
        return astring_body(string: decimal_string(number: number, fraction_digits: fraction_digits))
}

func astring_from_p_value(p_value p_value: Double, cutoff: Double = 0.05) -> Astring {
        var result: Astring

        if p_value.isNaN {
                return astring_body(string: "NaN")
        }

        if p_value >= 0.995 {
                let string = "1.00"
                result = Astring(string: string)
        } else if p_value >= 0.0995 {
                let string = "0." + String(Int(round(p_value * 100)))
                result = Astring(string: string)
        } else if p_value >= 0.00995 {
                let string = "0.0" + String(Int(round(p_value * 1000)))
                result = Astring(string: string)
        } else {
                result = scientific_format_astring(number: p_value, decimals: 1)
        }

        let full_range = NSRange(location: 0, length: result.length)
        result.addAttribute(NSFontAttributeName, value: font_body, range: full_range)
        if p_value <= cutoff {
                result.addAttribute(NSForegroundColorAttributeName, value: color_significant, range: full_range)
        }

        return result
}

func scientific_format_astring(number number: Double, decimals: Int) -> Astring {
        if number == 0 {
                var string = "0"
                if decimals > 0 {
                        string += "."
                        for _ in 0 ..< decimals {
                                string += "0"
                        }
                }
                return Astring(string: string)

        }

        var abs_number = abs(number)
        var exponent = 0
        if abs_number >= 10 {
                while abs_number >= 10 {
                        ++exponent
                        abs_number /= 10
                }
        } else {
                while abs_number <= 1 {
                        --exponent
                        abs_number *= 10
                }
        }

        let multiplier = pow(10.0, Double(decimals)) as Double
        abs_number *= multiplier
        let abs_int = Int(round(abs_number))
        var mantissa = number > 0 ? "" : "-"

        for (index, ch) in String(abs_int).characters.enumerate() {
                if index == 0 {
                        mantissa.append(ch)
                } else if index == 1 {
                        mantissa +=  "."
                        mantissa.append(ch)
                } else {
                        mantissa.append(ch)
                }
        }

        let result = Astring(string: mantissa)
        if exponent == 0 {
                return result
        }
        result.appendAttributedString(Astring(string: "\u{b7}10"))
        result.appendAttributedString(Astring(string: String(exponent), attributes: [String(kCTSuperscriptAttributeName): 1]))
        
        return result
}

func number_format_tick_value(value value: Double, font_size: CGFloat) -> Astring {

        if abs(value) > 1000 || abs(value) < 0.001 {
                let astring = scientific_format_astring(number: value, decimals: 1)
                let full_range = NSRange(location: 0, length: astring.length)
                let font = UIFont(name: font_body.fontName, size: font_size)!
                astring.addAttribute(NSFontAttributeName, value: font, range: full_range)
                return astring
        } else {
                let value_string = decimal_string(number: value, fraction_digits: 1)
                return astring_font_size_color(string: value_string, font: font_body, font_size: font_size, color: nil)
        }
}
