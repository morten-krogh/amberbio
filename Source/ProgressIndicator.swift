import UIKit

class ProgressIndicator: UIViewController {

        var progress = -1

        let info_label = UILabel()
        let progress_label = UILabel()
        let progress_view = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(info_label)

                view.addSubview(progress_label)

                view.addSubview(progress_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                var origin_y = 0 as CGFloat

                info_label.frame.origin = CGPoint(x: (view.frame.width - info_label.frame.width) / 2, y: origin_y)

                origin_y += info_label.frame.height + 50

                progress_label.frame = CGRect(x: 0, y: origin_y, width: view.frame.width, height: 40)

                origin_y += progress_label.frame.height + 50

                progress_view.frame = CGRect(x: 30, y: origin_y, width: view.frame.width - 60, height: 60)

                origin_y += progress_view.frame.height + 50

                let height = origin_y

                let margin = min(max(0, view.frame.height - height) / 2, 200)

                info_label.frame.origin.y += margin
                progress_label.frame.origin.y += margin
                progress_view.frame.origin.y += margin
        }

        func set_info(text text: String) {
                info_label.attributedText = astring_headline(string: text)
                info_label.sizeToFit()
        }

        func set_progress(progress progress: Int) {
                if progress != self.progress {
                        self.progress = progress
                        progress_label.attributedText = astring_body(string: "Progress: \(progress)%")
                        progress_label.textAlignment = .Center
                        progress_view.setProgress(Float(progress) / 100, animated: false)
                }
        }

        func set_progress_from_dispatch_queue(progress progress: Int) {
                dispatch_async(dispatch_get_main_queue(), {
                        self.set_progress(progress: progress)
                })
        }

        func progress_step(total total: Int, index: Int, min: Int, max: Int, step_size: Int) {
                if index % step_size == 0 || index == total - 1 {
                        let progress = min + (max - min) * (index + 1) / total
                        if progress > self.progress {
                                set_progress_from_dispatch_queue(progress: progress)
                        }
                }
        }
}


//class ProgressIndicator: UIViewController {
//
//        var progress = -1
//        var counter = 0
//
//        var cancel_handler: (() -> ())?
//
//        let info_label = UILabel()
//        let progress_label = UILabel()
//        let progress_view = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
//        let cancel_button = UIButton(type: .System) as! UIButton
//
//        override func viewDidLoad() {
//                super.viewDidLoad()
//
//                set_info(text: "Computing")
//                view.addSubview(info_label)
//
//                set_progress(counter: self.counter, progress: 0)
//                view.addSubview(progress_label)
//
//                cancel_button.setAttributedTitle(astring_body(string: "Cancel"), forState: .Normal)
//                cancel_button.addTarget(self, action: "cancel_action", forControlEvents: .TouchUpInside)
//                cancel_button.sizeToFit()
//                view.addSubview(cancel_button)
//
//                view.addSubview(progress_view)
//        }
//
//        override func viewWillLayoutSubviews() {
//                super.viewWillLayoutSubviews()
//
//                var origin_y = 0 as CGFloat
//
//                info_label.frame.origin = CGPoint(x: (view.frame.width - info_label.frame.width) / 2, y: origin_y)
//
//                origin_y += info_label.frame.height + 50
//
//                progress_label.frame = CGRect(x: 0, y: origin_y, width: view.frame.width, height: 40)
//
//                origin_y += progress_label.frame.height + 50
//
//                progress_view.frame = CGRect(x: 30, y: origin_y, width: view.frame.width - 60, height: 60)
//
//                origin_y += progress_view.frame.height + 50
//
//                cancel_button.frame.origin = CGPoint(x: (view.frame.width - cancel_button.frame.width) / 2, y: origin_y)
//
//                let height = origin_y + cancel_button.frame.height
//
//                let margin = min(max(0, view.frame.height - height) / 2, 200)
//
//                info_label.frame.origin.y += margin
//                progress_label.frame.origin.y += margin
//                progress_view.frame.origin.y += margin
//                cancel_button.frame.origin.y += margin
//        }
//
//        func set_info(#text: String) {
//                info_label.attributedText = astring_headline(string: text)
//                info_label.sizeToFit()
//        }
//
//        func set_progress(#counter: Int, progress: Int) {
//                if counter == self.counter && progress != self.progress {
//                        self.progress = progress
//                        progress_label.attributedText = astring_body(string: "Progress: \(progress)%")
//                        progress_label.textAlignment = .Center
//                        progress_view.setProgress(Double(progress) / 100, animated: false)
//
//                        cancel_button.hidden = progress == 100
//                }
//        }
//
//        func set_progress_from_non_main_queue(#counter: Int, progress: Int) {
//                dispatch_sync(dispatch_get_main_queue(), {
//                        self.set_progress(counter: counter, progress: progress)
//                })
//        }
//
//        func start() -> Int {
//                counter++
//                set_progress(counter: self.counter, progress: 0)
//                return counter
//        }
//
//        func end(#counter: Int) {
//                if counter == self.counter {
//                        self.counter++
//                }
//        }
//
//        func cancel_action() {
//                end(counter: counter)
//                if let cancel_handler = cancel_handler {
//                        cancel_handler()
//                }
//                state_hide_progress_indicator()
//                state.render()
//        }
//
//        func progress_step(#counter: Int, total: Int, index: Int, min: Int, max: Int, step_size: Int) {
//                if index % step_size == 0 || index == total - 1 {
//                        let progress = min + (max - min) * (index + 1) / total
//                        if progress > self.progress {
//                                set_progress_from_non_main_queue(counter: counter, progress: progress)
//                        }
//                }
//        }
//
//        func show_cancel_button() {
//                cancel_button.hidden = false
//        }
//
//        func hide_cancel_button() {
//                cancel_button.hidden = true
//        }
//}
