import UIKit

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
                result.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: full_range)
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

func is_missing_value (string string: String) -> Bool {
        switch string {
        case "", "NA", "na", "NaN", "NAN", "nan":
                return true
        default:
                return false
        }
}

func string_to_double (string string: String) -> Double? {

        enum NumberState {
                case Start
                case Principal
                case Point
                case Fraction
                case E
                case Exponent
                case End
        }

        var state = NumberState.Start
        var sign: Double = 1
        var number: Double = 0
        var fractionMultiplier: Double = 1
        var exponent: Int = 0
        var exponentSign: Int = 1

        for ch in string.characters {
                switch state {
                case .Start:
                        if ch == " " {
                        } else if ch == "+" || ch == "-" {
                                sign = ch == "+" ? 1 : -1
                                number = 0
                                state = .Principal
                        } else if ch >= "0" && ch <= "9" {
                                sign = 1
                                number = Double(Int(String(ch))!)
                                state = .Principal
                        } else if ch == "." {
                                sign = 1
                                number = 0
                                fractionMultiplier = 0.1
                                state = .Fraction
                        } else {
                                return nil
                        }
                case .Principal:
                        if ch == " " {
                                state = .End
                        } else if ch >= "0" && ch <= "9" {
                                number = 10.0 * number + Double(Int(String(ch))!)
                        } else if ch == "." {
                                fractionMultiplier = 0.1
                                state = .Fraction
                        } else if ch == "e" || ch == "E" {
                                state = .E
                        } else {
                                return nil
                        }
                case .Fraction:
                        if ch == " " {
                                state = .End
                        } else if ch >= "0" && ch <= "9" {
                                number = number + Double(Int(String(ch))!) * fractionMultiplier
                                fractionMultiplier = fractionMultiplier / 10.0
                        } else if ch == "e" || ch == "E" {
                                state = .E
                        } else {
                                return nil
                        }
                case .E:
                        if ch == "+" || ch == "-" {
                                exponentSign = ch == "+" ? 1 : -1
                                state = .Exponent
                        } else if ch >= "0" && ch <= "9" {
                                exponent = Int(String(ch))!
                                state = .Exponent
                        } else {
                                return nil
                        }
                case .Exponent:
                        if ch == " " {
                                state = .End
                        } else if ch >= "0" && ch <= "9" {
                                exponent = exponent * 10 + Int(String(ch))!
                        } else {
                                return nil
                        }
                case .End:
                        if ch != " " {
                                return nil
                        }
                default:
                        break
                }
        }

        if state == .Start {
                return nil
        }

        return sign * number * pow(10.0, Double(exponentSign * exponent))
}
