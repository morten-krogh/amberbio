import UIKit

class ColorSelectionPickerState: PageState {

        let level_id: Int
        let level_name: String
        let factor_name: String
        let reset_color: UIColor
        var color: UIColor

        init(level_id: Int, level_name: String, factor_name: String, color: String) {
                self.level_id = level_id
                self.level_name = level_name
                self.factor_name = factor_name
                self.reset_color = color_from_hex(hex: color)
                self.color = color_from_hex(hex: color)
                super.init()
                name = "color_selection_picker"
                title = astring_body(string: "Color Selection")
                info = "Select a color and tap done.\n\nTap reset to set the color to the current value."
        }

        func set_color(color color: UIColor) {
                let color_hex = color_to_hex_format(color: color)
                state.update_level_color(level_id: level_id, level_color: color_hex)
        }
}

class ColorSelectionPicker: Component {

        var color_selection_picker_state: ColorSelectionPickerState!

        let scroll_view = UIScrollView()
        let info_label = UILabel()
        let color_picker = ColorPicker(frame: CGRect.zero)

        override func loadView() {
                view = scroll_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                color_picker.addTarget(self, action: "color_picker_action:", forControlEvents: UIControlEvents.EditingDidEnd)

                scroll_view.addSubview(info_label)
                scroll_view.addSubview(color_picker)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height
                let content_height = max(650, height)

                let margin = 10.0 as CGFloat
                let label_height = 30.0 as CGFloat
                var origin_y = 20 as CGFloat

                info_label.frame = CGRect(x: 0, y: origin_y, width: width, height: label_height)
                origin_y += label_height + 5

                color_picker.frame = CGRect(x: margin, y: origin_y, width: width - margin, height: content_height - origin_y)

                scroll_view.contentSize = CGSize(width: width, height: content_height)
        }

        override func render() {
                color_selection_picker_state = state.page_state as! ColorSelectionPickerState

                color_picker.update(color: color_selection_picker_state.color, reset_color: color_selection_picker_state.reset_color)

                let text = "Select a color for \(color_selection_picker_state.level_name) in \(color_selection_picker_state.factor_name)"

                info_label.text = text
                info_label.font = font_body
                info_label.textAlignment = .Center
        }

        func color_picker_action(sender: ColorPicker) {
                color_selection_picker_state.set_color(color: color_picker.color)
                let page_state = ColorSelectionLevelState()
                state.navigate(page_state: page_state)
                state.render()
        }
}
