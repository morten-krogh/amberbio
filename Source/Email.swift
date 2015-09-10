import UIKit
import MessageUI

let extension_to_mimetype = [
        "pdf": "application/pdf",
        "png": "image/png",
        "csv": "text/csv",
        "txt": "text/plain",
        "sqlite": "application/octet-stream"
]

func validate_email(address address: String) -> Bool {
        let email_regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
        let range = address.rangeOfString(email_regex, options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil)
        return range != nil
}

func file_extension(file_name file_name: String) -> String? {
        let regex = "\\.[A-Za-z]+$"
        if let range = file_name.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) {
                return file_name.substringWithRange(Range<String.Index>(start: range.startIndex.advancedBy(1), end: range.endIndex))
        } else {
                return nil
        }
}

func mime_type_of_file(file_name file_name: String) -> String? {
        if let ext = file_extension(file_name: file_name) {
                return extension_to_mimetype[ext]
        } else {
                return nil
        }
}

func send_email(subject subject: String, body: String, emails: [String], view_controller: UIViewController, mail_compose_delegate: MFMailComposeViewControllerDelegate) {
        if MFMailComposeViewController.canSendMail() {
                let mail_composer = MFMailComposeViewController()
                mail_composer.mailComposeDelegate = mail_compose_delegate

                mail_composer.setSubject(subject)
                mail_composer.setMessageBody(body, isHTML: false)
                mail_composer.setToRecipients(emails)

                view_controller.presentViewController(mail_composer, animated: true, completion: nil)
        } else {
                alert(title: "The mail client is not set up", message: "Configure the mail client with your mail account and try again", view_controller: view_controller)
        }
}

func send_email(file_name file_name: String, file_data: NSData, emails: [String], view_controller: UIViewController, mail_compose_delegate: MFMailComposeViewControllerDelegate) {
        if MFMailComposeViewController.canSendMail() {
                if let mime_type = mime_type_of_file(file_name: file_name) {
                        let mail_composer = MFMailComposeViewController()
                        mail_composer.mailComposeDelegate = mail_compose_delegate
                        let subject = "\(file_name) from Amberbio app"
                        let body = "Dear\n\nThe file \(file_name) is attached\n"

                        mail_composer.setSubject(subject)
                        mail_composer.setMessageBody(body, isHTML: false)
                        mail_composer.addAttachmentData(file_data, mimeType: mime_type, fileName: file_name)
                        mail_composer.setToRecipients(emails)

                        view_controller.presentViewController(mail_composer, animated: true, completion: nil)
                }
        } else {
                alert(title: "The mail client is not set up", message: "Configure the mail client with your mail account and try again", view_controller: view_controller)
        }
}
