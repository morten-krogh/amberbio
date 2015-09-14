import UIKit

class EditFactorState: PageState {

        var factor_id: Int?

        init(factor_id: Int?) {
                super.init()
                name = "edit_factor"
                title = astring_body(string: "Edit the factor")
                info = "Tap the factor name to edit.\n\nTap a level name to edit.\n\nTap the squares with green circles to change the level of a sample.\n\nAll samples in the project are included."
                self.factor_id = factor_id
        }
}

class EditFactor: Component, UITextFieldDelegate, SingleChoiceTableDelegate {

        var factor_id: Int?
        var factor_name = ""
        var current_factor_name: String?

        var sample_id_to_level_id = [:] as [Int: Int]

        var temp_level_ids = [] as [Int]

        var temp_level_id_counter = 0
        var temp_level_id_to_level_id = [:] as [Int: Int]
        var level_id_to_temp_level_id = [:] as [Int: Int]

        var temp_level_id_to_name = [:] as [Int: String]
        var sample_id_to_temp_level_id = [:] as [Int: Int]

        let cancel_button = UIButton(type: .System)
        let done_button = UIButton(type: .System)

        let factor_name_text_field = UITextField()
        let add_level_button = UIButton(type: UIButtonType.System)
        let message_label = UILabel()
        let edit_level_text_field = UITextField()
        let delete_level_button = UIButton(type: .System)
        let single_choice_table = SingleChoiceTable(frame: CGRect.zero)

        var edit_level_index: Int?

        override func viewDidLoad() {
                super.viewDidLoad()

                cancel_button.setAttributedTitle(astring_body(string: "Cancel"), forState: .Normal)
                cancel_button.addTarget(self, action: "cancel_action:", forControlEvents: .TouchUpInside)
                view.addSubview(cancel_button)

                done_button.setAttributedTitle(astring_body(string: "Done"), forState: .Normal)
                done_button.addTarget(self, action: "done_action:", forControlEvents: .TouchUpInside)
                view.addSubview(done_button)

                factor_name_text_field.textAlignment = .Center
                factor_name_text_field.delegate = self
                view.addSubview(factor_name_text_field)

                add_level_button.setAttributedTitle(astring_body(string: "Add level"), forState: .Normal)
                add_level_button.addTarget(self, action: "add_level_action:", forControlEvents: .TouchUpInside)
                view.addSubview(add_level_button)

                message_label.text = "Tap a level to edit"
                view.addSubview(message_label)

                edit_level_text_field.textAlignment = .Center
                edit_level_text_field.delegate = self
                edit_level_text_field.addTarget(self, action: "edit_level_text_field_did_change:", forControlEvents: UIControlEvents.EditingChanged)
                view.addSubview(edit_level_text_field)

                delete_level_button.setAttributedTitle(astring_body(string: "Delete Level"), forState: .Normal)
                delete_level_button.addTarget(self, action: "delete_level_action:", forControlEvents: .TouchUpInside)
                view.addSubview(delete_level_button)

                single_choice_table.delegate = self
                view.addSubview(single_choice_table)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let top_margin = 20 as CGFloat
                let margin = 20 as CGFloat

                var origin_y = top_margin

                cancel_button.sizeToFit()
                cancel_button.frame.origin = CGPoint(x: margin, y: origin_y)

                done_button.sizeToFit()
                done_button.frame.origin = CGPoint(x: width - margin - done_button.frame.width, y: origin_y)

                let factorNameHeight = 30 as CGFloat
                factor_name_text_field.frame = CGRect(x: cancel_button.frame.width + 2.0 * margin, y: origin_y, width: width - cancel_button.frame.width - done_button.frame.width - 4.0 * margin, height: factorNameHeight)
                origin_y += factorNameHeight + margin
                let levelHeight = 30 as CGFloat
                add_level_button.sizeToFit()
                add_level_button.frame = CGRect(x: margin, y: origin_y, width: add_level_button.frame.width, height: levelHeight)

                message_label.sizeToFit()
                let message_label_origin_x = (width - margin - add_level_button.frame.width - message_label.frame.width) / 2.0 + margin + add_level_button.frame.width
                message_label.frame = CGRect(x: message_label_origin_x, y: origin_y, width: message_label.frame.width, height: levelHeight)

                delete_level_button.sizeToFit()
                let delete_level_button_origin_x = width - margin - delete_level_button.frame.width
                delete_level_button.frame = CGRect(x: delete_level_button_origin_x, y: origin_y, width: delete_level_button.frame.width, height: levelHeight)

                let edit_level_text_field_origin_x = add_level_button.frame.width + 2 * margin
                let edit_level_text_fieldWidth = width - delete_level_button.frame.width - 2 * margin - edit_level_text_field_origin_x
                edit_level_text_field.frame = CGRect(x: edit_level_text_field_origin_x, y: origin_y, width: edit_level_text_fieldWidth, height: levelHeight)

                origin_y += levelHeight + 2 * margin
                single_choice_table.frame = CGRect(x: 0, y: origin_y, width: width, height: view.frame.height - origin_y)
        }

