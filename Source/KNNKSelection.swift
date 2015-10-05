import UIKit

class KNNKSelectionState: PageState {

        let knn: KNN

        init(knn: KNN) {
                self.knn = knn
                super.init()
                name = "knn_k_selection"
                title = astring_body(string: "k nearest neighbor classification")
                info = "Select the number of nearest neightbors, k.\n\nA test sample is classified to a level if the majority of the k nearest neighbors belong to the level.\n\nIf k is odd and there are two levels, all samples will be classified to a level.\n\nOtherwise, a sample can be classified as undecided."
        }
}

class KNNKSelection: Component {

        var knn_k_selection_state: KNNKSelectionState!

        




        override func render() {
                knn_k_selection_state = state.page_state as! KNNKSelectionState
        }



}
