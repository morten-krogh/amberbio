import UIKit

class ColorKey {

        let color_palette = [String](color_brewer_diverging_11_RdYlGn.reverse())
        var break_points = [] as [Double]

        let missing_color = UIColor.whiteColor()

        var colors = [] as [[UIColor]]

        init(values: [[Double]]) {
                var value_array = [] as [Double]
                for row in values {
                        for value in row {
                                if !value.isNaN {
                                        value_array.append(value)
                                }
                        }
                }
                value_array.sortInPlace { $0 < $1 }
                if !value_array.isEmpty {
                        for i in 0 ..< color_palette.count + 1 {
                                let index = i * (value_array.count - 1) / color_palette.count
                                let value = value_array[index]
                                break_points.append(value)
                        }
                }

                for row in values {
                        let color_row = row.map { (value: Double) -> UIColor in
                                if value.isNaN {
                                        return self.missing_color
                                } else {
                                        return self.color_from_value(value: value)
                                }
                        }
                        colors.append(color_row)
                }
        }

        func color_from_value(value value: Double) -> UIColor {
                var hex_color = "000000"
                for i in 0 ..< color_palette.count {
                        if value <= break_points[i + 1] {
                                hex_color = color_palette[i]
                                break
                        }
                }
                return color_from_hex(hex: hex_color)
        }
}
