import UIKit

class Back: Component {

        let button = UIButton(type: UIButtonType.System)

        override func loadView() {
                view = button
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                button.setAttributedTitle(astring_font_size_color(string: "back", font: nil, font_size: 19, color: nil), forState: .Normal)
                button.sizeToFit()
                button.addTarget(self, action: "action", forControlEvents: UIControlEvents.TouchUpInside)
        }

        override func render() {
                let empty = state.back_pages.isEmpty
                button.enabled = !empty
                button.hidden = empty
        }

        func action() {
                state.navigate_back()
                state.render()
        }
}
