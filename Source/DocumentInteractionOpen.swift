import UIKit

let documentInteractionOpen = DocumentInteractionOpen()

class DocumentInteractionOpen: NSObject, UIDocumentInteractionControllerDelegate {

        var tempURL: NSURL?
        var interactionController: UIDocumentInteractionController?

        func openResultFile(fileName fileName: String, fileData: NSData, inRect: CGRect, inView: UIView) {
                tempURL = file_create_temp(file_name: fileName, content: fileData)
                if let tempURL = tempURL {
                        interactionController = UIDocumentInteractionController(URL: tempURL)
                        interactionController?.delegate = self
                        interactionController?.presentOpenInMenuFromRect(inRect, inView: inView, animated: true)
                }
        }

        func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
                cleanUp()
        }

        func cleanUp() {
                if let tempURL = tempURL {
                        file_remove(url: tempURL)
                }
                tempURL = nil
                interactionController = nil
        }
}
