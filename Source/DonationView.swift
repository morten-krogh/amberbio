import Foundation

class DonationView: Component {

        let content_view = UIView()
        let donate_button = UIButton(type: .System)
        let no_thanks_button = UIButton(type: .System)
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                content_view.layer.cornerRadius = 20
                content_view.layer.borderColor = color_green.CGColor
                content_view.layer.borderWidth = 5
                view.addSubview(content_view)
                content_view.backgroundColor = UIColor.whiteColor()
                
                donate_button.setAttributedTitle(astring_body(string: "Go to the donation page"), forState: .Normal)
                donate_button.addTarget(self, action: "donate_action", forControlEvents: .TouchUpInside)
                content_view.addSubview(donate_button)
                
                
                
        }
        
        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()
                
                content_view.frame = CGRectInset(view.bounds, 40, 40)

//                let (width, height)
        
                donate_button.sizeToFit()
                donate_button.center = CGPoint(x: 200, y: 100)
        
                donate_button.layer.zPosition = 2
                print(donate_button.layer.zPosition)
        }
        
        
        
        
        func donate_action() {
                print("donate action")
                let page_state = ModuleStoreState()
                state.navigate(page_state: page_state)
                state.render_type = .full_page
                state.render()
        }
        
        func finish_action() {
                
        }
}
