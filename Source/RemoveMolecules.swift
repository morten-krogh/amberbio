import UIKit

class RemoveMoleculesState: PageState {

        var maximum_missing_values = 0
        var minimum_std_dev = 0 as Double
        var missing_values_per_molecule = [] as [Int]
        var std_dev_per_molecule = [] as [Double]
        var highest_std_dev = 0 as Double

        override init() {
                super.init()
                name = "remove_molecules"
                title = astring_body(string: "Remove molecules")
                info = "Create a new data set with fewer molecules by tapping the button.\n\nSet the maximum number of missing values and the minimum variance.\n\n Molecules with fewer missing values and larger variances than the threshold are included in the new data set."

                missing_values_per_molecule = [Int](count: state.number_of_molecules, repeatedValue: 0)
                std_dev_per_molecule = [Double](count: state.number_of_molecules, repeatedValue: 0)
                calculate_missing_values_and_std_devs(state.values, state.number_of_molecules, state.number_of_samples, &missing_values_per_molecule, &std_dev_per_molecule)
                highest_std_dev = std_dev_per_molecule.maxElement() ?? 1
                if isnan(highest_std_dev) || highest_std_dev == 0 {
                        highest_std_dev = 1
                }
                highest_std_dev += 0.01
        }
}

class RemoveMolecules: Component, UITextFieldDelegate {

        var remove_molecules_state: RemoveMoleculesState!
        var number_of_remaining_molecules = 0

        let scroll_view = UIScrollView()

        let create_data_set_button = UIButton(type: .System)
        let number_of_molecules_label = UILabel()
        let missing_values_label = UILabel()
        let missing_values_field = UITextField()
        let missing_values_slider = UISlider()
        let missing_values_low_value_label = UILabel()
        let missing_values_high_value_label = UILabel()

        let std_dev_label = UILabel()
        let std_dev_field = UITextField()
        let std_dev_slider = UISlider()
        let std_dev_low_label = UILabel()
        let std_dev_high_label = UILabel()

        override func loadView() {
                view = scroll_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                create_data_set_button.setAttributedTitle(astring_body(string: "Create new data set"), forState: .Normal)
                create_data_set_button.addTarget(self, action: "create_data_set_action", forControlEvents: UIControlEvents.TouchUpInside)
                view.addSubview(create_data_set_button)

                view.addSubview(number_of_molecules_label)

                missing_values_label.attributedText = astring_headline(string: "Maximum number of missing values")
                missing_values_label.textAlignment = .Center
                view.addSubview(missing_values_label)

                missing_values_field.textAlignment = .Center
                missing_values_field.keyboardType = UIKeyboardType.NumberPad
                missing_values_field.borderStyle = UITextBorderStyle.Bezel
                missing_values_field.delegate = self
                view.addSubview(missing_values_field)

                missing_values_slider.addTarget(self, action: "missing_values_slider_action", forControlEvents: UIControlEvents.ValueChanged)
                view.addSubview(missing_values_slider)

                view.addSubview(missing_values_low_value_label)
                view.addSubview(missing_values_high_value_label)

                std_dev_label.attributedText = astring_headline(string: "Minimum standard deviation")
                std_dev_label.textAlignment = .Center
                view.addSubview(std_dev_label)

                std_dev_field.textAlignment = .Center
                std_dev_field.keyboardType = UIKeyboardType.NumbersAndPunctuation
                std_dev_field.borderStyle = UITextBorderStyle.Bezel
                std_dev_field.delegate = self
                view.addSubview(std_dev_field)

                std_dev_slider.addTarget(self, action: "std_dev_slider_action", forControlEvents: UIControlEvents.ValueChanged)
                view.addSubview(std_dev_slider)

                view.addSubview(std_dev_low_label)
                view.addSubview(std_dev_high_label)

                let tap_action: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap_action:")
                view.addGestureRecognizer(tap_action)
        }

