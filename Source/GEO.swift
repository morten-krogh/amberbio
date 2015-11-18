import UIKit

enum GEOStatus {
        case NoInput
        case CorrectInput
        case IncorrectInput
        case Downloading
        case NoConnection
        case FileNotFound
        case Importing
        case ImportError
        case Done
}

class GEOState: PageState {

        var session: NSURLSession!
        var state = GEOStatus.CorrectInput
        var geo_id = "GDS1001"

        override init() {
                super.init()
                name = "geo"
                title = astring_body(string: "Gene expression omnibus")
                info = "Download data set and series records from Gene expression omnibus (GEO).\n\nDataset records have ids of the form GDSxxxx.\n\nSeries records have ids of the form GSExxxx.\n\nxxxx denotes a number of any number of digits."
        }

        
}

class GEO: Component, UITextFieldDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {

        var geo_state: GEOState!

        let scroll_view = UIScrollView()
        let info_label = UILabel()
        let message_label = UILabel()
        let text_field = UITextField()
        let button = UIButton(type: .System)

        let serial_queue = dispatch_queue_create("GEO download", DISPATCH_QUEUE_SERIAL)
        var session: NSURLSession!
        var task: NSURLSessionDataTask?
        var bytes_downloaded = 0
        var received_data = [] as [NSData]
        var response_status_code = 200
        var canceled = false

        override func viewDidLoad() {
                super.viewDidLoad()

                session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())

                info_label.text = "Download a public data set from Gene expression omnibus. Type an id for a GEO data set of the form GDSnnnn or a GEO series of the form GSEnnnn."
                info_label.textAlignment = .Left
                info_label.font = font_body
                info_label.numberOfLines = 0
                scroll_view.addSubview(info_label)

                message_label.numberOfLines = 0
                scroll_view.addSubview(message_label)

                text_field.clearButtonMode = UITextFieldViewMode.WhileEditing
                text_field.font = font_body
                text_field.autocorrectionType = UITextAutocorrectionType.No
                text_field.textAlignment = NSTextAlignment.Center
                text_field.borderStyle = UITextBorderStyle.Bezel
                text_field.layer.masksToBounds = true
                text_field.delegate = self
                scroll_view.addSubview(text_field)

                button.addTarget(self, action: "button_action", forControlEvents: .TouchUpInside)
                scroll_view.addSubview(button)

                view.addSubview(scroll_view)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action")
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                var origin_y = 20 as CGFloat

                let info_label_size = info_label.sizeThatFits(CGSize(width: width - 40, height: 0))
                info_label.frame = CGRect(x: 20, y: origin_y, width: width - 40, height: info_label_size.height)
                origin_y = CGRectGetMaxY(info_label.frame) + 20

                let message_label_size = message_label.sizeThatFits(CGSize(width: width - 40, height: 0))
                message_label.frame = CGRect(x: 20, y: origin_y, width: width - 40, height: message_label_size.height)
                origin_y = CGRectGetMaxY(message_label.frame) + 20

                let text_field_width = min(width - 40, 300)
                text_field.frame = CGRect(x: (width - text_field_width) / 2, y: origin_y, width: text_field_width, height: 50)
                origin_y = CGRectGetMaxY(text_field.frame) + 30

                button.sizeToFit()
                button.frame.origin = CGPoint(x: (width - button.frame.width) / 2, y: origin_y)
                origin_y = CGRectGetMaxY(button.frame) + 20

