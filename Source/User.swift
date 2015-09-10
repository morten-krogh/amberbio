import UIKit

class UserState: PageState {

        override init() {
                super.init()
                name = "user"
                title = astring_body(string: "User")
                info = "The user name is optional and is only used as a tag for the results of the analysis. The user name is most useful in the collaborative projects.\n\nThe emails are also optional and are used as suggested emails when a result file is mailed from the app."
        }
}

class User: Component, UITextFieldDelegate, UITextViewDelegate {

        let scroll_view = UIScrollView()
        let user_name_label = UILabel()
        let user_name_field = UITextField()
        let user_name_info = UITextView()

        let email_label = UILabel()
        let email_fields = UITextView()
        let email_info = UITextView()

        override func loadView() {
                view = scroll_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                view.backgroundColor = UIColor.whiteColor()

                user_name_label.text = "User name"
                user_name_label.font = font_headline
                user_name_label.textAlignment = NSTextAlignment.Center

                user_name_field.clearButtonMode = UITextFieldViewMode.WhileEditing
                user_name_field.font = font_body
                user_name_field.autocorrectionType = UITextAutocorrectionType.No
                user_name_field.textAlignment = NSTextAlignment.Center
                user_name_field.borderStyle = UITextBorderStyle.Bezel
                user_name_field.layer.masksToBounds = true
                user_name_field.delegate = self

                user_name_info.text = "The user name is optional and is only used to facilitate collaboration by marking your result files with your name."
                user_name_info.clipsToBounds = true
                user_name_info.textAlignment = NSTextAlignment.Left
                user_name_info.editable = false
                user_name_info.font = font_footnote

                email_label.text = "Email adresses"
                email_label.font = font_body
                email_label.textAlignment = NSTextAlignment.Center

                email_fields.keyboardType = UIKeyboardType.EmailAddress
                email_fields.autocorrectionType = UITextAutocorrectionType.No
                email_fields.autocapitalizationType = UITextAutocapitalizationType.None
                email_fields.textAlignment = NSTextAlignment.Center
                email_fields.font = font_body
                email_fields.layer.borderWidth = 1.0
                email_fields.layer.borderColor = UIColor.blueColor().CGColor
                email_fields.layer.cornerRadius = 5.0
                email_fields.delegate = self

                email_info.text = "The email adresses are optional and are used as suggested email addresses when a result file is sent by email. Each email address must be on its own line."

                email_info.clipsToBounds = true
                email_info.textAlignment = NSTextAlignment.Left
                email_info.editable = false
                email_info.font = font_footnote

                scroll_view.addSubview(user_name_label)
                scroll_view.addSubview(user_name_field)
                scroll_view.addSubview(user_name_info)

                scroll_view.addSubview(email_label)
                scroll_view.addSubview(email_fields)
                scroll_view.addSubview(email_info)

                let tap_action: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap_action:")
                tap_action.numberOfTapsRequired = 1
                scroll_view.addGestureRecognizer(tap_action)
                
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = scroll_view.frame.width
                let margin = 20.0 as CGFloat
                var yPosition = margin

                user_name_label.sizeToFit()
                user_name_label.frame = CGRect(x: 0.0, y: yPosition, width: width, height: user_name_label.frame.height + margin)
                yPosition += user_name_label.frame.height + margin

                user_name_field.sizeToFit()
                user_name_field.frame = CGRect(x: margin, y: yPosition, width: width - 2.0 * margin, height: user_name_field.frame.height + margin)
                yPosition += user_name_field.frame.height + margin

                user_name_info.sizeToFit()
                user_name_info.frame = CGRect(x: margin, y: yPosition, width: width - 2.0 * margin, height: user_name_info.contentSize.height)
                yPosition += user_name_info.frame.height + 2.0 * margin

                email_label.sizeToFit()
                email_label.frame = CGRect(x: 0.0, y: yPosition, width: width, height: email_label.frame.height)
                yPosition += email_label.frame.height + margin

                email_fields.frame = CGRect(x: margin, y: yPosition, width: width - 2.0 * margin, height: 10.0 * email_fields.font!.lineHeight)
                yPosition += email_fields.frame.height + margin

                email_info.sizeToFit()
                email_info.frame = CGRect(x: margin, y: yPosition, width: width - 2.0 * margin, height: email_info.frame.height)

                scroll_view.contentSize = CGSize(width: width, height: CGRectGetMaxY(email_info.frame))
        }

        override func render() {
                user_name_field.text = state.get_user_name()
                update_email_fields(emails: state.get_emails())
        }

        func textFieldDidEndEditing(textField: UITextField) {
                let text = trim(string: textField.text ?? "")
                let new_user_name = text.isEmpty ? "No user name" : text
                state.set_user_name(user_name: new_user_name)
                user_name_field.text = new_user_name
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
                for ch in string.characters {
                        if ch == "\r" || ch == "\n" || ch == "\t" {
                                return false
                        }
                }
                return true
        }

        func update_email_fields(emails emails: [String]) {
                email_fields.attributedText = make_email_text(emails: emails)
                email_fields.textAlignment = NSTextAlignment.Center
        }

        func textViewDidEndEditing(textView: UITextView) {
                var emails = [] as [String]
                var strings = [] as [String]
                for line in textView.text.componentsSeparatedByString("\n") {
                        let trimmed_line = trim(string: line)
                        if trimmed_line.isEmpty {
                                continue
                        }
                        if validate_email(address: trimmed_line) {
                                emails.append(trimmed_line)
                        }
                        strings.append(trimmed_line)
                }

                state.set_emails(emails: emails)
                update_email_fields(emails: strings)
        }

        func tap_action(recognizer: UITapGestureRecognizer) {
                user_name_field.resignFirstResponder()
                email_fields.resignFirstResponder()
        }
}

func make_email_text(emails emails: [String]) -> Astring {
        let attributes_valid = attributes_body
        let attributes_invalid = [NSFontAttributeName: font_body, NSForegroundColorAttributeName: UIColor.redColor()]

        let attributed_text = Astring()
        for string in emails {
                if validate_email(address: string) {
                        attributed_text.appendAttributedString(Astring(string: string + "\n", attributes: attributes_valid))
                } else {
                        attributed_text.appendAttributedString(Astring(string: string + "\n", attributes: attributes_invalid))
                }
        }

        return attributed_text
}