        override func render() {
                factor_id = (state.page_state as! EditFactorState).factor_id

                if let factor_id = factor_id {
                        if let factor_index = state.factor_ids.indexOf(factor_id) {
                                current_factor_name = state.factor_names[factor_index]
                                self.factor_id = factor_id
                                self.factor_name = state.factor_names[factor_index]

                                let level_ids = state.level_ids_by_factor[factor_index]
                                let level_names = state.level_names_by_factor[factor_index]

                                temp_level_ids = []
                                temp_level_id_to_level_id = [:]
                                level_id_to_temp_level_id = [:]
                                temp_level_id_to_name = [:]

                                for i in 0 ..< level_ids.count {
                                        temp_level_ids.append(i)
                                        temp_level_id_to_level_id[i] = level_ids[i]
                                        level_id_to_temp_level_id[level_ids[i]] = i
                                        temp_level_id_to_name[i] = level_names[i]
                                }
                                temp_level_id_counter = level_ids.count

                                let sample_level_ids = state.level_ids_by_factor_and_sample[factor_index]

                                sample_id_to_level_id = [:]
                                sample_id_to_temp_level_id = [:]

                                for i in 0 ..< state.sample_ids.count {
                                        sample_id_to_level_id[state.sample_ids[i]] = sample_level_ids[i]
                                        sample_id_to_temp_level_id[state.sample_ids[i]] = level_id_to_temp_level_id[sample_level_ids[i]]!
                                }

                                render_common()
                        } else {
                                let edit_factors_state = EditFactorsState()
                                state.set_page_state(page_state: edit_factors_state)
                                state.render()
                        }
                } else {
                        self.factor_id = nil
                        self.factor_name = "Factor ??"
                        current_factor_name = nil

                        temp_level_ids = [0]
                        temp_level_id_counter = 1
                        temp_level_id_to_level_id = [:]
                        temp_level_id_to_name[0] = "Level ??"
                        for sample_id in state.sample_ids {
                                sample_id_to_temp_level_id[sample_id] = 0
                        }
                        sample_id_to_level_id = [:]

                        render_common()
                }
        }

        func render_common() {
                factor_name_text_field.text = factor_name
                show_level_message()
                update_single_choice_table()
        }

        func update_single_choice_table() {
                single_choice_table.rowNames = state.sample_names
                single_choice_table.colNames = temp_level_ids.map { self.temp_level_id_to_name[$0]! }
                single_choice_table.choices = state.sample_ids.map { sample_id in
                        let temp_level_id = self.sample_id_to_temp_level_id[sample_id]!
                        return self.temp_level_ids.indexOf(temp_level_id)!
                }
        }

        func show_level_message() {
                edit_level_index = nil
                message_label.hidden = false
                edit_level_text_field.hidden = true
                delete_level_button.hidden = true
        }

        func single_choice_table(single_choice_table: SingleChoiceTable, didSelectColNameWithIndex level_index: Int) {
                edit_level_index = level_index
                message_label.hidden = true
                edit_level_text_field.text = temp_level_id_to_name[temp_level_ids[level_index]]!
                edit_level_text_field.hidden = false
                edit_level_text_field.becomeFirstResponder()
                delete_level_button.hidden = !empty_level(index: level_index)
        }

