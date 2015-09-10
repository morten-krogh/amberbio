import UIKit

let documentInteractionOpen = DocumentInteractionOpen()

class DocumentInteractionOpen: NSObject, UIDocumentInteractionControllerDelegate {

        var temp_url: NSURL?
        var interaction_controller: UIDocumentInteractionController?

        func openResultFile(fileName fileName: String, fileData: NSData, inRect: CGRect, inView: UIView) {
                temp_url = file_create_temp_file_url(file_name: fileName, content: fileData)
                if let temp_url = temp_url {
                        interaction_controller = UIDocumentInteractionController(URL: temp_url)
                        interaction_controller?.delegate = self
                        interaction_controller?.presentOpenInMenuFromRect(inRect, inView: inView, animated: true)
                }
        }

        func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
                cleanUp()
        }

        func cleanUp() {
                if let temp_url = temp_url {
                        file_remove(url: temp_url)
                }
                temp_url = nil
                interaction_controller = nil
        }
}
