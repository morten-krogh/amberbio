import UIKit

class LinearRegressionDrawer: TiledScrollViewDelegate {

        let width = 500 as CGFloat
        let height = 500 as CGFloat
        let left_margin = 50 as CGFloat
        let right_margin = 20 as CGFloat
        let bottom_margin = 40 as CGFloat
        let top_margin = 3 as CGFloat
        let axis_title_font_size = 12 as CGFloat
        let tick_font_size = 10 as CGFloat
        var content_size = CGSize.zero

        var x_values = [] as [Double]
        var y_values = [] as [Double]
        var tick_values = [] as [Double]
        var minimum_y_value = 0 as Double
        var maximum_y_value = 0 as Double
        var intercept = 0 as Double
        var slope = 0 as Double
        var x_axis_title = ""

        var plot_minimum_x_value = 0 as Double
        var plot_maximum_x_value = 0 as Double
        var plot_minimum_y_value = 0 as Double
        var plot_maximum_y_value = 0 as Double

        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 1 as CGFloat

        let circle_radius = 4 as CGFloat
        let circle_color = color_blue_circle_color

        var y_tick_values = [] as [Double]

        init(x_values: [Double], y_values: [Double], tick_values: [Double], minimum_x_value: Double, maximum_x_value: Double, minimum_y_value: Double, maximum_y_value: Double, slope: Double, intercept: Double, x_axis_title: String) {
                content_size = CGSize(width: width, height: height)

                self.x_values = x_values
                self.y_values = y_values
                self.tick_values = tick_values
                self.minimum_y_value = minimum_y_value
                self.maximum_y_value = maximum_y_value
                self.intercept = intercept
                self.slope = slope
                self.x_axis_title = x_axis_title

                plot_minimum_x_value = min(0, minimum_x_value)
                plot_maximum_x_value = max(0, maximum_x_value)
                plot_minimum_y_value = intercept.isNaN ? min(0, minimum_y_value) : min(0, intercept, minimum_y_value)
                plot_maximum_y_value = intercept.isNaN ? max(0, maximum_y_value) : max(0, intercept, maximum_y_value)

                if plot_minimum_x_value == 0 && plot_maximum_x_value == 0 {
                        plot_minimum_x_value = -1
                        plot_maximum_x_value = 1
                }

                if plot_minimum_y_value == 0 && plot_maximum_y_value == 0 {
                        plot_minimum_y_value = -1
                        plot_maximum_y_value = 1
                }

                plot_maximum_x_value *= 1.10
                plot_minimum_x_value *= 1.10
                plot_maximum_y_value *= 1.10
                plot_minimum_y_value *= 1.10

                y_tick_values = calculate_tick_values(minimum: minimum_y_value, maximum: maximum_y_value)
        }

        func value_to_point(x_value x_value: Double, y_value: Double) -> CGPoint {
                let x = left_margin + (width - left_margin - right_margin) * CGFloat(x_value - plot_minimum_x_value) / CGFloat(plot_maximum_x_value - plot_minimum_x_value)
                let y = height - bottom_margin - (height - bottom_margin - top_margin) * CGFloat(y_value - plot_minimum_y_value) / CGFloat(plot_maximum_y_value - plot_minimum_y_value)
                return CGPoint(x: x, y: y)
        }

        func draw(context context: CGContext, rect: CGRect) {
                draw_x_axis(context: context)
                draw_y_axis(context: context)

                for i in 0 ..< x_values.count {
                        draw_linear_regression_circle(context: context, x_value: x_values[i], y_value: y_values[i])
                }

                draw_linear_regression_line(context: context)
        }

