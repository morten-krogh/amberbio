import UIKit

class Drawing {


        class func maxWidth(names names: [String], font: UIFont) -> CGFloat {
                var maximum = 0 as CGFloat
                for name in names {
                        let attributedString = Astring(string: name, attributes: [NSFontAttributeName: font])
                        let width = ceil(attributedString.size().width)
                        maximum = max(maximum, width)
                }
                return maximum
        }

        class func drawCellWithAttributedString(context context: CGContext, rect: CGRect, lineWidth: CGFloat, attributedString: Astring?, backgroundColor: UIColor?, horizontalCell: Bool, marginHorizontal: CGFloat, marginVertical: CGFloat, circleColor: UIColor?, circleRadius: CGFloat, topLine: Bool, rightLine: Bool, bottomLine: Bool, leftLine: Bool) {
                CGContextSaveGState(context)
                CGContextSetLineWidth(context, lineWidth)
                if let backgroundColor = backgroundColor {
                        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
                        CGContextBeginPath(context)
                        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y)
                        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y)
                        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
                        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height)
                        CGContextClosePath(context)
                        CGContextFillPath(context)
                }

                CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
                CGContextBeginPath(context)
                if topLine {
                        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y)
                        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y)
                }
                if rightLine {
                        CGContextMoveToPoint(context, rect.origin.x + rect.size.width, rect.origin.y)
                        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
                }
                if bottomLine {
                        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height)
                        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
                }
                if leftLine {
                        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y)
                        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height)
                }
                CGContextStrokePath(context)

                if let attributedString = attributedString {
                        let size = attributedString.size()
                        var origin: CGPoint
                        let rectMidX = rect.origin.x + (rect.size.width - (circleColor == nil ? 0 : (marginHorizontal + 2.0 * circleRadius))) / 2.0
                        if horizontalCell {
                                origin = CGPoint(x: rectMidX - size.width / 2.0, y: CGRectGetMidY(rect) - size.height / 2.0)
                        } else {
                                origin = CGPoint(x: rectMidX + size.height / 2.0, y: CGRectGetMidY(rect) - size.width / 2.0)
                        }
                        drawAttributedString(context: context, attributedString: attributedString, origin: origin, horizontal: horizontalCell)
                }

                if let circleColor = circleColor {
                        let centerX = CGRectGetMaxX(rect) - marginHorizontal - circleRadius
                        let centerY = CGRectGetMidY(rect)
                        drawCircle(context: context, centerX: centerX, centerY: centerY, radius: circleRadius, color: circleColor)
                }

                CGContextRestoreGState(context)
        }

        class func drawAttributedString(context context: CGContext, attributedString: Astring, origin: CGPoint, horizontal: Bool) {
                CGContextSaveGState(context)
                UIGraphicsPushContext(context)
                if horizontal {
                        attributedString.drawAtPoint(origin)
                } else {
                        let translation = CGAffineTransformMakeTranslation(-origin.x, -origin.y)
                        let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                        let transform = CGAffineTransformConcat(CGAffineTransformConcat(translation, rotation), CGAffineTransformInvert(translation))
                        CGContextConcatCTM(context, transform)
                        attributedString.drawAtPoint(origin)
                }
                UIGraphicsPopContext()
                CGContextRestoreGState(context)
        }

        class func drawCell(context ctx: CGContext, originX: CGFloat, originY: CGFloat, width: CGFloat, height: CGFloat, lineWidth: CGFloat, topLine: Bool, rightLine: Bool, bottomLine: Bool, leftLine: Bool) {
                drawCellWithName(context: ctx, originX: originX, originY: originY, width: width, height: height, lineWidth: lineWidth, name: nil, font: nil, horizontalName: nil, margin: nil, topLine: topLine, rightLine: rightLine, bottomLine: bottomLine, leftLine: leftLine)
        }

        class func drawCellWithName(context ctx: CGContext, originX: CGFloat, originY: CGFloat, width: CGFloat, height: CGFloat, lineWidth: CGFloat, name: String?, font: UIFont?, horizontalName: Bool?, margin: CGFloat?, topLine: Bool, rightLine: Bool, bottomLine: Bool, leftLine: Bool) {
                CGContextSaveGState(ctx)
                CGContextSetLineWidth(ctx, lineWidth)
                CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
                CGContextBeginPath(ctx)
                if topLine {
                        CGContextMoveToPoint(ctx, originX, originY)
                        CGContextAddLineToPoint(ctx, originX + width, originY)
                }
                if rightLine {
                        CGContextMoveToPoint(ctx, originX + width, originY)
                        CGContextAddLineToPoint(ctx, originX + width, originY + height)
                }
                if bottomLine {
                        CGContextMoveToPoint(ctx, originX, originY + height)
                        CGContextAddLineToPoint(ctx, originX + width, originY + height)
                }
                if leftLine {
                        CGContextMoveToPoint(ctx, originX, originY)
                        CGContextAddLineToPoint(ctx, originX, originY + height)
                }
                CGContextStrokePath(ctx)

                if let name = name {
                        if horizontalName! {
                                let originNameX = originX + margin!
                                let originNameY = originY + height / 2.0 - font!.lineHeight / 2.0
                                drawText(context: ctx, text: name, font: font!, origin: CGPoint(x: originNameX, y: originNameY), horizontal: true)
                        } else {
                                let originNameX = originX + width / 2.0 + font!.lineHeight / 2.0
                                let originNameY = originY + margin!
                                drawText(context: ctx, text: name, font: font!, origin: CGPoint(x: originNameX, y: originNameY), horizontal: false)
                        }
                }
                CGContextRestoreGState(ctx)
        }

        class func drawText(context context: CGContext, text: String, font: UIFont, origin: CGPoint, horizontal: Bool) {
                let attributedText = Astring(string: text, attributes: [NSFontAttributeName: font])
                drawAttributedText(context: context, attributedText: attributedText, origin: origin, horizontal: horizontal)
        }

        class func drawAttributedText(context context: CGContext, attributedText: Astring, origin: CGPoint, horizontal: Bool) {
                CGContextSaveGState(context)
                UIGraphicsPushContext(context)
                if horizontal {
                        attributedText.drawAtPoint(origin)
                } else {
                        let translation = CGAffineTransformMakeTranslation(-origin.x, -origin.y)
                        let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                        let transform = CGAffineTransformConcat(CGAffineTransformConcat(translation, rotation), CGAffineTransformInvert(translation))
                        CGContextConcatCTM(context, transform)
                        attributedText.drawAtPoint(origin)
                }
                UIGraphicsPopContext()
                CGContextRestoreGState(context)
        }

        class func drawCellWithCenteredCircle(context context: CGContext, originX: CGFloat, originY: CGFloat, width: CGFloat, height: CGFloat, lineWidth: CGFloat, topLine: Bool, rightLine: Bool, bottomLine: Bool, leftLine: Bool, radius: CGFloat, color: UIColor) {
                drawCell(context: context, originX: originX, originY: originY, width: width, height: height, lineWidth: lineWidth, topLine: topLine, rightLine: rightLine, bottomLine: bottomLine, leftLine: leftLine)
                drawCircle(context: context, centerX: originX + 0.5 * width, centerY: originY + 0.5 * height, radius: radius, color: color)
        }

        class func drawCircle(context ctx: CGContext, centerX: CGFloat, centerY: CGFloat, radius: CGFloat, color: UIColor) {
                CGContextSaveGState(ctx)
                CGContextSetLineWidth(ctx, 0)
                CGContextSetFillColorWithColor(ctx, color.CGColor)
                CGContextBeginPath(ctx)
                CGContextAddEllipseInRect(ctx, CGRect(x: centerX - radius, y: centerY - radius, width: 2.0 * radius, height: 2.0 * radius))
                CGContextClosePath(ctx)
                CGContextFillPath(ctx)
                CGContextRestoreGState(ctx)
        }

        class func drawLine(context context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
                CGContextSaveGState(context)
                CGContextBeginPath(context)
                CGContextMoveToPoint(context, startPoint.x, startPoint.y)
                CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
                CGContextStrokePath(context)
                CGContextRestoreGState(context)
        }

        class func drawArrowVertical(context context: CGContext, point: CGPoint, length: CGFloat) {
                let offSetX = length
                let offSetY = length
                drawLine(context: context, startPoint: point, endPoint: CGPoint(x: point.x - offSetX , y: point.y + offSetY))
                drawLine(context: context, startPoint: point, endPoint: CGPoint(x: point.x + offSetX , y: point.y + offSetY))
        }

        class func drawArrowHorizontal(context context: CGContext, point: CGPoint, length: CGFloat) {
                let offSetX = length
                let offSetY = length
                drawLine(context: context, startPoint: point, endPoint: CGPoint(x: point.x - offSetX , y: point.y - offSetY))
                drawLine(context: context, startPoint: point, endPoint: CGPoint(x: point.x - offSetX , y: point.y + offSetY))
        }
}
