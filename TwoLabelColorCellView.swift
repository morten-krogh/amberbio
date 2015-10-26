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
                label_1.attributedText = astring_font_size_color(string: text_1, font: nil, font_size: 18, color: nil)
                label_1.textAlignment = .Center

                if let text_2 = text_2 {
                        label_2.attributedText = astring_font_size_color(string: text_2, font: nil, font_size: 16, color: nil)
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
