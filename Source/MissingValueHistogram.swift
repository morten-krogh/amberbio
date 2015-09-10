import UIKit

protocol MissingValueHistogramDelegate: class {
        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat)
}

class MissingValueHistogram: TiledScrollViewDelegate {

        var delegate: MissingValueHistogramDelegate?

        var content_size = CGSize.zeroSize
        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 0.5 as CGFloat

        let labels: [Astring]
        let values: [Int]
        let colors: [UIColor]

        let lineWidth = 1 as CGFloat
        let margin = 2 as CGFloat
        let distanceBetweenTicks = 30 as CGFloat
        let heightValueText = 30 as CGFloat

        let widthOfBar = 30 as CGFloat
        let distanceBetweenBars = 20 as CGFloat

        let middle_margin = 50 as CGFloat
        let lineMargin = 20 as CGFloat
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        let fontFootnote = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)

        var numberOfTicks: Int!
        var originCoordinateSystem = CGPoint.zeroPoint

        init(labels: [Astring], values: [Int], colors: [UIColor]) {
                self.labels = labels
                self.values = values
                self.colors = colors

                calculateHistogram()
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func calculateHistogram() {
                let maxValue = max(values.reduce(0, combine: max), 1)
                numberOfTicks = Int(floor(log2(Double(maxValue)))) + 2

                originCoordinateSystem.y = margin + CGFloat(numberOfTicks + 2) * distanceBetweenTicks

                let maxLabelWidth = labels.reduce(0 as CGFloat, combine: { max($0, $1.size().width) })

                let height = originCoordinateSystem.y + lineWidth + heightValueText + maxLabelWidth + margin

                originCoordinateSystem.x = margin + astring_footnote(string: "Missing   ").size().width + margin

                let width = originCoordinateSystem.x + lineWidth + (CGFloat(labels.count) + 1) * (widthOfBar + distanceBetweenTicks) + margin

                content_size = CGSize(width: width, height: height)
        }

        func draw(context ctx: CGContext, rect: CGRect) {
                drawHistogram(context: ctx, rect: rect)
        }

        func drawHistogram(context context: CGContext, rect: CGRect) {

                CGContextSetLineWidth(context, lineWidth)
                CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)

                Drawing.drawText(context: context, text: "Missing\nValues", font: fontFootnote, origin: CGPoint(x: margin, y: margin), horizontal: true)

                let endPointYAxis = CGPoint(x: originCoordinateSystem.x, y: margin)
                Drawing.drawLine(context: context, startPoint: originCoordinateSystem, endPoint: endPointYAxis)
                Drawing.drawArrowVertical(context: context, point: endPointYAxis, length: 10)

                let protrusion = 3 as CGFloat
                var tickPoint = originCoordinateSystem
                var tickNumber = 0
                for  i in 0 ..< numberOfTicks + 1 {
                        if i > 0 {
                                Drawing.drawLine(context: context, startPoint: CGPoint(x: tickPoint.x - protrusion, y: tickPoint.y), endPoint: CGPoint(x: tickPoint.x + protrusion, y: tickPoint.y))
                        }
                        let attributedString = astring_body(string: "\(tickNumber)")
                        let tickNumberPoint = CGPoint(x: tickPoint.x - 2 * protrusion - attributedString.size().width, y: tickPoint.y - attributedString.size().height / 2)
                        Drawing.drawText(context: context, text: "\(tickNumber)", font: font, origin: tickNumberPoint, horizontal: true)
                        tickPoint.y -= distanceBetweenTicks
                        tickNumber = tickNumber == 0 ? 1 : 2 * tickNumber
                }

                let endPointXAxis = CGPoint(x: originCoordinateSystem.x + lineWidth + (CGFloat(labels.count) + 1) * (widthOfBar + distanceBetweenTicks), y: originCoordinateSystem.y)
                Drawing.drawLine(context: context, startPoint: originCoordinateSystem, endPoint: endPointXAxis)
                Drawing.drawArrowHorizontal(context: context, point: endPointXAxis, length: 10)

                for i in 0 ..< labels.count {
                        let lowerLeftCornerOfRect = CGPoint(x: originCoordinateSystem.x + distanceBetweenTicks + CGFloat(i) * (widthOfBar + distanceBetweenTicks), y: originCoordinateSystem.y)
                        let value = values[i]
                        let barHeight = value == 0 ? 0 : CGFloat(1 + log2(Double(value))) * distanceBetweenTicks
                        let barRect = CGRect(x: lowerLeftCornerOfRect.x, y: lowerLeftCornerOfRect.y - barHeight, width: widthOfBar, height: barHeight)
                        CGContextSaveGState(context)
                        CGContextSetFillColorWithColor(context, colors[i].CGColor)
                        CGContextBeginPath(context)
                        CGContextAddRect(context, barRect)
                        CGContextFillPath(context)
                        CGContextRestoreGState(context)

                        let attributedValue = Astring(string: String(value), attributes: [NSFontAttributeName: fontFootnote])
                        let originValue = CGPoint(x: lowerLeftCornerOfRect.x + (widthOfBar - attributedValue.size().width) / 2, y: lowerLeftCornerOfRect.y + 0.2 * heightValueText)
                        Drawing.drawText(context: context, text: String(value), font: fontFootnote, origin: originValue, horizontal: true)

                        let label = labels[i]
                        let originLabel = CGPoint(x: lowerLeftCornerOfRect.x + (widthOfBar + label.size().height) / 2, y: lowerLeftCornerOfRect.y + heightValueText)
                        Drawing.drawAttributedText(context: context, attributedText: label, origin: originLabel, horizontal: false)
                }
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {
                delegate?.scroll_view_did_end_zooming(zoom_scale: zoom_scale)
        }

        func tap_action(location location: CGPoint) {}
}
