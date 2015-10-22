import UIKit

let store_restore_table_view_cell_height = 100 as CGFloat

class StoreRestoreTableViewCell: UITableViewCell {

        let description_text = "If a module is purchased on one device, it can be transferred to another device with the same Apple ID. Likewise, if the app is deleted and reinstalled, previous purchased modules will be forgotten. All purchased modules can be restored. The restoration process contacts Apple'se servers and obtains a copy of all past purchases. There is nothing to lose by restoring, and it can be done multiple times. Restore if you think you are missing some purchased modules."

        let description_label = UILabel()
        let restore_button = UIButton(type: .System)
        let inset_view = UIView()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.backgroundColor = UIColor.whiteColor()

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10
                inset_view.backgroundColor = color_blue_selectable
                contentView.addSubview(inset_view)

                description_label.text = description_text
                description_label.font = font_body
                description_label.textAlignment = .Left
                description_label.numberOfLines = 0
                inset_view.addSubview(description_label)

                let restore_text = astring_font_size_color(string: "Restore", font: nil, font_size: 24, color: nil)
                restore_button.setAttributedTitle(restore_text, forState: .Normal)
                restore_button.addTarget(self, action: "restore_action", forControlEvents: .TouchUpInside)
                inset_view.addSubview(restore_button)
        }

        required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()

                inset_view.frame = CGRectInset(contentView.frame, 20, 8)

                let width = inset_view.frame.width

                var origin_y = 10 as CGFloat

                let description_width = min(width - 20, 500)
                description_label.frame = CGRect(x: (width - description_width) / 2, y: origin_y, width: description_width, height: 120)
                origin_y += description_label.frame.height + 10

                restore_button.sizeToFit()
                restore_button.frame.origin = CGPoint(x: (width - restore_button.frame.width) / 2, y: origin_y)
        }

        func restore_action() {
                state.store.restore()
        }
}
