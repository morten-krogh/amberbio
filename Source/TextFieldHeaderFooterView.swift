import UIKit

class TextFieldHeaderFooterView: UITableViewHeaderFooterView {

        let text_field = UITextField()

        override init(reuseIdentifier: String?) {
                super.init(reuseIdentifier: reuseIdentifier)

                contentView.backgroundColor = UIColor.whiteColor()

                text_field.backgroundColor = UIColor.whiteColor()
                text_field.textAlignment = NSTextAlignment.Center
                text_field.font = font_body
                text_field.textColor = UIColor.blueColor()
                text_field.borderStyle = UITextBorderStyle.Bezel
                text_field.layer.masksToBounds = true
                contentView.addSubview(text_field)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                let margin = 20 as CGFloat
                let width = contentView.frame.width

                text_field.sizeToFit()
                text_field.frame = CGRect(x: margin, y: 0, width: width - 2 * margin, height: text_field.frame.height + margin)
        }

        func update(text text: String, tag: Int, delegate: UITextFieldDelegate) {
                text_field.tag = tag
                text_field.text = text
                text_field.delegate = delegate
        }
}
