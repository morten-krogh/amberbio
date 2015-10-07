import UIKit

let cross_validation_table_view_cell_height = 120 as CGFloat

class CrossValidationTableViewCell: UITableViewCell {

        let text_label = UILabel()
        let text_field = UITextField()
        let symbol_label = UILabel()
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

                text_field.backgroundColor = UIColor.whiteColor()
                text_field.textAlignment = NSTextAlignment.Center
                text_field.font = font_body
                text_field.textColor = color_blue_selectable_header
                text_field.borderStyle = UITextBorderStyle.Bezel
                text_field.layer.masksToBounds = true
                inset_view.addSubview(text_field)

                let symbol_string = "\u{2192}"
                symbol_label.attributedText = astring_font_size_color(string: symbol_string, font: nil, font_size: 24, color: nil)
                inset_view.addSubview(symbol_label)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                inset_view.frame = CGRectInset(contentView.frame, 20, 8)

                let width = inset_view.frame.width
                let height = inset_view.frame.height

                let label_height = 40 as CGFloat
                let text_field_height = 40 as CGFloat

                symbol_label.sizeToFit()
                symbol_label.frame.origin = CGPoint(x: width - 15 - symbol_label.frame.width, y: (height - symbol_label.frame.height) / 2)
                let symbol_label_margin = symbol_label.frame.width + 30

                text_label.frame = CGRect(x: symbol_label_margin, y: 0, width: width - 2 * symbol_label_margin, height: label_height)

                let origin_y = label_height + 10
                let text_field_width = min(width - 200, 300)
                text_field.frame = CGRect(x: text_field_width / 2, y: origin_y, width: text_field_width, height: text_field_height)
        }

        func update(text text: String, k_fold: Int, tag: Int, delegate: UITextFieldDelegate) {
                inset_view.backgroundColor = color_blue_selectable
                
                text_label.text = text
                text_field.tag = tag
                text_field.text = "\(k_fold)"
                text_field.delegate = delegate
        }
}
