import UIKit

class Button: UIControl {

        let label = UILabel()

        var text = ""
        var font_size: CGFloat?
        var color = color_home_button_enabled

        override init(frame: CGRect) {
                super.init(frame: frame)

                backgroundColor = UIColor.whiteColor()

                addSubview(label)

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

        override func layoutSubviews() {
                super.layoutSubviews()

                label.frame = bounds
        }

        func update_label() {
                label.attributedText = astring_font_size_color(string: text, font: nil, font_size: font_size, color: color)
        }

        func update(text text: String, font_size: CGFloat? = nil) {
                self.text = text
                self.font_size = font_size
                update_label()
        }

        override var enabled: Bool {
                didSet {
                        color = enabled ? color_home_button_enabled : color_home_button_disabled
                        update_label()
                }
        }

        func action_enabled() {
                print("hej3")
                color = color_home_button_enabled
                update_label()
        }

        func action_higlighted () {
                print("hej4")
                color = color_home_button_highlighted
                update_label()
        }

        override func sizeToFit() {
                label.sizeToFit()
                frame.size = label.frame.size
        }
}
