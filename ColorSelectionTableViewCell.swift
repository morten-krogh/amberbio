import UIKit

class ColorSelectionTableViewCell: UITableViewCell {

        let inset_view = UIView()
        let label = UILabel()
        let color_circle = ColorCircle(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        var label_text = ""

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10

                contentView.addSubview(inset_view)
                inset_view.addSubview(label)
                inset_view.addSubview(color_circle)

                selectionStyle = UITableViewCellSelectionStyle.None
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                inset_view.frame = CGRectInset(contentView.frame, 20, 8)

                let width = inset_view.frame.width
                let height = inset_view.frame.height

                let margin = 20 as CGFloat

                let astring = astring_max_width(string: label_text, max_width: width - 2 * margin - color_circle.frame.width - 30)
                label.attributedText = astring
                label.textAlignment = .Center
                label.sizeToFit()
                print("values:")
                print(width)
                print(width - 2 * margin - color_circle.frame.width - 10)
                print(label.frame.width)

                label.frame = CGRect(x: margin, y: (height - label.frame.height) / 2.0, width: label.frame.width, height: label.frame.height)
                color_circle.frame.origin = CGPoint(x: width - margin - color_circle.frame.width, y: (height - color_circle.frame.height) / 2.0)
        }

        func update(text text: String, color: UIColor) {
                inset_view.backgroundColor = color_blue_selectable
                
                label_text = text
                color_circle.color = color
                
                setNeedsLayout()
        }
}
