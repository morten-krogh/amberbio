import UIKit

class SupervisedClassificationParameterSelectionState: PageState {

        let supervised_classification: SupervisedClassification

        init(supervised_classification: SupervisedClassification) {
                self.supervised_classification = supervised_classification
                super.init()
                name = "supervised_classification_parameter_selection"
                switch supervised_classification.supervised_classification_type {
                case .KNN:
                        title = astring_body(string: "k nearest neighbor classifier")
                        info = "Select the number of nearest neighbors, k.\n\nA test sample is classified to a level if the majority of the k nearest neighbors belong to the level.\n\nIf k is odd and there are two levels, all samples will be classified to a level.\n\nOtherwise, a sample can be unclassified."
                case .SVM:
                        title = astring_body(string: "support vector machine")
                        info = "Select the parameters for the support vector machine."
                }
        }
}

class SupervisedClassificationParameterSelection: Component, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

        var supervised_classification: SupervisedClassification!

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

//        let classify_button = UIButton(type: .System)
//        let info_label = UILabel()
//        let k_label = UILabel()
//        let text_field = UITextField()

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.registerClass(CrossValidationTableViewCell.self, forCellReuseIdentifier: "text field cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                tap_recognizer.cancelsTouchesInView = false
                view.addGestureRecognizer(tap_recognizer)


//                classify_button.setAttributedTitle(astring_font_size_color(string: "Classify", font: nil, font_size: 22, color: nil), forState: .Normal)
//                classify_button.addTarget(self, action: "classify_action", forControlEvents: UIControlEvents.TouchUpInside)
//                view.addSubview(classify_button)
//
//                info_label.text = "Select the number of nearest neighbors"
//                info_label.font = font_body
//                info_label.textAlignment = .Center
//                view.addSubview(info_label)
//
//                k_label.text = "k = "
//                k_label.font = font_body
//                view.addSubview(k_label)
//
//                text_field.keyboardType = UIKeyboardType.NumbersAndPunctuation
//                text_field.font = font_body
//                text_field.textAlignment = .Center
//                text_field.autocorrectionType = UITextAutocorrectionType.No
//                text_field.borderStyle = UITextBorderStyle.Bezel
//                text_field.layer.masksToBounds = true
//                text_field.delegate = self
//
//                view.addSubview(text_field)
//
//                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
//                view.addGestureRecognizer(tap_recognizer)
        }

//        override func viewWillLayoutSubviews() {
//                super.viewWillLayoutSubviews()
//
//                let width = view.frame.width
//                let height = view.frame.height
//
//                let vertical_margin = height > 300 ? 25 : 20 as CGFloat
//                var origin_y = height > 300 ? 40 : 30 as CGFloat
//
//                classify_button.sizeToFit()
//                classify_button.center = CGPoint(x: width / 2, y: origin_y)
//                origin_y = CGRectGetMaxY(classify_button.frame) + vertical_margin
//
//                info_label.sizeToFit()
//                info_label.center = CGPoint(x: width / 2, y: origin_y + info_label.frame.height / 2)
//
//                origin_y = CGRectGetMaxY(info_label.frame) + vertical_margin + 10
//
//                k_label.sizeToFit()
//
//                let text_field_width = 80 as CGFloat
//                let text_field_height = 40 as CGFloat
//                let middle_margin = 10 as CGFloat
//
//                var origin_x = (width - text_field_width) / 2 - k_label.frame.width - middle_margin
//                k_label.frame.origin = CGPoint(x: origin_x, y: origin_y + (text_field_height - info_label.frame.height) / 2)
//
//                origin_x += k_label.frame.width + middle_margin
//
//                text_field.frame = CGRect(x: origin_x, y: origin_y, width: text_field_width, height: text_field_height)
//        }

        override func render() {
                supervised_classification = (state.page_state as! SupervisedClassificationParameterSelectionState).supervised_classification

                table_view.dataSource = self
                table_view.delegate = self

//                text_field.text = "\(knn_k_selection_state.knn.k)"
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                switch supervised_classification.supervised_classification_type {
                case .KNN:
                        return 1
                case .SVM:
                        return 0
                }
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height + 20
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text: String
                switch supervised_classification.supervised_classification_type {
                case .KNN:
                        text = "Classify"
                case .SVM:
                        text = ""
                }

                header.update_selectable_arrow(text: text)
                header.tag = section

                if header.tap_recognizer == nil {
                        header.addTapGestureRecognizer(target: self, action: "header_tap_action:")
                }

                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                switch supervised_classification.supervised_classification_type {
                case .KNN:
                        return 1
                case .SVM:
                        return 0
                }
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return indexPath.row < 2 ? centered_table_view_cell_height + 10 : cross_validation_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                switch indexPath.row {
                case 0:
                        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell
                        let text = "Fixed training and test set"
                        cell.update_selectable_arrow(text: text)
                        return cell
                case 1:
                        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell
                        let text = "Leave one out cross validation"
                        cell.update_selectable_arrow(text: text)
                        return cell
                default:
                        let cell = tableView.dequeueReusableCellWithIdentifier("text field cell") as! CrossValidationTableViewCell
                        let text = "k fold cross validation"
                        cell.update(text: text, k_fold: supervised_classification.k_fold, tag: 0, delegate: self)
                        return cell
                }
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//                let page_state: PageState
//                switch indexPath.row {
//                case 0:
//                        supervised_classification.validation_training_test()
//                        page_state = SupervisedClassificationTrainingSelectionState(supervised_classification: supervised_classification)
//                case 1:
//                        supervised_classification.validation_leave_one_out()
//                        page_state = SupervisedClassificationParameterSelectionState(supervised_classification: supervised_classification)
//                default:
//                        supervised_classification.validation_k_fold_cross_validation()
//                        page_state = SupervisedClassificationParameterSelectionState(supervised_classification: supervised_classification)
//                }
//                state.navigate(page_state: page_state)
//                state.render()
        }

        func textFieldDidEndEditing(textField: UITextField) {
//                correct_text_field(text_field: textField)
//                let k_fold = Int(textField.text!)!
//                supervised_classification.set_k_fold(k_fold: k_fold)
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
        






//        func textFieldDidEndEditing(textField: UITextField) {
//                correct_text_field()
////                let k = Int(textField.text!)!
////                knn_k_selection_state.knn.k = k
//        }
//
//        func textFieldShouldReturn(textField: UITextField) -> Bool {
//                textField.resignFirstResponder()
//                return true
//        }
//
//        func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//                if range.length != 0 && string.isEmpty {
//                        return true
//                }
//
//                return Int(string) != nil
//        }
//
//        func correct_text_field() {
//                let text = text_field.text ?? ""
//                if let number = Int(text) {
//                        if number < 1 {
//                                text_field.text = "1"
////                        } else if number > knn_k_selection_state.knn.max_k() {
////                                text_field.text = "\(knn_k_selection_state.knn.max_k())"
//                        }
//                } else {
//                        text_field.text = "1"
//                }
//        }
//
//        func classify_action() {
//                text_field.resignFirstResponder()
////                knn_k_selection_state.knn.classify()
////                let page_state = KNNResultState(knn: knn_k_selection_state.knn)
////                state.navigate(page_state: page_state)
//                state.render()
//        }


        func header_tap_action(sender: UITapGestureRecognizer) {
                if let section = sender.view?.tag {
                        print(section)
                }
        }

        func tap_action() {
//                text_field.resignFirstResponder()
        }
}
