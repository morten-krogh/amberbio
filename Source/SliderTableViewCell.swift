import UIKit

class SliderTableViewCell: UITableViewCell {

        let slider = UISlider()
        var current_target = false

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                selectionStyle = UITableViewCellSelectionStyle.None
                contentView.addSubview(slider)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                slider.frame = CGRectInset(contentView.frame, 20, 5)
        }

        func update(minimum_value minimum_value: Double, maximum_value: Double, value: Double, target: AnyObject?, selector: Selector) {
                slider.minimumValue = Float(minimum_value)
                slider.maximumValue = Float(maximum_value)
                slider.value = Float(value)

                if !current_target {
                        slider.addTarget(target, action: selector, forControlEvents: .ValueChanged)
                        current_target = true
                }
        }
}
