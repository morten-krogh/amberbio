import UIKit

func pdf_draw_info_page(description description: String, project_name: String, data_set_name: String, user_name: String) {

        let content = result_file_info_array(description: description, project_name: project_name, data_set_name: data_set_name, user_name: user_name).joinWithSeparator("\r\n") + "\r\n"

        let attributed_content = astring_body(string: content)

        UIGraphicsBeginPDFPage()

        let margin = 20.0 as CGFloat
        let rect = CGRect(x: margin, y: margin, width: attributed_content.size().width, height: attributed_content.size().height)
        attributed_content.drawInRect(rect)
}

func pdf_result_file(name name: String, description: String, project_name: String, data_set_name: String, user_name: String, content_size: CGSize, draw: (context: CGContext, rect: CGRect) -> ()) -> (file_name: String, content: NSData) {

        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, [:])
        let rect = CGRect(origin: CGPoint.zero, size: content_size)
        UIGraphicsBeginPDFPageWithInfo(rect, nil)

        let context = UIGraphicsGetCurrentContext()
        draw(context: context!, rect: rect)
        pdf_draw_info_page(description: description, project_name: project_name, data_set_name: data_set_name, user_name: user_name)
        UIGraphicsEndPDFContext()

        let file_name = file_name_for_result_file(name: name, ext: "pdf")

        return (file_name, data)
}

func file_name_for_result_file(name name: String, ext: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let date_string = formatter.stringFromDate(NSDate())
        return name + "-" + date_string + "." + ext
}
