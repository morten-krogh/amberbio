import UIKit

class HeaderReusableView: UICollectionReusableView {

        let label = UILabel()

        override init(frame: CGRect) {
                super.init(frame: frame)

                label.numberOfLines = 0
                label.textAlignment = .Center
                addSubview(label)
        }

        required init(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()
                label.frame = CGRectInset(bounds, 15, 10)
        }
        
        func update(text text: String, font: UIFont?, font_size: CGFloat?, color: UIColor?) {
                let astring = astring_font_size_color(string: text, font: font, font_size: font_size, color: color)
                label.attributedText = astring
                label.textAlignment = .Center
        }

        func update(title title: String) {
                let attributed_text = astring_font_size_color(string: title, font: font_headline, font_size: 20, color: nil)
                label.attributedText = attributed_text
                label.textAlignment = .Center
        }
        
        func update_normal(text text: String) {
                update(text: text, font: nil, font_size: 25, color: nil)
        }
}
