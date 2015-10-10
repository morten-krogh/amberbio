import UIKit

class KNNKSelectionState: PageState {

        let knn: KNN

        init(knn: KNN) {
                self.knn = knn
                super.init()
                name = "knn_k_selection"
                title = astring_body(string: "k nearest neighbor classifier")
                info = "Select the number of nearest neighbors, k.\n\nA test sample is classified to a level if the majority of the k nearest neighbors belong to the level.\n\nIf k is odd and there are two levels, all samples will be classified to a level.\n\nOtherwise, a sample can be unclassified."
        }
}

class KNNKSelection: Component, UITextFieldDelegate {

        var knn_k_selection_state: KNNKSelectionState!

        let classify_button = UIButton(type: .System)
        let info_label = UILabel()
        let k_label = UILabel()
        let text_field = UITextField()

        override func viewDidLoad() {
                super.viewDidLoad()

                classify_button.setAttributedTitle(astring_font_size_color(string: "Classify", font: nil, font_size: 22, color: nil), forState: .Normal)
                classify_button.addTarget(self, action: "classify_action", forControlEvents: UIControlEvents.TouchUpInside)
                view.addSubview(classify_button)

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
                text_field.delegate = self

                view.addSubview(text_field)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                let vertical_margin = height > 300 ? 25 : 20 as CGFloat
                var origin_y = height > 300 ? 40 : 30 as CGFloat

                classify_button.sizeToFit()
                classify_button.center = CGPoint(x: width / 2, y: origin_y)
                origin_y = CGRectGetMaxY(classify_button.frame) + vertical_margin

                info_label.sizeToFit()
                info_label.center = CGPoint(x: width / 2, y: origin_y + info_label.frame.height / 2)

                origin_y = CGRectGetMaxY(info_label.frame) + vertical_margin + 10

                k_label.sizeToFit()

                let text_field_width = 80 as CGFloat
                let text_field_height = 40 as CGFloat
                let middle_margin = 10 as CGFloat

                var origin_x = (width - text_field_width) / 2 - k_label.frame.width - middle_margin
                k_label.frame.origin = CGPoint(x: origin_x, y: origin_y + (text_field_height - info_label.frame.height) / 2)

                origin_x += k_label.frame.width + middle_margin

                text_field.frame = CGRect(x: origin_x, y: origin_y, width: text_field_width, height: text_field_height)
        }

        override func render() {
                knn_k_selection_state = state.page_state as! KNNKSelectionState

                text_field.text = "\(knn_k_selection_state.knn.k)"
        }

        func textFieldDidEndEditing(textField: UITextField) {
                correct_text_field()
                let k = Int(textField.text!)!
                knn_k_selection_state.knn.k = k
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
                if range.length != 0 && string.isEmpty {
                        return true
                }

                return Int(string) != nil
        }

        func correct_text_field() {
                let text = text_field.text ?? ""
                if let number = Int(text) {
                        if number < 1 {
                                text_field.text = "1"
                        } else if number > knn_k_selection_state.knn.max_k() {
                                text_field.text = "\(knn_k_selection_state.knn.max_k())"
                        }
                } else {
                        text_field.text = "1"
                }
        }

        func classify_action() {
                text_field.resignFirstResponder()
                knn_k_selection_state.knn.classify()
                let page_state = KNNResultState(knn: knn_k_selection_state.knn)
                state.navigate(page_state: page_state)
                state.render()
        }

        func tap_action() {
                text_field.resignFirstResponder()
        }
}
