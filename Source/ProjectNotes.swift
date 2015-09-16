import UIKit

class ProjectNotesState: PageState {

        override init() {
                super.init()
                name = "project_notes"
                title = astring_body(string: "Project Notes")
                info = "Notes for the active project.\n\nAdd a note by tapping \"New note\".\n\nDelete a note by swiping to the left.\n\nNotes created automatically by the app are blue.\n\nNotes created by the user are green.\n\nEdit a user note by tapping it."
        }
}

class ProjectNotes: Component, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

        var should_reload_data = true

        let new_note_button = UIButton(type: .System)
        let table_view = UITableView()

        let done_button = UIButton(type: .System)
        let cancel_button = UIButton(type: .System)
        let text_view = UITextView()

        var (project_note_ids, project_note_dates, project_note_texts, project_note_types, project_note_user_names) = ([], [], [], [], []) as ([Int], [String], [String], [String], [String])

        var (project_note_edit_id, project_note_edit_text) = (nil, nil) as (Int?, String?)

        override func viewDidLoad() {
                super.viewDidLoad()

                new_note_button.setAttributedTitle(astring_body(string: "New note"), forState: .Normal)
                new_note_button.addTarget(self, action: "new_note_action", forControlEvents: .TouchUpInside)
                new_note_button.sizeToFit()
                view.addSubview(new_note_button)

                table_view.registerClass(ProjectNotesTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.allowsSelection = false
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = UITableViewCellSeparatorStyle.None
                table_view.dataSource = self
                table_view.delegate = self
                view.addSubview(table_view)

                done_button.setAttributedTitle(astring_body(string: "Done"), forState: .Normal)
                done_button.addTarget(self, action: "done_action", forControlEvents: .TouchUpInside)
                done_button.sizeToFit()
                view.addSubview(done_button)

                cancel_button.setAttributedTitle(astring_body(string: "Cancel"), forState: .Normal)
                cancel_button.addTarget(self, action: "cancel_action", forControlEvents: .TouchUpInside)
                cancel_button.sizeToFit()
                view.addSubview(cancel_button)

                text_view.autocorrectionType = UITextAutocorrectionType.No
                text_view.autocapitalizationType = UITextAutocapitalizationType.Sentences
                text_view.font = font_body
                text_view.layer.borderWidth = 1.0
                text_view.layer.borderColor = UIColor.blueColor().CGColor
                text_view.layer.cornerRadius = 5.0
                text_view.delegate = self
                view.addSubview(text_view)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                tap_recognizer.numberOfTapsRequired = 1
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                layout_notes()
                layout_new_note()
        }

        override func render() {
                (project_note_ids, project_note_dates, project_note_texts, project_note_types, project_note_user_names) = state.get_project_notes(project_id: state.project_id)

                let editing = project_note_edit_text != nil

                new_note_button.hidden = editing
                table_view.hidden = editing
                done_button.hidden = !editing
                cancel_button.hidden = !editing
                text_view.hidden = !editing

                if let edit_text = project_note_edit_text {
                        text_view.text = edit_text
                }

                if should_reload_data {
                        table_view.reloadData()
                }
                should_reload_data = true
        }

        func layout_notes() {
                let middle_margin = 20 as CGFloat
                var top_margin = 20 as CGFloat

                new_note_button.frame.origin = CGPoint(x: (view.frame.width - new_note_button.frame.width) / 2, y: top_margin)

                top_margin = CGRectGetMaxY(new_note_button.frame) + middle_margin
                table_view.frame = CGRect(x: 0, y: top_margin, width: view.frame.width, height: view.frame.height - top_margin)
        }

        func layout_new_note() {
                let side_margin = 20 as CGFloat
                let middle_margin = 20 as CGFloat
                var top_margin = 20 as CGFloat

                cancel_button.frame.origin = CGPoint(x: side_margin, y: top_margin)
                done_button.frame.origin = CGPoint(x: view.frame.width - side_margin - done_button.frame.width, y: top_margin)

                top_margin = max(CGRectGetMaxY(cancel_button.frame), CGRectGetMaxY(done_button.frame)) + middle_margin

                let width_text_view = min(350 as CGFloat, view.frame.width)
                text_view.frame = CGRect(x: (view.frame.width - width_text_view) / 2, y: top_margin, width: width_text_view, height: view.frame.height - top_margin - middle_margin)
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return project_note_ids.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                let project_note_date = project_note_dates[indexPath.row]
                let project_note_text = project_note_texts[indexPath.row]
                let project_note_user_name = project_note_user_names[indexPath.row]
                let width = view.frame.width

                let height = height_of_project_note_table_view_cell(width: width, project_note_date: project_note_date, project_note_user_name: project_note_user_name, project_note_text: project_note_text)

                return height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ProjectNotesTableViewCell

                let project_note_date = project_note_dates[indexPath.row]
                let project_note_text = project_note_texts[indexPath.row]
                let project_note_type = project_note_types[indexPath.row]
                let project_note_user_name = project_note_user_names[indexPath.row]

                let tap_handler = project_note_type == "user" ? { [unowned self] in self.edit_action(row: indexPath.row) } : nil as (() -> ())?

                cell.update(project_note_date: project_note_date, project_note_type: project_note_type, project_note_user_name: project_note_user_name, project_note_text: project_note_text, tap_handler: tap_handler)

                return cell
        }

        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                if editingStyle == .Delete {
                        let project_note_id = project_note_ids[indexPath.row]
                        state.delete_project_note(project_note_id: project_note_id)
                        should_reload_data = false
                        state.render()
                        table_view.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
        }

        func edit_action(row row: Int) {
                project_note_edit_id = project_note_ids[row]
                project_note_edit_text = project_note_texts[row]
                state.render()
        }

        func new_note_action() {
                project_note_edit_text = ""
                state.render()
        }

        func done_action() {
                text_view.resignFirstResponder()
                let text = text_view.text
                if text != "" {
                        if let project_note_edit_id = project_note_edit_id {
                                state.update_project_note(project_note_id: project_note_edit_id, project_note_text: text)
                        } else {
                                state.insert_project_note(project_note_text: text, project_note_type: "user", project_note_user_name: state.get_user_name(), project_id: state.project_id)
                        }
                }
                (project_note_edit_id, project_note_edit_text) = (nil, nil)
                state.render()
        }

        func cancel_action() {
                text_view.resignFirstResponder()
                (project_note_edit_id, project_note_edit_text) = (nil, nil)
                state.render()
        }

        func tap_action() {
                text_view.resignFirstResponder()
        }
}

