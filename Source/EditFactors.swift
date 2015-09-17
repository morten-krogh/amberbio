import UIKit

class EditFactorsState: PageState {

        override init() {
                super.init()
                name = "edit_factors"
                title = astring_body(string: "Edit Factors")
                info = "Tap a factor to edit.\n\nDelete a factor by swiping.\n\nAdd a new factor by tapping \"New factor\"."
        }
}

class EditFactors: Component, UITableViewDataSource, UITableViewDelegate {

        let add_factor_button = UIButton(type: UIButtonType.System)
        let table_view = UITableView()

        var reload = true

        override func viewDidLoad() {
                super.viewDidLoad()

                add_factor_button.setAttributedTitle(astring_body(string: "New factor"), forState: .Normal)
                add_factor_button.addTarget(self, action: "add_factor_action", forControlEvents: .TouchUpInside)

                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None

                view.addSubview(add_factor_button)
                view.addSubview(table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                add_factor_button.sizeToFit()
                add_factor_button.frame.origin = CGPoint(x: (width - add_factor_button.frame.width) / 2, y: 20)

                let origin_y = CGRectGetMaxY(add_factor_button.frame) + 25
                table_view.frame = CGRect(x: 0, y: origin_y, width: width, height: view.frame.height - origin_y)
        }

        override func render() {
                if reload {
                        table_view.reloadData()
                }
                reload = true
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
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

        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                if editingStyle == .Delete {
                        let factor_id = state.factor_ids[indexPath.row]
                        state.delete_factor(factor_id: factor_id)
                        reload = false
                        state.render()
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                tableView.cellForRowAtIndexPath(indexPath)?.selected = false
                let factor_id = state.factor_ids[indexPath.row]
                let edit_factor_state = EditFactorState(factor_id: factor_id)
                state.navigate(page_state: edit_factor_state)
                state.render()
        }

        func add_factor_action() {
                let edit_factor_state = EditFactorState(factor_id: nil)
                state.navigate(page_state: edit_factor_state)
                state.render()
        }
}
