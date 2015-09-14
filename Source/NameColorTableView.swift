//import UIKit
//
//class NameColorTableView: UIView, TiledScrollViewDelegate {
//
//        let font: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
//        let fontHeader: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
//        let line_width: CGFloat = 1.0
//
//        override var frame: CGRect {
//                didSet {
//                        propertiesDidChange()
//                }
//        }
//
//        var namesAndColors: [[(name: String, color: UIColor?)]]? {
//                didSet {
//                        propertiesDidChange()
//                }
//        }
//
//        let tiledScrollView = TiledScrollView(frame: CGRect.zero)
//
//        var contentSize = CGSize.zero
//        var maximumZoomScale = 1.0 as CGFloat
//        var minimumZoomScale = 1.0 as CGFloat
//        var rowHeight = 0.0 as CGFloat
//        var columnWidths = [] as [CGFloat]
//        var circleRadius = 0.0 as CGFloat
//
//        override init(frame: CGRect) {
//                super.init(frame: frame)
//                tiledScrollView.delegate = nil
//
//                addSubview(tiledScrollView)
//        }
//
//        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}
//
//        func propertiesDidChange() {
//                tiledScrollView.frame = bounds
//                if let namesAndColors = namesAndColors {
//                        calculateTable(namesAndColors)
//                        minimumZoomScale = max(0.25, min(1, frame.width / max(1, contentSize.width), frame.height / max(1, contentSize.height)))
//                        maximumZoomScale = 1.0
//                        tiledScrollView.delegate = self
//                } else {
//                        contentSize = CGSize.zero
//                        maximumZoomScale = 1.0 as CGFloat
//                        minimumZoomScale = 1.0 as CGFloat
//                        rowHeight = 0.0 as CGFloat
//                        columnWidths = [] as [CGFloat]
//                        circleRadius = 0.0 as CGFloat
//                        tiledScrollView.delegate = nil
//                }
//        }
//
//        func calculateTable(namesAndColors: [[(name: String, color: UIColor?)]]) {
//                circleRadius = font.lineHeight / 2.0
//                rowHeight = 3.0 * font.lineHeight
//                columnWidths = []
//                for var i = 0; i < namesAndColors[0].count; ++i {
//                        var maximumWidth = 0.0 as CGFloat
//                        for row in namesAndColors {
//                                var width = 0.0 as CGFloat
//                                if i > 0 {
//                                        width += font.pointSize
//                                }
//                                let name = row[i].name
//                                let attributedString = Astring(string: name, attributes: [NSFontAttributeName: font])
//                                width += ceil(attributedString.size().width)
//                                width += font.pointSize
//                                if row[i].color != nil {
//                                        width += 2.0 * circleRadius + font.pointSize
//                                }
//                                if width > maximumWidth {
//                                        maximumWidth = width
//                                }
//                        }
//                        columnWidths.append(maximumWidth)
//                }
//
//                contentSize = CGSize(width: ceil(columnWidths.reduce(0, combine: +)), height: ceil(CGFloat(namesAndColors.count) * rowHeight))
//        }
//
//        func drawPDF() {
//                let rect = CGRect(origin: CGPoint.zero, size: contentSize)
//                UIGraphicsBeginPDFPageWithInfo(rect, nil)
//                let context = UIGraphicsGetCurrentContext()
//                draw(context: context!, rect: rect)
//        }
//
//        func draw(context ctx: CGContext, rect: CGRect) {
//                if let namesAndColors = namesAndColors {
//                        drawTable(context: ctx, rect: rect, namesAndColors: namesAndColors)
//                }
//        }
//
//        func drawTable(context ctx: CGContext, rect: CGRect, namesAndColors: [[(name: String, color: UIColor?)]]) {
//                CGContextSaveGState(ctx)
//
//                var startY = max(Int(floor(rect.minY / rowHeight)), 0)
//                var endY = min(Int(ceil(rect.maxY / rowHeight)), namesAndColors.count)
//
//                var originX = 0.0 as CGFloat
//                for var x = 0; x < columnWidths.count; ++x {
//                        let width = columnWidths[x]
//                        if originX > rect.maxX {
//                                return
//                        }
//                        if originX + width > rect.minX {
//                                let margin = font.pointSize
//                                let leftLine = x > 0
//                                for var y = startY; y < endY; ++y {
//                                        let (name, color) = namesAndColors[y][x]
//                                        let cellFont = (x == 0 || y == 0) ? fontHeader : font
//                                        let topLine = y > 0
//                                        let originY = CGFloat(y) * rowHeight
//                                        drawNameAndColorCircle(context: ctx, originX: originX, originY: originY, width: width, height: rowHeight, line_width: line_width, name: name, font: cellFont, circleColor: color, circleRadius: circleRadius, margin: margin, topLine: topLine, leftLine: leftLine)
//                                }
//                        }
//                        originX += width
//                }
//
//                CGContextRestoreGState(ctx)
//        }
//
//        func drawNameAndColorCircle(context ctx: CGContext, originX: CGFloat, originY: CGFloat, width: CGFloat, height: CGFloat, line_width: CGFloat, name: String, font: UIFont, circleColor: UIColor?, circleRadius: CGFloat, margin: CGFloat, topLine: Bool, leftLine: Bool) {
//                CGContextSaveGState(ctx)
//                CGContextSetLineWidth(ctx, line_width)
//                CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
//                CGContextBeginPath(ctx)
//                if topLine {
//                        CGContextMoveToPoint(ctx, originX, originY)
//                        CGContextAddLineToPoint(ctx, originX + width, originY)
//                }
//                if leftLine {
//                        CGContextMoveToPoint(ctx, originX, originY)
//                        CGContextAddLineToPoint(ctx, originX, originY + height)
//                }
//                CGContextStrokePath(ctx)
//
//                let originNameX = originX + (leftLine ? margin : 0)
//                let originNameY = originY + height / 2.0 - font.lineHeight / 2.0
//                NSString(string: name).drawInRect(CGRect(x: originNameX, y: originNameY, width: width, height: height), withAttributes: [NSFontAttributeName : font])
//
//                if let circleColor = circleColor {
//                        let centerCircleX = originX + width - margin - circleRadius
//                        let centerCircleY = originY + height / 2.0
//                        drawCircle(context: ctx, centerX: centerCircleX, centerY: centerCircleY, radius: circleRadius, color: circleColor.CGColor)
//                }
//
//                CGContextRestoreGState(ctx)
//        }
//
//        func drawCircle (context ctx: CGContext, centerX: CGFloat, centerY: CGFloat, radius: CGFloat, color: CGColor) {
//                CGContextSaveGState(ctx)
//                CGContextSetLineWidth(ctx, 0)
//                CGContextSetFillColorWithColor(ctx, color)
//                CGContextBeginPath(ctx)
//                CGContextAddEllipseInRect(ctx, CGRect(x: centerX - radius, y: centerY - radius, width: 2.0 * radius, height: 2.0 * radius))
//                CGContextClosePath(ctx)
//                CGContextFillPath(ctx)
//                CGContextRestoreGState(ctx)
//        }
//}
