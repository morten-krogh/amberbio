import UIKit

class StoreFrontState: PageState {

        override init() {
                super.init()
                name = "store_front"
                title = astring_body(string: "Store")
                info = "The store is used to purchase modules.\n\nA purchased module is unlocked forever on this device and other devices with the same Apple ID.\n\nTap the button \"Restore modules\" to unlock modules that have been purchased on another device or on as previous installation of this app."

                state.store.request_products()
        }
}

class StoreFront: Component, UITableViewDataSource, UITableViewDelegate {

        let request_products_pending_label = UILabel()
        let table_view = UITableView()

        override func viewDidLoad() {
                super.viewDidLoad()

                request_products_pending_label.attributedText = astring_font_size_color(string: "The products are fetched from the server", font: nil, font_size: 20, color: nil)
                view.addSubview(request_products_pending_label)

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "centered header")
                table_view.registerClass(CenteredTableViewCell.self, forCellReuseIdentifier: "centered cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
                view.addSubview(table_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width

                request_products_pending_label.sizeToFit()
                request_products_pending_label.center = CGPoint(x: width / 2, y: 100)

                table_view.frame = view.bounds
        }

        override func render() {
                request_products_pending_label.hidden = !state.store.request_products_pending
                table_view.hidden = state.store.request_products_pending
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 2
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("centered header") as! CenteredHeaderFooterView

                let text: String
                if section == 0 {
                        text = "Modules to purchase"
                } else {
                        text = "Purchased modules"
                }
                header.update_normal(text: text)

                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                if section == 0 {
                        return state.store.unpurchased_products.count
                } else {
                        return state.store.purchased_products.count
                }
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return centered_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("centered cell") as! CenteredTableViewCell

                let (section, row) = (indexPath.section, indexPath.row)

                if section == 0 {
                        let product = state.store.unpurchased_products[row]
                        let text = product.localizedTitle + ": " + "\(product.price)"
                        cell.update_normal(text: text)
                } else {
                        let product = state.store.purchased_products[row]
                        let text = product.localizedTitle + ": " + "\(product.price)"
                        cell.update_normal(text: text)
                }

                return cell
        }



        


}
