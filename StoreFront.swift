import UIKit

class StoreFrontState: PageState {

        override init() {
                super.init()
                name = "store_Front"
                title = astring_body(string: "Store")
                info = "The store is used to purchase modules.\n\nA purchased module is unlocked forever on this device and other devices with the same Apple ID.\n\nTap the button \"Restore modules\" to unlock modules that have been purchased on another device or on as previous installation of this app."
        }
}

class StoreFront: Component, UITableViewDataSource, UITableViewDelegate {

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "centered header")
                table_view.registerClass(CenteredTableViewCell.self, forHeaderFooterViewReuseIdentifier: "centered cell")
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
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("centered header") as! CenteredHeaderFooterView

                header.update_normal(text: "Modules to purchase")

                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return state.store.products.count
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("centered cell") as! CenteredTableViewCell

                let (section, row) = (indexPath.section, indexPath.row)

                if section == 0 {
                        let product = state.store.products[row]
                        let text = product.localizedTitle + ": " + "\(product.price)"

                        cell.update_normal(text: text)
                }

                return cell
        }



        


}
