import UIKit

enum GEOStatus {
        case NoInput
        case CorrectInput
        case IncorrectInput
        case Downloading
        case Parsing
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


                button.addTarget(self, action: "download_and_import_action", forControlEvents: .TouchUpInside)
                scroll_view.addSubview(button)

                view.addSubview(scroll_view)
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





                view.setNeedsLayout()
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textFieldDidEndEditing(textField: UITextField) {
                let text = textField.text ?? ""

                




        }





        func download_and_import_action() {


        }

        func set_button_title(title title: String) {
                button.setAttributedTitle(astring_font_size_color(string: title, font: nil, font_size: 20, color: nil), forState: .Normal)
                button.setAttributedTitle(astring_font_size_color(string: title, font: nil, font_size: 20, color: color_disabled), forState: .Disabled)
        }
}
