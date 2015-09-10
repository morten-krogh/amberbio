import UIKit

class MultiSegmentedScrollView: UIControl {

        var selected_segments = [] as [Int]
        let multi_segmented_view = MultiSegmentedView()
        let scroll_view = UIScrollView()
        var content_size = CGSize.zeroSize

        override init(frame: CGRect) {
                super.init(frame: frame)

                multi_segmented_view.addTarget(self, action: "change_action:", forControlEvents: .ValueChanged)
                scroll_view.addSubview(multi_segmented_view)
                addSubview(scroll_view)
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func render(names names: [String], selected_segments: [Int]) {
                self.selected_segments = selected_segments
                multi_segmented_view.render(names: names, selected_segments: selected_segments)
                content_size = multi_segmented_view.content_size
        }

        func change_action(multi_segmented_view: MultiSegmentedView) {
                selected_segments = multi_segmented_view.selected_segments
                sendActionsForControlEvents(.ValueChanged)
        }

        override func layoutSubviews() {
                let rect = CGRect(origin: CGPoint.zeroPoint, size: bounds.size)
                scroll_view.frame = layout_centered_frame(contentSize: multi_segmented_view.content_size, rect: rect)
                scroll_view.contentSize = multi_segmented_view.content_size
                multi_segmented_view.frame = CGRect(origin: CGPoint.zeroPoint, size: multi_segmented_view.content_size)
        }
}

class MultiSegmentedView: UIControl {

        let line_width = 0.5 as CGFloat
        let corner_radius = 5 as CGFloat
        var width_of_cell = 70 as CGFloat
        let height = 40 as CGFloat
        let fill_color = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
        let stroke_color = UIColor.blueColor()

        var content_size = CGSize.zeroSize
        var names = [] as [String]
        var selected_segments = [] as [Int]

        var tap_recognizer: UITapGestureRecognizer?

        func render(names names: [String], selected_segments: [Int]) {
                self.names = names
                self.selected_segments = selected_segments.sort()

                content_size = CGSize(width: CGFloat(names.count) * width_of_cell + 2 * line_width, height: height + 2 * line_width)

                backgroundColor = UIColor.whiteColor()

                if tap_recognizer == nil {
                        tap_recognizer = UITapGestureRecognizer()
                        tap_recognizer!.addTarget(self, action: "tap_action:")
                        self.addGestureRecognizer(tap_recognizer!)
                }
                setNeedsDisplay()
        }

        override func drawRect(rect: CGRect) {
                let context = UIGraphicsGetCurrentContext()
                draw_segmented_control(context: context)
        }

        func draw_segmented_control(context context: CGContext) {
                CGContextSaveGState(context)
                CGContextSetLineWidth(context, line_width)

                for i in 0 ..< names.count {
                        draw_cell(context: context, index: i)
                }

                CGContextRestoreGState(context)
        }

        func draw_cell(context context: CGContext, index: Int) {
                let left_cell = index == 0
                let right_cell = index == names.count - 1
                let selected = selected_segments.indexOf(index) != nil

                CGContextSetStrokeColorWithColor(context, stroke_color.CGColor)
                CGContextSetFillColorWithColor(context, fill_color.CGColor)

                let origin_x = line_width + CGFloat(index) * width_of_cell
                let origin_y = line_width

                CGContextBeginPath(context)
                CGContextMoveToPoint(context, origin_x, origin_y + corner_radius)
                if left_cell {
                        CGContextAddArc(context, origin_x + corner_radius, origin_y + corner_radius, corner_radius, CGFloat(M_PI), CGFloat(-M_PI_2), 0)
                } else {
                        CGContextAddLineToPoint(context, origin_x, origin_y)
                        CGContextAddLineToPoint(context, origin_x + corner_radius, origin_y)
                }

                CGContextAddLineToPoint(context, origin_x + width_of_cell - corner_radius, origin_y)
                if right_cell {
                        CGContextAddArc(context, origin_x + width_of_cell - corner_radius, origin_y + corner_radius, corner_radius, CGFloat(-M_PI_2), 0, 0)
                } else {
                        CGContextAddLineToPoint(context, origin_x + width_of_cell, origin_y)
                        CGContextAddLineToPoint(context, origin_x + width_of_cell, origin_y + corner_radius)
                }

                CGContextAddLineToPoint(context, origin_x + width_of_cell, origin_y + height - corner_radius)
                if right_cell {
                        CGContextAddArc(context, origin_x + width_of_cell - corner_radius, origin_y + height - corner_radius, corner_radius, 0, CGFloat(M_PI_2), 0)
                } else {
                        CGContextAddLineToPoint(context, origin_x + width_of_cell, origin_y + height)
                        CGContextAddLineToPoint(context, origin_x + width_of_cell - corner_radius, origin_y + height)
                }

                CGContextAddLineToPoint(context, origin_x + corner_radius, origin_y + height)
                if left_cell {
                        CGContextAddArc(context, origin_x + corner_radius, origin_y + height - corner_radius, corner_radius, CGFloat(M_PI_2), CGFloat(M_PI), 0)
                } else {
                        CGContextAddLineToPoint(context, origin_x, origin_y + height)
                        CGContextAddLineToPoint(context, origin_x, origin_y + height - corner_radius)
                }

                CGContextClosePath(context)

                if selected {
                        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
                } else {
                        CGContextStrokePath(context)
                }

                var astring =  astring_shorten_footnote(string: astring_footnote(string: names[index]), width: width_of_cell - 10 * line_width)

                if selected {
                        astring = astring_change_color(string: astring, color: UIColor.whiteColor())
                } else {
                        astring = astring_change_color(string: astring, color: fill_color)
                }

                let origin_astring_x = origin_x + (width_of_cell - astring.size().width) / 2
                let origin_astring_y = origin_y + (height - astring.size().height) / 2
                astring.drawAtPoint(CGPoint(x: origin_astring_x, y: origin_astring_y))
        }

        func index_for_location(location location: CGPoint) -> Int? {
                if location.y < 0 || location.y > height + line_width {
                        return nil
                }
                if location.x < line_width || location.x > CGFloat(names.count) * width_of_cell + line_width {
                        return nil
                }
                return Int(floor((location.x - line_width) / width_of_cell))
        }

        func tap_action(tap_recognizer: UITapGestureRecognizer) {
                let location = tap_recognizer.locationInView(self)
                if let index = index_for_location(location: location) {
                        if let index_of_index = selected_segments.indexOf(index) {
                                selected_segments.removeAtIndex(index_of_index)
                        } else {
                                selected_segments.append(index)
                        }
                        render(names: names, selected_segments: selected_segments)
                        sendActionsForControlEvents(UIControlEvents.ValueChanged)
                }
        }
}
