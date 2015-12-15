import UIKit

let centered_header_footer_view_height = 80 as CGFloat

class CenteredHeaderFooterView: UITableViewHeaderFooterView {

        let color_normal = UIColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 1)
        let color_disabled = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)

        let symbol_label = UILabel()
        let text_label = UILabel()

        var tap_recognizer: UITapGestureRecognizer?

        override init(reuseIdentifier: String?) {
                super.init(reuseIdentifier: reuseIdentifier)

                contentView.clipsToBounds = true
                contentView.backgroundColor = UIColor.whiteColor()

                contentView.addSubview(symbol_label)
                contentView.addSubview(text_label)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                let width = contentView.frame.width
                let height = contentView.frame.height

                let margin: CGFloat
                if !symbol_label.hidden {
                        symbol_label.sizeToFit()
                        symbol_label.frame.origin = CGPoint(x: width - 30 - symbol_label.frame.width, y: (height - symbol_label.frame.height) / 2)
                        margin = symbol_label.frame.width + 35
                } else {
                        margin = 15
                }

                text_label.frame = CGRect(x: margin, y: 0, width: width - 2 * margin, height: height)
        }

        func set_symbol(symbol symbol: CenteredTableViewCellSymbol, color: UIColor) {
                let symbol_string: String
                var font_size = nil as CGFloat?
                switch symbol {
                case .Arrow:
                        symbol_string = "\u{2192}"
                        font_size = 24
                case .Checkmark:
                        symbol_string = "\u{2713}"
                        font_size = 24
                case .Number(let number):
                        symbol_string = "\(number)"
                default:
                        symbol_string = ""
                }
                symbol_label.attributedText = astring_font_size_color(string: symbol_string, font: nil, font_size: font_size, color: color)
                symbol_label.hidden = symbol_string == ""
        }

        func update(attributed_text attributed_text: Astring, color: UIColor, symbol: CenteredTableViewCellSymbol) {
                set_symbol(symbol: symbol, color: color)
                text_label.attributedText = attributed_text
                text_label.textAlignment = .Center
        }

        func update(text text: String, font_size: CGFloat, color: UIColor, symbol: CenteredTableViewCellSymbol) {
                let attributed_text = astring_font_size_color(string: text, font: nil, font_size: font_size, color: color)
                update(attributed_text: attributed_text, color: color, symbol: symbol)
        }

        func update_normal(text text: String) {
                update(text: text, font_size: 25, color: UIColor.blackColor(), symbol: .None)
        }
        
        func update_multiline(text text: String) {
                text_label.numberOfLines = 0
                update_normal(text: text)
        }

        func update_unselected(text text: String) {
                update(text: text, font_size: 25, color: color_gray_unselected, symbol: .None)
        }

        func update_selectable_arrow(text text: String) {
                update(text: text, font_size: 25, color: color_blue_selectable_header, symbol: .Arrow)
        }

        func addTapGestureRecognizer(target target: AnyObject, action: Selector) {
                tap_recognizer = UITapGestureRecognizer(target: target, action: action)
                addGestureRecognizer(tap_recognizer!)
        }

        func removeTapGestureRecognizer() {
                if let tap_recognizer = tap_recognizer {
                        removeGestureRecognizer(tap_recognizer)
                }
                tap_recognizer = nil
        }
}
