import UIKit

let documentPickerImport = DocumentPickerImport()

class DocumentPickerImport: NSObject, UIDocumentMenuDelegate, UIDocumentPickerDelegate {

        var importedFileHandler: ((file_name: String, content: NSData) -> Void)?
        let documentTypes = ["public.text"]
        var fromViewController: UIViewController?

        func importFile(fromViewController fromViewController: UIViewController, sourceView: UIView, importedFileHandler: ((file_name: String, content: NSData) -> Void)) {
                self.fromViewController = fromViewController
                self.importedFileHandler = importedFileHandler
                let importMenu = UIDocumentMenuViewController(documentTypes: documentTypes, inMode: UIDocumentPickerMode.Import)
                importMenu.delegate = self
                if let popOverPresentationController = importMenu.popoverPresentationController {
                        popOverPresentationController.sourceView = sourceView
                        popOverPresentationController.sourceRect = CGRect(x: sourceView.frame.width / 2.0, y: sourceView.frame.height, width: 0, height: 5)
                        popOverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.Up
                        importMenu.view.translatesAutoresizingMaskIntoConstraints = false
                }
                fromViewController.presentViewController(importMenu, animated: true, completion: nil)
        }

        func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
                documentPicker.delegate = self
                if let fromViewController = fromViewController {
                        fromViewController.presentViewController(documentPicker, animated: true, completion: nil)
                }
        }

        func documentMenuWasCancelled(documentMenu: UIDocumentMenuViewController) {
                cleanUp()
        }


        func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
                if let (file_name, content) = file_fetch_and_remove(url: url) {
                        if let importedFileHandler = importedFileHandler {
                                importedFileHandler(file_name: file_name, content: content)
                        }
                }
                cleanUp()
        }

        func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
                cleanUp()
        }

        func cleanUp() {
                importedFileHandler = nil
                fromViewController = nil
        }
}