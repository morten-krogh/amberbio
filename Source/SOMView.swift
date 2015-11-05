import UIKit

class SOMNode {
        var row = 0
        var column = 0
        var names = [] as [String?]
        var colors = [] as [UIColor]
        var border_values = [] as [Double]
}

class SOMView: DrawView {

        let margin = 10 as CGFloat
        let size_of_hexagon_side = 50 as CGFloat
        let sqrt_3 = sqrt(3) as CGFloat

        var number_of_rows = 0
        var number_of_columns = 0
        var som_nodes = [] as [[SOMNode]]

        init() {
                super.init(frame: CGRect.zero, tappable: false)
        }

        required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        func update(som_nodes: [[SOMNode]]) {
                number_of_rows = som_nodes.count
                number_of_columns = som_nodes[0].count
                self.som_nodes = som_nodes

                let width = margin + (CGFloat(number_of_columns) + (number_of_rows > 1 ? 0.5 : 0)) * sqrt_3 * size_of_hexagon_side + margin
                let height = margin + (1.5 * CGFloat(number_of_rows) + 0.5) * size_of_hexagon_side + margin
                content_size = CGSize(width: width, height: height)

                setNeedsDisplay()
        }

        override func draw(context context: CGContext, rect: CGRect) {
                for i in 0 ..< number_of_rows {
                        let origin_y = margin + 1.5 * CGFloat(i) * size_of_hexagon_side
                        for j in 0 ..< number_of_columns {
                                let origin_x = margin + (CGFloat(j) + (i % 2 == 0 ? 0 : 0.5)) * sqrt_3 * size_of_hexagon_side
                                draw_som_node(som_node: som_nodes[i][j], origin_x: origin_x, origin_y: origin_y)
                        }
                }
        }

        func draw_som_node(som_node som_node: SOMNode, origin_x: CGFloat, origin_y: CGFloat) {




        }
        















}