        func single_choice_table(single_choice_table: SingleChoiceTable, didSelectCellWithRowIndex: Int, andColIndex: Int) {
                sample_id_to_temp_level_id[state.sample_ids[didSelectCellWithRowIndex]] = temp_level_ids[andColIndex]
                tap_action()
                show_level_message()
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textFieldDidEndEditing(textField: UITextField) {
                if textField == factor_name_text_field {
                        if (textField.text ?? "").isEmpty {
                                textField.text = "Factor??"
                        }
                        factor_name = textField.text ?? ""
                } else if textField == edit_level_text_field && edit_level_index != nil {
                        let text = (textField.text ?? "").isEmpty ? "Level??" : (textField.text ?? "")
                        temp_level_id_to_name[temp_level_ids[edit_level_index!]] = text
                        single_choice_table.colNames[edit_level_index!] = text
                        show_level_message()
                }
        }

        func edit_level_text_field_did_change(textField: UITextField) {
                let text = textField.text ?? ""
                temp_level_id_to_name[temp_level_ids[edit_level_index!]] = text
                single_choice_table.colNames[edit_level_index!] = text
        }

        func delete_level_action(sender: UIButton) {
                temp_level_ids.removeAtIndex(edit_level_index!)
                edit_level_index = nil
                edit_level_text_field.resignFirstResponder()
                show_level_message()
                update_single_choice_table()
        }

        func add_level_action(sender: UIButton) {
                temp_level_ids.append(temp_level_id_counter)
                temp_level_id_to_name[temp_level_id_counter] = "Level ??"
                temp_level_id_counter++
                update_single_choice_table()
        }

        func cancel_action(sender: UIBarButtonItem) {
                factor_name_text_field.resignFirstResponder()
                edit_level_text_field.resignFirstResponder()
                let edit_factors_state = EditFactorsState()
                state.set_page_state(page_state: edit_factors_state)
                state.render()
        }

        func done_action(sender: UIBarButtonItem) {
                factor_name_text_field.resignFirstResponder()
                edit_level_text_field.resignFirstResponder()

                if let (title, message) = done() {
                        alert(title: title, message: message, view_controller: self)
                } else {
                        let edit_factors_state = EditFactorsState()
                        state.set_page_state(page_state: edit_factors_state)
                        state.render()
                }
        }

        func empty_level(index index: Int) -> Bool {
                let temp_level_id = temp_level_ids[index]
                for (_, value) in sample_id_to_temp_level_id {
                        if value == temp_level_id {
                                return false
                        }
                }
                return true
        }

        func error_from_single_factor() -> (title: String, message: String)? {
                if factor_name.isEmpty {
                        return ("Empty factor name", "Factor names can not be empty")
                }

                if factor_name == "Sample Name" {
                        return ("Invalid factor name", "A factor name can not be \"Sample Name\"")
                }

                if !state.factor_names.filter({ $0 == self.factor_name }).isEmpty && current_factor_name != factor_name {
                        return ("Duplicate factor name", "\(factor_name) already exists")
                }

                if let duplicate = find_duplicate_element(array: [String](temp_level_id_to_name.values)) {
                        return ("Duplicate levels", "The level \"\(duplicate)\" is a duplicate")
                }

                return nil
        }

        func prune_levels() {
                let temp_level_id_set = Set<Int>(sample_id_to_temp_level_id.values)
                let excluded_temp_level_id_set = Set<Int>(temp_level_id_to_name.keys).subtract(temp_level_id_set)
                for temp_level_id in excluded_temp_level_id_set {
                        temp_level_id_to_name[temp_level_id] = nil
                        temp_level_id_to_level_id[temp_level_id] = nil

                }
        }

        func done() -> (title: String, message: String)? {
                if let error = error_from_single_factor() {
                        return error
                }

                prune_levels()

                if let factor_id = factor_id {
                        state.update_factor(factor_id: factor_id, factor_name: factor_name, temp_level_id_to_name: temp_level_id_to_name, temp_level_id_to_level_id: temp_level_id_to_level_id, sample_id_to_temp_level_id: sample_id_to_temp_level_id)
                } else {
                        state.insert_factor(factor_name: factor_name, temp_level_id_to_name: temp_level_id_to_name, sample_id_to_temp_level_id: sample_id_to_temp_level_id)
                }

                return nil
        }

        func tap_action() {
                factor_name_text_field.resignFirstResponder()
                edit_level_text_field.resignFirstResponder()
        }
}
