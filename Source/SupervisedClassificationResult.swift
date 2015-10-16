import UIKit

class SupervisedClassificationResultState: PageState {

        let supervised_classification: SupervisedClassification

        var selected_segment_index = 0
        var supervised_classification_result_summary_delegate: SupervisedClassificationResultSummaryDelegate?
        var supervised_classification_result_samples_delegate: SupervisedClassificationResultSamplesDelegate?
        var table_of_attributed_strings: TableOfAttributedStrings?
        var any_unclassified = false

        var roc_label_name_1 = ""
        var roc_label_name_2 = ""
        var roc_decision_values_1 = [] as [Double]
        var roc_decision_values_2 = [] as [Double]

        init(supervised_classification: SupervisedClassification) {
                self.supervised_classification = supervised_classification
                super.init()
                name = "supervised_classification_result"
                switch supervised_classification.supervised_classification_type {
                case .KNN:
                        title = astring_body(string: "k nearest neighbor classifier")
                case .SVM:
                        title = astring_body(string: "support vector machine")
                }
                supervised_classification_result_summary_delegate = SupervisedClassificationResultSummaryDelegate(supervised_classification: supervised_classification)
                supervised_classification_result_samples_delegate = SupervisedClassificationResultSamplesDelegate(supervised_classification: supervised_classification)

                let (table_of_attributed_strings, any_unclassified) = supervised_classification_result_table_of_attributed_strings(supervised_classification: supervised_classification)
                self.table_of_attributed_strings = table_of_attributed_strings
                self.any_unclassified = any_unclassified

                if supervised_classification.supervised_classification_type == .SVM && supervised_classification.comparison_level_ids.count == 2 {
                        let svm = supervised_classification as! SVM

                        let (i0, i1) = svm.first_training_level_id == svm.comparison_level_ids[0] ? (1, 0) : (0, 1)

                        roc_label_name_1 = supervised_classification.comparison_level_names[i0]
                        roc_label_name_2 = supervised_classification.comparison_level_names[i1]

                        roc_decision_values_1 = []
                        roc_decision_values_2 = []

                        for i in 0 ..< supervised_classification.test_sample_decision_values.count {
                                if supervised_classification.test_sample_level_ids[i] == supervised_classification.comparison_level_ids[i0] {
                                        roc_decision_values_1.append(supervised_classification.test_sample_decision_values[i])
                                } else {
                                        roc_decision_values_2.append(supervised_classification.test_sample_decision_values[i])
                                }
                        }
                }

                set_selected_segment_index(index: 0)
        }

        func set_selected_segment_index(index index: Int) {
                selected_segment_index = index
                full_screen = index == 3
                pdf_enabled = index == 3
                set_info()
        }

        func set_info() {
                let is_knn = supervised_classification.supervised_classification_type == .KNN

                if !supervised_classification.classification_success && is_knn {
                        info = "The result of the k nearest neighbor classification"
                } else if !supervised_classification.classification_success {
                        info = "The result of the support vector machine classification"
                } else if selected_segment_index == 0 {
                        info = "A summary of the classification results.\n\nThe additional samples are samples that have levels different from the levels used in the classifier."
                } else if selected_segment_index == 1 && is_knn && any_unclassified {
                        let k = (supervised_classification as! KNN).k
                        info = "The row names are the actual levels of the samples.\n\nThe column names are the predicted levels.\n\nA sample is unclassified if there is no majority level among the k=\(k) neighbors.\n\nThe cells contain the number of samples with a combination of actual and predicted levels."
                } else if selected_segment_index == 1  {
                        info = "The row names are the actual levels of the samples.\n\nThe column names are the predicted levels.\n\nThe cells contain the number of samples with a combination of actual and predicted levels."
                } else if selected_segment_index == 2 {
                        info = "Information about the individual samples.\n\nSamples are grouped according to their actual levels.\n\nGreen samples are correctly classified, red samples are incorrectly classified, and gray samples have levels unknown to the classifier."
                } else {
                        info = "The receiver operating characteristic(ROC) curve.\n\nA ROC area of 1 implies perfect separation.\n\nA ROC area around 0.5, or below 0.5, means that the classification is unsuccessful.\n\nSee the manual for a full discussion."
                }
        }
}

class SupervisedClassificationResult: Component {

        var supervised_classification_result_state: SupervisedClassificationResultState!

        let classification_failure_label = UILabel()

        let segmented_control = UISegmentedControl(items: ["Summary", "Table", "Samples"])

        let table_view = UITableView()

        let tiled_scroll_view = TiledScrollView(frame: CGRect.zero)

        var roc_view: ROCView!

