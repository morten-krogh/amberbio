import UIKit

class FactorSummaryState: PageState {

        override init() {
                super.init()
                name = "factor_summary"
                title = astring_body(string: "Factor Summary")
                info = "Select a factor to see a summary."
        }
}

class FactorSummary: Component, UITableViewDataSource, UITableViewDelegate {

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.dataSource = self
                table_view.delegate = self
                table_view.separatorStyle = UITableViewCellSeparatorStyle.None
                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.backgroundColor = UIColor.whiteColor()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView
                header.update_normal(text: "Select a factor")
                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return state.factor_ids.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CenteredTableViewCell
                cell.update_selectable_arrow(text: state.factor_names[indexPath.row])
                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                tableView.cellForRowAtIndexPath(indexPath)?.selected = false
                let factor_id = state.factor_ids[indexPath.row]
                let factor_summary_detail_state = FactorSummaryDetailState(factor_id: factor_id)
                state.navigate(page_state: factor_summary_detail_state)
                state.render()
        }
}
