import UIKit

class LogarithmTransformState: PageState {

        var offset = 0 as Double

        override init() {
                super.init()
                name = "logarithm_transform"
                title = astring_body(string: "Logarithm transform")
                info = "The logarithm transform creates a new data set by taking the base 2 logarithm of each value shifted by an offset.\n\nValues that are not positive after adding the offset are set to missing values.\n\nChoose an offset of 0 if in doubt\nThe analysis in this app works best with log transformed data."
        }
}

class LogarithmTransform: Component, UITextFieldDelegate {

        var logarithm_transform_state: LogarithmTransformState!

        let scroll_view = UIScrollView()

        let explanation_text_view = UITextView()

        let offset_label = UILabel()
        let offset_text_field = UITextField()

        let number_of_present_label = UILabel()
        let number_of_missing_label = UILabel()

        let new_data_set_button = UIButton(type: .System)

        override func viewDidLoad() {
                super.viewDidLoad()

                let color = UIColor.blueColor()
                let text = astring_font_size_color(string: "new value = log", color: color)
                text.appendAttributedString(Astring(string: "2", attributes: [String(kCTSuperscriptAttributeName): -1, String(NSForegroundColorAttributeName): color]))
                text.appendAttributedString(astring_font_size_color(string: "(old value + offset)", color: color))
                explanation_text_view.attributedText = text
                explanation_text_view.editable = false
                scroll_view.addSubview(explanation_text_view)

                offset_label.attributedText = astring_body(string: "offset: ")
                offset_label.sizeToFit()
                scroll_view.addSubview(offset_label)

                offset_text_field.text = "0.0"
                offset_text_field.keyboardType = UIKeyboardType.NumbersAndPunctuation
                offset_text_field.textAlignment = NSTextAlignment.Center
                offset_text_field.borderStyle = UITextBorderStyle.Bezel
                offset_text_field.layer.masksToBounds = true
                offset_text_field.delegate = self
                scroll_view.addSubview(offset_text_field)

                number_of_present_label.textAlignment = .Center
                number_of_present_label.font = font_body
                scroll_view.addSubview(number_of_present_label)

                number_of_missing_label.textAlignment = .Center
                number_of_missing_label.font = font_body
                scroll_view.addSubview(number_of_missing_label)

                new_data_set_button.setAttributedTitle(astring_body(string: "Create new data set"), forState: .Normal)
                new_data_set_button.addTarget(self, action: "create_new_data_set_action", forControlEvents: .TouchUpInside)
                new_data_set_button.sizeToFit()
                scroll_view.addSubview(new_data_set_button)

                view.addSubview(scroll_view)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let side_margin = 20 as CGFloat

                var origin_y = 20 as CGFloat
                position_text_view(text_view: explanation_text_view, width: view.frame.width, side_margin: side_margin, origin_y: origin_y)

                let middle_margin = 40 as CGFloat
                origin_y = CGRectGetMaxY(explanation_text_view.frame) + 30
                offset_label.frame.size.height = 30
                offset_text_field.frame.size = CGSize(width: 150, height: 30)
                let offset_width = offset_label.frame.width + middle_margin + offset_text_field.frame.width
                var origin_x = (view.frame.width - offset_width) / 2
                offset_label.frame.origin = CGPoint(x: origin_x, y: origin_y)
                origin_x += offset_label.frame.width + middle_margin
                offset_text_field.frame.origin = CGPoint(x: origin_x, y: origin_y)

                origin_y = CGRectGetMaxY(offset_text_field.frame) + 40
                number_of_present_label.frame = CGRect(x: 0, y: origin_y, width: view.frame.width, height: 30)

                origin_y += 30
                number_of_missing_label.frame = CGRect(x: 0, y: origin_y, width: view.frame.width, height: 30)

                origin_y += 50
                new_data_set_button.frame = CGRect(x: (view.frame.width - new_data_set_button.frame.width) / 2, y: origin_y, width: new_data_set_button.frame.width, height: new_data_set_button.frame.height)

                scroll_view.frame = view.bounds
                scroll_view.contentSize = CGSize(width: view.frame.width, height: CGRectGetMaxY(new_data_set_button.frame))
        }