        override func viewDidLoad() {
                super.viewDidLoad()

                let classification_failure_text = "The classification could not be performed because there are no molecules without missing values or too few samples"
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

                roc_view = ROCView()
                view.addSubview(roc_view)
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
                        var tiled_scroll_view_delegate: TiledScrollViewDelegate?
                        var zoom_scale = 1 as CGFloat

                        if supervised_classification_result_state.selected_segment_index == 1, let table_of_atrributed_strings = supervised_classification_result_state.table_of_attributed_strings {
                                tiled_scroll_view_delegate = table_of_atrributed_strings
                                zoom_scale = table_of_atrributed_strings.zoom_scale
                        }

                        if let tiled_scroll_view_delegate = tiled_scroll_view_delegate {
                                let scale_x = width / tiled_scroll_view_delegate.content_size.width
                                let scale_y = (height - origin_y) / tiled_scroll_view_delegate.content_size.height
                                let scale_min = min(1, scale_x, scale_y)
                                let scale_max = max(1, scale_x, scale_y)
                                tiled_scroll_view_delegate.minimum_zoom_scale = scale_min
                                tiled_scroll_view_delegate.maximum_zoom_scale = scale_max
                                tiled_scroll_view.delegate = tiled_scroll_view_delegate
                                tiled_scroll_view.scroll_view.zoomScale = zoom_scale
                                tiled_scroll_view.layoutScrollView()
                        }
                }

                roc_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height - origin_y)
        }

        override func render() {
                supervised_classification_result_state = state.page_state as! SupervisedClassificationResultState
                let supervised_classification = supervised_classification_result_state.supervised_classification

                roc_view.update(label_name_1: supervised_classification_result_state.roc_label_name_1, label_name_2: supervised_classification_result_state.roc_label_name_2, decision_values_1: supervised_classification_result_state.roc_decision_values_1, decision_values_2: supervised_classification_result_state.roc_decision_values_2)

                classification_failure_label.hidden = true
                segmented_control.hidden = false
                table_view.hidden = true
                tiled_scroll_view.hidden = true
                roc_view.hidden = true

                if supervised_classification.supervised_classification_type == .SVM && supervised_classification.comparison_level_ids.count == 2 && segmented_control.numberOfSegments == 3 {
                        segmented_control.insertSegmentWithTitle("ROC", atIndex: 3, animated: false)
                }
                segmented_control.selectedSegmentIndex = supervised_classification_result_state.selected_segment_index

                if !supervised_classification.classification_success {
                        classification_failure_label.hidden = false
                        segmented_control.hidden = true
                } else if supervised_classification_result_state.selected_segment_index == 0 {
                        table_view.hidden = false
                        table_view.dataSource = supervised_classification_result_state.supervised_classification_result_summary_delegate
                        table_view.delegate = supervised_classification_result_state.supervised_classification_result_summary_delegate
                        table_view.reloadData()
                } else if supervised_classification_result_state.selected_segment_index == 1 {
                        tiled_scroll_view.hidden = false
                } else if supervised_classification_result_state.selected_segment_index == 2 {
                        table_view.hidden = false
                        table_view.dataSource = supervised_classification_result_state.supervised_classification_result_samples_delegate
                        table_view.delegate = supervised_classification_result_state.supervised_classification_result_samples_delegate
                        table_view.reloadData()
                } else {
                        roc_view.hidden = false
                }

                view.setNeedsLayout()
        }

        func segmented_control_action() {
                supervised_classification_result_state.set_selected_segment_index(index: segmented_control.selectedSegmentIndex)
                state.render()
        }

        func pdf_action () {
                let file_name_stem = "svm-roc-curve"
                let description = "ROC curve for support vector machine classifier"
                state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: roc_view.content_size, draw: roc_view.draw)
                state.render()
        }
}

class SupervisedClassificationResultSummaryDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {

        let supervised_classification: SupervisedClassification
        var (classified_test_samples, correctly_classified_test_samples) = (0, 0)
        var headers = [] as [String]
        var cells = [] as [String]

