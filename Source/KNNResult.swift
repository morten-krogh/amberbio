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
                title = astring_body(string: "k nearest neighbor classifier")
                info = info_0
        }

        func set_selected_segment_index(index index: Int) {
                selected_segment_index = index
                info = index == 0 ? info_0 : (index == 1 ? info_1 : info_2)
        }
}

class KNNResult: Component {

        var knn_result_state: KNNResultState!

        let segmented_control = UISegmentedControl(items: ["Summary", "Table", "Samples"])

        let table_view = UITableView()

        var knn_result_samples_delegate: KNNResultSamplesDelegate?

        override func viewDidLoad() {
                super.viewDidLoad()

                segmented_control.addTarget(self, action: "segmented_control_action", forControlEvents: UIControlEvents.ValueChanged)
                view.addSubview(segmented_control)

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

                let segmented_control_width = min(500, width - 40)
                segmented_control.frame = CGRect(x: (width - segmented_control_width) / 2, y: top_margin, width: segmented_control_width, height: segmented_control.frame.height)

                let origin_y = CGRectGetMaxY(segmented_control.frame) + top_margin

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
        var level_ids = [] as [Int]
        var level_names = [] as [String]
        var sample_names = [] as [[String]]
        var classified_level_ids = [] as [[Int]]

        init(knn: KNN) {
                self.knn = knn

                level_ids = knn.comparison_level_ids + knn.additional_level_ids
                level_names = knn.comparison_level_names + knn.additional_level_names

                for level_id in knn.comparison_level_ids {
                        var current_sample_names = [] as [String]
                        var current_classified_level_ids = [] as [Int]
                        for i in 0 ..< knn.test_sample_indices.count {
                                if knn.test_sample_level_ids[i] == level_id {
                                        current_sample_names.append(knn.test_sample_names[i])
                                        current_classified_level_ids.append(knn.test_sample_classified_level_ids[i])
                                }
                        }
                        sample_names.append(current_sample_names)
                        classified_level_ids.append(current_classified_level_ids)
                }

                for level_id in knn.additional_level_ids {
                        var current_sample_names = [] as [String]
                        var current_classified_level_ids = [] as [Int]
                        for i in 0 ..< knn.additional_sample_indices.count {
                                if knn.additional_sample_level_ids[i] == level_id {
                                        current_sample_names.append(knn.additional_sample_names[i])
                                        current_classified_level_ids.append(knn.additional_sample_classified_level_ids[i])
                                }
                        }
                        sample_names.append(current_sample_names)
                        classified_level_ids.append(current_classified_level_ids)
                }
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return level_ids.count
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text = level_names[section]
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
                return sample_names[section].count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return classification_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("classification cell") as! ClassificationTableViewCell

                let (section, row) = (indexPath.section, indexPath.row)

                let level_id = level_ids[section]

                let sample_name = sample_names[section][row]
                let classified_level_id = classified_level_ids[section][row]

                let classified_level_name: String
                if classified_level_id > 0 {
                        let level_index = knn.comparison_level_ids.indexOf(classified_level_id)!
                        classified_level_name = knn.comparison_level_names[level_index]
                } else {
                        classified_level_name = "unclassified"
                }

                if section < knn.comparison_level_ids.count {
                        if level_id == classified_level_id {
                                cell.update_success(text_1: sample_name, text_2: classified_level_name)
                        } else {
                                cell.update_failure(text_1: sample_name, text_2: classified_level_name)
                        }
                } else {
                        cell.update_additional(text_1: sample_name, text_2: classified_level_name)
                }

                return cell
        }
}
