import UIKit

class PdfTxtButtons: UIView {

        let contentSize: CGSize
        let pdfButton: UIButton?
        let txtButton: UIButton?

        init(target: AnyObject, pdf_action: Selector?, txt_action: Selector?) {
                (contentSize, pdfButton, txtButton) = PdfTxtButtons.initHelper(target: target, pdf_action: pdf_action, txt_action: txt_action)

                super.init(frame: CGRect.zeroRect)

                if let pdfButton = pdfButton {
                        addSubview(pdfButton)
                }

                if let txtButton = txtButton {
                        addSubview(txtButton)
                }
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        class func initHelper(target target: AnyObject, pdf_action: Selector?, txt_action: Selector?) -> (contentSize: CGSize, pdfButton: UIButton?, txtButton: UIButton?) {
                let margin = 20 as CGFloat

                var contentSize = CGSize.zeroSize
                var pdfButton: UIButton?
                var txtButton: UIButton?

                if let txt_action = txt_action {
                        let button = UIButton(type: UIButtonType.System)
                        button.setAttributedTitle(astring_font_size_color(string: "txt", font: nil, font_size: 20 as CGFloat, color: nil), forState: .Normal)
                        button.addTarget(target, action: txt_action, forControlEvents: .TouchUpInside)
                        button.sizeToFit()
                        txtButton = button
                }

                if let pdf_action = pdf_action {
                        let button = UIButton(type: UIButtonType.System)
                        button.setAttributedTitle(astring_font_size_color(string: "pdf", font: nil, font_size: 20 as CGFloat, color: nil), forState: .Normal)
                        button.addTarget(target, action: pdf_action, forControlEvents: .TouchUpInside)
                        button.sizeToFit()
                        pdfButton = button
                }

                if let txtButton = txtButton {
                        contentSize.height = txtButton.frame.height
                }
                if let pdfButton = pdfButton {
                        if pdfButton.frame.height > contentSize.height {
                                contentSize.height = pdfButton.frame.height
                        }
                }

                if let txtButton = txtButton {
                        txtButton.frame.origin = CGPoint(x: 0, y: (contentSize.height - txtButton.frame.height) / 2.0)
                        contentSize.width = txtButton.frame.width
                }

                if let pdfButton = pdfButton {
                        if txtButton != nil {
                                contentSize.width += margin
                        }
                        pdfButton.frame.origin = CGPoint(x: contentSize.width, y: (contentSize.height - pdfButton.frame.height) / 2.0)
                        contentSize.width += pdfButton.frame.width
                }

                return (contentSize, pdfButton, txtButton)
        }
}
