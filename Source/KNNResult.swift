import UIKit

class KNNResultState: PageState {

        let knn: KNN

        var selected_segment_index = 0

        var knn_result_samples_delegate: KNNResultSamplesDelegate?
        var knn_result_summary_delegate: KNNResultSummaryDelegate?

        let info_0 = "0"

        let info_1 = "1"

        let info_2 = "2"

        init(knn: KNN) {
                self.knn = knn
                super.init()
                name = "knn_result"
                title = astring_body(string: "k nearest neighbor classifier")
                info = "The result of the k nearest neighbor classification"

                if knn.classification_success {
                        knn_result_samples_delegate = KNNResultSamplesDelegate(knn: knn)
                        knn_result_summary_delegate = KNNResultSummaryDelegate(knn: knn)
                }
        }

        func set_selected_segment_index(index index: Int) {
                selected_segment_index = index
                info = index == 0 ? info_0 : (index == 1 ? info_1 : info_2)
        }
}

class KNNResult: Component {

        var knn_result_state: KNNResultState!

        let classification_failure_label = UILabel()

        let segmented_control = UISegmentedControl(items: ["Summary", "Table", "Samples"])

        let table_view = UITableView()

        let tiled_scroll_view = TiledScrollView(frame: CGRect.zero)
        var table_of_attributed_strings: TableOfAttributedStrings?

        override func viewDidLoad() {
                super.viewDidLoad()

                let classification_failure_text = "The classification could not be performed because there are no molecules without missing values"
                classification_failure_label.attributedText = astring_font_size_color(string: classification_failure_text, font: nil, font_size: 20, color: nil)
                classification_failure_label.textAlignment = .Center
                classification_failure_label.numberOfLines = 0
                view.addSubview(classification_failure_label)

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

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height
                let top_margin = 20 as CGFloat

                let classification_failure_label_size = classification_failure_label.sizeThatFits(CGSize(width: width - 100, height: 0))
                classification_failure_label.frame.size = classification_failure_label_size
                classification_failure_label.frame.origin = CGPoint(x: 50, y: 100)

                let segmented_control_width = min(500, width - 40)
                segmented_control.frame = CGRect(x: (width - segmented_control_width) / 2, y: top_margin, width: segmented_control_width, height: segmented_control.frame.height)

                let origin_y = CGRectGetMaxY(segmented_control.frame) + top_margin

                table_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height - origin_y)
        }

        override func render() {
                knn_result_state = state.page_state as! KNNResultState
                let knn = knn_result_state.knn

                classification_failure_label.hidden = true
                segmented_control.hidden = false
                table_view.hidden = true
                tiled_scroll_view.hidden = true

                segmented_control.selectedSegmentIndex = knn_result_state.selected_segment_index

                if !knn.classification_success {
                        classification_failure_label.hidden = false
                        segmented_control.hidden = true
                } else if knn_result_state.selected_segment_index == 0 {
                        table_view.hidden = false
                        table_view.dataSource = knn_result_state.knn_result_summary_delegate
                        table_view.delegate = knn_result_state.knn_result_summary_delegate
                        table_view.reloadData()
                } else if knn_result_state.selected_segment_index == 1 {
                        tiled_scroll_view.hidden = false

                } else {
                        table_view.hidden = false
                        table_view.dataSource = knn_result_state.knn_result_samples_delegate
                        table_view.delegate = knn_result_state.knn_result_samples_delegate
                        table_view.reloadData()
                }
        }

        func segmented_control_action() {
                knn_result_state.set_selected_segment_index(index: segmented_control.selectedSegmentIndex)
                render()
        }
}

class KNNResultSummaryDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {

        let knn: KNN

        init(knn: KNN) {
                self.knn = knn

        }

        let training_test_headers = ["Type of classification", "Training samples", "Test samples", "Classified test samples", "Correctly classified test samples", "Incorrectly classified test samples", "Unclassified test samples", "Additional predicted samples"]
        let cross_validation_headers = ["Type of classification"]

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return knn.validation_method == .TrainingTest ? training_test_headers.count : cross_validation_headers.count
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text: String
                if knn.validation_method == .TrainingTest {
                        text = training_test_headers[section]
                } else {
                        text = cross_validation_headers[section]
                }

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
                return 1
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let (section, _) = (indexPath.section, indexPath.row)

                let text: String
                if knn.validation_method == .TrainingTest {
                        switch section {
                        case 0:
                                text = "Fixed training and test set"
                        case 1:
                                text = String(knn.training_sample_index_set.count)
                        default:
                                text = "\(knn.test_sample_indices.count)"
                        }
                } else {
                        text = ""
                }

                cell.update_normal(text: text)

                return cell
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
