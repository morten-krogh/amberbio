import UIKit

class ROC: TiledScrollViewDelegate {

        var content_size = CGSize(width: 620, height: 730)
        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 1 as CGFloat
        var zoom_scale = 0.1 as CGFloat

        var curve_values = [] as [(Double, Double)]
        var area = 0.0
        let title_label: Astring
        let title_area: Astring

        init(label_name_1: String, label_name_2: String, decision_values_1: [Double], decision_values_2: [Double]) {
                // group 2 is "positive". High decision values are in group 2. Lower left corner has all samples predicted in group 1.

                let sorted_1 = decision_values_1.sort().reverse() as [Double]
                let sorted_2 = decision_values_2.sort().reverse() as [Double]

                curve_values = [(0, 0)]
                area = 0.0

                var (i1, i2) = (0, 0)
                var unit_area = 0
                while i1 < sorted_1.count || i2 < sorted_2.count {
                        if i2 < sorted_2.count && (i1 == sorted_1.count || sorted_2[i2] >= sorted_1[i1]) {
                                var i = i2
                                while i < sorted_2.count && (i1 == sorted_1.count || sorted_2[i] >= sorted_1[i1]) {
                                        i++
                                }
                                i2 = i
                        } else {
                                var i = i1
                                while i < sorted_1.count && (i2 == sorted_2.count || sorted_2[i2] < sorted_1[i]) {
                                        i++
                                }
                                unit_area += (i - i1) * i2
                                i1 = i
                        }

                        let curve_value = (sorted_1.isEmpty ? 1 : Double(i1) / Double(sorted_1.count), sorted_2.isEmpty ? 1 : Double(i2) / Double(sorted_2.count))
                        curve_values.append(curve_value)
                }

                title_label = astring_font_size_color(string: label_name_2, font: nil, font_size: 22, color: nil)
                title_label.appendAttributedString(astring_font_size_color(string: " (pos)", font: nil, font_size: 16, color: nil))
                title_label.appendAttributedString(astring_font_size_color(string: "  vs.  ", font: nil, font_size: 20, color: nil))
                title_label.appendAttributedString(astring_font_size_color(string: label_name_1, font: nil, font_size: 22, color: nil))
                title_label.appendAttributedString(astring_font_size_color(string: " (neg)", font: nil, font_size: 16, color: nil))

                let title_area_str: String
                if  sorted_1.isEmpty || sorted_2.isEmpty {
                        area = Double.NaN
                        title_area_str = "ROC area = NA"
                        curve_values = [(0, 0)]
                } else {
                        area = Double(unit_area) / (Double(sorted_1.count) * Double(sorted_2.count))
                        title_area_str = "ROC area = " + decimal_string(number: area, fraction_digits: 2)
                }
                title_area = astring_font_size_color(string: title_area_str, font: nil, font_size: 21, color: nil)
        }

        let box_lower_left = CGPoint(x: 100, y: 630)
        let box_upper_right = CGPoint(x: 600, y: 130)
        let tick_length = 20 as CGFloat

        func draw(context context: CGContext, rect: CGRect) {
                draw_box(context: context)
                draw_ticks(context: context)
                draw_axis_1_labels(context: context)
                draw_axis_2_labels(context: context)
                draw_axis_1_title(context: context)
                draw_axis_2_title(context: context)
                draw_diagonal(context: context)
                draw_curve(context: context)
                draw_title(context: context)
        }

        func draw_box(context context: CGContext) {
                let box_upper_left = CGPoint(x: box_lower_left.x, y: box_upper_right.y)
                let box_lower_right = CGPoint(x: box_upper_right.x, y: box_lower_left.y)
                drawing_draw_line(context: context, start_point: box_lower_left, end_point: box_upper_left)
                drawing_draw_line(context: context, start_point: box_upper_left, end_point: box_upper_right)
                drawing_draw_line(context: context, start_point: box_upper_right, end_point: box_lower_right)
                drawing_draw_line(context: context, start_point: box_lower_right, end_point: box_lower_left)
        }

        func draw_ticks(context context: CGContext) {
                for value_1 in [0.2, 0.4, 0.6, 0.8] {
                        let point = value_to_point(value_1: value_1, value_2: 0)
                        let start_point = CGPoint(x: point.x, y: point.y + tick_length / 2)
                        let end_point = CGPoint(x: point.x, y: point.y - tick_length / 2)
                        drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                }

                for value_2 in [0.2, 0.4, 0.6, 0.8] {
                        let point = value_to_point(value_1: 0, value_2: value_2)
                        let start_point = CGPoint(x: point.x - tick_length / 2, y: point.y)
                        let end_point = CGPoint(x: point.x + tick_length / 2, y: point.y)
                        drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                }


        }

