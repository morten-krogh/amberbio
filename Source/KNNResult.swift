import UIKit

class KNNResultState: PageState {

        let knn: KNN

        var selected_segment_index = 0

        let info_0 = "0"

        let info_1 = "1"

        let info_2 = "2"

        init(knn: KNN) {
                self.knn = knn
                super.init()
                name = "knn_result"
                title = astring_body(string: "k nearest neighbor classification")
                info = info_0
        }

        func set_selected_segment_index(index index: Int) {
                selected_segment_index = index
                info = index == 0 ? info_0 : (index == 1 ? info_1 : info_2)
        }
}

class KNNResult: Component {

        var knn_result_state: KNNResultState!

        let scroll_view_segmented_control = UIScrollView()
        let segmented_control = UISegmentedControl(items: ["Summary", "Table", "Samples"])

        let table_view = UITableView()

        var knn_result_samples_delegate: KNNResultSamplesDelegate?

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(scroll_view_segmented_control)

                segmented_control.addTarget(self, action: "segmented_control_action", forControlEvents: UIControlEvents.ValueChanged)
                scroll_view_segmented_control.addSubview(segmented_control)

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "tappable-header")
                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(SelectAllHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "select-all-header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.registerClass(ClassificationTableViewCell.self, forCellReuseIdentifier: "classification cell")

                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                view.addSubview(table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height
                let top_margin = 20 as CGFloat

                let segmented_control_width = max(min(500, width - 20), 300)
                segmented_control.frame.size.width = segmented_control_width
                let segmented_rect = CGRect(x: 0, y: 0, width: width, height: segmented_control.frame.height + 2 * top_margin)
                scroll_view_segmented_control.frame = layout_centered_frame(contentSize: segmented_control.frame.size, rect: segmented_rect)
                scroll_view_segmented_control.contentSize = segmented_control.bounds.size
                segmented_control.frame.origin = CGPoint.zero

                let origin_y = CGRectGetMaxY(scroll_view_segmented_control.frame)

                table_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height)
        }

        override func render() {
                knn_result_state = state.page_state as! KNNResultState
                let knn = knn_result_state.knn

                segmented_control.selectedSegmentIndex = knn_result_state.selected_segment_index

                knn_result_samples_delegate = KNNResultSamplesDelegate(knn: knn)
                table_view.dataSource = knn_result_samples_delegate
                table_view.delegate = knn_result_samples_delegate
                table_view.reloadData()
        }

        func segmented_control_action() {
                knn_result_state.set_selected_segment_index(index: segmented_control.selectedSegmentIndex)
                render()
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
                return 15
        }

        func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier("footer")
                footer?.contentView.backgroundColor = UIColor.whiteColor()
                return footer
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return knn.test_sample_indices_per_level[section].count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return classification_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("classification cell") as! ClassificationTableViewCell

                let sample_index = knn.test_sample_indices_per_level[indexPath.section][indexPath.row]
                let sample_number = knn.test_sample_indices.indexOf(sample_index)!
                let sample_name = knn.test_sample_names[sample_number]
                let level_id = knn.comparison_level_ids[indexPath.section]
                let label = knn.test_sample_classified_labels[sample_number]
                let label_name: String
                if label == -1 {
                        label_name = "unclassified"
                } else {
                        let label_number = knn.comparison_level_ids.indexOf(label)!
                        label_name = knn.comparison_level_names[label_number]
                }

                if level_id == label {
                        cell.update_success(text_1: sample_name, text_2: label_name)
                } else {
                        cell.update_failure(text_1: sample_name, text_2: label_name)
                }

                return cell
        }
}
