import UIKit

class KNNResultState: PageState {

        let knn: KNN

        var selected_segment_index = 0

        var knn_result_samples_delegate: KNNResultSamplesDelegate?
        var knn_result_summary_delegate: KNNResultSummaryDelegate?
        var table_of_attributed_strings: TableOfAttributedStrings?

        let info_0 = "A summary of the classification results.\n\nThe additional samples are samples that have levels different from the levels used in the classifier."

        var info_1 = ""

        let info_2 = "Information about the individual samples.\n\nSamples are grouped according to their actual levels.\n\nGreen samples are correctly classified, red samples are incorrectly classified, and gray samples have levels unknown to the classifier."

        init(knn: KNN) {
                self.knn = knn
                super.init()
                name = "knn_result"
                title = astring_body(string: "k nearest neighbor classifier")
                info = "The result of the k nearest neighbor classification"

                if knn.classification_success {
                        knn_result_samples_delegate = KNNResultSamplesDelegate(knn: knn)
                        knn_result_summary_delegate = KNNResultSummaryDelegate(knn: knn)
                        let (table_of_attributed_strings, any_unclassified) = knn_result_table_of_attributed_strings(knn: knn)
                        self.table_of_attributed_strings = table_of_attributed_strings
                        set_selected_segment_index(index: 0)

                        if any_unclassified {
                                info_1 = "The row names are the actual levels of the samples.\n\nThe column names are the predicted levels.\n\nA sample is unclassified if there is no majority level among the k=\(knn.k) neighbors.\n\nThe cells contain the number of samples with a combination of actual and predicted levels."
                        } else {
                                info_1 = "The row names are the actual levels of the samples.\n\nThe column names are the predicted levels.\n\nThe cells contain the number of samples with a combination of actual and predicted levels."
                        }
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

                if !tiled_scroll_view.hidden {
                        tiled_scroll_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height - origin_y)
                        if let table_of_atrributed_strings = knn_result_state.table_of_attributed_strings {
                                let scale_x = width / table_of_atrributed_strings.content_size.width
                                let scale_y = (height - origin_y) / table_of_atrributed_strings.content_size.height
                                let scale_min = min(1, scale_x, scale_y)
                                let scale_max = max(1, scale_x, scale_y)
                                table_of_atrributed_strings.minimum_zoom_scale = scale_min
                                table_of_atrributed_strings.maximum_zoom_scale = scale_max
                                tiled_scroll_view.delegate = table_of_atrributed_strings
//                                tiled_scroll_view.scroll_view.zoomScale = max(0.7, scale_min)
                                tiled_scroll_view.scroll_view.zoomScale = table_of_atrributed_strings.zoom_scale
                        }
                }
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

                view.setNeedsLayout()
        }

        func segmented_control_action() {
                knn_result_state.set_selected_segment_index(index: segmented_control.selectedSegmentIndex)
                render()
        }
}

class KNNResultSummaryDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {

        let knn: KNN

        var classified_test_samples = 0
        var correctly_classified_test_samples = 0

        init(knn: KNN) {
                self.knn = knn

                for i in 0 ..< knn.test_sample_indices.count {
                        if knn.test_sample_classified_level_ids[i] > 0 {
                                classified_test_samples++
                                if knn.test_sample_level_ids[i] == knn.test_sample_classified_level_ids[i] {
                                        correctly_classified_test_samples++
                                }
                        }
                }
        }

