//
//  ViewController.swift
//  AmberbioTestingGround
//
//  Created by Morten Krogh on 15/10/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

        let draw_view_example = DrawViewExample(frame: CGRect.zero)

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(draw_view_example)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                draw_view_example.frame = CGRectInset(view.bounds, 70, 70)
        }
}

class DrawViewExample: DrawView {

        override init(frame: CGRect) {
                super.init(frame: frame)

                content_size = CGSize(width: 800, height: 500)
//                scroll_view.contentSize = content_size

        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(context context: CGContext, rect: CGRect) {

                let start_point = CGPoint(x: 0, y: 0)
                let end_point = CGPoint(x: 800, y: 500)
                drawing_draw_line(context: context, start_point: start_point, end_point: end_point)

                drawing_draw_circle(context: context, center_x: 150, center_y: 200, radius: 30, color: UIColor.redColor())
                drawing_draw_circle(context: context, center_x: 750, center_y: 400, radius: 40, color: UIColor.greenColor())

        }


}
