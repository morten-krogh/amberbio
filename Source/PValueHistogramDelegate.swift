import UIKit

class PValueHistogramDelegate: TiledScrollViewDelegate {

        var content_size = CGSize(width: 600, height: 400)
        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 1 as CGFloat

        var number_of_bins = 1
        var frequencies = [] as [Int]
        var max_frequency = 0
        var average_frequency = 0 as Double

        let margin = 20 as CGFloat

        let color_significant = UIColor(red: CGFloat(228) / CGFloat(255), green: CGFloat(26) / CGFloat(255), blue: CGFloat(28) / CGFloat(255), alpha: 1)
        let color_insignificant = UIColor(red: CGFloat(55) / CGFloat(255), green: CGFloat(126) / CGFloat(255), blue: CGFloat(184) / CGFloat(255), alpha: 1)

        func update(p_values p_values: [Double], number_of_bins: Int) {
                self.number_of_bins = number_of_bins
                frequencies = [Int](count: number_of_bins, repeatedValue: 0)
                var number_of_p_values = 0
                for p_value in p_values {
                        if !p_value.isNaN {
                                number_of_p_values++
                                let bin = Int(floor(p_value * Double(number_of_bins)))
                                if bin >= 0 && bin < number_of_bins {
                                        frequencies[bin]++
                                } else if bin == number_of_bins {
                                        frequencies[number_of_bins - 1]++
                                }
                        }
                }

                max_frequency = 0
                for frequency in frequencies {
                        if frequency > max_frequency {
                                max_frequency = frequency
                        }
                }

                average_frequency = Double(number_of_p_values) / Double(number_of_bins)
        }

        func draw(context context: CGContext, rect: CGRect) {
                CGContextSaveGState(context)
                CGContextSetLineWidth(context, 1)
                CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)

                if max_frequency > 0 {
                        drawHistogram(context: context, rect: rect)
                }

                CGContextRestoreGState(context)
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {}
        func tap_action(location location: CGPoint) {}

        func drawHistogram(context context: CGContext, rect: CGRect) {
                let (width, height) = (content_size.width, content_size.height)

                let astring_max_frequency = astring_body(string: "\(max_frequency)")
                let max_frequency_point = CGPoint(x: margin, y: 3 * margin - astring_max_frequency.size().height / 2)
                astring_max_frequency.drawAtPoint(max_frequency_point)

                let zero_x = margin + astring_max_frequency.size().width + margin

                let origin_y = height - margin - astring_body(string: "0.1").size().height
                for i in 1 ... 10 {
                        let p_value = Double(i) / Double(10)
                        let text = "\(p_value)"
                        let astring = astring_body(string: text)
                        let origin_x = zero_x + CGFloat(i) * (width - zero_x - 3 * margin) / CGFloat(10) - astring.size().width / 2
                        astring.drawAtPoint(CGPoint(x: origin_x, y: origin_y))
                }

                let zero_y = origin_y - 10
                let zero_point = CGPoint(x: zero_x, y: zero_y)

                let y_axis_end = CGPoint(x: zero_x, y: margin)
                Drawing.drawLine(context: context, startPoint: zero_point, endPoint: y_axis_end)
                Drawing.drawArrowVertical(context: context, point: y_axis_end, length: 10)

                let x_axis_end = CGPoint(x: width - margin, y: zero_y)
                Drawing.drawLine(context: context, startPoint: zero_point, endPoint: x_axis_end)
                Drawing.drawArrowHorizontal(context: context, point: x_axis_end, length: 10)

                let max_bin_height = zero_y - 3 * margin
                let bin_spacing = (width - 3 * margin - zero_x) / CGFloat(number_of_bins)

                for i in 0 ..< number_of_bins {
                        let frequency = frequencies[i]
                        let bin_height = CGFloat(frequency) / CGFloat(max_frequency) * max_bin_height
                        let lower_left_corner_x = zero_x + CGFloat(i) * bin_spacing
                        let color = Double(i) / Double(number_of_bins) < 0.05 ? color_significant : color_insignificant
                        CGContextSetFillColorWithColor(context, color.CGColor)
                        CGContextBeginPath(context)
                        CGContextMoveToPoint(context, lower_left_corner_x, zero_y)
                        CGContextAddLineToPoint(context, lower_left_corner_x, zero_y - bin_height)
                        CGContextAddLineToPoint(context, lower_left_corner_x + bin_spacing, zero_y - bin_height)
                        CGContextAddLineToPoint(context, lower_left_corner_x + bin_spacing, zero_y)
                        CGContextClosePath(context)
                        CGContextFillPath(context)
                }

                let stipulated_line_y = zero_y - CGFloat(average_frequency) / CGFloat(max_frequency) * max_bin_height
                let width_of_segment = 3 as CGFloat
                let number_of_segments = Int(floor((width - 2 * margin - zero_x) / (2 * width_of_segment)))

                for i in 0 ..< number_of_segments {
                        let initial_x = zero_x + CGFloat(i * 2) * width_of_segment
                        let segment_start_point = CGPoint(x: initial_x, y: stipulated_line_y)
                        let segment_end_point = CGPoint(x: initial_x + width_of_segment, y: stipulated_line_y)
                        Drawing.drawLine(context: context, startPoint: segment_start_point, endPoint: segment_end_point)
                }


        }
}
