import UIKit

class Title: Component {

        let label = UILabel()

        override func loadView() {
                view = label
        }

        override func render() {
                label.attributedText = state.page_state.title
                label.textAlignment = .Center
        }
}
