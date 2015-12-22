import UIKit

class SampleNormalizationState: PageState {

        var indices_of_molecules_without_missing_values = [] as [Int]
        var selected_rows = [] as Set<Int>

        override init() {
                super.init()
                name = "sample_normalization"
                title = astring_body(string: "Sample normalization")
                info = "Each sample is normalized such that the mean of the values for the selected molecules is constant across all samples.\n\nOnly molecules without missing values are used to calculate the sample mean value.\n\nThe arbitrary average of the sample means after normalization is chosen to be the average over all sample means before normalization.\n\nThis normalization works best on logarithm transformed data."
                prepared = false
        }

        override func prepare() {
                indices_of_molecules_without_missing_values = calculate_indices_of_molecules_without_missing_values(values: state.values, number_of_molecules: state.number_of_molecules)
                selected_rows = Set<Int>(0 ..< indices_of_molecules_without_missing_values.count)

                prepared = true
        }
}

class SampleNormalization: Component, UITableViewDataSource, UITableViewDelegate {

        var sample_normalization_state: SampleNormalizationState!

        let create_normalized_data_set_button = UIButton(type: .System)

        let number_of_molecules_label = UILabel()
        let number_of_selected_molecules_label = UILabel()

        let select_all_button = UIButton(type: .System)
        let deselect_all_button = UIButton(type: .System)

        let table_view = UITableView()

