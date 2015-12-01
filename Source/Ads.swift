import UIKit

let ad_time_to_next_ad = 10.0
let ad_time_show = 10.0

class Ads: Component, AVCustomAdDelegate {

        var timer: NSTimer?
        var elapsed_time = 0.0

        let remove_ads_button = UIButton(type: .System)
        let timer_label = UILabel()

        let av_button = UIButton(type: .System)
        let av_headline = UILabel()
        let av_subheadline = UILabel()
        let av_image_view = UIImageView()

        var ad: AVCustomAd?

        override func viewDidLoad() {
                super.viewDidLoad()

                let av_custom = AvocarrotCustom()
                av_custom.apiKey = "d63c88bab12483f26954d2a0e2d3388fe5ccc6fc"
                av_custom.sandbox = false
                av_custom.delegate = self
                av_custom.setLogger(true, withLevel: "ALL")
                av_custom.loadAdForPlacement("32f5518cc3f0cd20a557f893906dcdd02badfb85")

                remove_ads_button.setAttributedTitle(astring_body_size(string: "Remove ads and support the app", font_size: 20), forState: .Normal)
                remove_ads_button.addTarget("self", action: "remove_ads_action", forControlEvents: .TouchUpInside)
                view.addSubview(remove_ads_button)

                view.addSubview(timer_label)

                av_button.addTarget(self, action: "av_button_action", forControlEvents: .TouchUpInside)
                av_button.enabled = false
                view.addSubview(av_button)

                av_headline.numberOfLines = 0
                view.addSubview(av_headline)

                av_subheadline.numberOfLines = 0
                view.addSubview(av_subheadline)

                view.addSubview(av_image_view)

        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let (width, height) = (view.frame.width, view.frame.height)

                var origin_y = 20 as CGFloat

                remove_ads_button.sizeToFit()
                remove_ads_button.center = CGPoint(x: width / 2, y: origin_y + remove_ads_button.frame.height / 2)
                origin_y = CGRectGetMaxY(remove_ads_button.frame) + 15

                timer_label.sizeToFit()
                timer_label.frame = CGRect(x: 0, y: origin_y, width: width, height: timer_label.frame.height)
                origin_y = CGRectGetMaxY(timer_label.frame) + 20

                av_button.sizeToFit()
                av_button.center = CGPoint(x: width / 2, y: origin_y + av_button.frame.height / 2)
                origin_y = CGRectGetMaxY(av_button.frame) + 10

                let av_headline_size = av_headline.sizeThatFits(CGSize(width: width - 20, height: 0))
                av_headline.frame = CGRect(x: 10, y: origin_y, width: width - 20, height: av_headline_size.height)
                origin_y = CGRectGetMaxY(av_headline.frame) + 15

                let av_subheadline_size = av_subheadline.sizeThatFits(CGSize(width: width - 20, height: 0))
                av_subheadline.frame = CGRect(x: 10, y: origin_y, width: width - 20, height: av_subheadline_size.height)
                origin_y = CGRectGetMaxY(av_subheadline.frame) + 10

                let image_width = CGFloat(ad?.getImageWidth().floatValue ?? 0.0)
                let image_height = CGFloat(ad?.getImageHeight().floatValue ?? 0.0)
                let remaining_height = height - origin_y
                let remaining_width = width

                if image_width > 0 && image_height > 0 && remaining_width > 0 && remaining_height > 0 {
                        let scale_width = remaining_width / image_width
                        let scale_height = remaining_height / image_height
                        let scale = min(scale_width, scale_height)
                        av_image_view.frame.size = CGSize(width: scale * image_width, height: scale * image_height)
                        av_image_view.center = CGPoint(x: width / 2, y: origin_y + remaining_height / 2)
                } else {
                        av_image_view.frame = CGRect.zero
                }
        }

        override func render() {
                elapsed_time = 0
                set_timer_label()
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timer_action", userInfo: nil, repeats: true)
        }

        func set_timer_label() {
                let remaining = Int(ad_time_show - elapsed_time)
                let text = "The ad will disappear in \(remaining) seconds"
                timer_label.attributedText = astring_body(string: text)
                timer_label.textAlignment = .Center
        }

        func timer_action() {
                if elapsed_time < ad_time_show {
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
                state.render_type = .full_page
                state.navigate(page_state: ModuleStoreState())
                state.render()
        }

        func adDidLoad(ad: AVCustomAd!) {
                print("\n\n\ncall adDidLoad")
                self.ad = ad
                ad.bindToView(view)

//                print(ad.getImageUrl())

                dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), {

                        let valid_ad = avocarrot_ad_valid(ad) as Bool
                        print("The ad is valid = \(valid_ad)")

                        if (valid_ad) {
                                let av_button_text = ad.getCTAText()
                                self.av_button.setAttributedTitle(astring_body_size(string: av_button_text!, font_size: 20), forState: .Normal)
                                self.av_button.enabled = true

                                let av_headline_text = ad.getHeadline()
                                self.av_headline.attributedText = astring_body(string: av_headline_text)
                                self.av_headline.textAlignment = .Center

                                let av_subheadline_text = ad.getSubHeadline()
                                self.av_subheadline.attributedText = astring_body(string: av_subheadline_text)
                                self.av_subheadline.textAlignment = .Center

                                if ad.getImageHeight().integerValue > 0 && ad.getImageWidth().integerValue > 0 {
                                        self.av_image_view.image = ad.getImage()
                                }
                                
                                self.view.setNeedsLayout()
                        }
                })
        }

        func av_button_action() {
                ad?.handleClick()
        }

        func onAdClick(message: String!) {
                print("ad click")
        }

        func onAdImpression(message: String!) {
                print("ad impression")
        }

        func userWillLeaveApp() {
                print("user will leave app")
        }
}
