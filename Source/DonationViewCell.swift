import UIKit
import StoreKit

class DonationViewCell: UICollectionViewCell {
        
        var product: SKProduct?
        
        let title_label = UILabel()
        let price_label = UILabel()
        let buy_button = UIButton(type: .System)
        let inset_view = UIView()

        override init(frame: CGRect) {
                super.init(frame: frame)
                
                contentView.backgroundColor = UIColor.whiteColor()
                
                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10
                contentView.addSubview(inset_view)
                
                title_label.font = font_headline
                title_label.textAlignment = .Center
                inset_view.addSubview(title_label)
                
                price_label.font = font_headline
                price_label.textAlignment = .Center
                inset_view.addSubview(price_label)
                
                let buy_text = astring_font_size_color(string: "Buy", font: nil, font_size: 24, color: nil)
                buy_button.setAttributedTitle(buy_text, forState: .Normal)
                buy_button.addTarget(self, action: "buy_action", forControlEvents: .TouchUpInside)
                inset_view.addSubview(buy_button)
                
                let tap_recognizer = UITapGestureRecognizer(target: self, action: "buy_action")
                inset_view.addGestureRecognizer(tap_recognizer)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
                super.layoutSubviews()
                
                inset_view.frame = CGRectInset(contentView.frame, 5, 5)
                
                let width = inset_view.frame.width
                
                var origin_y = 5 as CGFloat
                
                title_label.frame = CGRect(x: 0, y: origin_y, width: width, height: 37)
                origin_y += title_label.frame.height
                
                price_label.frame = CGRect(x: 0, y: origin_y, width: width, height: 40)
                origin_y += price_label.frame.height
                
                buy_button.sizeToFit()
                buy_button.frame.origin = CGPoint(x: (width - buy_button.frame.width) / 2, y: origin_y)
        }
        
        func update(product product: SKProduct, color: UIColor) {
                self.product = product
                
                inset_view.backgroundColor = color
                
                title_label.text = product.localizedTitle
                
                let number_formatter = NSNumberFormatter()
                number_formatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
                number_formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                number_formatter.locale = product.priceLocale
                let formatted_price = number_formatter.stringFromNumber(product.price)
                price_label.text = formatted_price
        }
        
        func buy_action() {
                if let product = product {
                        state.store.buy(product: product)
                }
        }
}
