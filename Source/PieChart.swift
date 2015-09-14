import UIKit

class PieChart: TiledScrollViewDelegate {

        var content_size = CGSize.zero
        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 1 as CGFloat

        let names: [String]
        let colors: [UIColor]
        let values: [Double]

        var fractions: [Double]!
        var attributed_names: [Astring]!

        let margin = 20 as CGFloat
        let middle_margin = 50 as CGFloat
        let line_margin = 20 as CGFloat
        let font = font_body

        let circle_radius = 100 as CGFloat

        var color_square_length = 30 as CGFloat

        init(names: [String], colors: [UIColor], values: [Double]) {
                self.names = names
                self.colors = colors
                self.values = values
                calculate_diagram()
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func calculate_diagram() {
                let sum_of_values = values.reduce(0, combine: +)
                fractions = values.map { $0 / sum_of_values }
                attributed_names = names.map { astring_body(string: $0) }

                color_square_length = max(color_square_length, font.lineHeight)

                let height_left = 2 * (margin + circle_radius)
                let height_right = 2 * margin + CGFloat(names.count) * color_square_length + (CGFloat(names.count) - 1) * line_margin
                let height = max(height_left, height_right)

                let text_width = attributed_names.reduce(0 as CGFloat, combine: { max($0, $1.size().width) })

                let width = margin + 2 * circle_radius + middle_margin + color_square_length + margin + text_width + margin

                content_size = CGSize(width: width, height: height)
        }

        func draw(context context: CGContext, rect: CGRect) {
                let circle_center = CGPoint(x: margin + circle_radius, y: content_size.height / 2)

                draw_circle(context: context, center: circle_center, radius: circle_radius, fractions: fractions, colors: colors)

                let first_square_center_y = (content_size.height - (CGFloat(names.count) * color_square_length + (CGFloat(names.count) - 1) * line_margin)) / 2 + color_square_length / 2

                var origin_x = margin + 2 * circle_radius + middle_margin

                for i in 0 ..< colors.count {
                        let color = colors[i]
                        let origin_y = first_square_center_y - color_square_length / 2 + CGFloat(i) * (line_margin + color_square_length)

                        CGContextSetFillColorWithColor(context, color.CGColor)
                        CGContextBeginPath(context)
                        CGContextAddRect(context, CGRect(x: origin_x, y: origin_y, width: color_square_length, height: color_square_length))
                        CGContextFillPath(context)
                }

                origin_x += color_square_length + margin

                for  i in 0 ..< names.count {
                        let name = names[i]
                        let origin_y = first_square_center_y + CGFloat(i) * (line_margin + color_square_length) - font.lineHeight / 2
                        let astring = astring_font_size_color(string: name, font: font, font_size: nil, color: nil)
                        drawing_draw_attributed_text(context: context, attributed_text: astring, origin: CGPoint(x: origin_x, y: origin_y), horizontal: true)
                }
        }

        func draw_circle(context context: CGContext, center: CGPoint, radius: CGFloat, fractions: [Double], colors: [UIColor]) {
                CGContextSetLineWidth(context, 1.0)
                var start_angle = 0 as CGFloat
                for i in 0 ..< fractions.count {
                        let fraction = fractions[i]
                        let color = colors[i]
                        let angle = -CGFloat(fraction) * 2 *  CGFloat(M_PI)

                        let peripheral_point = CGPoint(x: center.x + radius * cos(start_angle), y: center.y + radius * sin(start_angle))

                        CGContextSetFillColorWithColor(context, color.CGColor)
                        CGContextBeginPath(context)
                        CGContextMoveToPoint(context, center.x, center.y)
                        CGContextAddLineToPoint(context, peripheral_point.x, peripheral_point.y)
                        CGContextAddArc(context, center.x, center.y, radius, start_angle, start_angle + angle, 1)
                        CGContextClosePath(context)
                        CGContextFillPath(context)
                        
                        start_angle += angle
                }
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {}
        func tap_action(location location: CGPoint) {}
}
