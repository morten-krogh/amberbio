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













}
