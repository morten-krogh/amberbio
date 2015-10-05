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

        let info_label = UILabel()
        let k_label = UILabel()
        let text_field = UITextField()

        override func viewDidLoad() {
                super.viewDidLoad()

                info_label.text = "Select the number of nearest neighbors"
                info_label.font = font_body
                info_label.textAlignment = .Center
                view.addSubview(info_label)

                k_label.text = "k = "
                k_label.font = font_body
                view.addSubview(k_label)

                text_field.keyboardType = UIKeyboardType.NumbersAndPunctuation
                text_field.font = font_body
                text_field.textAlignment = .Center
                text_field.autocorrectionType = UITextAutocorrectionType.No
                text_field.borderStyle = UITextBorderStyle.Bezel
                text_field.layer.masksToBounds = true
//                text_field.delegate = self

                view.addSubview(text_field)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                var origin_y = 40 as CGFloat

                info_label.sizeToFit()
                info_label.center = CGPoint(x: width / 2, y: origin_y + info_label.frame.height / 2)

                origin_y = CGRectGetMaxY(info_label.frame) + 20

                k_label.sizeToFit()

                let text_field_width = 80 as CGFloat
                let text_field_height = 40 as CGFloat
                let middle_margin = 10 as CGFloat

                var origin_x = (width - k_label.frame.width - text_field_width - middle_margin) / 2
                k_label.frame.origin = CGPoint(x: origin_x, y: origin_y + (text_field_height - info_label.frame.height) / 2)

                origin_x += k_label.frame.width + middle_margin

                text_field.frame = CGRect(x: origin_x, y: origin_y, width: text_field_width, height: text_field_height)
        }

        override func render() {
                knn_k_selection_state = state.page_state as! KNNKSelectionState

                text_field.text = "\(knn_k_selection_state.knn.k)"
        }



}
