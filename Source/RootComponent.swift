import UIKit

class RootComponent: Component {

        var child_view_controller: UIViewController?

        let full_page = FullPage()
        let progress_indicator = ProgressIndicator()
        let activity_indicator = ActivityIndicator()
        let ads = Ads()

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()
                child_view_controller?.view.frame = view.bounds
        }

        func set_child_view_controller(view_controller view_controller: UIViewController) {
                if view_controller != child_view_controller {
                        if let child_view_controller = child_view_controller {
                                remove_child_view_controller(child: child_view_controller)
                        }

                        add_child_view_controller(parent: self, child: view_controller)
                        child_view_controller = view_controller
                }
        }

        override func render() {
                switch state.render_type {
                case .full_page:
                        set_child_view_controller(view_controller: full_page)
                        full_page.render()
                case .progress_indicator:
                        set_child_view_controller(view_controller: progress_indicator)
                        progress_indicator.render()
                case .activity_indicator:
                        set_child_view_controller(view_controller: activity_indicator)
                        activity_indicator.render()
                case .ads:
                        set_child_view_controller(view_controller: ads)
                        ads.render()
                }
        }

        override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
                return UIInterfaceOrientationMask.All
        }
}
