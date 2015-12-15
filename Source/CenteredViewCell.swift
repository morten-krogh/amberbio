import UIKit

class CenteredViewCell: UICollectionViewCell {
        
        let text_label = UILabel()
        let inset_view = UIView()
        
        override init(frame: CGRect) {
                super.init(frame: frame)
                
                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10
         
                text_label.numberOfLines = 0
                
                contentView.addSubview(inset_view)
                inset_view.addSubview(text_label)
        }

        required init(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
                super.layoutSubviews()
                
                inset_view.frame = CGRectInset(contentView.frame, 20, 8)
                
                let width = inset_view.frame.width
                let height = inset_view.frame.height
                
                let margin = 5 as CGFloat
                
                text_label.frame = CGRect(x: margin, y: 0, width: width - 2 * margin, height: height)
        }
        
        func update(text text: String, font: UIFont?, font_size: CGFloat?, color: UIColor?, background_color: UIColor?) {
                let astring = astring_font_size_color(string: text, font: font, font_size: font_size, color: color)
                text_label.attributedText = astring
                text_label.textAlignment = .Center
                inset_view.backgroundColor = background_color ?? UIColor.whiteColor()
        }

        func update_unselected(text text: String) {
                update(text: text, font: nil, font_size: nil, color: nil, background_color: color_gray_unselected)
        }
}
