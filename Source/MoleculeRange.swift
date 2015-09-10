import UIKit

protocol MoleculeRangeDelegate {
        func molecule_range_select() -> ()
        func molecule_range_cancel() -> ()
        func molecule_range_create_data_set(index1 index1: Int, index2: Int) -> ()
}

class MoleculeRange: UIView {

        var state = ""
        var selected_index_1: Int?
        var selected_index_2: Int?

        let info_label = UILabel()
        let cancel_button = UIButton(type: UIButtonType.System)
        let create_dataset_button = UIButton(type: UIButtonType.System)

        let delegate: MoleculeRangeDelegate

        init(delegate: MoleculeRangeDelegate) {
                self.delegate = delegate
                super.init(frame: CGRect.zero)

                info_label.textAlignment = .Center

                cancel_button.setAttributedTitle(astring_font_size_color(string: "cancel", font_size: 18), forState: UIControlState.Normal)
                cancel_button.addTarget(self, action: "cancel_action", forControlEvents: UIControlEvents.TouchUpInside)
                cancel_button.sizeToFit()

                create_dataset_button.setAttributedTitle(astring_font_size_color(string: "create", font_size: 18), forState: UIControlState.Normal)
                create_dataset_button.addTarget(self, action: "create_data_set_action", forControlEvents: UIControlEvents.TouchUpInside)
                create_dataset_button.sizeToFit()

                addSubview(info_label)
                addSubview(cancel_button)
                addSubview(create_dataset_button)

                render()
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()

                let width = frame.width
                let height = frame.height
                let margin = 10 as CGFloat

                let position_y = (height - cancel_button.frame.height) / 2
                var position_x = width - cancel_button.frame.width - margin
                cancel_button.frame.origin = CGPoint(x: position_x, y: position_y)

                position_x -= margin + create_dataset_button.frame.width
                create_dataset_button.frame.origin = CGPoint(x: position_x, y: position_y)

                position_x -= margin
                let width_info = max(0, position_x - margin)
                info_label.frame = CGRect(x: margin, y: position_y, width: width_info, height: create_dataset_button.frame.height)
        }

        func render() {
                var info_label_text = ""
                if selected_index_1 == nil {
                        info_label_text = "tap a row"
                        create_dataset_button.enabled = false
                } else if selected_index_2 == nil {
                        info_label_text = "tap another row"
                        create_dataset_button.enabled = false
                } else {
                        let min_index = min(selected_index_1!, selected_index_2!) + 1
                        let max_index = max(selected_index_1!, selected_index_2!) + 1
                        info_label_text = "rows  \(min_index) - \(max_index) selected"
                        create_dataset_button.enabled = true
                }
                info_label.attributedText = astring_font_size_color(string: info_label_text, font_size: 18)
                info_label.textAlignment = .Center
        }

        func cancel_action() {
                selected_index_1 = nil
                selected_index_2 = nil
                delegate.molecule_range_cancel()
        }

        func create_data_set_action() {
                if let index1 = selected_index_1, let index2 = selected_index_2 {
                        let min_index = min(index1, index2)
                        let max_index = max(index1, index2)
                        delegate.molecule_range_create_data_set(index1: min_index, index2: max_index)
                }
        }

        func select_index(index index: Int) {
                if selected_index_1 == nil {
                        selected_index_1 = index
                } else if selected_index_2 == nil {
                        selected_index_2 = index
                }
                render()
        }
}
