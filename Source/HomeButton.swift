import UIKit

class HomeButton: Component {

        let home_button_view = HomeButtonView(frame: CGRect.zero)

        override func loadView() {
                view = home_button_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()
                home_button_view.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
        }

        override func render() {
                home_button_view.enabled = state.page_state.name != "home"
        }

        func action() {
                state.navigate(page_state: HomeState())
                state.render()
        }
}
