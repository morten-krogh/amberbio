import UIKit

protocol SpreadSheetDelegate: class {

        func spread_sheet_header_height(spread_sheet spread_sheet: SpreadSheet) -> CGFloat
        func spread_sheet_row_heights(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat]
        func spread_sheet_column_widths(spread_sheet spread_sheet: SpreadSheet) -> [CGFloat]

        func spread_sheet_header_astring(spread_sheet spread_sheet: SpreadSheet, column: Int) -> Astring
        func spread_sheet_astring(spread_sheet spread_sheet: SpreadSheet, row: Int, column: Int) -> Astring

        func spread_sheet_header_tapable(spread_sheet spread_sheet: SpreadSheet) -> Bool
        func spread_sheet_header_tapped(spread_sheet spread_sheet: SpreadSheet, column: Int) -> Void

        func spread_sheet_tapable(spread_sheet spread_sheet: SpreadSheet) -> Bool
        func spread_sheet_tapped(spread_sheet spread_sheet: SpreadSheet, row: Int, column: Int) -> Void

        func spread_sheet_did_scroll(spread_sheet spread_sheet: SpreadSheet, content_offset: CGPoint) -> Void
}

class SpreadSheet: UIView, UIScrollViewDelegate, SpreadSheetCellsDelegate {

        weak var delegate: SpreadSheetDelegate?

        let header_scroll_view = UIScrollView()
        let cell_scroll_view = UIScrollView()

        let header_spread_sheet_cells = SpreadSheetCells(frame: CGRect.zero)
        let cell_spread_sheet_cells = SpreadSheetCells(frame: CGRect.zero)

        var header_tap_action: ((column: Int) -> ())?
        var cell_tap_action: ((row: Int, column: Int) -> ())?

        override init(frame: CGRect) {
                super.init(frame: frame)

                header_scroll_view.showsHorizontalScrollIndicator = false
                header_scroll_view.delegate = self
                cell_scroll_view.delegate = self
                cell_scroll_view.directionalLockEnabled = true

                addSubview(header_scroll_view)
                addSubview(cell_scroll_view)

                header_spread_sheet_cells.delegate = self
                header_spread_sheet_cells.bottom_line = true
                cell_spread_sheet_cells.delegate = self

                header_scroll_view.addSubview(header_spread_sheet_cells)
                cell_scroll_view.addSubview(cell_spread_sheet_cells)
        }

