import UIKit

class DrawView: UIView, UIScrollViewDelegate, DrawViewTiledLayerViewDelegate {

        let scroll_view = UIScrollView()
        var draw_view_tiled_layer_view: DrawViewTiledLayerView!

        override init(frame: CGRect) {
                super.init(frame: frame)

                scroll_view.delegate = self
                addSubview(scroll_view)

                draw_view_tiled_layer_view = DrawViewTiledLayerView(frame: CGRect.zero, delegate: self)
                scroll_view.addSubview(draw_view_tiled_layer_view)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        









        func draw(context context: CGContext, rect: CGRect) {

        }
}

protocol DrawViewTiledLayerViewDelegate: class {
        func draw (context context: CGContext, rect: CGRect) -> Void
}

class DrawViewTiledLayerView: UIView {

        unowned let delegate: DrawViewTiledLayerViewDelegate
        
        init(frame: CGRect, delegate: DrawViewTiledLayerViewDelegate) {
                self.delegate = delegate
                super.init(frame: frame)
                backgroundColor = UIColor.whiteColor()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func set_levels_of_detail(maximum_zoom_scale: CGFloat, minimum_zoom_scale: CGFloat) {
                (layer as! CATiledLayer).levelsOfDetail = Int(floor(log(maximum_zoom_scale / minimum_zoom_scale) / log(2.0)) + 1)
                (layer as! CATiledLayer).levelsOfDetailBias = Int(ceil(log(maximum_zoom_scale) / log(2.0)))
                setNeedsDisplay()
        }

        override class func layerClass() -> AnyClass {
                return CATiledLayer.self
        }

        override func drawRect(rect: CGRect) {
                if let context = UIGraphicsGetCurrentContext() {
                        delegate.draw(context: context, rect: rect)
                }
        }
}
