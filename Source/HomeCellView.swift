import UIKit

class HomeCellView: UICollectionViewCell {

        var color_normal = UIColor.redColor()

        let label = UILabel()
        let lock_label = UILabel()

        override init(frame: CGRect) {
                super.init(frame: frame)

                contentView.layer.cornerRadius = 10

                lock_label.attributedText = astring_font_size_color(string: "\u{1F512}", font: nil, font_size: 30, color: nil)
                lock_label.textAlignment = .Center
                contentView.addSubview(lock_label)

                label.numberOfLines = 0
                label.textAlignment = .Center
                contentView.addSubview(label)
        }

        required init(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()

                if lock_label.hidden {
                        label.frame = bounds
                } else {
                        lock_label.sizeToFit()
                        let separator_x = bounds.width - lock_label.frame.width
                        lock_label.frame.origin = CGPoint(x: separator_x, y: (bounds.height - lock_label.frame.height) / 2)
                        label.frame = CGRect(x: 0, y: 0, width: separator_x, height: bounds.height)
                }
        }

        func update(title title: String, section: Int, border: Bool, locked: Bool) {
                let attributed_text = astring_font_size_color(string: title, font: font_body, font_size: 16, color: nil)
                label.attributedText = attributed_text
                label.textAlignment = .Center
                color_normal = color_from_hex(hex: color_brewer_qualitative_9_pastel1[section])
                contentView.backgroundColor = color_normal
                if border {
                        contentView.layer.borderWidth = 2
                        contentView.layer.borderColor = UIColor.blackColor().CGColor
                } else {
                        contentView.layer.borderWidth = 0
                        contentView.layer.borderColor = UIColor.whiteColor().CGColor
                }
                lock_label.hidden = !locked
                setNeedsLayout()
        }

        func highlight() {
                contentView.backgroundColor = color_normal.colorWithAlphaComponent(0.5)
        }
        
        func dehighlight() {
                contentView.backgroundColor = color_normal
        }
}
