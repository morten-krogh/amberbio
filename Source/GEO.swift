import UIKit

enum GEOStatus {
        case NoInput
        case CorrectInput
        case IncorrectInput
        case Downloading
        case Importing
}

class GEOState: PageState {

        var state = GEOStatus.NoInput
        var geo_id = ""

        override init() {
                super.init()
                name = "geo"
                title = astring_body(string: "Gene expression omnibus")
                info = "Download data set and series records from Gene expression omnibus (GEO).\n\nRDatasets have ids of the form GDSnnnnn.\n\nSeries have ids of the form GSEnnnn.\n\n"
        }
}

class GEO: Component, UITextFieldDelegate {

        var geo_state: GEOState!

        let scroll_view = UIScrollView()
        let info_label = UILabel()
        let message_label = UILabel()
        let text_field = UITextField()
        let button = UIButton(type: .System)

        override func viewDidLoad() {
                super.viewDidLoad()

                info_label.text = "Download a public data set from Gene expression omnibus. Type an id for a GEO data set of the form GDSnnnn or a GEO series of the form GSEnnnn."
                info_label.textAlignment = .Left
                info_label.font = font_body
                info_label.numberOfLines = 0
                scroll_view.addSubview(info_label)

                message_label.numberOfLines = 0
                scroll_view.addSubview(message_label)

                text_field.clearButtonMode = UITextFieldViewMode.WhileEditing
                text_field.font = font_body
                text_field.autocorrectionType = UITextAutocorrectionType.No
                text_field.textAlignment = NSTextAlignment.Center
                text_field.borderStyle = UITextBorderStyle.Bezel
                text_field.layer.masksToBounds = true
                text_field.delegate = self
                scroll_view.addSubview(text_field)

                button.addTarget(self, action: "button_action", forControlEvents: .TouchUpInside)
                scroll_view.addSubview(button)

                view.addSubview(scroll_view)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                var origin_y = 20 as CGFloat

                let info_label_size = info_label.sizeThatFits(CGSize(width: width - 40, height: 0))
                info_label.frame = CGRect(x: 20, y: origin_y, width: width - 40, height: info_label_size.height)
                origin_y = CGRectGetMaxY(info_label.frame) + 20

                let message_label_size = message_label.sizeThatFits(CGSize(width: width - 40, height: 0))
                message_label.frame = CGRect(x: 20, y: origin_y, width: width - 40, height: message_label_size.height)
                origin_y = CGRectGetMaxY(message_label.frame) + 20

                let text_field_width = min(width - 40, 300)
                text_field.frame = CGRect(x: (width - text_field_width) / 2, y: origin_y, width: text_field_width, height: 50)
                origin_y = CGRectGetMaxY(text_field.frame) + 30

                button.sizeToFit()
                button.frame.origin = CGPoint(x: (width - button.frame.width) / 2, y: origin_y)
                origin_y = CGRectGetMaxY(button.frame) + 20






                scroll_view.contentSize = CGSize(width: width, height: origin_y)
                scroll_view.frame = view.bounds
        }

        override func render() {
                geo_state = state.page_state as! GEOState

                button.enabled = true
                button.hidden = false

                let message_text: String
                let message_color: UIColor

                switch geo_state.state {
                case .NoInput:
                        message_text = "Type an id of the form GDSxxxx or GSExxxx"
                        message_color = UIColor.blackColor()
                        set_button_title(title: "Download and import")
                        button.enabled = false
                case .IncorrectInput:
                        message_text = "Type an id of the form GDSxxxx or GSExxxx"
                        message_color = UIColor.redColor()
                        set_button_title(title: "Download and import")
                        button.enabled = false
                case .CorrectInput:
                        message_text = "Tap the button"
                        message_color = UIColor.blackColor()
                        set_button_title(title: "Download and import")
                case .Downloading:
                        message_text = "The data set is being downloaded from GEO"
                        message_color = UIColor.blackColor()
                        set_button_title(title: "Cancel")
                        button.enabled = true
                case .Importing:
                        message_text = "The data set is being imported"
                        message_color = UIColor.blackColor()
                        set_button_title(title: "Cancel")
                        button.hidden = true
                }

                message_label.attributedText = astring_font_size_color(string: message_text, font: nil, font_size: nil, color: message_color)
                message_label.textAlignment = .Center

                view.setNeedsLayout()
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textFieldDidEndEditing(textField: UITextField) {
                let original_text = textField.text ?? ""

                let text = original_text.uppercaseString

                if text == "" {
                        geo_state.state = .NoInput
                } else if text.hasPrefix("GSE") || text.hasPrefix("GDS") {
                        let substring = text.substringFromIndex(text.startIndex.advancedBy(3))
                        if Int(substring) == nil {
                                geo_state.state = .IncorrectInput
                        } else {
                                geo_state.state = .CorrectInput
                        }
                } else {
                        geo_state.state = .IncorrectInput
                }

                if text != original_text && geo_state.state == .CorrectInput {
                        textField.text = text
                }
                render()
        }

        func button_action() {


        }

        func tap_action() {
                text_field.resignFirstResponder()
        }

        func set_button_title(title title: String) {
                button.setAttributedTitle(astring_font_size_color(string: title, font: nil, font_size: 20, color: nil), forState: .Normal)
                button.setAttributedTitle(astring_font_size_color(string: title, font: nil, font_size: 20, color: color_disabled), forState: .Disabled)
        }
}