        func draw_axis_1_labels(context context: CGContext) {
                for value_1 in [0, 0.2, 0.4, 0.6, 0.8, 1] {
                        let point = value_to_point(value_1: value_1, value_2: 0)
                        let str = value_1 == 0 ? "0" : value_1 == 1 ? "1" : String(value_1)
                        let astring = astring_body(string: str)
                        let point_text = CGPoint(x: point.x - astring.size().width / 2, y: point.y + tick_length)
                        drawing_draw_attributed_text(context: context, attributed_text: astring, origin: point_text, horizontal: true)
                }
        }

        func draw_axis_2_labels(context context: CGContext) {
                for value_2 in [0, 0.2, 0.4, 0.6, 0.8, 1] {
                        let point = value_to_point(value_1: 0, value_2: value_2)
                        let str = value_2 == 0 ? "0" : value_2 == 1 ? "1" : String(value_2)
                        let astring = astring_body(string: str)
                        let point_text = CGPoint(x: point.x - tick_length - astring.size().width, y: point.y - astring.size().height / 2)
                        drawing_draw_attributed_text(context: context, attributed_text: astring, origin: point_text, horizontal: true)
                }
        }

        func draw_axis_1_title(context context: CGContext) {
                let point = value_to_point(value_1: 0.5, value_2: 0)
                let astring = astring_font_size_color(string: "False positive rate", font: nil, font_size: 21, color: nil)
                let center = CGPoint(x: point.x, y: point.y + tick_length + 1.8 * astring.size().height)
                drawing_draw_attributed_text(context: context, attributed_text: astring, center: center, angle: 0)
        }

        func draw_axis_2_title(context context: CGContext) {
                let point = value_to_point(value_1: 0, value_2: 0.5)
                let astring = astring_font_size_color(string: "True positive rate", font: nil, font_size: 21, color: nil)
                let center = CGPoint(x: point.x - tick_length - 2.3 * astring.size().height, y: point.y)
                drawing_draw_attributed_text(context: context, attributed_text: astring, center: center, angle: -CGFloat(M_PI_2))
        }

        func draw_diagonal(context context: CGContext) {
                CGContextSaveGState(context)
                CGContextSetStrokeColorWithColor(context, color_blue.CGColor)
                let number_of_segments = 40
                let frac = 0.5
                for i in 0 ... number_of_segments {
                        let center_value = Double(i) / Double(number_of_segments)
                        let start_value = max(0.0, center_value - frac / Double(2 * number_of_segments))
                        let end_value = min(1.0, center_value + frac / Double(2 * number_of_segments))
                        let start_point = value_to_point(value_1: start_value, value_2: start_value)
                        let end_point = value_to_point(value_1: end_value, value_2: end_value)
                        drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                }
                CGContextRestoreGState(context)
        }

        func draw_curve(context context: CGContext) {
                CGContextSaveGState(context)
                CGContextSetLineWidth(context, 2)
                CGContextSetStrokeColorWithColor(context, color_red.CGColor)
                for i in 0 ..< curve_values.count - 1 {
                        let start_value = curve_values[i]
                        let end_value = curve_values[i + 1]
                        let start_point = value_to_point(value_1: start_value.0 , value_2: start_value.1)
                        let end_point = value_to_point(value_1: end_value.0, value_2: end_value.1)
                        drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                }
                CGContextRestoreGState(context)
        }

        func draw_title(context context: CGContext) {
                let point = value_to_point(value_1: 0.5, value_2: 1)
                var center = CGPoint(x: point.x, y: point.y - 100)
                drawing_draw_attributed_text(context: context, attributed_text: title_label, center: center, angle: 0)

                center.y += 50
                drawing_draw_attributed_text(context: context, attributed_text: title_area, center: center, angle: 0)
        }

        func value_to_point(value_1 value_1: Double, value_2: Double) -> CGPoint {
                let x = CGFloat(value_1) * (box_upper_right.x - box_lower_left.x) + box_lower_left.x
                let y = CGFloat(value_2) * (box_upper_right.y - box_lower_left.y) + box_lower_left.y
                return CGPoint(x: x, y: y)
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {
                self.zoom_scale = zoom_scale
        }

        func tap_action(location location: CGPoint) {}
}
