import UIKit

class HomeButtonView: UIButton {

        var color: UIColor = color_home_button_enabled

        override init(frame: CGRect) {
                super.init(frame: frame)

                contentMode = UIViewContentMode.Redraw

                addTarget(self, action: "action_enabled", forControlEvents: UIControlEvents.TouchUpInside)
                addTarget(self, action: "action_higlighted", forControlEvents: UIControlEvents.TouchDown)
                addTarget(self, action: "action_enabled", forControlEvents: UIControlEvents.TouchUpOutside)
                addTarget(self, action: "action_enabled", forControlEvents: UIControlEvents.TouchDragExit)

                enabled = true
        }

        required init(coder aDecoder: NSCoder) {
                fatalError("This initializer should not be called")
        }

        convenience init () {
                self.init(frame: CGRectZero)
        }

        override var enabled: Bool {
                didSet {
                        color = enabled ? color_home_button_enabled : color_home_button_disabled
                        layer.setNeedsDisplay()
                }
        }

        func action_enabled() {
                color = color_home_button_enabled
                layer.setNeedsDisplay()
        }

        func action_higlighted () {
                color = color_home_button_highlighted
                layer.setNeedsDisplay()
        }

        override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
                CGContextSetFillColorWithColor(ctx, color.CGColor)
                drawHouse(layer, inContext: ctx)
        }

        // drawHouse draws a house with a roof.
        func drawHouse (layer: CALayer, inContext ctx:CGContext) {
                let a: CGFloat = 20
                let c: CGFloat = 18
                let d: CGFloat = 25
                let e: CGFloat = 8
                let f: CGFloat = 6
                let g: CGFloat = 10
                let h: CGFloat = 40
                let i: CGFloat = h * f / (c/2 + a + e)
                let j: CGFloat = h * g / (c/2 + a + e)

                let width = 2 * (g + f + e + a) + c
                let height = d + h + i + j

                let scaleX = layer.bounds.width / width
                let scaleY = layer.bounds.height / height
                let scale = min(scaleX, scaleY)

                let transform = CGAffineTransform(a: scale, b: 0, c: 0, d: -scale, tx: 0, ty: layer.bounds.height)

                CGContextSaveGState(ctx)

                CGContextConcatCTM(ctx, transform)

                CGContextSetLineWidth(ctx, 0)

                // house

                CGContextBeginPath(ctx)
                CGContextMoveToPoint(ctx, g + f + e, 0)
                CGContextAddLineToPoint(ctx, g + f + e, d)
                CGContextAddLineToPoint(ctx, g + f, d)
                CGContextAddLineToPoint(ctx, g + f + e + a + c / 2, d + h)
                CGContextAddLineToPoint(ctx, g + f + e + a + c + a + e, d)
                CGContextAddLineToPoint(ctx, g + f + e + a + c + a, d)
                CGContextAddLineToPoint(ctx, g + f + e + a + c + a, 0)
                CGContextAddLineToPoint(ctx, g + f + e + a + c, 0)
                CGContextAddLineToPoint(ctx, g + f + e + a + c, d)
                CGContextAddLineToPoint(ctx, g + f + e + a, d)
                CGContextAddLineToPoint(ctx, g + f + e + a, 0)
                CGContextAddLineToPoint(ctx, g + f + e, 0)
                CGContextClosePath(ctx)
                CGContextFillPath(ctx)

                // roof
                //CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)

                CGContextBeginPath(ctx)
                CGContextMoveToPoint(ctx, 0, d)
                CGContextAddLineToPoint(ctx, g, d)
                CGContextAddLineToPoint(ctx, g + f + e + a + c / 2, d + h + i)
                CGContextAddLineToPoint(ctx, g + f + e + a + c + a + e + f, d)
                CGContextAddLineToPoint(ctx, g + f + e + a + c + a + e + f + g, d)
                CGContextAddLineToPoint(ctx, g + f + e + a + c / 2, d + h + i + j)
                CGContextAddLineToPoint(ctx, 0, d)
                CGContextClosePath(ctx)
                CGContextFillPath(ctx)
                
                CGContextRestoreGState(ctx)
        }
}
