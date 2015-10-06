import UIKit

let classification_table_view_cell_height = 75 as CGFloat

class ClassificationTableViewCell: UITableViewCell {

        let text_label_1 = UILabel()
        let text_label_2 = UILabel()
        let inset_view = UIView()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 15

                text_label_1.font = font_body
                text_label_1.textAlignment = .Center

                text_label_2.font = font_footnote
                text_label_2.textAlignment = .Center

                contentView.addSubview(inset_view)
                inset_view.addSubview(text_label_1)
                inset_view.addSubview(text_label_2)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                inset_view.frame = CGRectInset(contentView.frame, 20, 8)

                let width = inset_view.frame.width

                let label_height_1 = 30 as CGFloat
                let label_height_2 = 30 as CGFloat

                var origin_y = 0 as CGFloat
                text_label_1.frame = CGRect(x: 0, y: origin_y, width: width, height: label_height_1)
                origin_y += label_height_1
                text_label_2.frame = CGRect(x: 0, y: origin_y, width: width, height: label_height_2)
        }

        func update_success(text_1 text_1: String, text_2: String) {
                text_label_1.text = text_1
                text_label_2.text = text_2
                inset_view.backgroundColor = color_success
        }

        func update_failure(text_1 text_1: String, text_2: String) {
                text_label_1.text = text_1
                text_label_2.text = text_2
                inset_view.backgroundColor = color_failure
        }
}
