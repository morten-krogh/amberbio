import UIKit

class ActiveDataSet: Component {

        let label = UILabel()

        var (displayed_data_set_name, displayed_project_name) = (nil, nil) as (String?, String?)

        override func loadView() {
                view = label
        }

        override func viewDidLoad() {
                super.viewDidLoad()
                label.clipsToBounds = true
                label.numberOfLines = 0
                label.lineBreakMode = NSLineBreakMode.ByWordWrapping
                label.textAlignment = NSTextAlignment.Center
                update_to_nil()
        }

        override func render() {
                if state.active_data_set {
                        if state.data_set_name != displayed_data_set_name || state.project_name != displayed_project_name {
                                update(data_set_name: state.data_set_name, project_name: state.project_name)
                                (displayed_data_set_name, displayed_project_name) = (state.data_set_name, state.project_name)
                        }
                } else {
                        if displayed_data_set_name != nil {
                                update_to_nil()
                                (displayed_data_set_name, displayed_project_name) = (nil, nil)
                        }
                }
        }

        func update_to_nil() {
                label.attributedText = astring_body(string: "There is no active data set")
        }

        func update(data_set_name data_set_name: String, project_name: String) {
                let astring = astring_body(string: data_set_name)
                astring.appendAttributedString(astring_font_size_color(string: " in project ", font: font_footnote, font_size: nil, color: color_gray))
                astring.appendAttributedString(astring_body(string: project_name))
                
                label.attributedText = astring
        }
}
