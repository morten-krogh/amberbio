import UIKit

class ColorGrid: UIControl {

        override var frame: CGRect {
                didSet {
                        frame_did_change()
                }
        }

        var color = UIColor.whiteColor()

        private let button_size = 50.0 as CGFloat
        private let button_separation = 20.0 as CGFloat
        private var number_of_squares_per_row = 0
        private var number_of_squares_per_column = 0
        private var palette = [] as [UIColor]

        override init(frame: CGRect) {
                super.init(frame: frame)
                backgroundColor = UIColor.whiteColor()
                let tap_action: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap_action:")
                tap_action.numberOfTapsRequired = 1
                self.addGestureRecognizer(tap_action)
                frame_did_change()
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func frame_did_change () {
                number_of_squares_per_row = Int(floor((frame.size.width - button_size) / (button_size + button_separation))) + 1
                number_of_squares_per_column = Int(floor((frame.size.height - button_size) / (button_size + button_separation))) + 1
                palette = color_palette(number_of_colors: number_of_squares_per_row * number_of_squares_per_column)
                setNeedsDisplay()
        }

        func tap_action (recognizer: UITapGestureRecognizer) {
                let tapLocation = recognizer.locationInView(self)
                let normalizedX = (tapLocation.x - button_size / 2) / (button_size + button_separation)
                let integralX = round(normalizedX)
                let fractionalX = normalizedX - integralX
                if (abs(fractionalX) > 0.6 * button_size / (button_size + button_separation)) || (integralX >= CGFloat(number_of_squares_per_row)) {
                        return
                }
                let normalizedY = (tapLocation.y - button_size / 2) / (button_size + button_separation)
                let integralY  = round(normalizedY)
                let fractionalY = normalizedY - integralY
                if (abs(fractionalY) > 0.6 * button_size / (button_size + button_separation)) || (integralY >= CGFloat(number_of_squares_per_column)) {
                        return
                }
                let buttonNumber: Int = Int(integralY) * number_of_squares_per_row + Int(integralX)
                color = palette[buttonNumber]
                sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }

        override func drawRect(rect: CGRect) {
                let ctx = UIGraphicsGetCurrentContext()
                CGContextSetLineWidth(ctx, 0)
                drawGrid(context: ctx!)
        }

        func drawGrid (context ctx: CGContext) {
                for var i = 0; i < number_of_squares_per_column; ++i {
                        let cornerPointY = CGFloat(i) * (button_size + button_separation)
                        for var j = 0; j < number_of_squares_per_row; ++j {
                                let cornerPointX = CGFloat(j) * (button_size + button_separation)
                                let color = palette[i * number_of_squares_per_row + j]
                                drawSquare(context: ctx, cornerPointX: cornerPointX, cornerPointY: cornerPointY, color: color.CGColor)
                        }
                }
        }

        func drawSquare (context ctx: CGContext, cornerPointX: CGFloat, cornerPointY: CGFloat, color: CGColor) {
                CGContextBeginPath(ctx)
                CGContextMoveToPoint(ctx, cornerPointX, cornerPointY)
                CGContextAddLineToPoint(ctx, cornerPointX + button_size, cornerPointY)
                CGContextAddLineToPoint(ctx, cornerPointX + button_size, cornerPointY + button_size)
                CGContextAddLineToPoint(ctx, cornerPointX, cornerPointY + button_size)
                CGContextClosePath(ctx)
                CGContextSetFillColorWithColor(ctx, color)
                CGContextFillPath(ctx)
        }
}
