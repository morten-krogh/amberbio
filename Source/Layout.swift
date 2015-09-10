import UIKit

func add_child_view_controller(parent parent: UIViewController, child: UIViewController) {
        parent.addChildViewController(child)
        parent.view.addSubview(child.view)
        child.didMoveToParentViewController(parent)
}

func remove_child_view_controller(child child: UIViewController) {
        child.willMoveToParentViewController(nil)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
}

func layout_centered_frame(contentSize contentSize: CGSize, rect: CGRect) -> CGRect {
                var frame = rect
                if contentSize.width < rect.size.width {
                        frame.origin.x += (rect.size.width - contentSize.width) / 2.0
                        frame.size.width = contentSize.width
                }
                if contentSize.height < rect.size.height {
                        frame.origin.y += (rect.size.height - contentSize.height) / 2.0
                        frame.size.height = contentSize.height
                }
                return frame
}


