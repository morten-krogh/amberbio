import UIKit
import MessageUI

class FeedbackState: PageState {

        override init() {
                super.init()
                name = "feedback"
                title = astring_body(string: "Feedback")
                info = "Feedback and support"
        }
}

class Feedback: Component, MFMailComposeViewControllerDelegate {

        let info_label1 = UILabel()
        let info_label2 = UILabel()
        let info_label3 = UILabel()

        let email_button = UIButton(type: .System)
        let web_button = UIButton(type: .System)

        override func viewDidLoad() {
                super.viewDidLoad()

                let astring = astring_body(string: "Please give us feedback\nor\nask for support")
                let paragraph_style = NSMutableParagraphStyle()
                paragraph_style.lineSpacing = 10 as CGFloat
                astring.addAttribute(NSParagraphStyleAttributeName, value: paragraph_style, range: NSMakeRange(0, astring.length))
                info_label1.attributedText = astring
                info_label1.textAlignment = .Center
                info_label1.numberOfLines = 3
                view.addSubview(info_label1)

                info_label2.attributedText = astring_body(string: "Email:")
                info_label2.textAlignment = .Center
                view.addSubview(info_label2)

                info_label3.attributedText = astring_body(string: "Web page:")
                info_label3.textAlignment = .Center
                view.addSubview(info_label3)

                email_button.setAttributedTitle(astring_body(string: "info@amberbio.com"), forState: .Normal)
                email_button.addTarget(self, action: "email_action", forControlEvents: .TouchUpInside)
                email_button.sizeToFit()
                view.addSubview(email_button)

                web_button.setAttributedTitle(astring_body(string: "www.amberbio.com"), forState: .Normal)
                web_button.addTarget(self, action: "web_action", forControlEvents: .TouchUpInside)
                web_button.sizeToFit()
                view.addSubview(web_button)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                var origin_y = 20 as CGFloat

                info_label1.sizeToFit()
                info_label1.center = CGPoint(x: width / 2, y: origin_y + info_label1.frame.height / 2)
                origin_y += info_label1.frame.height + 30

                info_label2.sizeToFit()
                info_label2.center = CGPoint(x: width / 2, y: origin_y + info_label2.frame.height)
                origin_y += info_label2.frame.height + 15

                email_button.sizeToFit()
                email_button.frame.origin = CGPoint(x: (width - email_button.frame.width) / 2, y: origin_y)
                origin_y += email_button.frame.height + 20

                info_label3.sizeToFit()
                info_label3.center = CGPoint(x: width / 2, y: origin_y + info_label3.frame.height)
                origin_y += info_label3.frame.height + 15

                web_button.sizeToFit()
                web_button.frame.origin = CGPoint(x: (width - web_button.frame.width) / 2, y: origin_y)
        }

        func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
                controller.dismissViewControllerAnimated(true, completion: nil)
        }

        func email_action() {
                let subject = "Feedback for the Amberbio app"
                let emails = ["info@amberbio.com"]
                send_email(subject: subject, body: "", emails: emails, view_controller: self, mail_compose_delegate: self)
        }

        func web_action() {
                if let url = NSURL(string: "http://www.amberbio.com") {
                        UIApplication.sharedApplication().openURL(url)
                }
        }
}
