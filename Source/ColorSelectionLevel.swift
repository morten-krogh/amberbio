import UIKit

class ColorSelectionLevelState: PageState {

        override init() {
                super.init()
                name = "color_selection_level"
                title = astring_body(string: "Color Selection")
                info = "Each factor level is associated with a color that is used in plots throughout the app.\n\nSelect a level to change the color."
        }
}

class ColorSelectionLevel: Component, UITableViewDataSource, UITableViewDelegate {

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.dataSource = self
                table_view.delegate = self
                table_view.registerClass(ColorSelectionTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = UITableViewCellSeparatorStyle.None
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return state.factor_names.count
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height - 30
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header_view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text = state.factor_names[section]
                header_view.update_normal(text: text)

                return header_view
        }

        func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return 20
        }

        func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier("footer")
                footer?.contentView.backgroundColor = UIColor.whiteColor()
                return footer
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return state.level_ids_by_factor[section].count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return 60.0
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ColorSelectionTableViewCell

                let level_name = state.level_names_by_factor[indexPath.section][indexPath.row]
                let level_color = color_from_hex(hex: state.level_colors_by_factor[indexPath.section][indexPath.row])

                cell.update(text: level_name, color: level_color)

                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let factor_name = state.factor_names[indexPath.section]
                let level_id = state.level_ids_by_factor[indexPath.section][indexPath.row]
                let level_name = state.level_names_by_factor[indexPath.section][indexPath.row]
                let color = state.level_colors_by_factor[indexPath.section][indexPath.row]

                let page_state = ColorSelectionPickerState(level_id: level_id, level_name: level_name, factor_name: factor_name, color: color)

                state.navigate(page_state: page_state)
                state.render()
        }
}

class ColorSelectionTableViewCell: UITableViewCell {

        let inset_view = UIView()
        let label = UILabel()
        let color_circle = ColorCircle(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 10

                contentView.addSubview(inset_view)
                inset_view.addSubview(label)
                inset_view.addSubview(color_circle)

                selectionStyle = UITableViewCellSelectionStyle.None
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                inset_view.frame = CGRectInset(contentView.frame, 20, 8)

                let width = inset_view.frame.width
                let height = inset_view.frame.height

                let margin = 20 as CGFloat

                label.sizeToFit()
                label.frame = CGRect(x: margin, y: (height - label.frame.height) / 2.0, width: label.frame.width, height: label.frame.height)
                color_circle.frame.origin = CGPoint(x: width - margin - color_circle.frame.width, y: (height - color_circle.frame.height) / 2.0)
        }

        func update(text text: String, color: UIColor) {
                inset_view.backgroundColor = color_blue_selectable

                label.text = text
                label.textAlignment = .Center
                label.font = font_body

                color_circle.color = color

                setNeedsLayout()
        }
}
