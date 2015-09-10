import UIKit

class ColorCircle: UIView {

        override var frame: CGRect {
                didSet {
                        frame_did_change()
                }
        }

        var color: UIColor = UIColor.blackColor() {
                didSet {
                        colorDidChange()
                }
        }

        override init(frame: CGRect) {
                super.init(frame: frame)
                frame_did_change()
                colorDidChange()
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func frame_did_change () {
                layer.cornerRadius = frame.size.width / 2.0
        }

        func colorDidChange () {
                backgroundColor = color
        }
}
