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
        let size_of_hexagon_side = 50 as CGFloat
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

        func update(som_nodes: [SOMNode], number_of_rows: Int, number_of_columns: Int) {
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

                CGContextSetLineWidth(context, 2)

                let color = color_for_value(value: som_node.border_top_right)
                CGContextSetStrokeColorWithColor(context, color.CGColor)
                var start_point = CGPoint(x: origin_x + sqrt_3 * 0.5 * size_of_hexagon_side, y: origin_y)
                var end_point = CGPoint(x: origin_x + sqrt_3 * size_of_hexagon_side, y: origin_y + 0.5 * size_of_hexagon_side)
                drawing_draw_line(context: context, start_point: start_point, end_point: end_point)





        }

        func color_for_value(value value: Double) -> UIColor {
                return UIColor.blackColor()
        }
}
