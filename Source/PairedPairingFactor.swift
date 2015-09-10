import UIKit

class PairedPairingFactorState: PageState {

        override init() {
                super.init()
                name = "paired_pairing_factor"
                title = astring_body(string: "Paired test")
                info = "The pairing factor specifies the samples that should be paired.\n\nA pair is specified by a level with exactly two samples.\n\nLevels where the number of samples is different from two are ignored in the test."
        }
}

class PairedPairingFactor: Component, UITableViewDataSource, UITableViewDelegate {

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView
                header.update_normal(text: "Select a pairing factor")
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

                let factor_name = state.factor_names[indexPath.row]
                cell.update_selectable_arrow(text: factor_name)
                return cell
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let factor_id = state.factor_ids[indexPath.row]
                let paired_comparison_factor_state = PairedComparisonFactorState(pairing_factor_id: factor_id)
                state.navigate(page_state: paired_comparison_factor_state)
                state.render()
        }
}
