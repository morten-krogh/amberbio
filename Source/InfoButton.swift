import UIKit

class InfoButton: Component {

        let button = UIButton(type: UIButtonType.InfoDark)

        override func loadView() {
                view = button
        }

        override func viewDidLoad() {
                super.viewDidLoad()
                button.addTarget(self, action: "action", forControlEvents: UIControlEvents.TouchUpInside)
        }

        func action() {
                alert(title: "Info", message: state.page_state.info, view_controller: self)
        }
}
