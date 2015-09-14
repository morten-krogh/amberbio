import UIKit

class SingleMoleculePlot: TiledScrollViewDelegate {

        var content_size = CGSize.zero
        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 1 as CGFloat

        let names: [String]
        let all_values: [[Double]]
        let colors: [[UIColor]]

        let tick_values: [Double]
        let y_minimum: Double
        let y_maximum: Double

        let present_values: [[Double]]
        let number_of_missing_values: [Int]

        let plot_height = 400 as CGFloat
        let tick_margin_left = 1 as CGFloat
        let y_axis_margin_top = 10 as CGFloat
        let y_axis_margin_left = 45 as CGFloat

        let margin_between_groups = 30 as CGFloat
        let group_widths: [CGFloat]
        let margin_right = 10 as CGFloat

        let margin_bottom = 5 as CGFloat
        let margin_middle = 10 as CGFloat
        let height_name: CGFloat
        let height_present_missing: CGFloat
        let y_axis_margin_bottom: CGFloat

        let circle_radius = 5 as CGFloat

        init(names: [String], colors: [[UIColor]], values: [[Double]]) {
                self.names = names
                self.all_values = values
                self.colors = colors

                var minimum = Double.infinity
                var maximum = -Double.infinity
                var present_values = [] as [[Double]]
                var number_of_missing_values = [] as [Int]
                for level_values in values {
                        let present = level_values.filter { !$0.isNaN }
                        present_values.append(present)
                        let missing = level_values.count - present.count
                        number_of_missing_values.append(missing)
                        for value in present {
                                if value > maximum {
                                        maximum = value
                                }
                                if value < minimum {
                                        minimum = value
                                }
                        }
                }

                if minimum.isInfinite {
                        minimum = 0
                        maximum = 10
                }

                self.present_values = present_values
                self.number_of_missing_values = number_of_missing_values

                tick_values = calculate_tick_values(minimum: minimum, maximum: maximum)

                y_minimum = minimum >= 0 ? 0 : 1.05 * tick_values[0]
                y_maximum = maximum <= 0 ? 0 : 1.10 * tick_values[tick_values.count - 1]

                let size_missing_present_text = astring_footnote(string: "100 missing").size()
                height_present_missing = size_missing_present_text.height
                var group_widths = [] as [CGFloat]
                for name in names {
                        let width = astring_footnote(string: name).size().width
                        group_widths.append(max(width, size_missing_present_text.width))
                }
                self.group_widths = group_widths

                height_name = astring_body(string: "nase").size().height

                y_axis_margin_bottom = margin_bottom + height_name + 2 * height_present_missing + 3 * margin_middle

                let total_width = y_axis_margin_left + CGFloat((names.count + 1)) * margin_between_groups + group_widths.reduce(0, combine: +) + margin_right

                content_size = CGSize(width: total_width, height: plot_height)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func draw(context context: CGContext, rect: CGRect) {
                draw_plot(context: context, rect: rect)
        }

        func draw_plot(context context: CGContext, rect: CGRect) {
                CGContextSaveGState(context)
                CGContextSetLineWidth(context, 1)
                CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)

                draw_y_axis(context: context)
                for tick_value in tick_values {
                        draw_tick(context: context, y_value: tick_value)
                }

                draw_x_axis(context: context)

                for i in 0 ..< names.count {
                        draw_name(context: context, index: i)
                        draw_present(context: context, index: i)
                        draw_missing(context: context, index: i)
                        draw_values(context: context, index: i)
                }
                CGContextRestoreGState(context)
        }

        func draw_y_axis(context context: CGContext) {
                let start_point = CGPoint(x: y_axis_margin_left, y: plot_height - y_axis_margin_bottom)
                let end_point = CGPoint(x: y_axis_margin_left, y: y_axis_margin_top)
                drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                drawing_draw_arrow_vertical(context: context, point: end_point, length: 10)
        }

        func y_value_to_y_cord(y_value y_value: Double) -> CGFloat {
                let relative_position = (y_maximum - y_value) / (y_maximum - y_minimum)
                return y_axis_margin_top + CGFloat(relative_position) * (plot_height - y_axis_margin_bottom - y_axis_margin_top)
        }

