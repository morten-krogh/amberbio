//
//  ViewController.swift
//  AmberbioTestingGround
//
//  Created by Morten Krogh on 15/10/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

        let label = UILabel()

        override func viewDidLoad() {
                super.viewDidLoad()

                label.numberOfLines = 0
                view.addSubview(label)

                let file_manager = NSFileManager.defaultManager()
                if let path = NSBundle.mainBundle().pathForResource("GDS1001_full", ofType: "soft"), let content = file_manager.contentsAtPath(path) {
                        let geo_soft_file_parser = GEOSoftFileParser(data: content)

                        label.text = geo_soft_file_parser.text
                }
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                label.frame = CGRectInset(view.bounds, 10, 10)
        }
}

class GEOSoftFileParser {

        let data: NSData

        var text = ""

        init(data: NSData) {
                self.data = data

                var cstring = [CChar](count: 10000, repeatedValue: 0)

                geo_soft_find_header(data.bytes, data.length, &cstring, cstring.count - 1)

                let header = String.fromCString(cstring) ?? ""

                text = header
        }





}
