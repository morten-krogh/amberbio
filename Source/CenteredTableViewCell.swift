import UIKit

let centered_table_view_cell_height = 56 as CGFloat

enum CenteredTableViewCellSymbol {
        case Arrow
        case Checkmark
        case Number(number: Int)
        case None
}


class CenteredTableViewCell: UITableViewCell {

        let symbol_label = UILabel()
        let text_label = UILabel()
        let inset_view = UIView()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10

                text_label.font = font_body

                contentView.addSubview(inset_view)
                inset_view.addSubview(symbol_label)
                inset_view.addSubview(text_label)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                inset_view.frame = CGRectInset(contentView.frame, 20, 8)

                let width = inset_view.frame.width
                let height = inset_view.frame.height

                let margin: CGFloat
                if !symbol_label.hidden {
                        symbol_label.sizeToFit()
                        symbol_label.frame.origin = CGPoint(x: width - 15 - symbol_label.frame.width, y: (height - symbol_label.frame.height) / 2)
                        margin = symbol_label.frame.width + 30
                } else {
                        margin = 5
                }

                text_label.frame = CGRect(x: margin, y: 0, width: width - 2 * margin, height: height)
        }

        func set_symbol(symbol symbol: CenteredTableViewCellSymbol) {
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
                symbol_label.attributedText = astring_font_size_color(string: symbol_string, font: nil, font_size: font_size, color: nil)
                symbol_label.hidden = symbol_string == ""
        }

        func update(attributed_text attributed_text: Astring, background_color: UIColor, symbol: CenteredTableViewCellSymbol) {
                set_symbol(symbol: symbol)
                text_label.attributedText = attributed_text
                text_label.textAlignment = .Center
                inset_view.backgroundColor = background_color
        }

        func update_multiline(text: String) {
                update_selectable_arrow(text: text)
                text_label.numberOfLines = 2
        }

        func update_selectable_arrow(attributed_text attributed_text: Astring) {
                update(attributed_text: attributed_text, background_color: color_blue_selectable, symbol: .Arrow)
        }

        func update_selectable_arrow(text text: String) {
                update_selectable_arrow(attributed_text: astring_body(string: text))
        }

        func update_selected_checkmark(attributed_text attributed_text: Astring) {
                update(attributed_text: attributed_text, background_color: color_green_selected, symbol: .Checkmark)
        }

        func update_selected_checkmark(text text: String) {
                update_selected_checkmark(attributed_text: astring_body(string: text))
        }

        func update_selected_number(attributed_text attributed_text: Astring , number: Int) {
                update(attributed_text: attributed_text, background_color: color_green_selected, symbol: .Number(number: number))
        }

        func update_selected_number(text text: String, number: Int) {
                update_selected_number(attributed_text: astring_body(string: text), number: number)
        }

        func update_unselected(attributed_text attributed_text: Astring) {
                update(attributed_text: attributed_text, background_color: color_gray_unselected, symbol: .None)
        }

        func update_unselected(text text: String) {
                update_unselected(attributed_text: astring_body(string: text))
        }

}
