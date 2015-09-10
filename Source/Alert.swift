import UIKit

func alert(title title: String, message: String, view_controller: UIViewController) {
        let alert_controller = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)

        let ok_action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert_controller.addAction(ok_action)

        view_controller.presentViewController(alert_controller, animated: true, completion: nil)
}

func alert_confirm(title title: String, message: String, view_controller: UIViewController, ok_callback: () -> (), cancel_callback: (() -> ())? = nil) {
        let alert_controller = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)

        let cancel_action = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (alert_action: UIAlertAction!) -> Void in
                cancel_callback?()
        })
        alert_controller.addAction(cancel_action)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alert_action: UIAlertAction!) -> Void in
                ok_callback()
        })
        alert_controller.addAction(okAction)

        view_controller.presentViewController(alert_controller, animated: true, completion: nil)
}

func alert_text_field(title title: String, message: String, view_controller: UIViewController, placeholder: String, callback: (String -> Void)) {
        let alert_controller = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)

        let cancel_action = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert_controller.addAction(cancel_action)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alert_action: UIAlertAction!) -> Void in
                let textField = alert_controller.textFields![0] as UITextField
                let text = textField.text ?? ""
                callback(text)
        })
        alert_controller.addAction(okAction)

        alert_controller.addTextFieldWithConfigurationHandler { (text_field: UITextField!) -> Void in
                text_field.placeholder = placeholder
        }

        view_controller.presentViewController(alert_controller, animated: true, completion: nil)
}
