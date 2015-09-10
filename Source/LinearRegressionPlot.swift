import UIKit

class LinearRegressionPlotState: PageState {

        var factor_id = 0
        var factor_index = 0
        var factor_name = ""

        var molecule_number = 0

        var next_molecule_numbers = [] as [Int]
        var previous_molecule_numbers = [] as [Int]

        var x_values = [] as [[Double]]
        var y_values = [] as [[Double]]
        var slopes = [] as [Double]
        var intercepts = [] as [Double]

        var molecule_name = ""
        var current_x_values = [] as [Double]
        var current_y_values = [] as [Double]
        var tick_values = [] as [Double]
        var minimum_x_value = 0 as Double
        var maximum_x_value = 0 as Double
        var minimum_y_value = 0 as Double
        var maximum_y_value = 0 as Double
        var slope = 0 as Double
        var intercept = 0 as Double

        init(factor_id: Int, molecule_number: Int, next_molecule_numbers: [Int], previous_molecule_numbers: [Int], x_values: [[Double]], y_values: [[Double]], slopes: [Double], intercepts: [Double]) {
                super.init()
                name = "linear_regression_plot"
                title = astring_body(string: "Linear regression plot")
                self.factor_id = factor_id
                self.factor_index = state.factor_ids.indexOf(factor_id)!
                self.factor_name = state.factor_names[factor_index]
                info = "A plot of the values for a single molecule in the active data set as a function of the factor \(factor_name).\n\nThe best fit line is plotted."
                self.molecule_number = molecule_number
                self.next_molecule_numbers = next_molecule_numbers
                self.previous_molecule_numbers = previous_molecule_numbers
                self.x_values = x_values
                self.y_values = y_values
                self.slopes = slopes
                self.intercepts = intercepts
                current()

                full_screen = true
                pdf_enabled = true
        }

        func current() {
                molecule_name = state.molecule_names[molecule_number]
                current_x_values = x_values[molecule_number]
                current_y_values = y_values[molecule_number]
                var tick_value_set = [] as Set<Double>
                for value in current_x_values {
                        tick_value_set.insert(value)
                }
                tick_values = [Double](tick_value_set).sort()
                minimum_x_value = !tick_values.isEmpty ? tick_values[0] : 0
                maximum_x_value = !tick_values.isEmpty ? tick_values[tick_values.count - 1] : 0
                minimum_y_value = Double.infinity
                maximum_y_value = -Double.infinity
                (minimum_y_value, maximum_y_value) = math_min_max(numbers: current_y_values)
                slope = slopes[molecule_number]
                intercept = intercepts[molecule_number]
        }

        func next() {
                if !next_molecule_numbers.isEmpty {
                        let new_molecule_number = next_molecule_numbers.removeLast()
                        previous_molecule_numbers.append(molecule_number)
                        molecule_number = new_molecule_number
                        current()
                }
        }

        func previous() {
                if !previous_molecule_numbers.isEmpty {
                        let new_molecule_number = previous_molecule_numbers.removeLast()
                        next_molecule_numbers.append(molecule_number)
                        molecule_number = new_molecule_number
                        current()
                }
        }
}

class LinearRegressionPlot: Component {

        var linear_regression_plot_state: LinearRegressionPlotState!

        let next_button = UIButton(type: UIButtonType.System)
        let previous_button = UIButton(type: UIButtonType.System)
        let info_label = UILabel()

        let tiled_scroll_view = TiledScrollView(frame: CGRect.zeroRect)
        var linear_regression_drawer: LinearRegressionDrawer?

