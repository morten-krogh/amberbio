import UIKit

class NameDateTableViewCell: UITableViewCell {

        let inset_view = UIView()

        let name_label = UILabel()
        let date_label = UILabel()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.backgroundColor = UIColor.whiteColor()

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 20

                name_label.textAlignment = .Center
                name_label.font = font_body

                date_label.textAlignment = .Center
                date_label.font = font_footnote
                date_label.textColor = UIColor.lightGrayColor()

                contentView.addSubview(inset_view)
                inset_view.addSubview(name_label)
                inset_view.addSubview(date_label)
        }
        
        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                let top_margin = 5 as CGFloat
                let middle_margin = 20 as CGFloat

                inset_view.frame = CGRectInset(contentView.bounds, 10, 5)
                name_label.sizeToFit()
                date_label.sizeToFit()

                name_label.center = CGPoint(x: inset_view.frame.width / 2.0, y: top_margin + name_label.frame.height / 2.0)
                date_label.center = CGPoint(x: inset_view.frame.width / 2.0, y: top_margin + name_label.frame.height / 2.0 + middle_margin + date_label.frame.height / 2.0)
        }

        func update(name name: String, date: NSDate, background_color: UIColor) {
                name_label.text = name
                date_label.text = date_formatted_string(date: date)
                inset_view.backgroundColor = background_color
                setNeedsLayout()
        }

        func update_selected(name name: String, date: NSDate) {
                update(name: name, date: date, background_color: color_green_selected)
        }

        func update_unselected(name name: String, date: NSDate) {
                update(name: name, date: date, background_color: color_gray_unselected)
        }
}
