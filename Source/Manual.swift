import UIKit
import WebKit

class ManualState: PageState {

        override init() {
                super.init()
                name = "manual"
                title = astring_body(string: "Manual")
                info = "The manual provides an explanation of aspects of the app that are not evident from the user interface.\n\nEvery page has its own info text which can be accessed by tapping the info button."
        }
}

class Manual: Component, WKNavigationDelegate {

        let web_view = WKWebView()

        override func loadView() {
                view = web_view
                view.backgroundColor = UIColor.whiteColor()
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()
        }

        override func render() {
                web_view.navigationDelegate = self
                if let path = NSBundle.mainBundle().pathForResource("manual", ofType: "html") {
                        let url = NSURL(fileURLWithPath: path)
                        let request = NSURLRequest(URL: url)
                        web_view.loadRequest(request)
                }
        }

        func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
                let url = navigationAction.request.URL

                if url?.scheme == "file" {
                        decisionHandler(.Allow)
                } else {
                        if let url = url {
                                UIApplication.sharedApplication().openURL(url)
                        }
                        decisionHandler(.Cancel)
                }
        }
}
