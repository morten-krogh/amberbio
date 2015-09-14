import UIKit

class ColorPicker: UIControl {

        var color = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1)
        var reset_color = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)

        let reset_button = UIButton(type: UIButtonType.System)
        let done_button = UIButton(type: UIButtonType.System)
        let color_circle = ColorCircle(frame: CGRectZero)
        let color_slider = ColorSlider(frame: CGRectZero)
        let color_grid = ColorGrid(frame: CGRectZero)

        override init (frame: CGRect) {
                super.init(frame: frame)

                reset_button.setAttributedTitle(astring_body(string: "Reset"), forState: .Normal)
                reset_button.sizeToFit()
                reset_button.addTarget(self, action: "reset_action:", forControlEvents: UIControlEvents.TouchUpInside)
                addSubview(reset_button)

                done_button.setAttributedTitle(astring_body(string: "Done"), forState: .Normal)
                done_button.sizeToFit()
                done_button.addTarget(self, action: "done_action:", forControlEvents: UIControlEvents.TouchUpInside)
                addSubview(done_button)

                addSubview(color_circle)

                color_slider.addTarget(self, action: "slider_action:", forControlEvents: UIControlEvents.ValueChanged)
                addSubview(color_slider)

                color_grid.addTarget(self, action: "grid_action:", forControlEvents: UIControlEvents.ValueChanged)
                addSubview(color_grid)

                color_did_change()
        }
        
        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                let width = frame.size.width
                let height = frame.size.height
                
                var origin_y = 40 as CGFloat
                let circle_size = 60 as CGFloat

                reset_button.frame.origin = CGPoint(x: 0, y: origin_y + circle_size / 2 - reset_button.frame.size.height / 2)
                done_button.frame.origin = CGPoint(x: width - done_button.frame.size.width - 10, y: origin_y + circle_size / 2 - done_button.frame.size.width / 2)
                color_circle.frame = CGRect(x: (width - circle_size) / 2, y: origin_y, width: circle_size, height: circle_size)

                origin_y = 130
                let heightSlider = 150.0 as CGFloat
                color_slider.frame = CGRect(x: 0, y: origin_y, width: width, height: heightSlider)

                origin_y = 320
                color_grid.frame = CGRect(x: 0, y: origin_y, width: width, height: height - origin_y)
        }

        func update(color color: UIColor, reset_color: UIColor) {
                self.color = color
                self.reset_color = reset_color
                color_did_change()
        }

        func color_did_change () {
                color_circle.color = color
                color_slider.color = color

                sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }

        func reset_action (button: UIButton) {
                color = reset_color
                color_did_change()
        }

        func done_action (button: UIButton) {
                sendActionsForControlEvents(UIControlEvents.EditingDidEnd)
        }

        func slider_action (slider: ColorSlider) {
                color = slider.color
                color_did_change()
        }

        func grid_action (grid: ColorGrid) {
                color = grid.color
                color_did_change()
        }
}
