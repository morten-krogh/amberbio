import UIKit

class Forward: Component {

        let button = UIButton(type: UIButtonType.System)

        override func loadView() {
                view = button
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                button.setAttributedTitle(astring_font_size_color(string: "forward", font: nil, font_size: 19, color: nil), forState: .Normal)
                button.sizeToFit()
                button.addTarget(self, action: "action", forControlEvents: UIControlEvents.TouchUpInside)
        }

        override func render() {
                let empty = state.forward_pages.isEmpty
                button.enabled = !empty
                button.hidden = empty
        }

        func action() {
                state.store.ads_done()
                state.navigate_forward()
                state.store.ads_check()
                state.render()
        }
}
