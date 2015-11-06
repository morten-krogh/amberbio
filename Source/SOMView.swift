import UIKit

class SOMNode {
        var row = 0
        var column = 0
        var names = [] as [String?]
        var colors = [] as [UIColor]
        var border_top_right = 0.0
        var border_right = 0.0
        var border_bottom_right = 0.0
        var border_bottom_left = 0.0
        var border_left = 0.0
        var border_top_left = 0.0
}

class SOMView: DrawView {

        let margin = 10 as CGFloat
        let size_of_hexagon_side = 40 as CGFloat
        let sqrt_3 = sqrt(3) as CGFloat

        var number_of_rows = 0
        var number_of_columns = 0
        var som_nodes = [] as [SOMNode]

        init() {
                super.init(frame: CGRect.zero, tappable: false)
        }

        required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        func update(som_nodes som_nodes: [SOMNode], number_of_rows: Int, number_of_columns: Int) {
                self.number_of_rows = number_of_rows
                self.number_of_columns = number_of_columns
                self.som_nodes = som_nodes

                let width = margin + (CGFloat(number_of_columns) + (number_of_rows > 1 ? 0.5 : 0)) * sqrt_3 * size_of_hexagon_side + margin
                let height = margin + (1.5 * CGFloat(number_of_rows) + 0.5) * size_of_hexagon_side + margin
                content_size = CGSize(width: width, height: height)

                setNeedsDisplay()
        }

        override func draw(context context: CGContext, rect: CGRect) {
                for som_node in som_nodes {
                        draw_som_node(context: context, som_node: som_node)
                }
        }

        func draw_som_node(context context: CGContext, som_node: SOMNode) {
                let origin_y = margin + 1.5 * CGFloat(som_node.row) * size_of_hexagon_side
                let origin_x = margin + (CGFloat(som_node.column) + (som_node.row % 2 == 0 ? 0 : 0.5)) * sqrt_3 * size_of_hexagon_side

                let point_0 = CGPoint(x: origin_x + sqrt_3 * 0.5 * size_of_hexagon_side, y: origin_y)
                let point_1 = CGPoint(x: origin_x + sqrt_3 * size_of_hexagon_side, y: origin_y + 0.5 * size_of_hexagon_side)
                let point_2 = CGPoint(x: origin_x + sqrt_3 * size_of_hexagon_side, y: origin_y + 1.5 * size_of_hexagon_side)
                let point_3 = CGPoint(x: origin_x + sqrt_3 * 0.5 * size_of_hexagon_side, y: origin_y + 2 * size_of_hexagon_side)
                let point_4 = CGPoint(x: origin_x, y: origin_y + 1.5 * size_of_hexagon_side)
                let point_5 = CGPoint(x: origin_x, y: origin_y + 0.5 * size_of_hexagon_side)

                CGContextSetLineWidth(context, 1)

                CGContextSetStrokeColorWithColor(context, color_for_value(value: som_node.border_top_right).CGColor)
                CGContextSetLineWidth(context, line_width_for_value(value: som_node.border_top_right))
                drawing_draw_line(context: context, start_point: point_0, end_point: point_1)

                CGContextSetStrokeColorWithColor(context, color_for_value(value: som_node.border_right).CGColor)
                CGContextSetLineWidth(context, line_width_for_value(value: som_node.border_right))
                drawing_draw_line(context: context, start_point: point_1, end_point: point_2)

                CGContextSetStrokeColorWithColor(context, color_for_value(value: som_node.border_bottom_right).CGColor)
                CGContextSetLineWidth(context, line_width_for_value(value: som_node.border_bottom_right))
                drawing_draw_line(context: context, start_point: point_2, end_point: point_3)

                if som_node.column == 0 || som_node.row == number_of_rows - 1 {
                        CGContextSetStrokeColorWithColor(context, color_for_value(value: som_node.border_bottom_left).CGColor)
                        CGContextSetLineWidth(context, line_width_for_value(value: som_node.border_bottom_left))
                        drawing_draw_line(context: context, start_point: point_3, end_point: point_4)
                }

                if som_node.column == 0 {
                        CGContextSetStrokeColorWithColor(context, color_for_value(value: som_node.border_left).CGColor)
                        CGContextSetLineWidth(context, line_width_for_value(value: som_node.border_left))
                        drawing_draw_line(context: context, start_point: point_4, end_point: point_5)
                }

                if som_node.row == 0 || som_node.column == 0 {
                        CGContextSetStrokeColorWithColor(context, color_for_value(value: som_node.border_top_left).CGColor)
                        CGContextSetLineWidth(context, line_width_for_value(value: som_node.border_top_left))
                        drawing_draw_line(context: context, start_point: point_5, end_point: point_0)
                }

                CGContextSetLineWidth(context, 1)

                let names = som_node.names
                if !names.isEmpty {

                        let font_body_height = astring_body(string: "test string").size().height
                        let text_height = min(font_body_height, size_of_hexagon_side / CGFloat(2 * names.count - 1))
                        var font_multiplier = text_height / font_body_height
                        let origin_name_y = origin_y + 0.5 * size_of_hexagon_side + (size_of_hexagon_side - CGFloat(2 * names.count - 1) * text_height) / 2
                        for i in 0 ..< names.count {
                                let color = som_node.colors[i]
                                let center_x = origin_x + sqrt_3 * 0.5 * size_of_hexagon_side
                                let center_y = origin_name_y + (CGFloat(2 * i) + 0.5) * text_height
                                if let name = names[i] {
                                        let text_width_body = astring_body(string: name).size().width
                                        let width_multiplier = min(1, (0.8 * sqrt_3 * size_of_hexagon_side) / text_width_body)
                                        font_multiplier = min(font_multiplier, width_multiplier)
                                        let font_size = font_body.pointSize * font_multiplier
                                        let astring = astring_font_size_color(string: name, font: nil, font_size: font_size, color: color)
                                        drawing_draw_attributed_text(context: context, attributed_text: astring, center: CGPoint(x: center_x, y: center_y), angle: 0)
                                } else {
                                        drawing_draw_circle(context: context, center_x: center_x, center_y: center_y, radius: text_height / 2, color: color)
                                }
                        }
                }
        }

        func color_for_value(value value: Double) -> UIColor {
                let intensity = CGFloat(value)
                return UIColor(red: intensity, green: 1 - intensity, blue: 1 - intensity, alpha: 1)
        }

        func line_width_for_value(value value: Double) -> CGFloat {
                return CGFloat(1 + 0 * value)
        }
}
