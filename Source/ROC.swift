import UIKit

class ROC: TiledScrollViewDelegate {

        var content_size = CGSize(width: 500, height: 700)
        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 1 as CGFloat

        init(label_name_1: String, label_name_2: String, decision_values_1: [Double], decision_values_2: [Double]) {
                // high decision values are in group 1





        }


        let box_lower_left = CGPoint(x: 100, y: 600)
        let box_upper_right = CGPoint(x: 490, y: 200)
        let tick_length = 20 as CGFloat


        func draw(context context: CGContext, rect: CGRect) {
                draw_box(context: context)
                draw_ticks(context: context)


        }


        func draw_box(context context: CGContext) {
                let box_upper_left = CGPoint(x: box_lower_left.x, y: box_upper_right.y)
                let box_lower_right = CGPoint(x: box_upper_right.x, y: box_lower_left.y)
                drawing_draw_line(context: context, start_point: box_lower_left, end_point: box_upper_left)
                drawing_draw_line(context: context, start_point: box_upper_left, end_point: box_upper_right)
                drawing_draw_line(context: context, start_point: box_upper_right, end_point: box_lower_right)
                drawing_draw_line(context: context, start_point: box_lower_right, end_point: box_lower_left)
        }

        func draw_ticks(context context: CGContext) {
                for value_1 in [0.2, 0.4, 0.6, 0.8] {
                        let point = value_to_point(value_1: value_1, value_2: 0)
                        let start_point = CGPoint(x: point.x, y: point.y + tick_length / 2)
                        let end_point = CGPoint(x: point.x, y: point.y - tick_length / 2)
                        drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                        let astring = astring_body(string: String(value_1))
                        let point_text = CGPoint(x: point.x, y: point.y + tick_length)

                        drawing_draw_attributed_text(context: context, attributed_text: astring, origin: point_text, horizontal: true)

                }

                for value_2 in [0.2, 0.4, 0.6, 0.8] {
                        let point = value_to_point(value_1: 0, value_2: value_2)
                        let start_point = CGPoint(x: point.x - tick_length / 2, y: point.y)
                        let end_point = CGPoint(x: point.x + tick_length / 2, y: point.y)
                        drawing_draw_line(context: context, start_point: start_point, end_point: end_point)
                }


        }

        func value_to_point(value_1 value_1: Double, value_2: Double) -> CGPoint {
                let x = CGFloat(value_1) * (box_upper_right.x - box_lower_left.x) + box_lower_left.x
                let y = CGFloat(value_2) * (box_upper_right.y - box_lower_left.y) + box_lower_left.y
                return CGPoint(x: x, y: y)
        }



        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {}


        func tap_action(location location: CGPoint) {}
}
