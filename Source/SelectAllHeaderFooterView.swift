import UIKit

let select_all_header_footer_view_height = 90 as CGFloat

protocol SelectAllHeaderFooterViewDelegate: class {
        func select_all_action(tag tag: Int)
        func deselect_all_action(tag tag: Int)
}

class SelectAllHeaderFooterView: UITableViewHeaderFooterView {

        weak var delegate: SelectAllHeaderFooterViewDelegate?

        let text_label = UILabel()
        let select_all_button = UIButton(type: .System)
        let deselect_all_button = UIButton(type: .System)

        override init(reuseIdentifier: String?) {
                super.init(reuseIdentifier: reuseIdentifier)

                contentView.clipsToBounds = true
                contentView.backgroundColor = UIColor.whiteColor()

                contentView.addSubview(text_label)

                select_all_button.setAttributedTitle(astring_body(string: "Select all"), forState: .Normal)
                select_all_button.addTarget(self, action: "select_all_action", forControlEvents: .TouchUpInside)
                contentView.addSubview(select_all_button)

                deselect_all_button.setAttributedTitle(astring_body(string: "Deselect all"), forState: .Normal)
                deselect_all_button.addTarget(self, action: "deselect_all_action", forControlEvents: .TouchUpInside)
                deselect_all_button.sizeToFit()
                contentView.addSubview(deselect_all_button)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                let margin = 20 as CGFloat
                let width = contentView.frame.width
                let height = contentView.frame.height
                let text_label_height = min(50, height)

                text_label.frame = CGRect(x: margin, y: 0, width: width - 2 * margin, height: text_label_height)

                select_all_button.sizeToFit()
                deselect_all_button.sizeToFit()

                let origin_y = height - 10 - select_all_button.frame.height
                select_all_button.frame.origin = CGPoint(x: width - margin - select_all_button.frame.width, y: origin_y)
                deselect_all_button.frame.origin = CGPoint(x: margin, y: origin_y)
        }

        
        func update(text text: String, tag: Int, delegate: SelectAllHeaderFooterViewDelegate) {
                self.tag = tag
                self.delegate = delegate
                text_label.attributedText = astring_font_size_color(string: text, font: nil, font_size: 25, color: nil)
                text_label.textAlignment = .Center
        }

        func select_all_action() {
                delegate?.select_all_action(tag: tag)
        }

        func deselect_all_action() {
                delegate?.deselect_all_action(tag: tag)
        }
}
