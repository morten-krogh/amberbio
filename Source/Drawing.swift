import UIKit

func drawing_max_width(names names: [String], font: UIFont) -> CGFloat {
        var maximum = 0 as CGFloat
        for name in names {
                let attributed_string = astring_font_size_color(string: name, font: font, font_size: nil, color: nil)
                let width = ceil(attributed_string.size().width)
                maximum = max(maximum, width)
        }
        return maximum
}

func drawing_draw_text(context context: CGContext, text: String, font: UIFont, origin: CGPoint, horizontal: Bool) {
        let attributed_text = astring_font_size_color(string: text, font: font, font_size: nil, color: nil)
        drawing_draw_attributed_text(context: context, attributed_text: attributed_text, origin: origin, horizontal: horizontal)
}

func drawing_draw_attributed_text(context context: CGContext, attributed_text: Astring, origin: CGPoint, horizontal: Bool) {
        CGContextSaveGState(context)
        UIGraphicsPushContext(context)
        if horizontal {
                attributed_text.drawAtPoint(origin)
        } else {
                let translation = CGAffineTransformMakeTranslation(-origin.x, -origin.y)
                let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                let transform = CGAffineTransformConcat(CGAffineTransformConcat(translation, rotation), CGAffineTransformInvert(translation))
                CGContextConcatCTM(context, transform)
                attributed_text.drawAtPoint(origin)
        }
        UIGraphicsPopContext()
        CGContextRestoreGState(context)
}

func draw_circle(context ctx: CGContext, center_x: CGFloat, center_y: CGFloat, radius: CGFloat, color: UIColor) {
        CGContextSaveGState(ctx)
        CGContextSetLineWidth(ctx, 0)
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextBeginPath(ctx)
        CGContextAddEllipseInRect(ctx, CGRect(x: center_x - radius, y: center_y - radius, width: 2.0 * radius, height: 2.0 * radius))
        CGContextClosePath(ctx)
        CGContextFillPath(ctx)
        CGContextRestoreGState(ctx)
}

func draw_line(context context: CGContext, start_point: CGPoint, end_point: CGPoint) {
        CGContextSaveGState(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, start_point.x, start_point.y)
        CGContextAddLineToPoint(context, end_point.x, end_point.y)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
}

func draw_arrow_vertical(context context: CGContext, point: CGPoint, length: CGFloat) {
        let offSetX = length
        let offSetY = length
        draw_line(context: context, start_point: point, end_point: CGPoint(x: point.x - offSetX , y: point.y + offSetY))
        draw_line(context: context, start_point: point, end_point: CGPoint(x: point.x + offSetX , y: point.y + offSetY))
}

func draw_arrow_horizontal(context context: CGContext, point: CGPoint, length: CGFloat) {
        let offSetX = length
        let offSetY = length
        draw_line(context: context, start_point: point, end_point: CGPoint(x: point.x - offSetX , y: point.y - offSetY))
        draw_line(context: context, start_point: point, end_point: CGPoint(x: point.x - offSetX , y: point.y + offSetY))
}

func draw_cell_with_attributed_text(context context: CGContext, rect: CGRect, line_width: CGFloat, attributed_text: Astring?, background_color: UIColor?, horizontal_cell: Bool, margin_horizontal: CGFloat, margin_vertical: CGFloat, text_centered: Bool, circle_color: UIColor?, circle_radius: CGFloat, top_line: Bool, right_line: Bool, bottom_line: Bool, left_line: Bool) {
        CGContextSaveGState(context)
        CGContextSetLineWidth(context, line_width)
        if let background_color = background_color {
                CGContextSetFillColorWithColor(context, background_color.CGColor)
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
        if top_line {
                CGContextMoveToPoint(context, rect.origin.x, rect.origin.y)
                CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y)
        }
        if right_line {
                CGContextMoveToPoint(context, rect.origin.x + rect.size.width, rect.origin.y)
                CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
        }
        if bottom_line {
                CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height)
                CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
        }
        if left_line {
                CGContextMoveToPoint(context, rect.origin.x, rect.origin.y)
                CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height)
        }
        CGContextStrokePath(context)

        if let attributed_text = attributed_text {
                let size = attributed_text.size()
                var origin: CGPoint
                let rect_mid_x = rect.origin.x + (rect.size.width - (circle_color == nil ? 0 : (margin_horizontal + 2.0 * circle_radius))) / 2.0
                if horizontal_cell {
                        let origin_x = text_centered ? rect_mid_x - size.width / 2.0 : rect.origin.x
                        origin = CGPoint(x: origin_x, y: CGRectGetMidY(rect) - size.height / 2.0)
                } else {
                        let origin_y = text_centered ? CGRectGetMidY(rect) - size.width / 2.0 : rect.origin.y
                        origin = CGPoint(x: rect_mid_x + size.height / 2.0, y: origin_y)
                }
                drawing_draw_attributed_text(context: context, attributed_text: attributed_text, origin: origin, horizontal: horizontal_cell)
        }

        if let circle_color = circle_color {
                let center_x = CGRectGetMaxX(rect) - margin_horizontal - circle_radius
                let center_y = CGRectGetMidY(rect)
                draw_circle(context: context, center_x: center_x, center_y: center_y, radius: circle_radius, color: circle_color)
        }

        CGContextRestoreGState(context)
}

func drawing_draw_cell(context context: CGContext, origin_x: CGFloat, origin_y: CGFloat, width: CGFloat, height: CGFloat, line_width: CGFloat, top_line: Bool, right_line: Bool, bottom_line: Bool, left_line: Bool) {
        let rect = CGRect(x: origin_x, y: origin_y, width: width, height: height)

        draw_cell_with_attributed_text(context: context, rect: rect, line_width: line_width, attributed_text: nil, background_color: nil, horizontal_cell: true, margin_horizontal: 0, margin_vertical: 0, text_centered: true, circle_color: nil, circle_radius: 0, top_line: top_line, right_line: right_line, bottom_line: bottom_line, left_line: left_line)
}

func drawing_draw_cell_with_centered_circle(context context: CGContext, origin_x: CGFloat, origin_y: CGFloat, width: CGFloat, height: CGFloat, line_width: CGFloat, top_line: Bool, right_line: Bool, bottom_line: Bool, left_line: Bool, radius: CGFloat, color: UIColor) {
        drawing_draw_cell(context: context, origin_x: origin_x, origin_y: origin_y, width: width, height: height, line_width: line_width, top_line: top_line, right_line: right_line, bottom_line: bottom_line, left_line: left_line)
        draw_circle(context: context, center_x: origin_x + 0.5 * width, center_y: origin_y + 0.5 * height, radius: radius, color: color)
}