        override func viewDidLoad() {
                super.viewDidLoad()

                create_normalized_data_set_button.setAttributedTitle(astring_body(string: "Create normalized data set"), forState: .Normal)
                let title_disabled = astring_font_size_color(string: "At least one molecule must be selected", font: nil, font_size: nil, color: UIColor.blackColor())
                create_normalized_data_set_button.setAttributedTitle(title_disabled, forState: .Disabled)
                create_normalized_data_set_button.addTarget(self, action: "create_normalized_data_set_action", forControlEvents: .TouchUpInside)
                create_normalized_data_set_button.sizeToFit()
                view.addSubview(create_normalized_data_set_button)

                view.addSubview(number_of_molecules_label)

                number_of_selected_molecules_label.textAlignment = .Center
                view.addSubview(number_of_selected_molecules_label)

                select_all_button.setAttributedTitle(astring_body(string: "Select all"), forState: .Normal)
                select_all_button.addTarget(self, action: "select_all", forControlEvents: .TouchUpInside)
                select_all_button.sizeToFit()
                view.addSubview(select_all_button)

                deselect_all_button.setAttributedTitle(astring_body(string: "Deselect all"), forState: .Normal)
                deselect_all_button.addTarget(self, action: "deselect_all", forControlEvents: .TouchUpInside)
                deselect_all_button.sizeToFit()
                view.addSubview(deselect_all_button)

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                view.addSubview(table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let side_margin = 20 as CGFloat
                var origin_y = 20 as CGFloat

                create_normalized_data_set_button.frame = CGRect(x: (width - create_normalized_data_set_button.frame.width) / 2, y: origin_y, width: create_normalized_data_set_button.frame.width, height: create_normalized_data_set_button.frame.height)
                origin_y += create_normalized_data_set_button.frame.height + 20

                number_of_molecules_label.sizeToFit()
                number_of_molecules_label.frame.origin = CGPoint(x: (width - number_of_molecules_label.frame.width) / 2, y: origin_y)
                origin_y += number_of_molecules_label.frame.height + 20

                update_number_of_selected_molecules()
                number_of_selected_molecules_label.frame = CGRect(x: 0, y: origin_y, width: width, height: number_of_selected_molecules_label.frame.height)
                origin_y += number_of_selected_molecules_label.frame.height + 20

                select_all_button.frame.origin = CGPoint(x: width - side_margin - select_all_button.frame.width, y: origin_y)
                deselect_all_button.frame.origin = CGPoint(x: side_margin, y: origin_y)
                origin_y += select_all_button.frame.height + 20

                table_view.frame = CGRect(x: 0, y: origin_y, width: width, height: view.frame.height - origin_y)
        }

        override func render() {
                sample_normalization_state = state.page_state as! SampleNormalizationState

                let number_of_molecules_string = "Molecules without missing values: \(sample_normalization_state!.indices_of_molecules_without_missing_values.count)"
                number_of_molecules_label.attributedText = astring_body(string: number_of_molecules_string)

                table_view.dataSource = self
                table_view.delegate = self

                render_after_change()
        }

        func render_after_change() {
                update_number_of_selected_molecules()
                table_view.reloadData()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return 0
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return sample_normalization_state.indices_of_molecules_without_missing_values.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell

                let index = sample_normalization_state.indices_of_molecules_without_missing_values[indexPath.row]
                let molecule_name = state.get_molecule_annotation_selected(molecule_index: index)

                if sample_normalization_state.selected_rows.contains(indexPath.row) {
                        cell.update_selected_checkmark(text: molecule_name)
                } else {
                        cell.update_unselected(text: molecule_name)
                }
                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                if sample_normalization_state.selected_rows.contains(indexPath.row) {
                        sample_normalization_state.selected_rows.remove(indexPath.row)
                } else {
                        sample_normalization_state.selected_rows.insert(indexPath.row)
                }

                render_after_change()
        }

        func update_number_of_selected_molecules() {
                let number_of_selected_molecules = sample_normalization_state.selected_rows.count
                let number_of_selected_molecules_string = "Selected molecules: \(number_of_selected_molecules)"
                number_of_selected_molecules_label.attributedText = astring_body(string: number_of_selected_molecules_string)
                number_of_selected_molecules_label.sizeToFit()
                create_normalized_data_set_button.enabled = number_of_selected_molecules > 0
                create_normalized_data_set_button.sizeToFit()
        }

        func select_all() {
                sample_normalization_state.selected_rows = Set<Int>(0 ..< sample_normalization_state.indices_of_molecules_without_missing_values.count)
                render_after_change()
        }

        func deselect_all() {
                sample_normalization_state.selected_rows = []
                render_after_change()
        }

        func create_normalized_data_set_action() {
                let normalizers = [Int](sample_normalization_state.selected_rows).map { self.sample_normalization_state.indices_of_molecules_without_missing_values[$0] }
                create_normalized_data_set(normalizers: normalizers)
        }
}

func create_normalized_data_set(normalizers normalizers: [Int]) {

        state.render_type = RenderType.progress_indicator
        state.progress_indicator_progress = 0
        state.progress_indicator_info = "The transformed data set is created"
        state.render()

        let serial_queue = dispatch_queue_create("sample normalization", DISPATCH_QUEUE_SERIAL)

        dispatch_async(serial_queue, {
                let normalized_values = normalize_sample_mean(values: state.values, number_of_molecules: state.number_of_molecules, normalizers: normalizers)
                let data_set_name = "Data set normalized"
                let project_note_text = "Creation of data set \"\(data_set_name)\" by sample normalization with \(normalizers.count) molecules."

                dispatch_async(dispatch_get_main_queue(), {

                        let data_set_id = state.insert_data_set(data_set_name: data_set_name, project_id: state.project_id, values: normalized_values, sample_ids: state.sample_ids, molecule_indices: state.molecule_indices)
                        state.insert_project_note(project_note_text: project_note_text, project_note_type: "auto", project_note_user_name: state.get_user_name(), project_id: state.project_id)

                        let data_set_selection_state = DataSetSelectionState()
                        state.navigate(page_state: data_set_selection_state)
                        state.render_type = RenderType.full_page
                        state.set_active_data_set(data_set_id: data_set_id)
                        state.render()
                })
        })
}

func calculate_indices_of_molecules_without_missing_values(values values: [Double], number_of_molecules: Int) -> [Int] {
        var indices = [] as [Int]
        let number_of_samples = values.count / number_of_molecules
        for i in 0 ..< number_of_molecules {
                var missing = false
                for j in 0 ..< number_of_samples {
                        if values[i * number_of_samples + j].isNaN {
                                missing = true
                                break
                        }
                }
                if !missing {
                        indices.append(i)
                }
        }
        return indices
}

func calculate_mean(values values: [Double]) -> Double {
        var sum = 0 as Double
        var count = 0
        for value in values {
                if !value.isNaN {
                        sum += value
                        count++
                }
        }
        return count > 0 ? sum / Double(count) : Double.NaN
}

func normalize_sample_mean(values values: [Double], number_of_molecules: Int, normalizers: [Int]) -> [Double] {
        let number_of_samples = values.count / number_of_molecules
        var sums = [Double](count: number_of_samples, repeatedValue: 0)

        for i in 0 ..< normalizers.count {
                let normalizer = normalizers[i]
                for j in 0 ..< number_of_samples {
                        let value = values[normalizer * number_of_samples + j]
                        sums[j] += value
                }

                state.progress_indicator_step(total: normalizers.count, index: i, min: 0, max: 50, step_size: 1_000)
        }

        let means = sums.map { $0 / Double(normalizers.count) }
        let mean_of_means = calculate_mean(values: means)
        var normalized_values = [Double](count: values.count, repeatedValue: Double.NaN)

        for i in 0 ..< number_of_molecules {
                for j in 0 ..< number_of_samples {
                        let index = i * number_of_samples + j
                        let value = values[index]
                        if !value.isNaN {
                                normalized_values[index] = value - means[j] + mean_of_means
                        }

                        state.progress_indicator_step(total: number_of_molecules, index: i, min: 50, max: 100, step_size: 10_000)
                }
        }

        return normalized_values
}
