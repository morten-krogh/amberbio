import UIKit

let document_picker_import = DocumentPickerImport()

class DocumentPickerImport: NSObject, UIDocumentMenuDelegate, UIDocumentPickerDelegate {

        var imported_file_handler: ((file_name: String, content: NSData) -> Void)?
        let document_types = ["public.text", "com.amberbio.sqlite", "com.amberbio.xlsx"]
        var from_view_controller: UIViewController?

        func import_file(from_view_controller from_view_controller: UIViewController, source_view: UIView, imported_file_handler: ((file_name: String, content: NSData) -> Void)) {
                self.from_view_controller = from_view_controller
                self.imported_file_handler = imported_file_handler
                let importMenu = UIDocumentMenuViewController(documentTypes: document_types, inMode: UIDocumentPickerMode.Import)
                importMenu.delegate = self
                if let popOverPresentationController = importMenu.popoverPresentationController {
                        popOverPresentationController.sourceView = source_view
                        popOverPresentationController.sourceRect = CGRect(x: source_view.frame.width / 2.0, y: source_view.frame.height, width: 0, height: 5)
                        popOverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.Up
                        importMenu.view.translatesAutoresizingMaskIntoConstraints = false
                }
                from_view_controller.presentViewController(importMenu, animated: true, completion: nil)
        }

        func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
                documentPicker.delegate = self
                if let from_view_controller = from_view_controller {
                        from_view_controller.presentViewController(documentPicker, animated: true, completion: nil)
                }
        }

        func documentMenuWasCancelled(documentMenu: UIDocumentMenuViewController) {
                clean_up()
        }


        func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
                if let (file_name, content) = file_fetch_and_remove(url: url) {
                        if let imported_file_handler = imported_file_handler {
                                imported_file_handler(file_name: file_name, content: content)
                        }
                }
                clean_up()
        }

        func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
                clean_up()
        }

        func clean_up() {
                imported_file_handler = nil
                from_view_controller = nil
        }
}