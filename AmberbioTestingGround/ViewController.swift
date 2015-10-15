//
//  ViewController.swift
//  AmberbioTestingGround
//
//  Created by Morten Krogh on 15/10/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

        let tiled_scroll_view = TiledScrollView()

        var roc: ROC?

        override func viewDidLoad() {
                super.viewDidLoad()

                let decision_values_1 = [1.2, 3, 4]
                let decision_values_2 = [2, 3.5, 5, 6, 7, 3.6]

                roc = ROC(label_name_1: "label 1", label_name_2: "label 2", decision_values_1: decision_values_1, decision_values_2: decision_values_2)
                tiled_scroll_view.delegate = roc

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                tiled_scroll_view.frame = view.bounds
        }


}