        override func render() {
                logarithm_transform_state = state.page_state as! LogarithmTransformState
                set_number_of_molecules(offset: logarithm_transform_state.offset)
        }

        func set_number_of_molecules(offset offset: Double) {
                logarithm_transform_state.offset = offset
                let positives = calculate_positive_values(values: state.values, offset: offset)
                let missing = state.values.count - positives
                number_of_present_label.text = "Present values after transform: \(positives)"
                number_of_missing_label.text = "Missing values after transform: \(missing)"
                offset_text_field.text = "\(logarithm_transform_state.offset)"
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
                for ch in string.characters {
                        switch ch {
                                case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "+", "-", "e", "E":
                                continue
                        default:
                                return false
                        }
                }
                return true
        }

        func textFieldDidEndEditing(textField: UITextField) {
                let text = textField.text ?? ""
                if let offset = string_to_double(string: text) {
                        set_number_of_molecules(offset: offset)
                } else {
                        set_number_of_molecules(offset: 0)
                }
        }

        func create_new_data_set_action() {
                let text = offset_text_field.text ?? ""
                if let offset = string_to_double(string: text) {
                        create_logarithm_transformed_data_set(offset: offset)
                } else {
                        offset_text_field.text = "0.0"
                }
        }

        func tap_action() {
                offset_text_field.resignFirstResponder()
        }
}

func create_logarithm_transformed_data_set(offset offset: Double) {

        state.render_type = RenderType.progress_indicator
        state.progress_indicator_progress = 0
        state.progress_indicator_info = "The transformed data set is created"
        state.render()

        let serial_queue = dispatch_queue_create("logarithmic transformation", DISPATCH_QUEUE_SERIAL)

        dispatch_async(serial_queue, {
                let transformed_values = log_transform(values: state.values, offset: offset)

                let data_set_name = "Data set log-transform"
                let project_note_text = "Creation of data set \"\(data_set_name)\" by log transformation with offset = \(offset)."

                dispatch_async(dispatch_get_main_queue(), {

                        let data_set_id = state.insert_data_set(data_set_name: data_set_name, project_id: state.project_id, values: transformed_values, sample_ids: state.sample_ids, molecule_indices: state.molecule_indices)
                        state.insert_project_note(project_note_text: project_note_text, project_note_type: "auto", project_note_user_name: state.get_user_name(), project_id: state.project_id)

                        let data_set_selection_state = DataSetSelectionState()
                        state.navigate(page_state: data_set_selection_state)
                        state.render_type = RenderType.full_page
                        state.set_active_data_set(data_set_id: data_set_id)
                        state.render()
                })
        })
}

func calculate_positive_values(values values: [Double], offset: Double) -> Int {
        var positives = 0
        for value in values {
                if !value.isNaN && value + offset > 0 {
                        positives++
                }
        }
        return positives
}

func log_transform(values values: [Double], offset: Double) -> [Double] {
        var transformed_values = [Double](count: values.count, repeatedValue: Double.NaN)

        for i in 0 ..< values.count {
                let value = values[i]

                if !value.isNaN {
                        let shifted_value = value + offset
                        if shifted_value > 0 {
                                transformed_values[i] = log2(shifted_value)
                        }
                }

                state.progress_indicator_step(total: values.count, index: i, min: 0, max: 90, step_size: 100_000)
        }

        return transformed_values
}

func position_text_view(text_view text_view: UITextView, width: CGFloat, side_margin: CGFloat, origin_y: CGFloat) {
        text_view.textAlignment = .Center
        let size = text_view.sizeThatFits(CGSize(width: width - 2 * side_margin, height: CGFloat(Double.infinity)))
        let actual_width = min(size.width, width)
        text_view.frame = CGRect(x: (width - actual_width) / 2, y: origin_y, width: actual_width, height: size.height)
}
