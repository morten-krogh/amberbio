import UIKit

let two_label_color_cell_view_size = CGSize(width: 100, height: 80)

class TwoLabelColorCellView: UICollectionViewCell {

        let label_1 = UILabel()
        let label_2 = UILabel()

        override init(frame: CGRect) {
                super.init(frame: frame)

                contentView.layer.cornerRadius = 10

                contentView.addSubview(label_1)
                contentView.addSubview(label_2)
        }

        required init(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()

                let width = bounds.width

                if label_2.hidden {
                        label_1.frame = bounds
                } else {
                        var origin_y = 10 as CGFloat

                        label_1.frame = CGRect(x: 0, y: origin_y, width: width, height: 40)
                        origin_y += 40
                        label_2.frame = CGRect(x: 0, y: origin_y, width: width, height: 30)
                }
        }

        func update(text_1 text_1: String, text_2: String?, color: UIColor) {
                let max_width = two_label_color_cell_view_size.width - 15

                let astring_1 = astring_font_size_color(string: text_1, font: nil, font_size: 18, color: nil)
                let astring_1_adjusted = astring_max_width(astring: astring_1, max_width: max_width)

                label_1.attributedText = astring_1_adjusted
                label_1.textAlignment = .Center

                if let text_2 = text_2 {
                        let astring_2 = astring_font_size_color(string: text_2, font: nil, font_size: 16, color: nil)
                        let astring_2_adjusted = astring_max_width(astring: astring_2, max_width: max_width)
                        label_2.attributedText = astring_2_adjusted
                        label_2.textAlignment = .Center
                        label_2.hidden = false
                } else {
                        label_2.hidden = true
                }

                contentView.layer.borderWidth = 3
                contentView.layer.borderColor = color.CGColor
                setNeedsLayout()
        }
}
