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

class KMeansClusteringResult: Component, UICollectionViewDataSource, UICollectionViewDelegate {

        var k_means: KMeans!

        let create_new_factor_button = UIButton(type: .System)
        let collection_view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

//        var collection_view: UICollectionView!

        override func viewDidLoad() {
                super.viewDidLoad()

                create_new_factor_button.setAttributedTitle(astring_body(string: "Create new factor"), forState: .Normal)
                create_new_factor_button.addTarget(self, action: "create_new_factor_action", forControlEvents: .TouchUpInside)
                view.addSubview(create_new_factor_button)

                collection_view.backgroundColor = UIColor.whiteColor()
                collection_view.registerClass(HomeCellView.self, forCellWithReuseIdentifier: "cell")
                collection_view.registerClass(HomeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
                view.addSubview(collection_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                create_new_factor_button.sizeToFit()
                create_new_factor_button.frame.origin = CGPoint(x: (width - create_new_factor_button.frame.width) / 2, y: 20)

                let origin_y = CGRectGetMaxY(create_new_factor_button.frame) + 20

                collection_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height - origin_y)
        }

        override func render() {
                 self.k_means = (state.page_state as! KMeansClusteringResultState).k_means
                collection_view.dataSource = self
                collection_view.delegate = self
        }

        






        func create_new_factor_action() {
                let factor_id = 1

                let page_state = FactorSummaryDetailState(factor_id: factor_id)
                state.navigate(page_state: page_state)
                state.render()
        }
}
