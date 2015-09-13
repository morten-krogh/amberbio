import UIKit

let document_interaction_open = DocumentInteractionOpen()

class DocumentInteractionOpen: NSObject, UIDocumentInteractionControllerDelegate {

        var temp_url: NSURL?
        var interaction_controller: UIDocumentInteractionController?

        func open_result_file(file_name file_name: String, file_content: NSData, inRect: CGRect, inView: UIView) {
                temp_url = file_create_temp_file_url(file_name: file_name, content: file_content)
                if let temp_url = temp_url {
                        interaction_controller = UIDocumentInteractionController(URL: temp_url)
                        interaction_controller?.delegate = self
                        interaction_controller?.presentOpenInMenuFromRect(inRect, inView: inView, animated: true)
                }
        }

        func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
                clean_up()
        }

        func clean_up() {
                if let temp_url = temp_url {
                        file_remove(url: temp_url)
                }
                temp_url = nil
                interaction_controller = nil
        }
}
