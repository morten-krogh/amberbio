import UIKit

class TableOfAttributedStrings: TiledScrollViewDelegate {

        var content_size = CGSize.zeroSize
        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 1 as CGFloat

        var attributed_strings: [[Astring?]]
        let background_colors: [[UIColor?]]?
        let horizontal_cells: [[Bool]]?
        let circle_colors: [[UIColor?]]?
        var tap_action: ((row: Int, col: Int) -> ())?
        let number_of_rows: Int
        let number_of_columns: Int
        let line_width = 1 as CGFloat
        let margin_horizontal: CGFloat
        let margin_vertical: CGFloat
        let circle_radius: CGFloat
        var row_heights: [CGFloat]!
        var column_widths: [CGFloat]!

        init(attributed_strings: [[Astring?]], background_colors: [[UIColor?]]? = nil, horizontal_cells: [[Bool]]? = nil, circle_colors: [[UIColor?]]? = nil, margin_horizontal: CGFloat = 20, margin_vertical: CGFloat = 20, circle_radius: CGFloat = 10, tap_action: ((row: Int, col: Int) -> ())? = nil) {
                self.attributed_strings = attributed_strings
                self.number_of_rows = attributed_strings.count
                self.number_of_columns = attributed_strings[0].count
                self.background_colors = background_colors
                self.horizontal_cells = horizontal_cells
                self.circle_colors = circle_colors
                self.tap_action = tap_action
                self.margin_horizontal = margin_horizontal
                self.margin_vertical = margin_vertical
                self.circle_radius = circle_radius
                calculate_table()
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func tap_action(location location: CGPoint) {
                let cell = cell_for_point(point: location)
                tap_action?(row: cell.row, col: cell.col)
        }

        func calculate_table() {
                row_heights = [CGFloat](count: number_of_rows, repeatedValue: 0)
                column_widths = [CGFloat](count: number_of_columns, repeatedValue: 0)
                for row in 0..<number_of_rows {
                        for col in 0..<number_of_columns {
                                var size: CGSize
                                if let attributed_string = attributed_strings[row][col] {
                                        size = attributed_string.size()
                                } else {
                                        size = CGSize.zeroSize
                                }
                                let horizontal_cell = horizontal_cells == nil || horizontal_cells![row][col]
                                var width = (horizontal_cell ? size.width : size.height) + (col == 0 ? 1 : 2) * margin_horizontal
                                let height = (horizontal_cell ? size.height : size.width) + (row == 0 ? 1 : 2) * margin_vertical
                                if let circle_colors = circle_colors {
                                        if circle_colors[row][col] != nil {
                                                width += margin_horizontal + 2.0 * circle_radius
                                        }
                                }
                                if width > column_widths[col] {
                                        column_widths[col] = width
                                }
                                if height > row_heights[row] {
                                        row_heights[row] = height
                                }
                        }
                }
                content_size = CGSize(width: column_widths.reduce(0, combine: +)  , height: row_heights.reduce(0, combine: +))
        }

        func cell_for_point(point point: CGPoint) -> (row: Int, col: Int) {
                return (row: index_for(value: point.y, inArray: row_heights), col: index_for(value: point.x, inArray: column_widths))
        }

        func index_for(value value: CGFloat, inArray: [CGFloat]) -> Int {
                var sum = 0 as CGFloat
                for i in 0..<inArray.count {
                        sum += inArray[i]
                        if value < sum {
                                return i
                        }
                }
                return inArray.count - 1
        }

        func rect_for_cell(row row: Int, col: Int) -> CGRect {
                var rect = CGRect.zeroRect
                for i in 0..<col {
                        rect.origin.x += column_widths[i]
                }
                rect.size.width = column_widths[col]
                for i in 0..<row {
                        rect.origin.y += row_heights[i]
                }
                rect.size.height = row_heights[row]
                return rect
        }

        func draw(context context: CGContext, rect: CGRect) {
                let (minRow, minCol) = cell_for_point(point: rect.origin)
                let (maxRow, maxCol) = cell_for_point(point: CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)))
                for row in minRow...maxRow {
                        for col in minCol...maxCol {
                                draw_cell(context: context, row: row, col: col)
                        }
                }
        }

        func draw_cell(context context: CGContext, row: Int, col: Int) {
                let rect = rect_for_cell(row: row, col: col)
                let horizontalCell = horizontal_cells == nil || horizontal_cells![row][col]
                var backgroundColor = nil as UIColor?
                if let background_colors = background_colors {
                        backgroundColor = background_colors[row][col]
                }
                var circle_color = nil as UIColor?
                if let circle_colors = circle_colors {
                        circle_color = circle_colors[row][col]
                }

                Drawing.drawCellWithAttributedString(context: context, rect: rect, lineWidth: line_width, attributedString: attributed_strings[row][col], backgroundColor: backgroundColor, horizontalCell: horizontalCell, marginHorizontal: margin_horizontal, marginVertical: margin_vertical, circleColor: circle_color, circleRadius: circle_radius, topLine: false, rightLine: col != number_of_columns - 1, bottomLine: row != number_of_rows - 1, leftLine: false)
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {}
}