                scroll_view.contentSize = CGSize(width: width, height: origin_y)
                scroll_view.frame = view.bounds
        }

        override func render() {
                geo_state = state.page_state as! GEOState

                if text_field.text != geo_state.geo_id {
                        text_field.text = geo_state.geo_id
                }

                text_field.hidden = false
                button.enabled = true
                button.hidden = false

                let message_text: String
                let message_color: UIColor

                switch geo_state.state {
                case .NoInput:
                        message_text = "Type GDSxxxx or GSExxxx"
                        message_color = UIColor.blackColor()
                        set_button_title(title: "Download and import")
                        button.enabled = false
                case .IncorrectInput:
                        message_text = "Type GDSxxxx or GSExxxx"
                        message_color = UIColor.redColor()
                        set_button_title(title: "Download and import")
                        button.enabled = false
                case .CorrectInput:
                        message_text = "The id has the correct form"
                        message_color = UIColor.blackColor()
                        set_button_title(title: "Download and import")
                case .Downloading:
                        message_text = "\(bytes_downloaded) bytes downloaded"
                        message_color = UIColor.blackColor()
                        set_button_title(title: "Cancel")
                        button.enabled = true
                        text_field.hidden = true
                case .NoConnection:
                        message_text = "There is a problem with the internet connection"
                        message_color = UIColor.redColor()
                        set_button_title(title: "Download and import")
                case .FileNotFound:
                        message_text = "The data set does not exist"
                        message_color = UIColor.redColor()
                        set_button_title(title: "Download and import")
                case .Importing:
                        message_text = "The downloaded data set is being imported"
                        message_color = UIColor.blackColor()
                        button.hidden = true
                        text_field.hidden = true
                case .ImportError:
                        message_text = "The file was not of the expected format"
                        message_color = UIColor.redColor()
                        button.hidden = true
                case .Done:
                        message_text = "The project \(geo_state.geo_id) has been created"
                        message_color = UIColor.blueColor()
                        set_button_title(title: "Download and import")
                        button.enabled = false
                }

                message_label.attributedText = astring_font_size_color(string: message_text, font: nil, font_size: 20, color: message_color)
                message_label.textAlignment = .Center

                view.setNeedsLayout()
        }

        override func finish() {
                session.invalidateAndCancel()
                session = nil
                if geo_state.state == .Downloading {
                        geo_state.state = .CorrectInput
                }
        }

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textFieldDidEndEditing(textField: UITextField) {
                let original_text = textField.text ?? ""

                let text = trim(string: original_text.uppercaseString)

                if text == "" {
                        geo_state.state = .NoInput
                } else if text.hasPrefix("GSE") || text.hasPrefix("GDS") {
                        let substring = text.substringFromIndex(text.startIndex.advancedBy(3))
                        if Int(substring) == nil {
                                geo_state.state = .IncorrectInput
                        } else {
                                geo_state.state = .CorrectInput
                        }
                } else {
                        geo_state.state = .IncorrectInput
                }

                if text != original_text && geo_state.state == .CorrectInput {
                        textField.text = text
                }
                geo_state.geo_id = text
                render()
        }

        func button_action() {
                if geo_state.state == .CorrectInput {
                        download()
                } else if geo_state.state == .Downloading {
                        cancel_download()
                }
        }

        func url_of_data_set() -> NSURL {
                let id = geo_state.geo_id
                let prefix = id.substringWithRange(id.startIndex ..< id.startIndex.advancedBy(3))
                let digits = [Character](id.substringFromIndex(id.startIndex.advancedBy(3)).characters).map { String($0) } as [String]
                let is_gds = prefix == "GDS"

                var url = "http://ftp.ncbi.nlm.nih.gov/geo/"
                url += is_gds ? "datasets/GDS" : "series/GSE"
                if digits.count > 3 {
                        for i in 0 ..< digits.count - 3 {
                                url += digits[i]
                        }
                }
                url += "nnn/" + id + "/soft/" + id + "_"
                url += is_gds ? "full" : "family"
                url += ".soft.gz"

                print(url)

//                let url_string = "http://ftp.ncbi.nlm.nih.gov/geo/datasets/GDS1nnn/GDS1001/soft/GDS1001_full.soft.gz"
//                let url_string = "http://ftp.ncbi.nlm.nih.gov/genomes/Acanthisitta_chloris/Gnomon/ref_ASM69581v1_gnomon_scaffolds.gff3.gz"
//                let url_string = "http://www.amberbio.com/345"
                let nsurl = NSURL(string: url)!
                return nsurl
        }

        func download() {
                print("start download")

                bytes_downloaded = 0
                received_data = []
                canceled = false
                response_status_code = 0
                let url = url_of_data_set()
                task = session?.dataTaskWithURL(url)

                dispatch_async(serial_queue, {
                        self.task?.resume()
                })

                geo_state.state = .Downloading
                state.render()
        }

        func cancel_download() {
                print("cancel")
                dispatch_async(serial_queue, {
                        self.task?.cancel()
                        self.task = nil
                })

                bytes_downloaded = 0
                received_data = []
                canceled = true
        }

        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
                received_data.append(data)
                bytes_downloaded += data.length
                render()
        }

        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
                print("did complete with error = \(error)")
                if canceled {
                        geo_state.state = .CorrectInput
                } else if error != nil {
                        geo_state.state = .NoConnection
                } else if response_status_code == 404 {
                        geo_state.state = .FileNotFound
                } else {
                        geo_state.state = .Importing
                        NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "import_data_set", userInfo: nil, repeats: false)
                }
                state.render()
        }

        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
                if let response = response as? NSHTTPURLResponse {
                        response_status_code = response.statusCode
                } else {
                        response_status_code = 404
                }
                print(response)
                completionHandler(NSURLSessionResponseDisposition.Allow)
        }

        func import_data_set() {
                let deflated_data = NSMutableData()
                for data in received_data {
                        deflated_data.appendData(data)
                }

                if let inflated_data = gunzip(data: deflated_data) {
                        if geo_state.geo_id.hasPrefix("GDS") {
                                let gds = GDS(data: inflated_data)
                                if gds.valid {
                                        import_data_set(sample_name: gds.sample_names, values: gds.values)


                                } else {
                                        geo_state.state = .ImportError
                                        render()
                                }
                        } else {
                                let gse = GSE(data: inflated_data)
                                if gse.valid {
                                        import_data_set(sample_name: gse.sample_names, values: gse.values)

                                } else {
                                        geo_state.state = .ImportError
                                        render()
                                }
                        }
                } else {
                        geo_state.state = .ImportError
                        render()
                }
        }

        func import_data_set(sample_name sample_names: [String], values: [Double]) {
                let project_name = geo_state.geo_id


                print(sample_names)



                geo_state.state = .Done
                state.render()
        }

        func tap_action() {
                text_field.resignFirstResponder()
        }

        func set_button_title(title title: String) {
                button.setAttributedTitle(astring_font_size_color(string: title, font: nil, font_size: 20, color: nil), forState: .Normal)
                button.setAttributedTitle(astring_font_size_color(string: title, font: nil, font_size: 20, color: color_disabled), forState: .Disabled)
        }
}
