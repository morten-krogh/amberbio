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
        let scroll_view = UIScrollView()

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(scroll_view)

                label.numberOfLines = 0
                scroll_view.addSubview(label)

                let file_manager = NSFileManager.defaultManager()
                if let path = NSBundle.mainBundle().pathForResource("GDS1001_full", ofType: "soft"), let content = file_manager.contentsAtPath(path) {
                        let geo_soft_file_parser = GEOSoftFileParser(data: content)

                        label.text = geo_soft_file_parser.header
                }
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                label.sizeToFit()
                scroll_view.contentSize = label.frame.size

                scroll_view.frame = CGRectInset(view.bounds, 10, 10)
                label.frame.origin = CGPoint.zero
        }
}

class GEOSoftFileParser {

        var error = false

        let data: NSData

        let header: String

        var dataset_info = ""
        var feature_count = 0
        var column_names = [] as [String]
        var sample_names = [] as [String]
        var sample_values = [] as [String]
        var value_for_sample_levels = [] as [String]
        var src_levels = [] as [String]

        var factor_names = [] as [String]
        var levels_for_samples = [] as [[String]]

        init(data: NSData) {
                self.data = data

                var cstring = [CChar](count: 10000, repeatedValue: 0)

                geo_soft_find_header(data.bytes, data.length, &cstring, cstring.count - 1)

                header = String.fromCString(cstring) ?? ""
                parse_header()
                if error {
                        return
                }
                make_factors()
                if error {
                        return
                }
                print(value_for_sample_levels)
                print(src_levels)

        }

        func split_and_trim(string string: String, separator: String) -> [String] {
                let comps = string.componentsSeparatedByString(separator)
                return comps.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }
        }

        func parse_header() {
                let lines = header.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())

                var index_caret_dataset = 0
                for line in lines {
                        if line.hasPrefix("^DATASET") {
                                break
                        }
                        index_caret_dataset++
                }

                var dataset_info_array = [] as [String]
                for i in (index_caret_dataset + 1) ..< lines.count {
                        if !lines[i].hasPrefix("^") {
                                dataset_info_array.append(lines[i])
                        } else {
                                break
                        }
                }

                dataset_info = dataset_info_array.joinWithSeparator("\n")

                for line in lines {
                        if line.hasPrefix("!dataset_feature_count") {
                                let comps = split_and_trim(string: line, separator: "=")
                                if comps.count == 2, let number = Int(comps[1]) {
                                        feature_count = number
                                } else {
                                        error = true
                                        return
                                }
                        }

                        if line.hasPrefix("#") {
                                let index = line.startIndex.advancedBy(1)
                                let line_without_pound = line.substringFromIndex(index)
                                let comps = split_and_trim(string: line_without_pound, separator: "=")
                                if comps.count != 2 {
                                        error = true
                                        return
                                }
                                column_names.append(comps[0])

                                if comps[0].hasPrefix("GSM") {
                                        sample_names.append(comps[0])
                                        sample_values.append(comps[1])
                                }
                        }



                }
        }

        func make_factors() {
                for sample_value in sample_values {
                        let semicolon_split_string = split_and_trim(string: sample_value, separator: ";")
                        if semicolon_split_string.count != 2 {
                                error = true
                                return
                        }
                        var levels = [] as [String]
                        for part in semicolon_split_string {
                                let colon_parts = split_and_trim(string: part, separator: ":")
                                if colon_parts.count != 2 {
                                        error = true
                                        return
                                }
                                levels.append(colon_parts[1])
                        }

                        value_for_sample_levels.append(levels[0])
                        src_levels.append(levels[1])
                }
        }






}
