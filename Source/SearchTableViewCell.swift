import UIKit

class SearchTableViewCell: UITableViewCell {

        let search_bar = custom_search_bar()
//        let inset_view = UIView()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                search_bar.backgroundColor = UIColor.whiteColor()

                selectionStyle = UITableViewCellSelectionStyle.None

                contentView.backgroundColor = UIColor.whiteColor()

//                inset_view.clipsToBounds = true
//                inset_view.layer.cornerRadius = 20
//                inset_view.backgroundColor = UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 1.0)
//                contentView.addSubview(inset_view)
//
//                inset_view.addSubview(text_field)
                contentView.addSubview(search_bar)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                search_bar.frame = CGRectInset(contentView.bounds, 10, 5)
//                inset_view.frame = CGRectInset(contentView.bounds, 10, 5)

//                text_field.frame.size = CGSize(width: 300, height: 30)
//                text_field.center = CGPoint(x: inset_view.bounds.width / 2, y: inset_view.bounds.height / 2)
        }

//        func update(text text: String, tag: Int, delegate: UITextFieldDelegate) {
//                text_field.tag = tag
//                text_field.text = text
//                text_field.delegate = delegate
//        }




}
