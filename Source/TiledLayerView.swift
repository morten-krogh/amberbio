import UIKit

protocol TiledLayerViewDelegate: class {
        var levelsOfDetail: Int {get}
        var levelsOfDetailBias: Int {get}

        func draw (context context: CGContext, rect: CGRect) -> Void
}

class TiledLayerView: UIView {

        weak var delegate: TiledLayerViewDelegate? {
                didSet {
                        delegateDidChange()
                }
        }

        override init (frame: CGRect) {
                super.init(frame: frame)
                backgroundColor = UIColor.whiteColor()
                delegateDidChange()
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        func delegateDidChange() {
                if let delegate = delegate {
                        (layer as! CATiledLayer).levelsOfDetail = delegate.levelsOfDetail
                        (layer as! CATiledLayer).levelsOfDetailBias = delegate.levelsOfDetailBias
                } else {
                        (layer as! CATiledLayer).levelsOfDetail = 1
                        (layer as! CATiledLayer).levelsOfDetailBias = 0
                }
                setNeedsDisplay()
        }

        override class func layerClass() -> AnyClass {
                return CATiledLayer.self
        }

        override func drawRect(rect: CGRect) {
                let ctx = UIGraphicsGetCurrentContext()
                delegate?.draw(context: ctx!, rect: rect)
        }
}
