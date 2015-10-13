import UIKit

let parameter_table_view_cell_height = 120 as CGFloat

class ParameterTableViewCell: UITableViewCell {

        let text_label = UILabel()
        let short_label = UILabel()
        let text_field = UITextField()
        let inset_view = UIView()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.backgroundColor = UIColor.whiteColor()

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10
                contentView.addSubview(inset_view)

                text_label.font = font_body
                text_label.textAlignment = .Center
                inset_view.addSubview(text_label)

                short_label.attributedText = astring_font_size_color(string: "k = ", font: nil, font_size: 20, color: nil)
                inset_view.addSubview(short_label)

                text_field.keyboardType = UIKeyboardType.NumbersAndPunctuation
                text_field.autocorrectionType = UITextAutocorrectionType.No
                text_field.backgroundColor = UIColor.whiteColor()
                text_field.textAlignment = NSTextAlignment.Center
                text_field.font = font_body
                text_field.textColor = color_blue_selectable_header
                text_field.borderStyle = UITextBorderStyle.Bezel
                text_field.layer.masksToBounds = true
                inset_view.addSubview(text_field)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                inset_view.frame = CGRectInset(contentView.frame, 20, 8)

                let width = inset_view.frame.width

                let label_height = 40 as CGFloat
                let text_field_height = 40 as CGFloat

                text_label.frame = CGRect(x: 0, y: 0, width: width, height: label_height)

                let origin_y = label_height + 10
                let text_field_width = min(width - 200, 150)

                short_label.sizeToFit()
                short_label.frame.origin = CGPoint(x: (width - text_field_width) / 2 - short_label.frame.width - 5, y: origin_y + (text_field_height - short_label.frame.height) / 2)

                text_field.frame = CGRect(x: (width - text_field_width) / 2, y: origin_y, width: text_field_width, height: text_field_height)
        }

        func update(text text: String, short_text: String, parameter: String, tag: Int, delegate: UITextFieldDelegate) {
                inset_view.backgroundColor = color_blue_selectable
                
                text_label.text = text
                short_label.attributedText = astring_font_size_color(string: short_text, font: nil, font_size: 20, color: nil)
                text_field.tag = tag
                text_field.text = parameter
                text_field.delegate = delegate
        }
}