        init(supervised_classification: SupervisedClassification) {
                self.supervised_classification = supervised_classification
                super.init()

                let (classified_test_samples, correctly_classified_test_samples) = calculate_test_samples()

                if supervised_classification.supervised_classification_type == .KNN {
                        let knn = supervised_classification as! KNN
                        if supervised_classification.validation_method == .TrainingTest {
                                headers = ["Type of classification", "Number of neighbors(k)", "Training samples", "Test samples", "Classified test samples", "Correctly classified test samples", "Incorrectly classified test samples", "Unclassified test samples", "Additional predicted samples"]
                                cells = [String](count: 9, repeatedValue: "")
                                cells[0] = "Fixed training and test set"
                                cells[1] = String(knn.k)
                                cells[2] = String(knn.training_sample_index_set.count)
                                cells[3] = String(knn.test_sample_indices.count)
                                cells[4] = String(classified_test_samples)
                                cells[5] = String(correctly_classified_test_samples)
                                cells[6] = String(classified_test_samples - correctly_classified_test_samples)
                                cells[7] = String(knn.test_sample_indices.count - classified_test_samples)
                                cells[8] = String(knn.additional_sample_indices.count)
                        } else {
                                headers = ["Type of classification", "Number of neighbors(k)", "Total samples", "Classified samples", "Correctly classified samples", "Incorrectly classified samples", "Unclassified samples"]
                                cells = [String](count: 7, repeatedValue: "")
                                cells[0] = knn.validation_method == .LeaveOneOut ? "Leave one out cross validation" : "\(knn.k_fold)-fold cross validation"
                                cells[1] = String(knn.k)
                                cells[2] = String(knn.test_sample_indices.count)
                                cells[3] = String(classified_test_samples)
                                cells[4] = String(correctly_classified_test_samples)
                                cells[5] = String(classified_test_samples - correctly_classified_test_samples)
                                cells[6] = String(knn.test_sample_indices.count - classified_test_samples)
                        }
                } else if supervised_classification.supervised_classification_type == .SVM {
                        let svm = supervised_classification as! SVM
                        if supervised_classification.validation_method == .TrainingTest {
                                headers = ["Type of classification", "Kernel", "Training samples", "Test samples", "Classified test samples", "Correctly classified test samples", "Incorrectly classified test samples", "Unclassified test samples", "Additional predicted samples"]
                                cells = [String](count: 9, repeatedValue: "")
                                cells[0] = "Fixed training and test set"
                                cells[1] = svm.kernel == .Linear ? "Linear" : "RBF"
                                cells[2] = String(svm.training_sample_index_set.count)
                                cells[3] = String(svm.test_sample_indices.count)
                                cells[4] = String(classified_test_samples)
                                cells[5] = String(correctly_classified_test_samples)
                                cells[6] = String(classified_test_samples - correctly_classified_test_samples)
                                cells[7] = String(svm.test_sample_indices.count - classified_test_samples)
                                cells[8] = String(svm.additional_sample_indices.count)
                        } else {
                                headers = ["Type of classification", "Kernel", "Total samples", "Correctly classified samples", "Incorrectly classified samples"]
                                cells = [String](count: 5, repeatedValue: "")
                                cells[0] = svm.validation_method == .LeaveOneOut ? "Leave one out cross validation" : "\(svm.k_fold)-fold cross validation"
                                cells[1] = svm.kernel == .Linear ? "Linear" : "RBF"
                                cells[2] = String(svm.test_sample_indices.count)
                                cells[3] = String(correctly_classified_test_samples)
                                cells[4] = String(classified_test_samples - correctly_classified_test_samples)
                        }
                }
        }

        func calculate_test_samples() -> (classified_test_samples: Int, correctly_classified_test_samples: Int) {
                var classified_test_samples = 0
                var correctly_classified_test_samples = 0

                for i in 0 ..< supervised_classification.test_sample_indices.count {
                        if supervised_classification.test_sample_classified_level_ids[i] > 0 {
                                classified_test_samples++
                                if supervised_classification.test_sample_level_ids[i] == supervised_classification.test_sample_classified_level_ids[i] {
                                        correctly_classified_test_samples++
                                }
                        }
                }
                return (classified_test_samples, correctly_classified_test_samples)
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return headers.count
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text = headers[section]
                header.update_normal(text: text)

                return header
        }

        func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return 0
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
                let text = cells[section]
                cell.update_normal(text: text)

                return cell
        }
}

class SupervisedClassificationResultSamplesDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {

        let supervised_classification: SupervisedClassification
        var level_ids = [] as [Int]
        var level_names = [] as [String]
        var sample_names = [] as [[String]]
        var classified_level_ids = [] as [[Int]]
        var decision_values = [] as [[Double]]

        var use_decision_values = true

