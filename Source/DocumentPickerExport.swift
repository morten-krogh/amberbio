import UIKit

let documentPickerExport = DocumentPickerExport()

class DocumentPickerExport: NSObject, UIDocumentMenuDelegate, UIDocumentPickerDelegate {

        var tempURL: NSURL?
        var fromViewController: UIViewController?

        func exportResultFile(fileName fileName: String, fileData: NSData, fromViewController: UIViewController, sourceView: UIView) {
                self.fromViewController = fromViewController
                tempURL = file_create_temp(file_name: fileName, content: fileData)
                if let tempURL = tempURL {
                        let exportMenu = UIDocumentMenuViewController(URL: tempURL, inMode: UIDocumentPickerMode.ExportToService)
                        exportMenu.delegate = self
                        if let popOverPresentationController = exportMenu.popoverPresentationController {
                                popOverPresentationController.sourceView = sourceView
                                popOverPresentationController.sourceRect = CGRect(x: sourceView.frame.width / 2.0, y: sourceView.frame.height, width: 0, height: 5)
                                popOverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.Up
                                exportMenu.view.translatesAutoresizingMaskIntoConstraints = false
                        }
                        fromViewController.presentViewController(exportMenu, animated: true, completion: nil)
                }
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
                cleanUp()
        }

        func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
                cleanUp()
        }

        func cleanUp() {
                if let tempURL = tempURL {
                        file_remove(url: tempURL)
                }
                tempURL = nil
                fromViewController = nil
        }
}