import UIKit

let document_picker_export = DocumentPickerExport()

class DocumentPickerExport: NSObject, UIDocumentMenuDelegate, UIDocumentPickerDelegate {

        var temp_url: NSURL?
        var from_view_controller: UIViewController?

        func export_result_file(file_name file_name: String, file_content: NSData, from_view_controller: UIViewController, source_view: UIView) {
                self.from_view_controller = from_view_controller
                temp_url = file_create_temp_file_url(file_name: file_name, content: file_content)
                if let temp_url = temp_url {
                        let export_menu = UIDocumentMenuViewController(URL: temp_url, inMode: UIDocumentPickerMode.ExportToService)
                        export_menu.delegate = self
                        if let popOverPresentationController = export_menu.popoverPresentationController {
                                popOverPresentationController.sourceView = source_view
                                popOverPresentationController.sourceRect = CGRect(x: source_view.frame.width / 2.0, y: source_view.frame.height, width: 0, height: 5)
                                popOverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.Up
                                export_menu.view.translatesAutoresizingMaskIntoConstraints = false
                        }
                        from_view_controller.presentViewController(export_menu, animated: true, completion: nil)
                }
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
                clean_up()
        }

        func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
                clean_up()
        }

        func clean_up() {
                if let temp_url = temp_url {
                        file_remove(url: temp_url)
                }
                temp_url = nil
                from_view_controller = nil
        }
}