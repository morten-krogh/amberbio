import UIKit

class KMeansClusteringResultState: PageState {

        let k_means: KMeans

        init(k_means: KMeans) {
                self.k_means = k_means
                super.init()
                name = "k_means_clustering_result"
                title = astring_body(string: "k means clustering")
                info = "Create a new factor from the clusters by tapping the button \"Create new factor\".\n\nEach cluster will become a level.\n\nEdit the new factor on the page \"Edit factor\" if necessary."
        }
}

class KMeansClusteringResult: Component {

        let create_new_factor_button = UIButton(type: .System)


        override func viewDidLoad() {
                super.viewDidLoad()

                create_new_factor_button.setAttributedTitle(astring_body(string: "Create new factor"), forState: .Normal)
                create_new_factor_button.addTarget(self, action: "create_new_factor_action", forControlEvents: .TouchUpInside)
                view.addSubview(create_new_factor_button)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                create_new_factor_button.sizeToFit()
                create_new_factor_button.frame.origin = CGPoint(x: (width - create_new_factor_button.frame.width) / 2, y: 20)

                let origin_y = CGRectGetMaxY(create_new_factor_button.frame) + 20

        }









        func create_new_factor_action() {
                let factor_id = 1

                let page_state = FactorSummaryDetailState(factor_id: factor_id)
                state.navigate(page_state: page_state)
                state.render()
        }
}
