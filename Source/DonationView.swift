import Foundation

class DonationView: Component {

        let info_text = "The app is completely free to use in order to benefit as many people as possible.\n\nPlease donate according to yuo r means if you find the app beneficial.\n\nDonations support hosting and development of the app."
        
        
        let content_view = UIView()
        let info_label = UILabel()
        let donate_button = UIButton(type: .System)
        let no_thanks_button = UIButton(type: .System)
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
//                view.backgroundColor = UIColor(white: 1, alpha: 0.6)
                
                content_view.layer.cornerRadius = 20
                content_view.layer.borderColor =   UIColor.blackColor().CGColor
                content_view.layer.borderWidth = 1.5
                view.addSubview(content_view)
                content_view.backgroundColor = UIColor.whiteColor()
              
                info_label.numberOfLines = 0
                info_label.text = info_text
                info_label.font = font_body.fontWithSize(20)
                content_view.addSubview(info_label)
                
                donate_button.setAttributedTitle(astring_body_size(string: "Go to donations", font_size: 22), forState: .Normal)
                donate_button.addTarget(self, action: "donate_action", forControlEvents: .TouchUpInside)
                content_view.addSubview(donate_button)
                
                no_thanks_button.setAttributedTitle(astring_body_size(string: "No thanks", font_size: 22), forState: .Normal)
                no_thanks_button.addTarget(self, action: "finish_action", forControlEvents: .TouchUpInside)
                content_view.addSubview(no_thanks_button)
                
                
        }
        
        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()
                
                let (width, height) = (view.frame.width, view.frame.height)
                let content_width = width < 540 ? CGFloat(width - 40) : CGFloat(500)
                let content_height = height < 740 ? CGFloat(height - 40) : CGFloat(700)

                content_view.frame = CGRect(x: (width - content_width) / 2, y: (height - content_height) / 2, width: content_width, height: content_height)
                
                let info_size = info_label.sizeThatFits(CGSize(width: content_width - 40, height: 0))
                info_label.frame.origin = CGPoint(x: 20, y: 20)
                info_label.frame.size = info_size
                
                var origin_y = CGRectGetMaxY(info_label.frame) + 50
                
                donate_button.sizeToFit()
                donate_button.frame.origin = CGPoint(x: (content_width - donate_button.frame.width) / 2, y: origin_y)
                origin_y = CGRectGetMaxY(donate_button.frame) + 30
                
                no_thanks_button.sizeToFit()
                no_thanks_button.frame.origin = CGPoint(x: (content_width - no_thanks_button.frame.width) / 2, y: origin_y)
                origin_y = CGRectGetMaxY(no_thanks_button.frame) + 30
                
//                content_view.frame.size.height = origin_y
        }
        
        func donate_action() {
                let page_state = ModuleStoreState()
                state.navigate(page_state: page_state)
                state.render_type = .full_page
                state.render()
        }
        
        func finish_action() {
                state.render_type = .full_page
                state.render()
        }
}
