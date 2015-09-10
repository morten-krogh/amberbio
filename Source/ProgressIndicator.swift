import UIKit

class ProgressIndicator: Component {

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

        override func render() {
                set_info(text: state.progress_indicator_info)
                set_progress(progress: state.progress_indicator_progress)
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
