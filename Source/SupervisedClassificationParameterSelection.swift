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

        var editing_text_field: UITextField?

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.registerClass(ParameterTableViewCell.self, forCellReuseIdentifier: "parameter cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                tap_recognizer.cancelsTouchesInView = false
                view.addGestureRecognizer(tap_recognizer)
        }

        override func render() {
                supervised_classification = (state.page_state as! SupervisedClassificationParameterSelectionState).supervised_classification

                table_view.dataSource = self
                table_view.delegate = self
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
                return parameter_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("parameter cell") as! ParameterTableViewCell

                let (section, _) = (indexPath.section, indexPath.row)

                let text: String
                let short_text: String
                let parameter: String

                switch supervised_classification.supervised_classification_type {
                case .KNN:
                        text = "Number of nearest neighbors"
                        short_text = "k = "
                        parameter = String((supervised_classification as! KNN).k)
                case .SVM:
                        text = ""
                        short_text = ""
                        parameter = ""
                }

                cell.update(text: text, short_text: short_text, parameter: parameter, tag: section, delegate: self)

                return cell
        }

        func textFieldDidBeginEditing(textField: UITextField) {
                editing_text_field = textField
        }

        func textFieldDidEndEditing(textField: UITextField) {
                read_text_fields()
                editing_text_field = nil
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

        func read_text_fields() {
                switch supervised_classification.supervised_classification_type {
                case .KNN:
                        let knn = supervised_classification as! KNN
                        let cell = table_view.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ParameterTableViewCell
                        let text_field = cell.text_field
                        let text = text_field.text ?? ""
                        if let number = Int(text) {
                                if number < 1 {
                                        text_field.text = "1"
                                        knn.k = 1
                                } else if number > knn.max_k() {
                                        text_field.text = "\(knn.max_k())"
                                        knn.k = knn.max_k()
                                } else {
                                        knn.k = number
                                }
                        } else {
                                text_field.text = "1"
                                knn.k = 1
                        }
                case .SVM:
                        break
                }
        }

        func header_tap_action(sender: UITapGestureRecognizer) {
                editing_text_field?.resignFirstResponder()
                read_text_fields()
                supervised_classification.classify()
                let page_state = SupervisedClassificationResultState(supervised_classification: supervised_classification)
                state.navigate(page_state: page_state)
                state.render()
        }

        func tap_action() {
                editing_text_field?.resignFirstResponder()
        }
}
