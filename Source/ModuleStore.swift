import UIKit

class ModuleStoreState: PageState {

        override init() {
                super.init()
                name = "module_store"
                title = astring_body(string: "Module store")
                info = "The module store is used to purchase modules.\n\nA purchased module is unlocked forever on this device and other devices with the same Apple ID.\n\nTap the button \"Restore\" to unlock modules that have been purchased on another device or on a previous installation of this app.\n\nAll modules cen be freely used for the demo data sets."

                state.store.request_products()
        }
}

class ModuleStore: Component, UITableViewDataSource, UITableViewDelegate {

        let info_label = UILabel()
        let table_view = UITableView()

        override func viewDidLoad() {
                super.viewDidLoad()

                info_label.numberOfLines = 0
                view.addSubview(info_label)

                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "centered header")
                table_view.registerClass(StoreProductTableViewCell.self, forCellReuseIdentifier: "product cell")
                table_view.registerClass(StoreRestoreTableViewCell.self, forCellReuseIdentifier: "restore cell")
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

                let info_size = info_label.sizeThatFits(CGSize(width: width - 40, height: 0))
                info_label.frame.size = info_size
                info_label.center = CGPoint(x: width / 2, y: 100)

                table_view.frame = view.bounds
        }

        override func render() {
                info_label.hidden = false
                table_view.hidden = true

                if state.store.request_products_pending {
                        info_label.attributedText = astring_font_size_color(string: "The products are fetched from the server", font: nil, font_size: 20, color: nil)
                } else if state.store.restoring_pending {
                        info_label.attributedText = astring_font_size_color(string: "Restoring purchased modules", font: nil, font_size: 22, color: nil)
                } else {
                        table_view.hidden = false
                        table_view.reloadData()
                }
                view.setNeedsLayout()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 5
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("centered header") as! CenteredHeaderFooterView

                let text: String
                if section == 0 {
                        text = "Products to purchase"
                } else if section == 1 {
                        text = "Purchased products"
                } else if section == 2 {
                        text = "Restore purchased products"
                } else if section == 3 {
                        text = "Locked modules"
                } else {
                        text = "Unlocked modules"
                }
                header.update_normal(text: text)

                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                if section == 0 {
                        return state.store.products_to_purchase.count
                } else if section == 1 {
                        return state.store.purchased_products.count
                } else if section == 2 {
                        return 1
                } else if section == 3 {
                        return state.store.locked_modules.count
                } else {
                        return state.store.unlocked_modules.count
                }
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                switch indexPath.section {
                case 0:
                        return store_product_table_view_cell_height
                case 1:
                        return centered_table_view_cell_height + 20
                case 2:
                        return store_restore_table_view_cell_height
                default:
                        return centered_table_view_cell_height + 20
                }
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let (section, row) = (indexPath.section, indexPath.row)

                if section == 0 {
                        let color = color_from_hex(hex: color_brewer_qualitative_9_pastel1[5])
                        let cell = tableView.dequeueReusableCellWithIdentifier("product cell") as! StoreProductTableViewCell
                        cell.update(product: state.store.products_to_purchase[row], color: color)
                        return cell
                } else if section == 1 {
                        let color = color_from_hex(hex: color_brewer_qualitative_9_pastel1[2])
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered cell") as! CenteredTableViewCell
                        let title = state.store.purchased_products[row].localizedTitle
                        let astring = astring_body(string: title)
                        cell.update(attributed_text: astring, background_color: color, symbol: .Checkmark)
                        return cell
                } else if section == 2 {
                        let cell = tableView.dequeueReusableCellWithIdentifier("restore cell") as! StoreRestoreTableViewCell
                        return cell
                } else if section == 3 {
                        let color = color_from_hex(hex: color_brewer_qualitative_9_pastel1[5])
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered cell") as! CenteredTableViewCell
                        let title = state.store.locked_modules[row]
                        let astring = astring_body(string: title)
                        cell.update(attributed_text: astring, background_color: color, symbol: .None)
                        return cell
                } else {
                        let color = color_from_hex(hex: color_brewer_qualitative_9_pastel1[2])
                        let cell = tableView.dequeueReusableCellWithIdentifier("centered cell") as! CenteredTableViewCell
                        let title = state.store.unlocked_modules[row]
                        let astring = astring_body(string: title)
                        cell.update(attributed_text: astring, background_color: color, symbol: .Checkmark)
                        return cell
                }
        }
}
