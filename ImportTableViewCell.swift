import UIKit

let import_table_view_cell_height = 120 as CGFloat

class ImportTableViewCell: UITableViewCell {

        var import_action: (() -> Void)?
        var name = ""

        let inset_view = UIView()

        let name_label = UILabel()
        let date_label = UILabel()
        let import_button = UIButton(type: .System)

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.backgroundColor = UIColor.whiteColor()

                inset_view.layer.cornerRadius = 20
                inset_view.backgroundColor = UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 1.0)

                date_label.textAlignment = .Center
                date_label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
                date_label.textColor = UIColor.lightGrayColor()

                import_button.setAttributedTitle(astring_body(string: "Import"), forState: .Normal)
                import_button.addTarget(self, action: "local_import_action", forControlEvents: .TouchUpInside)

                contentView.addSubview(inset_view)
                inset_view.addSubview(name_label)
                inset_view.addSubview(date_label)
                inset_view.addSubview(import_button)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                let top_margin = 15 as CGFloat
                let middle_margin = 20 as CGFloat

                inset_view.frame = CGRectInset(contentView.bounds, 10, 5)

                let name_astring = astring_body(string: name)
                name_label.attributedText = astring_max_width(astring: name_astring, max_width: inset_view.frame.width - 20)
                name_label.textAlignment = .Center
                name_label.sizeToFit()

                date_label.sizeToFit()

                name_label.center = CGPoint(x: inset_view.frame.width / 2.0, y: top_margin + name_label.frame.height / 2.0)
                date_label.center = CGPoint(x: inset_view.frame.width / 2.0, y: top_margin + name_label.frame.height / 2.0 + middle_margin + 5 + date_label.frame.height / 2.0)

                import_button.sizeToFit()
                import_button.center = CGPoint(x: inset_view.frame.width / 2.0, y: CGRectGetMaxY(date_label.frame) + middle_margin + 5)
        }

        func update(name name: String, date: NSDate, import_action: () -> Void) {
                self.name = name
                date_label.text = date_formatted_string(date: date)
                self.import_action = import_action
        }
        
        func local_import_action() {
                import_action?()
        }
}