        init(supervised_classification: SupervisedClassification) {
                self.supervised_classification = supervised_classification

                use_decision_values = supervised_classification.comparison_level_ids.count == 2 && supervised_classification.supervised_classification_type == .SVM

                level_ids = supervised_classification.comparison_level_ids
                level_names = supervised_classification.comparison_level_names

                for level_id in supervised_classification.comparison_level_ids {
                        var current_sample_names = [] as [String]
                        var current_classified_level_ids = [] as [Int]
                        var current_decision_values = [] as [Double]
                        for i in 0 ..< supervised_classification.test_sample_indices.count {
                                if supervised_classification.test_sample_level_ids[i] == level_id {
                                        current_sample_names.append(supervised_classification.test_sample_names[i])
                                        current_classified_level_ids.append(supervised_classification.test_sample_classified_level_ids[i])
                                        if use_decision_values {
                                                current_decision_values.append(supervised_classification.test_sample_decision_values[i])
                                        }
                                }
                        }
                        sample_names.append(current_sample_names)
                        classified_level_ids.append(current_classified_level_ids)
                        decision_values.append(current_decision_values)
                }

                if supervised_classification.validation_method == .TrainingTest {
                        level_ids += supervised_classification.additional_level_ids
                        level_names += supervised_classification.additional_level_names

                        for level_id in supervised_classification.additional_level_ids {
                                var current_sample_names = [] as [String]
                                var current_classified_level_ids = [] as [Int]
                                var current_decision_values = [] as [Double]
                                for i in 0 ..< supervised_classification.additional_sample_indices.count {
                                        if supervised_classification.additional_sample_level_ids[i] == level_id {
                                                current_sample_names.append(supervised_classification.additional_sample_names[i])
                                                current_classified_level_ids.append(supervised_classification.additional_sample_classified_level_ids[i])
                                                current_decision_values.append(supervised_classification.additional_sample_decision_values[i])
                                        }
                                }
                                sample_names.append(current_sample_names)
                                classified_level_ids.append(current_classified_level_ids)
                                decision_values.append(current_decision_values)
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

                let text_2: String
                if classified_level_id > 0 {
                        let level_index = supervised_classification.comparison_level_ids.indexOf(classified_level_id)!
                        let classified_level_name = supervised_classification.comparison_level_names[level_index]
                        if use_decision_values {
                                let decision_value = decision_values[section][row]
                                text_2 = classified_level_name + "(" + decimal_string(number: decision_value, significant_digits: 2) + ")"
                        } else {
                                text_2 = classified_level_name
                        }
                } else {
                        text_2 = "unclassified"
                }

                if section < supervised_classification.comparison_level_ids.count {
                        if level_id == classified_level_id {
                                cell.update_success(text_1: sample_name, text_2: text_2)
                        } else {
                                cell.update_failure(text_1: sample_name, text_2: text_2)
                        }
                } else {
                        cell.update_additional(text_1: sample_name, text_2: text_2)
                }

                return cell
        }
}

func supervised_classification_result_table_of_attributed_strings(supervised_classification supervised_classification: SupervisedClassification) -> (table_of_attributed_strings: TableOfAttributedStrings, any_unclassified: Bool) {

        var any_unclassified = false
        for classified_level_id in supervised_classification.test_sample_classified_level_ids {
                if classified_level_id == -1 {
                        any_unclassified = true
                }
        }
        if supervised_classification.validation_method == .TrainingTest {
                for classified_level_id in supervised_classification.additional_sample_classified_level_ids {
                        if classified_level_id == -1 {
                                any_unclassified = true
                        }
                }
        }

        let column_level_ids: [Int]
        let column_level_names: [String]
        if any_unclassified {
                column_level_ids = supervised_classification.comparison_level_ids + [-1]
                column_level_names = supervised_classification.comparison_level_names + ["Unclassified"]
        } else {
                column_level_ids = supervised_classification.comparison_level_ids
                column_level_names = supervised_classification.comparison_level_names
        }

        var attributed_strings = [] as [[Astring?]]
        var header = [nil] as [Astring?]
        for level_name in column_level_names {
                header.append(astring_body(string: level_name))
        }
        header.append(nil)
        attributed_strings.append(header)

        var column_totals = [Int](count: column_level_ids.count, repeatedValue: 0)
        for i in 0 ..< supervised_classification.comparison_level_ids.count {
                let level_id = supervised_classification.comparison_level_ids[i]
                var row = [astring_body(string: supervised_classification.comparison_level_names[i])] as [Astring?]
                var total = 0
                for j in 0 ..< column_level_ids.count {
                        var number = 0
                        let classified_level_id = column_level_ids[j]
                        for k in 0 ..< supervised_classification.test_sample_indices.count {
                                if supervised_classification.test_sample_level_ids[k] == level_id && supervised_classification.test_sample_classified_level_ids[k] == classified_level_id {
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

        if supervised_classification.validation_method == .TrainingTest {
                for i in 0 ..< supervised_classification.additional_level_ids.count {
                        let level_id = supervised_classification.additional_level_ids[i]
                        var row = [astring_body(string: supervised_classification.additional_level_names[i])] as [Astring?]
                        var total = 0
                        for j in 0 ..< column_level_ids.count {
                                var number = 0
                                let classified_level_id = column_level_ids[j]
                                for k in 0 ..< supervised_classification.additional_sample_indices.count {
                                        if supervised_classification.additional_sample_level_ids[k] == level_id && supervised_classification.additional_sample_classified_level_ids[k] == classified_level_id {
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
