import Foundation

enum FullScreen {
        case Partial
        case Full
        case Conditional
}

class PageState {

        var name = "To be completed"
        var title = astring_body(string: "To be completed")
        var info = "To be completed"
        var prepared = true

        var search_string = ""

        var full_screen = FullScreen.Partial
        var pdf_enabled = false
        var png_enabled = false
        var txt_enabled = false
        var histogram_enabled = false
        var search_enabled = false
        var select_enabled = false

        func prepare() {}
}
