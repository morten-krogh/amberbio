import UIKit

protocol TiledScrollViewDelegate: class {
        var content_size: CGSize {get set}
        var maximum_zoom_scale: CGFloat {get set}
        var minimum_zoom_scale: CGFloat {get set}
        func draw(context context: CGContext, rect: CGRect)
        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat)
        func tap_action(location location: CGPoint)
}

class TiledScrollView: UIView, UIScrollViewDelegate, TiledLayerViewDelegate {

        override var frame: CGRect {
                didSet {
                        propertiesDidChange()
                }
        }

        weak var delegate: TiledScrollViewDelegate? {
                didSet {
                        propertiesDidChange()
                }
        }

        let scroll_view = UIScrollView(frame: CGRect.zero)
        let tiled_view = TiledLayerView(frame: CGRect.zero)
        var levelsOfDetail = 1
        var levelsOfDetailBias = 0

        override init (frame: CGRect) {
                super.init(frame: frame)
                scroll_view.delegate = self
                tiled_view.delegate = self

                addSubview(scroll_view)
                scroll_view.addSubview(tiled_view)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_action:")
                tiled_view.addGestureRecognizer(tap_recognizer)
        }

        convenience init() {
                self.init(frame: CGRect.zero)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func propertiesDidChange () {
                scroll_view.frame = bounds
                scroll_view.zoomScale = 1.0
                if let delegate = delegate {
                        tiled_view.frame = CGRect(origin: CGPoint.zero, size: delegate.content_size)
                        scroll_view.contentSize = delegate.content_size
                        levelsOfDetail = Int(floor(log(delegate.maximum_zoom_scale / delegate.minimum_zoom_scale) / log(2.0)) + 1)
                        levelsOfDetailBias = Int(ceil(log(delegate.maximum_zoom_scale) / log(2.0)))
                        scroll_view.maximumZoomScale = delegate.maximum_zoom_scale
                        scroll_view.minimumZoomScale = delegate.minimum_zoom_scale
                        layoutScrollView()
                } else {
                        tiled_view.frame = CGRect.zero
                        levelsOfDetail = 1
                        levelsOfDetailBias = 0
                        scroll_view.contentSize = CGSize.zero
                        scroll_view.maximumZoomScale = 1
                        scroll_view.minimumZoomScale = 1
                }
                tiled_view.delegate = self
        }

        func layoutScrollView () {
                if let delegate = delegate {
                        let scaledContentSize = CGSizeApplyAffineTransform(delegate.content_size, CGAffineTransformMakeScale(scroll_view.zoomScale, scroll_view.zoomScale))
                        if scaledContentSize.width < bounds.width {
                                scroll_view.frame.origin.x = (bounds.width - scaledContentSize.width) / 2.0
                                scroll_view.frame.size.width = scaledContentSize.width
                        } else {
                                scroll_view.frame.origin.x = 0
                                scroll_view.frame.size.width = bounds.width
                        }
                        if scaledContentSize.height < bounds.height {
                                scroll_view.frame.origin.y = (bounds.height - scaledContentSize.height) / 2.0
                                scroll_view.frame.size.height = scaledContentSize.height
                        } else {
                                scroll_view.frame.origin.y = 0
                                scroll_view.frame.size.height = bounds.height
                        }
                        tiled_view.frame = CGRect(origin: CGPoint.zero, size: scaledContentSize)
                }
        }

        func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
                return tiled_view
        }

        func scrollViewDidZoom(scrollView: UIScrollView) {
                layoutScrollView()
        }

        func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
                layoutScrollView()
                delegate?.scroll_view_did_end_zooming(zoom_scale: scrollView.zoomScale)
        }

        func draw (context context: CGContext, rect: CGRect) {
                delegate?.draw(context: context, rect: rect)
        }

        func tap_action(recognizer: UITapGestureRecognizer) {
                let location = recognizer.locationInView(tiled_view)
                delegate?.tap_action(location: location)
        }
}
