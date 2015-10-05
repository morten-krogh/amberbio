import UIKit

class KNNValidationSelectionState: PageState {

        let knn: KNN

        init(knn: KNN) {
                self.knn = knn
                super.init()
                name = "knn_validation_selection"
                title = astring_body(string: "k nearest neighbor classification")
                info = "Select the type of training and testing."
        }
}

class KNNValidationSelection: Component, UITableViewDataSource, UITableViewDelegate {

        var knn_validation_selection_state: KNNValidationSelectionState!

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
        }

        override func render() {
                knn_validation_selection_state = state.page_state as! KNNValidationSelectionState
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                header.update_normal(text: "Select the type of training and testing")

                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return 3
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let text: String
                switch indexPath.row {
                case 0:
                        text = "Fixed training and test set"
                case 1:
                        text = "Leave one out cross validation"
                default:
                        text = "k fold cross validation"
                }

                cell.update_selectable_arrow(text: text)

                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                switch indexPath.row {
                case 0:
                        knn_validation_selection_state.knn.validation_training_test()
                        let page_state = KNNTrainingTestSelectionState(knn: knn_validation_selection_state.knn)
                        state.navigate(page_state: page_state)
                        state.render()
                case 1:
                        break
                default:
                        break
                }

        }
}
