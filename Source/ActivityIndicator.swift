import UIKit

class ActivityIndicator: Component {

        let indicator_view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        let info_label = UILabel()

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(info_label)

                indicator_view.color = UIColor.blueColor()
                indicator_view.sizeToFit()
                view.addSubview(indicator_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                var origin_y = 60 as CGFloat

                info_label.frame = CGRect(x: 0, y: origin_y, width: width, height: 50)
                origin_y += info_label.frame.height + 50

                indicator_view.frame.origin = CGPoint(x: (view.frame.width - indicator_view.frame.width) / 2, y: origin_y)
                origin_y += indicator_view.frame.height + 50

                let margin = min(max(0, view.frame.height - origin_y) / 2, 200)

                info_label.frame.origin.y += margin
                indicator_view.frame.origin.y += margin
        }

        override func render() {
                indicator_view.startAnimating()
                info_label.attributedText = astring_font_size_color(string: state.activity_indicator_info, font: nil, font_size: 22, color: UIColor.blueColor())
                info_label.textAlignment = .Center
        }
}
