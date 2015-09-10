import UIKit

let text_field_table_view_cell_height = 70 as CGFloat

class TextFieldTableViewCell: UITableViewCell {

        let text_field = UITextField()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None

                contentView.backgroundColor = UIColor.whiteColor()

                text_field.backgroundColor = UIColor.whiteColor()
                text_field.textAlignment = NSTextAlignment.Center
                text_field.font = font_body
                text_field.textColor = color_blue_selectable_header
                text_field.borderStyle = UITextBorderStyle.Bezel
                text_field.layer.masksToBounds = true
                contentView.addSubview(text_field)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                let width = contentView.frame.width

                text_field.frame.size = CGSize(width: width - 40, height: 50)
                text_field.center = CGPoint(x: width / 2, y: 35)
        }

        func update(text text: String, tag: Int, delegate: UITextFieldDelegate) {
                text_field.tag = tag
                text_field.text = text
                text_field.delegate = delegate
        }
}