        func draw_x_axis(context context: CGContext) {
                let start_point = value_to_point(x_value: plot_minimum_x_value, y_value: 0)
                let end_point = value_to_point(x_value: plot_maximum_x_value, y_value: 0)
                drawing_draw_line(context: context, start_point: start_point, end_point: end_point)

                let arrow_size = 6 as CGFloat
                var arrow_point = CGPoint(x: end_point.x - arrow_size, y: end_point.y - 0.8 * arrow_size)
                drawing_draw_line(context: context, start_point: end_point, end_point: arrow_point)
                arrow_point = CGPoint(x: end_point.x - arrow_size, y: end_point.y + 0.8 * arrow_size)
                drawing_draw_line(context: context, start_point: end_point, end_point: arrow_point)

                let astring = astring_font_size_color(string: x_axis_title, font: font_footnote, font_size: axis_title_font_size)
                let text_origin = CGPoint(x: end_point.x - astring.size().width + right_margin - 3, y: end_point.y + 10)
                drawing_draw_attributed_text(context: context, attributed_text: astring, origin: text_origin, horizontal: true)

                var last_text_position = -CGFloat.infinity
                for tick_value in tick_values {
                        let point = value_to_point(x_value: tick_value, y_value: 0)
                        if point.x < 30 || point.x > (width - 30) {
                                continue
                        }

                        let start_point = CGPoint(x: point.x, y: point.y + 5)
                        let end_point = CGPoint(x: point.x, y: point.y - 5)

                        let value_as_string = decimal_string(number: tick_value, fraction_digits: 1)
                        let astring = astring_font_size_color(string: value_as_string, font: font_footnote, font_size: tick_font_size)
                        if point.x - astring.size().width / 2 > last_text_position {
                                drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                                let text_origin = CGPoint(x: point.x - astring.size().width / 2, y: point.y + 10)
                                drawing_draw_attributed_text(context: context, attributed_text: astring, origin: text_origin, horizontal: true)
                                last_text_position = point.x + astring.size().width / 2
                        }
                }
        }

        func draw_y_axis(context context: CGContext) {
                let start_point = value_to_point(x_value: 0, y_value: plot_minimum_y_value)
                let end_point = value_to_point(x_value: 0, y_value: plot_maximum_y_value)
                drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                let arrow_size = 6 as CGFloat
                var arrow_point = CGPoint(x: end_point.x - arrow_size, y: end_point.y + 0.8 * arrow_size)
                drawing_draw_line(context: context, start_point: end_point, end_point: arrow_point)
                arrow_point = CGPoint(x: end_point.x + arrow_size, y: end_point.y + 0.8 * arrow_size)
                drawing_draw_line(context: context, start_point: end_point, end_point: arrow_point)

                for tick_value in y_tick_values {
                        let point = value_to_point(x_value: 0, y_value: tick_value)
                        if tick_value > plot_maximum_y_value || tick_value < plot_minimum_y_value || point.y < 30 || point.y > (height - 30) {
                                continue
                        }

                        let start_point = CGPoint(x: point.x - 5, y: point.y)
                        let end_point = CGPoint(x: point.x + 5, y: point.y)
                        drawing_draw_line(context: context, start_point: start_point, end_point: end_point)

                        let astring = number_format_tick_value(value: tick_value, font_size: tick_font_size)
                        let text_origin = CGPoint(x: point.x - 10 - astring.size().width, y: point.y - astring.size().height / 2)
                        drawing_draw_attributed_text(context: context, attributed_text: astring, origin: text_origin, horizontal: true)
                }
        }

        func draw_linear_regression_circle(context context: CGContext, x_value: Double, y_value: Double) {
                let point = value_to_point(x_value: x_value, y_value: y_value)
                drawing_draw_circle(context: context, center_x: point.x, center_y: point.y, radius: circle_radius, color: circle_color)
        }

        func draw_linear_regression_line(context context: CGContext) {
                if !intercept.isNaN && !slope.isNaN {
                        let y_value_0 = intercept + slope * plot_minimum_x_value
                        let start_point = value_to_point(x_value: plot_minimum_x_value, y_value: y_value_0)
                        let y_value_1 = intercept + slope * plot_maximum_x_value
                        let end_point = value_to_point(x_value: plot_maximum_x_value, y_value: y_value_1)
                        drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                }
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {

        }

        func tap_action(location location: CGPoint) {}
}
