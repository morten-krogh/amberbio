import UIKit

class PairedComparisonFactorState: PageState {

        var pairing_factor_id = 0

        init(pairing_factor_id: Int) {
                super.init()
                name = "paired_comparison_factor"
                title = astring_body(string: "Paired test")
                info = "Select a comparison factor\n\nThe levels will be selected on the next page."
                self.pairing_factor_id = pairing_factor_id
        }
}

class PairedComparisonFactor: Component, UITableViewDataSource, UITableViewDelegate {

        var pairing_factor_id = 0
        var pairing_factor_index = 0

        let pairing_factor_label = UILabel()
        let table_view = UITableView()

        override func viewDidLoad() {
                super.viewDidLoad()

                pairing_factor_label.textAlignment = .Center
                view.addSubview(pairing_factor_label)

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None

                view.addSubview(table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                var origin_y = 30 as CGFloat

                pairing_factor_label.sizeToFit()
                pairing_factor_label.frame = CGRect(x: 0, y: origin_y, width: view.frame.width, height: pairing_factor_label.frame.height)

                origin_y += pairing_factor_label.frame.height + 5

                table_view.frame = CGRect(x: 0, y: origin_y, width: view.frame.width, height: view.frame.height - origin_y)
        }

        override func render() {
                pairing_factor_id = (state.page_state as! PairedComparisonFactorState).pairing_factor_id
                pairing_factor_index = state.factor_ids.indexOf(pairing_factor_id)!

                let pairing_factor_name = state.factor_names[pairing_factor_index]
                pairing_factor_label.attributedText = astring_body(string: "The pairing factor is \(pairing_factor_name)")
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView
                header.update_normal(text: "Select a comparison factor")
                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return state.factor_ids.count - 1
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell
                let index = indexPath.row + (indexPath.row < pairing_factor_index ? 0 : 1)
                let factor_name = state.factor_names[index]
                cell.update_selectable_arrow(text: factor_name)
                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let index = indexPath.row + (indexPath.row < pairing_factor_index ? 0 : 1)
                let comparison_factor_id = state.factor_ids[index]
                let paired_level_state = PairedLevelState(pairing_factor_id: pairing_factor_id, comparison_factor_id: comparison_factor_id, level_id_pairs: [])
                state.navigate(page_state: paired_level_state)
                state.render()
        }
}
