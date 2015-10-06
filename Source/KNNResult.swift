import UIKit

class KNNResultState: PageState {

        let knn: KNN

        init(knn: KNN) {
                self.knn = knn
                super.init()
                name = "knn_result"
                title = astring_body(string: "k nearest neighbor classification")
                info = ""
        }
}

class KNNResult: Component {

        var knn_result_state: KNNResultState!

        let table_view = UITableView()

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "tappable-header")
                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(SelectAllHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "select-all-header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                view.addSubview(table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                table_view.frame = view.bounds
        }

        override func render() {
                knn_result_state = state.page_state as! KNNResultState
                let knn = knn_result_state.knn

                let knn_result_samples_delegate = KNNResultSamplesDelegate(knn: knn)
                table_view.dataSource = knn_result_samples_delegate
                table_view.delegate = knn_result_samples_delegate
                table_view.reloadData()
        }
}

class KNNResultSamplesDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {

        let knn: KNN

        init(knn: KNN) {
                self.knn = knn
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return knn.comparison_level_ids.count
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text = knn.comparison_level_names[section]
                header.update_normal(text: text)

                return header
        }

        func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return 20
        }

        func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier("footer")
                footer?.contentView.backgroundColor = UIColor.whiteColor()
                return footer
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return 0
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

//                let level_id = state.level_ids_by_factor[indexPath.section][indexPath.row]
//                let level_name = state.level_names_by_factor[indexPath.section][indexPath.row]
//
//                if knn_factor_selection_state.selected_level_ids.contains(level_id) {
//                        cell.update_selected_checkmark(text: level_name)
//                } else {
//                        cell.update_unselected(text: level_name)
//                }
                return cell
        }
}
