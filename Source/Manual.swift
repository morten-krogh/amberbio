import UIKit

class ManualState: PageState {

        override init() {
                super.init()
                name = "manual"
                title = astring_body(string: "Manual")
                info = "The manual provides an explanation of aspects of the app that are not evident from the user interface.\n\nEvery page has its own info text which can be accessed by tapping the info button."
        }
}

class Manual: Component {

        let web_view = UIWebView()

        var html = ""

        override func loadView() {
                view = web_view
                view.backgroundColor = UIColor.whiteColor()
        }

        override func render() {
                if let path = NSBundle.mainBundle().pathForResource("manual", ofType: "html") {
                        let url = NSURL(fileURLWithPath: path)
                        let request = NSURLRequest(URL: url)
                        web_view.loadRequest(request)
                }
        }
}
