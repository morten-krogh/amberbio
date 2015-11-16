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

                        let gds = gds_new(content.bytes, content.length)
                        let valid = gds_valid(gds);

                        if (valid) {
                                let header = String.fromCString(gds_header(gds))
                                let values = gds_values(gds)
                                label.text = header

                                print(values[0], values[17])
                        }

                        print(valid)

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

//class GDSParser {
//
//        var error: String?
//
//        let data: NSData
//
//        var header = ""
//
//        var dataset_info = ""
//        var feature_count = 0
//        var column_names = [] as [String]
//        var sample_column_min = -1
//        var sample_names = [] as [String]
//        var sample_values = [] as [String]
//        var value_for_sample_levels = [] as [String]
//        var src_levels = [] as [String]
//
//        var factor_names = [] as [String]
//        var levels_for_samples = [] as [[String]]
//
//        init(data: NSData) {
//                self.data = data
//                parse()
//        }
//
//        func parse() {
//                let full_range = NSRange(0 ..< data.length)
//                let range_dataset_table_begin = data.rangeOfData("!dataset_table_begin".dataUsingEncoding(NSUTF8StringEncoding)!, options: [], range: full_range)
//
//                if range_dataset_table_begin.location == NSNotFound {
//                        error = "header not found"
//                        return
//                }
//
//                let header_range = NSRange(0 ..< range_dataset_table_begin.location)
//                let data_header =  data.subdataWithRange(header_range)
//                header = String(data: data_header, encoding: NSUTF8StringEncoding) ?? ""
//
//                parse_header()
//                if error != nil {
//                        return
//                }
//                make_factors()
//                if error != nil {
//                        return
//                }
//
//                print(feature_count)
//                print(value_for_sample_levels)
//                print(src_levels)
//                print(sample_column_min)
//
//                let bytes = UnsafePointer<UInt8>(data.bytes)
//
//                var index_0 = range_dataset_table_begin.location + range_dataset_table_begin.length + 1
//                for i in index_0 ..< data.length {
//                        if bytes[i] == 10 {
//                                index_0 = i + 1
//                                break
//                        }
//                }

//                var values = [Double](count: feature_count * sample_names.count, repeatedValue: Double.NaN)
//                var row_number = 0
//                var column_number = 0
//                var index_1 = index_0
//                while index_1 < data.length {
//                        if bytes[index_1] == 9 || bytes[index_0] == 10 {
//                                if column_number >= sample_column_min && column_number < sample_column_min + sample_names.count {
//
//
//                                }
//                        }
//                        index_1++
//                }



//                let range = NSRange(1 ..< 20)
//                let str = NSString(data: data.subdataWithRange(range), encoding: NSUTF8StringEncoding) ?? ""
//                print(str)


//                var index = string.startIndex
//
//                print(string.substringWithRange(index ..< index.advancedBy(2))
//
//                while index != string.endIndex {
////                        string.substringWithRange(<#T##aRange: Range<Index>##Range<Index>#>)
//
//                }








//
//
//
//
//        }
//
//        func split_and_trim(string string: String, separator: String) -> [String] {
//                let comps = string.componentsSeparatedByString(separator)
//                return comps.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }
//        }
//
//        func parse_header() {
//                let lines = header.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
//
//                var index_caret_dataset = 0
//                for line in lines {
//                        if line.hasPrefix("^DATASET") {
//                                break
//                        }
//                        index_caret_dataset++
//                }
//
//                var dataset_info_array = [] as [String]
//                for i in (index_caret_dataset + 1) ..< lines.count {
//                        if !lines[i].hasPrefix("^") {
//                                dataset_info_array.append(lines[i])
//                        } else {
//                                break
//                        }
//                }
//
//                dataset_info = dataset_info_array.joinWithSeparator("\n")
//
//                for line in lines {
//                        if line.hasPrefix("!dataset_feature_count") {
//                                let comps = split_and_trim(string: line, separator: "=")
//                                if comps.count == 2, let number = Int(comps[1]) {
//                                        feature_count = number
//                                } else {
//                                        error = "incorrect feature count"
//                                        return
//                                }
//                        }
//
//                        if line.hasPrefix("#") {
//                                let index = line.startIndex.advancedBy(1)
//                                let line_without_pound = line.substringFromIndex(index)
//                                let comps = split_and_trim(string: line_without_pound, separator: "=")
//                                if comps.count != 2 {
//                                        error = "incorrect column names"
//                                        return
//                                }
//                                column_names.append(comps[0])
//
//                                if comps[0].hasPrefix("GSM") {
//                                        if sample_column_min == -1 {
//                                                sample_column_min = column_names.count - 1
//                                        }
//
//                                        sample_names.append(comps[0])
//                                        sample_values.append(comps[1])
//                                }
//                        }
//
//
//
//                }
//        }
//
//        func make_factors() {
//                for sample_value in sample_values {
//                        let semicolon_split_string = split_and_trim(string: sample_value, separator: ";")
//                        if semicolon_split_string.count != 2 {
//                                error = "incorrect sample values"
//                                return
//                        }
//                        var levels = [] as [String]
//                        for part in semicolon_split_string {
//                                let colon_parts = split_and_trim(string: part, separator: ":")
//                                if colon_parts.count != 2 {
//                                        error = "incorrect factors"
//                                        return
//                                }
//                                levels.append(colon_parts[1])
//                        }
//                        
//                        value_for_sample_levels.append(levels[0])
//                        src_levels.append(levels[1])
//                }
//        }
//}




//class GEOSoftFileParser {
//
//        var error = false
//
//        let data: NSData
//
//        let header: String
//
//        var dataset_info = ""
//        var feature_count = 0
//        var column_names = [] as [String]
//        var sample_names = [] as [String]
//        var sample_values = [] as [String]
//        var value_for_sample_levels = [] as [String]
//        var src_levels = [] as [String]
//
//        var factor_names = [] as [String]
//        var levels_for_samples = [] as [[String]]
//
//        init(data: NSData) {
//                self.data = data
//
//                var cstring = [CChar](count: 10000, repeatedValue: 0)
//
//                geo_soft_find_header(data.bytes, data.length, &cstring, cstring.count - 1)
//
//                header = String.fromCString(cstring) ?? ""
//                parse_header()
//                if error {
//                        return
//                }
//                make_factors()
//                if error {
//                        return
//                }
//                print(value_for_sample_levels)
//                print(src_levels)
//
//        }
//
//        func split_and_trim(string string: String, separator: String) -> [String] {
//                let comps = string.componentsSeparatedByString(separator)
//                return comps.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }
//        }
//
//
//
//
//
//
//
//}