        override func viewDidAppear(animated: Bool) {
                std_dev_slider.setMinimumTrackImage(missing_values_slider.maximumTrackImageForState(.Normal), forState: .Normal)
                std_dev_slider.setMaximumTrackImage(missing_values_slider.minimumTrackImageForState(.Normal), forState: .Normal)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let margin = 20 as CGFloat
                let text_field_width = 70 as CGFloat
                let text_field_height = missing_values_field.sizeThatFits(CGSize.zero).height

                let width = view.frame.width
                var origin_y = margin

                var height = create_data_set_button.sizeThatFits(CGSize.zero).height
                create_data_set_button.frame = CGRect(x: 0, y: origin_y, width: width, height: height)
                origin_y += height + margin

                height = number_of_molecules_label.sizeThatFits(CGSize.zero).height
                number_of_molecules_label.frame = CGRect(x: 0, y: origin_y, width: width, height: height)
                origin_y += height + 3 * margin

                missing_values_label.sizeToFit()
                missing_values_label.frame = CGRect(x: 0, y: origin_y, width: width, height: missing_values_label.frame.height)
                origin_y += missing_values_label.frame.height + margin

                missing_values_field.frame = CGRect(x: (width - text_field_width) / 2, y: origin_y, width: text_field_width, height: text_field_height)
                origin_y += text_field_height + margin

                missing_values_low_value_label.sizeToFit()
                missing_values_low_value_label.frame.origin = CGPoint(x: margin, y: origin_y)
                missing_values_high_value_label.sizeToFit()
                missing_values_high_value_label.frame.origin = CGPoint(x: width - margin - missing_values_high_value_label.frame.width, y: origin_y)
                var center_y = missing_values_low_value_label.center.y
                missing_values_slider.frame = CGRect(x: CGRectGetMaxX(missing_values_low_value_label.frame) + margin, y: center_y - missing_values_slider.frame.height / 2, width: CGRectGetMinX(missing_values_high_value_label.frame) - CGRectGetMaxX(missing_values_low_value_label.frame) - 2 * margin, height: missing_values_slider.frame.height)
                origin_y = max(CGRectGetMaxY(missing_values_low_value_label.frame), CGRectGetMaxY(missing_values_slider.frame)) + 3 * margin

                std_dev_label.sizeToFit()
                std_dev_label.frame = CGRect(x: 0, y: origin_y, width: width, height: std_dev_label.frame.height)
                origin_y += std_dev_label.frame.height + margin

                std_dev_field.frame = CGRect(x: (width - text_field_width) / 2, y: origin_y, width: text_field_width, height: text_field_height)
                origin_y += text_field_height + margin

                std_dev_low_label.sizeToFit()
                std_dev_low_label.frame.origin = CGPoint(x: margin, y: origin_y)
                std_dev_high_label.sizeToFit()
                std_dev_high_label.frame.origin = CGPoint(x: width - margin - std_dev_high_label.frame.width, y: origin_y)
                center_y = std_dev_low_label.center.y
                std_dev_slider.frame = CGRect(x: CGRectGetMaxX(std_dev_low_label.frame) + margin, y: center_y - std_dev_slider.frame.height / 2, width: CGRectGetMinX(std_dev_high_label.frame) - CGRectGetMaxX(std_dev_low_label.frame) - 2 * margin, height: std_dev_slider.frame.height)
                origin_y = max(CGRectGetMaxY(std_dev_low_label.frame), CGRectGetMaxY(std_dev_slider.frame)) + 0.4 * margin

                scroll_view.contentSize = CGSize(width: width, height: origin_y)
        }

        override func render() {
                remove_molecules_state = state.page_state as! RemoveMoleculesState

                missing_values_low_value_label.attributedText = astring_body(string: "0")
                missing_values_high_value_label.attributedText = astring_body(string: "\(state.number_of_samples)")

                std_dev_low_label.attributedText = astring_body(string: "0")
                std_dev_high_label.attributedText = decimal_astring(number: remove_molecules_state.highest_std_dev, fraction_digits: 2)

                render_after_change()
        }

        func render_after_change() {
                render_maximum_number_of_missing_values()
                render_minimum_std_dev()
                calculate_number_of_remaining_molecules()
                render_create_button()
                render_number_of_molecules_label()
        }

        func render_create_button() {
                if number_of_remaining_molecules == 0 {
                        create_data_set_button.enabled = false
                        create_data_set_button.setAttributedTitle(astring_body(string: "At least one molecule must remain"), forState: .Disabled)
                } else if number_of_remaining_molecules == state.number_of_molecules {
                        create_data_set_button.enabled = false
                        create_data_set_button.setAttributedTitle(astring_body(string: "At least one molecule must be removed"), forState: .Disabled)
                } else {
                        create_data_set_button.enabled = true
                }
        }

        func render_number_of_molecules_label() {
                let text = "Number of remaining molecules: \(number_of_remaining_molecules) of \(state.number_of_molecules)"
                number_of_molecules_label.attributedText = astring_body(string: text)
                number_of_molecules_label.textAlignment = .Center
        }

        func render_maximum_number_of_missing_values() {
                missing_values_field.text = "\(remove_molecules_state.maximum_missing_values)"
                if remove_molecules_state.maximum_missing_values != Int(round(Double(state.number_of_samples) * Double(missing_values_slider.value))) {
                        missing_values_slider.value = Float(remove_molecules_state.maximum_missing_values) / Float(state.number_of_samples)
                }
        }

        func render_minimum_std_dev() {
                let std_dev_string = decimal_string(number: remove_molecules_state.minimum_std_dev , fraction_digits: 2)
                if std_dev_field.text != std_dev_string {
                        std_dev_field.text = std_dev_string
                }

                let slider_value = remove_molecules_state.minimum_std_dev / remove_molecules_state.highest_std_dev
                if abs(slider_value - Double(std_dev_slider.value)) >= 0.001 {
                        std_dev_slider.value = Float(slider_value)
                }
        }

