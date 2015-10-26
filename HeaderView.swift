import UIKit

class HeaderView: UICollectionReusableView {

        let label = UILabel()

        override init(frame: CGRect) {
                super.init(frame: frame)

                label.textAlignment = .Center
                addSubview(label)
        }

        required init(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()
                label.frame = bounds
        }

        func update(title title: String) {
                let attributed_text = astring_font_size_color(string: title, font: font_headline, font_size: 20, color: nil)
                label.attributedText = attributed_text
                label.textAlignment = .Center
        }
}