        override func viewDidLoad() {
                super.viewDidLoad()

                next_button.addTarget(self, action: "next_action", forControlEvents: UIControlEvents.TouchUpInside)
                next_button.setAttributedTitle(astring_font_size_color(string: "next", font_size: 20 as CGFloat), forState: .Normal)

                previous_button.addTarget(self, action: "previous_action", forControlEvents: UIControlEvents.TouchUpInside)
                previous_button.setAttributedTitle(astring_font_size_color(string: "previous", font_size: 20 as CGFloat), forState: .Normal)

                info_label.textAlignment = .Center

                view.addSubview(next_button)
                view.addSubview(previous_button)
                view.addSubview(info_label)

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                let top_margin = 20 as CGFloat
                let side_margin = 20 as CGFloat

                var origin_y = 20 as CGFloat

                info_label.sizeToFit()
                info_label.frame = CGRect(x: 2 * side_margin + previous_button.frame.width, y: origin_y, width: width - 4 * side_margin - 2 * previous_button.frame.width, height: info_label.frame.height)

                next_button.sizeToFit()
                let origin_y_next = origin_y + (info_label.frame.height - next_button.frame.height) / 2
                next_button.frame.origin = CGPoint(x: width - side_margin - next_button.frame.width, y: origin_y_next)

                previous_button.sizeToFit()
                let origin_y_previous = origin_y + (info_label.frame.height - previous_button.frame.height) / 2
                previous_button.frame.origin = CGPoint(x: side_margin, y: origin_y_previous)

                origin_y += max(CGRectGetMaxY(info_label.frame), CGRectGetMaxY(next_button.frame), CGRectGetMaxY(previous_button.frame)) + top_margin

                if let linear_regression_drawer = linear_regression_drawer {
                        let linear_regression_rect = CGRect(x: side_margin, y: origin_y, width: width - 2 * side_margin, height: view.frame.height - origin_y)

                        let zoom_horizontal = max(0.2, min(1, linear_regression_rect.width / linear_regression_drawer.content_size.width))
                        let zoom_vertical = max(0.2, min(1, linear_regression_rect.height / linear_regression_drawer.content_size.height))

                        linear_regression_drawer.minimum_zoom_scale = min(zoom_horizontal, zoom_vertical)

                        tiled_scroll_view.frame = linear_regression_rect
                        tiled_scroll_view.scroll_view.zoomScale = linear_regression_drawer.minimum_zoom_scale
                }
        }

        override func render() {
                linear_regression_plot_state = state.page_state as! LinearRegressionPlotState

                next_button.hidden = linear_regression_plot_state.next_molecule_numbers.isEmpty
                previous_button.hidden = linear_regression_plot_state.previous_molecule_numbers.isEmpty

                info_label.attributedText = astring_body(string: linear_regression_plot_state.molecule_name)
                info_label.textAlignment = .Center

                linear_regression_drawer = LinearRegressionDrawer(x_values: linear_regression_plot_state.current_x_values, y_values: linear_regression_plot_state.current_y_values, tick_values: linear_regression_plot_state.tick_values, minimum_x_value: linear_regression_plot_state.minimum_x_value, maximum_x_value: linear_regression_plot_state.maximum_x_value, minimum_y_value: linear_regression_plot_state.minimum_y_value, maximum_y_value: linear_regression_plot_state.maximum_y_value, slope: linear_regression_plot_state.slope, intercept: linear_regression_plot_state.intercept, x_axis_title: linear_regression_plot_state.factor_name)
                tiled_scroll_view.delegate = linear_regression_drawer
                view.setNeedsLayout()
                view.setNeedsDisplay()
        }

        func pdf_action() {
                let file_name_stem = "linear-regression-plot"
                let description = "Plot of molecule \(linear_regression_plot_state.molecule_name).\nThe factor is \(linear_regression_plot_state.factor_name).\n"

                if let linear_regression_drawer = linear_regression_drawer {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: linear_regression_drawer.content_size, draw: linear_regression_drawer.draw)
                }
                state.render()
        }

        func next_action() {
                linear_regression_plot_state.next()
                state.render()
        }
        
        func previous_action() {
                linear_regression_plot_state.previous()
                state.render()
        }
}
