import UIKit
import StoreKit

let store_product_table_view_cell_height = 275 as CGFloat

class StoreProductTableViewCell: UITableViewCell {

        var product: SKProduct?

        let title_label = UILabel()
        let description_label = UILabel()
        let price_label = UILabel()
        let buy_button = UIButton(type: .System)
        let inset_view = UIView()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.backgroundColor = UIColor.whiteColor()

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10
                contentView.addSubview(inset_view)

                title_label.font = font_headline
                title_label.textAlignment = .Center
                inset_view.addSubview(title_label)

                description_label.font = font_body
                description_label.textAlignment = .Left
                description_label.numberOfLines = 0
                inset_view.addSubview(description_label)

                price_label.font = font_headline
                price_label.textAlignment = .Center
                inset_view.addSubview(price_label)

                let buy_text = astring_font_size_color(string: "Buy", font: nil, font_size: 24, color: nil)
                buy_button.setAttributedTitle(buy_text, forState: .Normal)
                buy_button.addTarget(self, action: "buy_action", forControlEvents: .TouchUpInside)
                inset_view.addSubview(buy_button)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()

                inset_view.frame = CGRectInset(contentView.frame, 20, 8)
                
                let width = inset_view.frame.width

                var origin_y = 10 as CGFloat

                title_label.frame = CGRect(x: 0, y: origin_y, width: width, height: 40)
                origin_y += title_label.frame.height + 5

                let description_width = min(width - 40, 500)
                description_label.font = font_body
                let description_size = description_label.sizeThatFits(CGSize(width: description_width, height: 0))
                print(description_size)
                if description_size.height > 120 {
                        description_label.font = font_footnote
                }

                description_label.frame = CGRect(x: (width - description_width) / 2, y: origin_y, width: description_width, height: 120)
                origin_y += description_label.frame.height

                price_label.frame = CGRect(x: 0, y: origin_y, width: width, height: 40)
                origin_y += price_label.frame.height

                buy_button.sizeToFit()
                buy_button.frame.origin = CGPoint(x: (width - buy_button.frame.width) / 2, y: origin_y)
        }

        func update(product product: SKProduct, color: UIColor) {

                self.product = product

                inset_view.backgroundColor = color

                title_label.text = product.localizedTitle
                description_label.text = product.localizedDescription

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
