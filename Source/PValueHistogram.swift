import UIKit

class PValueHistogramState: PageState {

        var histogram_title = ""
        var p_values = [] as [Double]

        init(histogram_title: String, p_values: [Double]) {
                super.init()
                name = "p_value_histogram"
                title = astring_body(string: "p-value histogram")
                info = "P-values are collected into twenty bins of size 0.05.\n\nThe y-axis represents the frequencies of the bins.\n\nThe x-axis represents the p-values.\n\nThe bin of p-value below 0.05 is red.\n\nThe left most bins should be taller than the rest in case of a test with a significant difference between the groups.\n\nThe stipulated line is the expected average frequency"
                self.histogram_title = histogram_title
                self.p_values = p_values

                pdf_enabled = true
        }
}

class PValueHistogram: Component {

        var p_value_histogram_state: PValueHistogramState!

        let info_label = UILabel()
        let tiled_scroll_view = TiledScrollView(frame: CGRect.zeroRect)
        let p_value_histogram_delegate = PValueHistogramDelegate()

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(info_label)

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                let margin = 20 as CGFloat
                info_label.frame = CGRect(x: margin, y: 15, width: width - 2 * margin, height: info_label.frame.height)

                let origin_y = CGRectGetMaxY(info_label.frame) + 10
                let height_tiled_scroll_view = height - origin_y

                let min_zoom = min(width / p_value_histogram_delegate.content_size.width, height_tiled_scroll_view / p_value_histogram_delegate.content_size.height)
                p_value_histogram_delegate.minimum_zoom_scale = min_zoom
                p_value_histogram_delegate.maximum_zoom_scale = 3 * p_value_histogram_delegate.minimum_zoom_scale

                tiled_scroll_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height_tiled_scroll_view)
                tiled_scroll_view.scroll_view.zoomScale = p_value_histogram_delegate.minimum_zoom_scale

        }

        override func render() {
                p_value_histogram_state = state.page_state as! PValueHistogramState

                info_label.attributedText = astring_body(string: p_value_histogram_state.histogram_title)
                info_label.sizeToFit()
                info_label.textAlignment = .Center

                p_value_histogram_delegate.update(p_values: p_value_histogram_state.p_values, number_of_bins: 20)
                tiled_scroll_view.delegate = p_value_histogram_delegate
        }

        func pdf_action() {
                let file_name_stem = "p-value histogram"
                let description = p_value_histogram_state.histogram_title
                state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: p_value_histogram_delegate.content_size, draw: p_value_histogram_delegate.draw)
                state.render()
        }
}
