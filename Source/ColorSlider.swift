import UIKit

class ColorSlider: UIControl, UITextFieldDelegate {

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

        let redLabel: UILabel = UILabel()
        let redSlider: UISlider = UISlider()
        let redTextField: UITextField = UITextField()

        let greenLabel: UILabel = UILabel()
        let greenSlider: UISlider = UISlider()
        let greenTextField: UITextField = UITextField()

        let blueLabel: UILabel = UILabel()
        let blueSlider: UISlider = UISlider()
        let blueTextField: UITextField = UITextField()

        private let keyboardType = UIKeyboardType.NumbersAndPunctuation
        
        override init (frame: CGRect) {
                super.init(frame: frame)

                redLabel.text = "Red"
                addSubview(redLabel)

                redSlider.minimumTrackTintColor = UIColor.redColor()
                redSlider.addTarget(self, action: "sliderAction:", forControlEvents: UIControlEvents.ValueChanged)
                addSubview(redSlider)

                redTextField.keyboardType = keyboardType
                redTextField.delegate = self
                addSubview(redTextField)

                greenLabel.text = "Green"
                addSubview(greenLabel)

                greenSlider.minimumTrackTintColor = UIColor.greenColor()
                greenSlider.addTarget(self, action: "sliderAction:", forControlEvents: UIControlEvents.ValueChanged)
                addSubview(greenSlider)

                greenTextField.keyboardType = keyboardType
                greenTextField.delegate = self
                addSubview(greenTextField)

                blueLabel.text = "Blue"
                addSubview(blueLabel)

                blueSlider.minimumTrackTintColor = UIColor.blueColor()
                blueSlider.addTarget(self, action: "sliderAction:", forControlEvents: UIControlEvents.ValueChanged)
                addSubview(blueSlider)

                blueTextField.keyboardType = keyboardType
                blueTextField.delegate = self
                addSubview(blueTextField)

                frame_did_change()
                colorDidChange()
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func frame_did_change () {
                let width = frame.size.width
                let height = frame.size.height
                let label_width = 50.0 as CGFloat
                let textFieldWidth = 40.0 as CGFloat
                let horizontalSpace = 0.5 * label_width
                let rowHeight = redSlider.frame.size.height
                let sliderWidth = max(40.0, width - 2.0 * horizontalSpace - label_width - textFieldWidth)
                let rowInterval = (height - 3.0 * rowHeight) / 2.0 + rowHeight

                var labelFrame = CGRect(x: 0, y: 0, width: label_width, height: rowHeight)
                var sliderFrame = CGRect(x: label_width + horizontalSpace, y: 0, width: sliderWidth, height: rowHeight)
                var textFieldFrame = CGRect(x: label_width + 2.0 * horizontalSpace + sliderWidth, y: 0, width: textFieldWidth, height: rowHeight)

                redLabel.frame = labelFrame
                redSlider.frame = sliderFrame
                redTextField.frame = textFieldFrame

                labelFrame.origin.y += rowInterval
                sliderFrame.origin.y += rowInterval
                textFieldFrame.origin.y += rowInterval

                greenLabel.frame = labelFrame
                greenSlider.frame = sliderFrame
                greenTextField.frame = textFieldFrame

                labelFrame.origin.y += rowInterval
                sliderFrame.origin.y += rowInterval
                textFieldFrame.origin.y += rowInterval

                blueLabel.frame = labelFrame
                blueSlider.frame = sliderFrame
                blueTextField.frame = textFieldFrame
        }

        func colorDidChange () {
                var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

                redSlider.value = Float(red)
                redTextField.text = String(min(Int(floor(red * 256)), 255))

                greenSlider.value = Float(green)
                greenTextField.text = String(min(Int(floor(green * 256)), 255))

                blueSlider.value = Float(blue)
                blueTextField.text = String(min(Int(floor(blue * 256)), 255))

                sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }

        func sliderAction (slider: UISlider) {
                color = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: 1.0)
        }

        func textFieldDidEndEditing(textField: UITextField) {
                textFieldCorrect(textField)
                let redInt = Int(redTextField.text!)!
                let greenInt = Int(greenTextField.text!)!
                let blueInt = Int(blueTextField.text!)!
                color = UIColor(red: CGFloat(redInt) / 255, green: CGFloat(greenInt) / 255, blue: CGFloat(blueInt) / 255, alpha: 1)
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
                if range.length != 0 && string.isEmpty {
                        return true
                }

                if range.location > 2 || string.characters.count != 1 {
                        return false
                }

                return Int(string) != nil
        }

        func textFieldCorrect (textField: UITextField) {
                if let text = textField.text, let value = Int(text) {
                        if value > 255 {
                                textField.text = "255"
                        }
                } else {
                        textField.text = "0"
                }
        }
}