        required init(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        func spread_sheet_cells_row_heights(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat] {
                if spread_sheet_cells == header_spread_sheet_cells {
                        return [delegate?.spread_sheet_header_height(spread_sheet: self) ?? 0]
                } else {
                        return delegate?.spread_sheet_row_heights(spread_sheet: self) ?? []
                }
        }

        func spread_sheet_cells_column_widths(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat] {
                return delegate?.spread_sheet_column_widths(spread_sheet: self) ?? []
        }

        func spread_sheet_cells_astring(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) -> Astring {
                if spread_sheet_cells == header_spread_sheet_cells {
                        return delegate?.spread_sheet_header_astring(spread_sheet: self, column: column) ?? astring_empty
                } else {
                        return delegate?.spread_sheet_astring(spread_sheet: self, row: row, column: column) ?? astring_empty
                }
        }

        func spread_sheet_cells_tapable(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> Bool {
                if spread_sheet_cells == header_spread_sheet_cells {
                        return delegate?.spread_sheet_header_tapable(spread_sheet: self) ?? false
                } else {
                        return delegate?.spread_sheet_tapable(spread_sheet: self) ?? false
                }
        }

        func spread_sheet_cells_tapped(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) {
                if spread_sheet_cells == header_spread_sheet_cells {
                        delegate?.spread_sheet_header_tapped(spread_sheet: self, column: column)
                } else {
                        delegate?.spread_sheet_tapped(spread_sheet: self, row: row, column: column)
                }
        }

        func reload() {

                header_spread_sheet_cells.reload()
                cell_spread_sheet_cells.reload()

                header_scroll_view.contentSize = header_spread_sheet_cells.content_size
                cell_scroll_view.contentSize = cell_spread_sheet_cells.content_size

                header_spread_sheet_cells.frame = CGRect(origin: CGPoint.zero, size: header_spread_sheet_cells.content_size)
                cell_spread_sheet_cells.frame = CGRect(origin: CGPoint.zero, size: cell_spread_sheet_cells.content_size)

                setNeedsLayout()
        }

        override func layoutSubviews() {
                super.layoutSubviews()

                header_scroll_view.frame = CGRect.zero
                cell_scroll_view.frame = CGRect.zero

                let content_width = header_spread_sheet_cells.content_size.width

                if content_width < bounds.width {
                        let margin = (bounds.width - content_width) / 2
                        header_scroll_view.frame.origin.x = margin
                        header_scroll_view.frame.size.width = content_width
                        cell_scroll_view.frame.origin.x = margin
                        cell_scroll_view.frame.size.width = content_width
                } else {
                        header_scroll_view.frame.size.width = bounds.width
                        cell_scroll_view.frame.size.width = bounds.width
                }

                if header_spread_sheet_cells.content_size.height + cell_spread_sheet_cells.content_size.height < bounds.height {
                        let margin = (bounds.height - header_spread_sheet_cells.content_size.height - cell_spread_sheet_cells.content_size.height) / 2
                        header_scroll_view.frame.origin.y = margin
                        header_scroll_view.frame.size.height = header_spread_sheet_cells.content_size.height
                        cell_scroll_view.frame.origin.y = margin + header_spread_sheet_cells.content_size.height
                        cell_scroll_view.frame.size.height = cell_spread_sheet_cells.content_size.height
                } else if header_spread_sheet_cells.content_size.height < bounds.height {
                        header_scroll_view.frame.origin.y = 0
                        header_scroll_view.frame.size.height = header_spread_sheet_cells.content_size.height
                        cell_scroll_view.frame.origin.y = header_spread_sheet_cells.content_size.height
                        cell_scroll_view.frame.size.height = bounds.height - header_spread_sheet_cells.content_size.height
                } else {
                        header_scroll_view.frame.size.height = bounds.height
                }
        }

        func scrollViewDidScroll(scrollView: UIScrollView) {
                let other_scroll_view = scrollView === header_scroll_view ? cell_scroll_view : header_scroll_view
                other_scroll_view.contentOffset.x = scrollView.contentOffset.x
                delegate?.spread_sheet_did_scroll(spread_sheet: self, content_offset: cell_scroll_view.contentOffset)
        }

        func set_content_offset(content_offset content_offset: CGPoint) {
                header_scroll_view.contentOffset.x = content_offset.x
                cell_scroll_view.contentOffset = content_offset
        }
}

protocol SpreadSheetCellsDelegate: class {

        func spread_sheet_cells_row_heights(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat]
        func spread_sheet_cells_column_widths(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat]
        func spread_sheet_cells_astring(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) -> Astring

        func spread_sheet_cells_tapable(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> Bool
        func spread_sheet_cells_tapped(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) -> Void
}

class SpreadSheetCells: UIView {

        let line_width = 1 as CGFloat
        let bottom_line_width = 2 as CGFloat

        weak var delegate: SpreadSheetCellsDelegate?
        var row_heights = [] as [CGFloat]
        var column_widths = [] as [CGFloat]
        var content_size = CGSize.zero
        var bottom_line = false

        var tap_recognizer: UITapGestureRecognizer?

        override init(frame: CGRect) {
                super.init(frame: CGRect.zero)

                backgroundColor = UIColor.whiteColor()
        }

        required init(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        func reload() {
                if let delegate = delegate {
                        row_heights = delegate.spread_sheet_cells_row_heights(spread_sheet_cells: self)
                        column_widths = delegate.spread_sheet_cells_column_widths(spread_sheet_cells: self)
                        content_size = CGSize(width: column_widths.reduce(0, combine: +), height: row_heights.reduce(0, combine: +) + (bottom_line ? bottom_line_width : 0 as CGFloat))

                        let tapable = delegate.spread_sheet_cells_tapable(spread_sheet_cells: self)

                        if tapable && tap_recognizer == nil {
                                tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action:")
                                self.addGestureRecognizer(tap_recognizer!)
                        } else if !tapable && tap_recognizer != nil {
                                self.removeGestureRecognizer(tap_recognizer!)
                                tap_recognizer = nil
                        }
                }

                setNeedsDisplay()
        }

        func tap_action(recognizer: UITapGestureRecognizer) {
                let location = recognizer.locationInView(self)
                let cell = cell_for_point(point: location)
                delegate?.spread_sheet_cells_tapped(spread_sheet_cells: self, row: cell.row, column: cell.col)
        }

        func index_for_position(position position: CGFloat, lengths: [CGFloat]) -> Int {
                var sum = 0 as CGFloat
                for i in 0 ..< lengths.count {
                        sum += lengths[i]
                        if position < sum {
                                return i
                        }
                }
                return lengths.count - 1
        }

        func cell_for_point(point point: CGPoint) -> (row: Int, col: Int) {
                return (row: index_for_position(position: point.y, lengths: row_heights), col: index_for_position(position: point.x, lengths: column_widths))
        }

        func rect_for_cell(row row: Int, col: Int) -> CGRect {
                var rect = CGRect.zero
                for i in 0 ..< col {
                        rect.origin.x += column_widths[i]
                }
                rect.size.width = column_widths[col]
                for i in 0..<row {
                        rect.origin.y += row_heights[i]
                }
                rect.size.height = row_heights[row]
                return rect
        }

        override func drawRect(rect: CGRect) {
                let context = UIGraphicsGetCurrentContext()
                drawSpreadSheetCells(context: context!, rect: rect)
        }

        func drawSpreadSheetCells(context context: CGContext, rect: CGRect) {
                let (min_row, min_col) = cell_for_point(point: rect.origin)
                let (max_row, max_col) = cell_for_point(point: CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)))
                for row in min_row ... max_row {
                        for col in min_col ... max_col {
                                drawCell(context: context, row: row, col: col)
                        }
                }
                if bottom_line && max_row == row_heights.count - 1 {
                        draw_bottom_line(context: context)
                }
        }

        func drawCell(context context: CGContext, row: Int, col: Int) {
                let rect = rect_for_cell(row: row, col: col)
                let astring = delegate?.spread_sheet_cells_astring(spread_sheet_cells: self, row: row, column: col) ?? astring_body(string: "")
                let right_line = col != column_widths.count - 1
                let bottom_line = row != row_heights.count - 1
                let margin_horizontal = (row_heights[row] - astring.size().height) / 2
                let margin_vertical = (column_widths[col] - astring.size().width) / 2

                drawing_draw_cell_with_attributed_text(context: context, rect: rect, line_width: line_width, attributed_text: astring, background_color: backgroundColor, horizontal_cell: true, margin_horizontal: margin_horizontal, margin_vertical: margin_vertical, text_centered: true, circle_color: nil, circle_radius: 0, top_line: false, right_line: right_line, bottom_line: bottom_line, left_line: false)
        }

        func draw_bottom_line(context context: CGContext) {
                CGContextSaveGState(context)
                CGContextSetLineWidth(context, bottom_line_width)
                CGContextBeginPath(context)
                CGContextMoveToPoint(context, 0, content_size.height - bottom_line_width / 2)
                CGContextAddLineToPoint(context, content_size.width, content_size.height - bottom_line_width / 2)
                CGContextStrokePath(context)
                CGContextRestoreGState(context)
        }
        
        override class func layerClass() -> AnyClass {
                return CATiledLayer.self
        }
}