        func calculate_number_of_remaining_molecules() {
                number_of_remaining_molecules = 0
                for i in 0 ..< state.number_of_molecules {
                        if remove_molecules_state.missing_values_per_molecule[i] > remove_molecules_state.maximum_missing_values {
                                continue
                        }
                        let std_dev = remove_molecules_state.std_dev_per_molecule[i]
                        if std_dev >= remove_molecules_state.minimum_std_dev {
                                number_of_remaining_molecules++
                        }
                }
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }
        
        func textFieldDidEndEditing(textField: UITextField) {
                if textField == missing_values_field {
                        if let number = Int(missing_values_field.text ?? "") where number >= 0 && number <= state.number_of_samples {
                                remove_molecules_state.maximum_missing_values = number
                        } else {
                                remove_molecules_state.maximum_missing_values = state.number_of_samples
                        }
                } else {
                        if let number = string_to_double(string: std_dev_field.text ?? "") {
                                if number < 0 {
                                        remove_molecules_state.minimum_std_dev = 0
                                } else if number > remove_molecules_state.highest_std_dev {
                                        remove_molecules_state.minimum_std_dev = remove_molecules_state.highest_std_dev
                                } else {
                                        remove_molecules_state.minimum_std_dev = number
                                }
                        } else {
                                remove_molecules_state.minimum_std_dev = 0
                        }
                }
                render_after_change()
        }

        func missing_values_slider_action() {
                remove_molecules_state.maximum_missing_values = Int(round(Double(missing_values_slider.value) * Double(state.number_of_samples)))
                render_after_change()
        }

        func std_dev_slider_action() {
                remove_molecules_state.minimum_std_dev = Double(std_dev_slider.value) * remove_molecules_state.highest_std_dev
                render_after_change()
        }

        func create_data_set_action() {
                create_remove_molecules_data_set(maximum_missing_values: remove_molecules_state.maximum_missing_values, minimum_std_dev: remove_molecules_state.minimum_std_dev, missing_values_per_molecule: remove_molecules_state.missing_values_per_molecule, std_dev_per_molecule: remove_molecules_state.std_dev_per_molecule, number_of_remaining_molecules: number_of_remaining_molecules)
        }

        func tap_action(tap_gesture_recognizer: UITapGestureRecognizer) {
                missing_values_field.resignFirstResponder()
                std_dev_field.resignFirstResponder()
        }
}

func create_remove_molecules_data_set(maximum_missing_values maximum_missing_values: Int, minimum_std_dev: Double, missing_values_per_molecule: [Int], std_dev_per_molecule: [Double], number_of_remaining_molecules: Int) {

        state.render_type = RenderType.progress_indicator
        state.progress_indicator_info =  "The data set is created"
        state.progress_indicator_progress = 0
        state.render()

        let serial_queue = dispatch_queue_create("remove samples", DISPATCH_QUEUE_SERIAL)

        dispatch_async(serial_queue, {
                var new_molecule_indices = [Int](count: number_of_remaining_molecules, repeatedValue: 0)
                var new_values = [Double](count: number_of_remaining_molecules * state.number_of_samples, repeatedValue: 0)

                var counter = 0
                for i in 0 ..< state.number_of_molecules {
                        if missing_values_per_molecule[i] <= maximum_missing_values && std_dev_per_molecule[i] >= minimum_std_dev {
                                new_molecule_indices[counter] = state.molecule_indices[i]
                                let offset = i * state.number_of_samples
                                let new_offset = counter * state.number_of_samples
                                for j in 0 ..< state.number_of_samples {
                                        new_values[new_offset + j] = state.values[offset + j]
                                }
                                counter++
                        }
                        state.progress_indicator_step(total: state.number_of_molecules, index: i, min: 0, max: 90, step_size: 1_000)
                }

                let data_set_name = "Data set with removed molecules"

                let number_of_removed_molecules = state.number_of_molecules - number_of_remaining_molecules
                let remove_text = number_of_removed_molecules == 1 ? "one molecule" : "\(number_of_removed_molecules) molecules"
                let project_note_text = "Creation of data set \"\(data_set_name)\" by removal of \(remove_text)."

                dispatch_async(dispatch_get_main_queue(), {

                        let data_set_id = state.insert_data_set(data_set_name: data_set_name, project_id: state.project_id, values: new_values, sample_ids: state.sample_ids, molecule_indices: new_molecule_indices)
                        state.insert_project_note(project_note_text: project_note_text, project_note_type: "auto", project_note_user_name: state.get_user_name(), project_id: state.project_id)

                        let data_set_selection_state = DataSetSelectionState()
                        state.navigate(page_state: data_set_selection_state)
                        state.render_type = RenderType.full_page
                        state.set_active_data_set(data_set_id: data_set_id)
                        state.render()
                })
        })
}
