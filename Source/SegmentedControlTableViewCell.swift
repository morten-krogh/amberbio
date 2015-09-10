import UIKit

let segmented_control_table_view_cell_height = 50 as CGFloat

class SegmentedControlTableViewCell: UITableViewCell {

        let segmented_control = UISegmentedControl()
        var items = [] as [String]
        var current_target = false

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.addSubview(segmented_control)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                segmented_control.frame = CGRectInset(contentView.frame, 20, 5)
        }
        
        func update(items items: [String], selected_segment_index: Int, target: AnyObject?, selector: Selector) {
                if items_changed(items: items) {
                        segmented_control.removeAllSegments()
                        for i in 0 ..< items.count {
                                segmented_control.insertSegmentWithTitle(items[i], atIndex: i, animated: false)
                        }
                        self.items = items
                }

                segmented_control.selectedSegmentIndex = selected_segment_index
                if !current_target {
                        segmented_control.addTarget(target, action: selector, forControlEvents: .ValueChanged)
                        current_target = true
                }
        }

        func items_changed(items items: [String]) -> Bool {
                if items.count != self.items.count {
                        return true
                }
                for i in 0 ..< items.count {
                        if items[i] != self.items[i] {
                                return true
                        }
                }
                return false
        }
}
