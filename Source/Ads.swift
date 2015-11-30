import UIKit

class Ads: Component {

        var timer: NSTimer?
        var elapsed_time = 0
        let total_time = 10
        let add_remove_time = 5

        let remove_ads_button = UIButton(type: .System)
        let timer_label = UILabel()
        
        override func viewDidLoad() {

                remove_ads_button.setAttributedTitle(astring_body(string: "Remove ads and support the app"), forState: .Normal)
                remove_ads_button.addTarget("self", action: "remove_ads_action", forControlEvents: .TouchUpInside)
                view.addSubview(remove_ads_button)

                set_timer_label()
                view.addSubview(timer_label)





        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let (width, height) = (view.frame.width, view.frame.height)

                var origin_y = 20 as CGFloat

                remove_ads_button.sizeToFit()
                remove_ads_button.center = CGPoint(x: width / 2, y: origin_y + remove_ads_button.frame.height / 2)
                origin_y = CGRectGetMaxY(remove_ads_button.frame) + 20

                timer_label.sizeToFit()
                timer_label.frame = CGRect(x: 0, y: origin_y, width: width, height: 40 + timer_label.frame.height)
                origin_y = CGRectGetMaxY(timer_label.frame)






        }

        override func render() {
                elapsed_time = 0
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timer_action", userInfo: nil, repeats: true)

        }

        func set_timer_label() {
                let text = "Ads will disappear in \(total_time - elapsed_time) seconds"
                timer_label.attributedText = astring_body(string: text)
                timer_label.textAlignment = .Center
        }

        func timer_action() {
                if elapsed_time < total_time {
                        elapsed_time++
                        set_timer_label()
                } else {
                        timer?.invalidate()
                        timer = nil
                        state.ads_finish()
                        state.render()
                }
        }



        func remove_ads_action() {
                timer?.invalidate()
                timer = nil
                state.ads_interrupt()
                state.render()
        }
}
