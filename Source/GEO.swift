import UIKit

enum GEOStatus {
        case Input
        case Downloading
        case Importing
}

class GEOState: PageState {

        var state = GEOStatus.Input
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

                text_field.clearButtonMode = UITextFieldViewMode.WhileEditing
                text_field.font = font_body
                text_field.autocorrectionType = UITextAutocorrectionType.No
                text_field.textAlignment = NSTextAlignment.Center
                text_field.borderStyle = UITextBorderStyle.Bezel
                text_field.layer.masksToBounds = true
                text_field.delegate = self
                scroll_view.addSubview(text_field)

                button.setAttributedTitle(astring_body(string: "Download"), forState: .Normal)
                button.setAttributedTitle(astring_font_size_color(string: "Download", font: nil, font_size: nil, color: color_disabled), forState: .Disabled)
                button.addTarget(self, action: "download_action", forControlEvents: .TouchUpInside)
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

                let text_field_width = min(width - 40, 400)
                text_field.frame = CGRect(x: (width - text_field_width) / 2, y: origin_y, width: text_field_width, height: 50)
                origin_y = CGRectGetMaxY(text_field.frame)

                





                scroll_view.frame = view.bounds
        }

        override func render() {
                geo_state = state.page_state as! GEOState




        }














}
