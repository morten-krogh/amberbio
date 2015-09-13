import UIKit

protocol SingleChoiceTableDelegate {
        func single_choice_table(singleChoiceTable: SingleChoiceTable, didSelectColNameWithIndex: Int) -> Void
        func single_choice_table(singleChoiceTable: SingleChoiceTable, didSelectCellWithRowIndex: Int, andColIndex: Int) -> Void
}

class SingleChoiceTable: UIView, TiledScrollViewDelegate {

        let font = font_body
        let lineWidth = 1.0 as CGFloat

        override var frame: CGRect { didSet { propertiesDidChange() } }

        var rowNames: [String] = [] { didSet { propertiesDidChange() } }
        var colNames: [String] = [] { didSet { propertiesDidChange() } }
        var choices: [Int] = [] { didSet { propertiesDidChange() } }      // choices.count == rowNames.count. Each choice is in [0, colNames.count - 1]
        var delegate: SingleChoiceTableDelegate?

        let tiledScrollView = TiledScrollView(frame: CGRect.zero)

        var content_size = CGSize.zero
        var maximum_zoom_scale = 1.0 as CGFloat
        var minimum_zoom_scale = 1.0 as CGFloat

        let margin = 10 as CGFloat
        let rowWidth = 50 as CGFloat
        let rowHeight = 50 as CGFloat
        let circleRadius = 18 as CGFloat
        let circleColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1)
        var rowNamesWidth = 0 as CGFloat
        var colNamesHeight = 0 as CGFloat

        override init(frame: CGRect) {
                super.init(frame: frame)
                tiledScrollView.delegate = nil
                addSubview(tiledScrollView)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func tap_action(location location: CGPoint) {
                let (row, col) = row_col_for_point(point: location)
                if row == 0 && col > 0 {
                        delegate?.single_choice_table(self, didSelectColNameWithIndex: col - 1)
                } else if row > 0 && col > 0 {
                        choices[row - 1] = col - 1
                        delegate?.single_choice_table(self, didSelectCellWithRowIndex: row - 1, andColIndex: col - 1)
                }
        }

        func propertiesDidChange() {
                if rowNames.count > 0 && colNames.count > 0 && choices.count == rowNames.count {
                        tiledScrollView.frame = bounds
                        rowNamesWidth = draw_max_width(names: rowNames, font: font) + margin
                        colNamesHeight = draw_max_width(names: colNames, font: font) + margin
                        content_size.width = rowNamesWidth + CGFloat(colNames.count) * rowWidth
                        content_size.height = colNamesHeight + CGFloat(rowNames.count) * rowHeight
                        tiledScrollView.delegate = self
                } else {
                        tiledScrollView.delegate = nil
                }
        }

        func row_col_for_point(point point: CGPoint) -> (Int, Int) {
                var row = 0
                var col = 0
                if point.x >= rowNamesWidth {
                        col = Int(floor((point.x - rowNamesWidth) / rowWidth)) + 1
                }
                if point.y >= colNamesHeight {
                        row = Int(floor((point.y - colNamesHeight) / rowHeight)) + 1
                }
                return (row, col)
        }

        func draw(context context: CGContext, rect: CGRect) {
                let (upperLeftRow, upperLeftCol) = row_col_for_point(point: rect.origin)
                let (lowerRightRow, lowerRightCol) = row_col_for_point(point: CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)))

                if upperLeftRow == 0 && upperLeftCol == 0 {
                        Drawing.drawCell(context: context, originX: 0, originY: 0, width: rowNamesWidth, height: colNamesHeight, lineWidth: lineWidth, topLine: false, rightLine: true, bottomLine: true, leftLine: false)
                }
                if upperLeftCol >= 0 {
                        for row in max(0, upperLeftRow - 1)..<min(lowerRightRow, rowNames.count) {
                                drawRowName(context: context, index: row)
                        }
                }
                if upperLeftRow == 0 {
                        for col in max(0, upperLeftCol - 1)..<min(lowerRightCol, colNames.count) {
                                drawColName(context: context, index: col)
                        }
                }
                for row in max(0, upperLeftRow - 1)..<min(lowerRightRow, rowNames.count) {
                        for col in max(0, upperLeftCol - 1)..<min(lowerRightCol, colNames.count) {
                                drawCell(context: context, row: row, col: col, choice: choices[row] == col)
                        }
                }
        }

        func drawRowName(context context: CGContext, index: Int) {
                let originY = colNamesHeight + CGFloat(index) * rowHeight
                let name = rowNames[index]
                let rect = CGRect(x: 0, y: originY, width: rowNamesWidth, height: rowHeight)
                let astring = astring_font_size_color(string: name, font: font, font_size: nil, color: nil)

                draw_cell_with_attributed_text(context: context, rect: rect, line_width: lineWidth, attributed_text: astring, background_color: nil, horizontal_cell: true, margin_horizontal: 0, margin_vertical: 0, text_centered: false, circle_color: nil, circle_radius: 0, top_line: false, right_line: true, bottom_line: index != rowNames.count - 1, left_line: false)


//                Drawing.drawCellWithAttributedString(context: context, rect: rect, lineWidth: lineWidth, attributedString: astring, backgroundColor: nil, horizontalCell: true, marginHorizontal: 0, marginVertical: 0, circleColor: nil, circleRadius: 0, topLine: false, rightLine: true, bottomLine: index != rowNames.count - 1, leftLine: false)

//                Drawing.drawCellWithName(context: context, originX: 0, originY: originY, width: rowNamesWidth, height: rowHeight, lineWidth: lineWidth, name: name, font: font, horizontalName: true, margin: 0, topLine: false, rightLine: true, bottomLine: index != rowNames.count - 1, leftLine: false)
        }

        func drawColName(context context: CGContext, index: Int) {
                let originX = rowNamesWidth + CGFloat(index) * rowWidth
                let name = colNames[index]
                Drawing.drawCellWithName(context: context, originX: originX, originY: 0, width: rowWidth, height: colNamesHeight, lineWidth: lineWidth, name: name, font: font, horizontalName: false, margin: 0, topLine: false, rightLine: index != colNames.count - 1, bottomLine: true, leftLine: false)
        }

        func drawCell(context context: CGContext, row: Int, col: Int, choice: Bool) {
                let originX = rowNamesWidth + CGFloat(col) * rowWidth
                let originY = colNamesHeight + CGFloat(row) * rowHeight
                if choice {
                        Drawing.drawCellWithCenteredCircle(context: context, originX: originX, originY: originY, width: rowWidth, height: rowHeight, lineWidth: lineWidth, topLine: false, rightLine: col != colNames.count - 1, bottomLine: row != rowNames.count - 1, leftLine: false, radius: circleRadius, color: circleColor)
                } else {
                        Drawing.drawCell(context: context, originX: originX, originY: originY, width: rowWidth, height: rowHeight, lineWidth: lineWidth, topLine: false, rightLine: col != colNames.count - 1, bottomLine: row != rowNames.count - 1, leftLine: false)
                }
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {}
}
