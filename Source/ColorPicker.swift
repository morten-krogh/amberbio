import UIKit

class ColorPicker: UIControl {

        override var frame: CGRect {
                didSet {
                        frame_did_change()
                }
        }

        var color: UIColor = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1) {
                didSet {
                        if color != oldValue {
                                colorDidChange()
                        }
                }
        }

        var defaultColor = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)

        var title: String = "" {
                didSet {
                        titleLabel.text = title
                        titleLabel.sizeToFit()
                        frame_did_change()
                }
        }

        let titleLabel = UILabel()
        let reset_button = UIButton(type: UIButtonType.System)
        let done_button = UIButton(type: UIButtonType.System)
        let colorCircle = ColorCircle(frame: CGRectZero)
        let colorSlider = ColorSlider(frame: CGRectZero)
        let colorGrid = ColorGrid(frame: CGRectZero)

        override init (frame: CGRect) {
                super.init(frame: frame)

                addSubview(titleLabel)

                reset_button.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                reset_button.setAttributedTitle(astring_body(string: "Reset"), forState: .Normal)
                reset_button.sizeToFit()
                reset_button.addTarget(self, action: "resetAction:", forControlEvents: UIControlEvents.TouchUpInside)
                addSubview(reset_button)

                done_button.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                done_button.setAttributedTitle(astring_body(string: "Done"), forState: .Normal)
                done_button.sizeToFit()
                done_button.addTarget(self, action: "doneAction:", forControlEvents: UIControlEvents.TouchUpInside)
                addSubview(done_button)

                addSubview(colorCircle)

                colorSlider.addTarget(self, action: "sliderAction:", forControlEvents: UIControlEvents.ValueChanged)
                addSubview(colorSlider)

                colorGrid.addTarget(self, action: "gridAction:", forControlEvents: UIControlEvents.ValueChanged)
                addSubview(colorGrid)

                frame_did_change()
                colorDidChange()
        }
        
        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func frame_did_change () {
                let width = frame.size.width
                let height = frame.size.height
                let titleFrame = CGRect(x: (width - titleLabel.frame.width) / 2.0, y: 0, width: titleLabel.frame.width, height: titleLabel.frame.height)
                titleLabel.frame = titleFrame

                let originYResetCircleDone = 40.0 as CGFloat
                let circleSize = 60.0 as CGFloat

                reset_button.frame.origin = CGPoint(x: 0, y: originYResetCircleDone + circleSize / 2.0 - reset_button.frame.size.height / 2.0)
                done_button.frame.origin = CGPoint(x: width - done_button.frame.size.width - 10, y: originYResetCircleDone + circleSize / 2.0 - done_button.frame.size.width / 2.0)
                colorCircle.frame = CGRect(x: (width - circleSize) / 2.0, y: originYResetCircleDone, width: circleSize, height: circleSize)

                let originYSlider = 130.0 as CGFloat
                let heightSlider = 150.0 as CGFloat
                colorSlider.frame = CGRect(x: 0, y: originYSlider, width: width, height: heightSlider)

                let originYGrid = 320 as CGFloat
                colorGrid.frame = CGRect(x: 0, y: originYGrid, width: width, height: height - originYGrid)
        }

        func colorDidChange () {
                colorCircle.color = color
                colorSlider.color = color

                sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }

        func resetAction (button: UIButton) {
                color = defaultColor
        }

        func doneAction (button: UIButton) {
                sendActionsForControlEvents(UIControlEvents.EditingDidEnd)
        }

        func sliderAction (slider: ColorSlider) {
                color = slider.color
        }

        func gridAction (grid: ColorGrid) {
                color = grid.color
                colorSlider.color = color
        }
}