        func draw_tick(context context: CGContext, y_value: Double) {
                let protrusion = y_value == 0 ? 0 : 3 as CGFloat
                let y_coord = y_value_to_y_cord(y_value: y_value)
                let start_point = CGPoint(x: y_axis_margin_left - protrusion, y: y_coord)
                let end_point = CGPoint(x: y_axis_margin_left + protrusion, y: y_coord)
                drawing_draw_line(context: context, start_point: start_point, end_point: end_point)

                let astring: Astring
                var is_integer = abs(y_value - floor(y_value)) <= 0.01 * abs(y_value)
                is_integer = is_integer || abs(y_value - ceil(y_value)) <= 0.01 * abs(y_value)

                if is_integer {
                        astring = astring_body(string: "\(Int(round(y_value)))")
                } else {
                        astring = decimal_astring(number: y_value, fraction_digits: 2)
                }

                let text_origin = CGPoint(x: tick_margin_left, y: y_coord - astring.size().height / 2)
                drawing_draw_attributed_text(context: context, attributed_text: astring, origin: text_origin, horizontal: true)
        }

        func draw_x_axis(context context: CGContext) {
                let y_cord = y_value_to_y_cord(y_value: 0)
                let start_point = CGPoint(x: y_axis_margin_left, y: y_cord)
                let end_point = CGPoint(x: content_size.width - margin_right, y: y_cord)
                drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
        }

        func index_to_x_coord(index index: Int) -> CGFloat {
                var result = y_axis_margin_left + margin_between_groups

                for i in 0 ..< index {
                        result += group_widths[i] + margin_between_groups
                }

                return result + group_widths[index] / 2
        }

        func draw_name(context context: CGContext, index: Int) {
                let astring = astring_footnote(string: names[index])
                let x_coord = index_to_x_coord(index: index)
                let origin = CGPoint(x: x_coord - astring.size().width / 2, y: plot_height - y_axis_margin_bottom + margin_middle)
                drawing_draw_attributed_text(context: context, attributed_text: astring, origin: origin, horizontal: true)
        }

        func draw_present(context context: CGContext, index: Int) {
                let number_of_values = present_values[index].count
                let string = number_of_values == 1 ? "1 value" : "\(number_of_values) values"
                let astring = astring_footnote(string: string)
                let x_coord = index_to_x_coord(index: index)
                let origin = CGPoint(x: x_coord - astring.size().width / 2, y: plot_height - y_axis_margin_bottom + 2 * margin_middle + height_present_missing + 3)
                drawing_draw_attributed_text(context: context, attributed_text: astring, origin: origin, horizontal: true)
        }

        func draw_missing(context context: CGContext, index: Int) {
                let string = "\(number_of_missing_values[index]) missing"
                let astring = astring_footnote(string: string)
                let x_coord = index_to_x_coord(index: index)
                let origin = CGPoint(x: x_coord - astring.size().width / 2, y: plot_height - y_axis_margin_bottom + 3 * margin_middle + 2 * height_present_missing)
                drawing_draw_attributed_text(context: context, attributed_text: astring, origin: origin, horizontal: true)
        }

        func draw_values(context context: CGContext, index: Int) {
                let x_coord = index_to_x_coord(index: index)
                for i in 0 ..< all_values[index].count {
                        let value = all_values[index][i]
                        if !value.isNaN {
                                let color = colors[index][i]
                                let y_coord = y_value_to_y_cord(y_value: value)
                                drawing_draw_circle(context: context, center_x: x_coord, center_y: y_coord, radius: circle_radius, color: color)
                        }
                }
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {}
        func tap_action(location location: CGPoint) {}
}

func calculate_tick_values(minimum minimum: Double, maximum: Double) -> [Double] {
        if maximum.isNaN || minimum.isNaN || maximum <= minimum {
                return []
        }

        let length = calculate_tick_length(minimum: minimum, maximum: maximum)
        let normalized_length = calculate_tick_normalize(length: length)
        let multiplier = length / normalized_length
        let interval = multiplier * calculate_tick_interval(normalized_length: normalized_length)

        let n_max = maximum <= 0 ? 0 : Int(ceil(maximum / interval + 0.5))
        let n_min = minimum >= 0 ? 0 : Int(floor(minimum / interval - 0.5))

        var result = [] as [Double]
        for i in n_min ... n_max {
                result.append(Double(i) * interval)
        }

        return result
}

func calculate_tick_length(minimum minimum: Double, maximum: Double) -> Double {
        if minimum >= 0 {
                return maximum
        } else if maximum <= 0 {
                return -minimum
        } else {
                return maximum - minimum
        }
}

func calculate_tick_normalize(length length: Double) -> Double {
        var normalized_length = length
        if normalized_length < 1 {
                while normalized_length < 1 {
                        normalized_length *= 10
                }
        } else if normalized_length >= 10 {
                while normalized_length >= 10 {
                        normalized_length /= 10
                }
        }
        return normalized_length
}

func calculate_tick_interval(normalized_length normalized_length: Double) -> Double {
        if normalized_length <= 2 {
                return 0.2
        } else if normalized_length <= 4 {
                return 0.5
        } else {
                return 1
        }
}