class ProjectNotesTableViewCell: UITableViewCell {

        let color_user = UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 1.0)
        let color_auto = UIColor(red: 0.9, green: 0.98, blue: 1, alpha: 1.0)

        let inset_view = UIView()

        let user_name_label = UILabel()
        let date_label = UILabel()
        let text_view = UITextView()

        var tap_handler: (() -> ())?

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                inset_view.layer.cornerRadius = 20
                inset_view.clipsToBounds = true

                user_name_label.textAlignment = .Center
                user_name_label.font = font_body

                date_label.textAlignment = .Center
                date_label.font = font_footnote
                date_label.textColor = UIColor.lightGrayColor()

                text_view.font = font_body
                text_view.editable = false
                text_view.backgroundColor = inset_view.backgroundColor
                text_view.editable = false

                contentView.addSubview(inset_view)
                inset_view.addSubview(user_name_label)
                inset_view.addSubview(date_label)
                inset_view.addSubview(text_view)

                addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tap_action"))
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                inset_view.frame = CGRectInset(contentView.bounds, 10, 5)

                var top_margin = 5 as CGFloat
                let middle_margin = 10 as CGFloat

                user_name_label.frame.origin = CGPoint(x: max((inset_view.frame.width - user_name_label.frame.width) / 2, 0), y: top_margin)

                top_margin = CGRectGetMaxY(user_name_label.frame) + middle_margin

                date_label.frame.origin = CGPoint(x: (inset_view.frame.width - date_label.frame.width) / 2, y: top_margin)

                top_margin = CGRectGetMaxY(date_label.frame) + middle_margin

                let width_text_view = min(350 as CGFloat, inset_view.frame.width)
                let height_text_view = height_of_text_view(text: text_view.text, width: width_text_view)

                text_view.frame = CGRect(x: (inset_view.frame.width - width_text_view) / 2, y: top_margin, width: width_text_view, height: height_text_view)
        }

        func update(project_note_date project_note_date: String, project_note_type: String, project_note_user_name: String, project_note_text: String, tap_handler: (() -> ())?) {
                inset_view.backgroundColor = project_note_type == "user" ? color_user : color_auto

                user_name_label.text = project_note_user_name
                user_name_label.sizeToFit()

                date_label.text = date_formatted_string(timestamp: project_note_date)
                date_label.sizeToFit()

                text_view.text = project_note_text

                self.tap_handler = tap_handler
        }

        func tap_action() {
                tap_handler?()
        }
}

func height_of_text_view(text text: String, width: CGFloat) -> CGFloat {
        let text_view = UITextView()
        text_view.font = font_body
        text_view.text = text
        let size = text_view.sizeThatFits(CGSize(width: width, height: CGFloat(Double.infinity)))
        return size.height
}

func height_of_project_note_table_view_cell(width width: CGFloat, project_note_date: String, project_note_user_name: String, project_note_text: String) -> CGFloat {
        let inset_view_width = width - 20
        
        let user_name_label = UILabel()
        user_name_label.font = font_body
        user_name_label.text = project_note_user_name
        user_name_label.sizeToFit()
        let user_name_height = user_name_label.frame.height
        
        let date_label = UILabel()
        date_label.font = font_footnote
        date_label.text = date_formatted_string(timestamp: project_note_date)
        date_label.sizeToFit()
        let date_height = date_label.frame.height
        
        let text_view_width = min(350 as CGFloat, inset_view_width)
        let text_view_height = height_of_text_view(text: project_note_text, width: text_view_width)
        
        let height = 5 + 5 + user_name_height + 10 + date_height + 10 + text_view_height + 5 + 5 + 10
        
        return height
}
