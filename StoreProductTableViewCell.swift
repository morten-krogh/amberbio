import UIKit
import StoreKit

let store_product_table_view_cell_height = 100 as CGFloat

class StoreProductTableViewCell: UITableViewCell {

        let title_label = UILabel()
        let description_label = UILabel()
        let inset_view = UIView()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.backgroundColor = UIColor.whiteColor()

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10
                contentView.addSubview(inset_view)

                title_label.font = font_body
                title_label.textAlignment = .Center
                inset_view.addSubview(title_label)

                description_label.font = font_body
                description_label.textAlignment = .Center
                description_label.numberOfLines = 0
                inset_view.addSubview(title_label)

        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()

                inset_view.frame = CGRectInset(contentView.frame, 20, 8)
                
                let width = inset_view.frame.width

                let label_height = 40 as CGFloat
                let text_field_height = 40 as CGFloat

                text_label.frame = CGRect(x: 0, y: 0, width: width, height: label_height)

                let origin_y = label_height + 10
                let text_field_width = min(width - 200, 150)

                short_label.sizeToFit()
                short_label.frame.origin = CGPoint(x: (width - text_field_width) / 2 - short_label.frame.width - 5, y: origin_y + (text_field_height - short_label.frame.height) / 2)

                text_field.frame = CGRect(x: (width - text_field_width) / 2, y: origin_y, width: text_field_width, height: text_field_height)
                
        
        }

        func update(product product: SKProduct) {
                

                product.localizedTitle
                product.localizedDescription

        }
        
}