        let training_test_headers = ["Type of classification", "Number of neighbors(k)", "Training samples", "Test samples", "Classified test samples", "Correctly classified test samples", "Incorrectly classified test samples", "Unclassified test samples", "Additional predicted samples"]
        let cross_validation_headers = ["Type of classification", "Number of neighbors(k)", "Total samples", "Classified samples", "Correctly classified samples", "Incorrectly classified samples", "Unclassified samples"]

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
                                text = String(knn.k)
                        case 2:
                                text = String(knn.training_sample_index_set.count)
                        case 3:
                                text = String(knn.test_sample_indices.count)
                        case 4:
                                text = String(classified_test_samples)
                        case 5:
                                text = String(correctly_classified_test_samples)
                        case 6:
                                text = String(classified_test_samples - correctly_classified_test_samples)
                        case 7:
                                text = String(knn.test_sample_indices.count - classified_test_samples)
                        default:
                                text = String(knn.additional_sample_indices.count)
                        }
                } else {
                        switch section {
                        case 0:
                                if knn.validation_method == .LeaveOneOut {
                                        text = "Leave one out cross validation"
                                } else {
                                        text = "\(knn.k_fold)-fold cross validation"
                                }
                        case 1:
                                text = String(knn.k)
                        case 2:
                                text = String(knn.test_sample_indices.count)
                        case 3:
                                text = String(classified_test_samples)
                        case 4:
                                text = String(correctly_classified_test_samples)
                        case 5:
                                text = String(classified_test_samples - correctly_classified_test_samples)
                        default:
                                text = String(knn.test_sample_indices.count - classified_test_samples)
                        }
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

                level_ids = knn.comparison_level_ids
                level_names = knn.comparison_level_names

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

                if knn.validation_method == .TrainingTest {
                        level_ids += knn.additional_level_ids
                        level_names += knn.additional_level_names

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

func knn_result_table_of_attributed_strings(knn knn: KNN) -> (table_of_attributed_strings: TableOfAttributedStrings, any_unclassified: Bool) {

        var any_unclassified = false
        for classified_level_id in knn.test_sample_classified_level_ids {
                if classified_level_id == -1 {
                        any_unclassified = true
                }
        }
        if knn.validation_method == .TrainingTest {
                for classified_level_id in knn.additional_sample_classified_level_ids {
                        if classified_level_id == -1 {
                                any_unclassified = true
                        }
                }
        }

        let column_level_ids: [Int]
        let column_level_names: [String]
        if any_unclassified {
                column_level_ids = knn.comparison_level_ids + [-1]
                column_level_names = knn.comparison_level_names + ["Unclassified"]
        } else {
                column_level_ids = knn.comparison_level_ids
                column_level_names = knn.comparison_level_names
        }

        var attributed_strings = [] as [[Astring?]]
        var header = [nil] as [Astring?]
        for level_name in column_level_names {
                header.append(astring_body(string: level_name))
        }
        header.append(nil)
        attributed_strings.append(header)

        var column_totals = [Int](count: column_level_ids.count, repeatedValue: 0)
        for i in 0 ..< knn.comparison_level_ids.count {
                let level_id = knn.comparison_level_ids[i]
                var row = [astring_body(string: knn.comparison_level_names[i])] as [Astring?]
                var total = 0
                for j in 0 ..< column_level_ids.count {
                        var number = 0
                        let classified_level_id = column_level_ids[j]
                        for k in 0 ..< knn.test_sample_indices.count {
                                if knn.test_sample_level_ids[k] == level_id && knn.test_sample_classified_level_ids[k] == classified_level_id {
                                        number++
                                }
                        }
                        let astring: Astring
                        if level_id == classified_level_id {
                                astring = astring_font_size_color(string: String(number), font: font_headline, font_size: nil, color: nil)
                        } else if number > 0 {
                                astring = astring_font_size_color(string: String(number), font: nil, font_size: nil, color: color_text_failure)
                        } else {
                                astring = astring_body(string: String(number))
                        }
                        row.append(astring)
                        column_totals[j] += number
                        total += number
                }
                row.append(astring_body(string: String(total)))
                attributed_strings.append(row)
        }

        if knn.validation_method == .TrainingTest {
                for i in 0 ..< knn.additional_level_ids.count {
                        let level_id = knn.additional_level_ids[i]
                        var row = [astring_body(string: knn.additional_level_names[i])] as [Astring?]
                        var total = 0
                        for j in 0 ..< column_level_ids.count {
                                var number = 0
                                let classified_level_id = column_level_ids[j]
                                for k in 0 ..< knn.additional_sample_indices.count {
                                        if knn.additional_sample_level_ids[k] == level_id && knn.additional_sample_classified_level_ids[k] == classified_level_id {
                                                number++
                                        }
                                }
                                row.append(astring_body(string: String(number)))
                                column_totals[j] += number
                                total += number
                        }
                        row.append(astring_body(string: String(total)))
                        attributed_strings.append(row)
                }
        }

        var footer = [nil] as [Astring?]
        for column_total in column_totals {
                footer.append(astring_body(string: String(column_total)))
        }
        let grand_total = column_totals.reduce(0, combine: +)
        footer.append(astring_body(string: String(grand_total)))
        attributed_strings.append(footer)

        let horizontal_row = [Bool](count: attributed_strings[0].count, repeatedValue: true)
        var horizontal_cells = [[Bool]](count: attributed_strings.count, repeatedValue: horizontal_row)
        for i in 0 ..< attributed_strings[0].count - 2 {
                horizontal_cells[0][i + 1] = false
        }

        return (TableOfAttributedStrings(attributed_strings: attributed_strings, horizontal_cells: horizontal_cells, tap_action: nil), any_unclassified)
}
