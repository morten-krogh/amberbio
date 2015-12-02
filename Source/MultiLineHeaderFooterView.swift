import UIKit

class MultiLineHeaderFooterView: UITableViewHeaderFooterView {

        let inset_view = UIView()
        let text_label = UILabel()

        override init(reuseIdentifier: String?) {
                super.init(reuseIdentifier: reuseIdentifier)

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10

                contentView.addSubview(inset_view)

                contentView.clipsToBounds = true
                contentView.backgroundColor = UIColor.whiteColor()

                text_label.numberOfLines = 0
                inset_view.addSubview(text_label)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                inset_view.frame = CGRectInset(contentView.frame, 20, 8)

                let width = inset_view.frame.width
                let height = inset_view.frame.height

                let margin = 15 as CGFloat
                text_label.frame = CGRect(x: margin, y: 0, width: width - 2 * margin, height: height)
        }

        func update(attributed_text attributed_text: Astring, background_color: UIColor) {
                text_label.attributedText = attributed_text
                text_label.textAlignment = .Left
                inset_view.backgroundColor = background_color
        }
}
