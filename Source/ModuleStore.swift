import UIKit

class ModuleStoreState: PageState {

        override init() {
                super.init()
                name = "module_store"
                title = astring_body(string: "Donate")
                info = "The Amberbio app is free to use.\n\nDonations support hosting and development of the app.\n\nWith donations, the app can be free and benefit people across the world.\n\nPlease consider donating if the app is useful to you."

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
                info_label.hidden = true
                table_view.hidden = true

                if state.store.request_products_pending {
                        info_label.hidden = false
                        let text = "The donation options are fetched from the server"
                        info_label.attributedText = astring_font_size_color(string: text, font: nil, font_size: 20, color: nil)
                        info_label.textAlignment = .Center
                } else {
                        table_view.hidden = false
                        table_view.reloadData()
                }
                view.setNeedsLayout()
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("centered header") as! CenteredHeaderFooterView

                let text = "Donations support the development of the app"
                header.update_multiline(text: text)
                
                return header
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return state.store.products.count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return store_product_table_view_cell_height
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("product cell") as! StoreProductTableViewCell
                let color = color_from_hex(hex: color_brewer_qualitative_9_pastel1[5])
                cell.update(product: state.store.products[indexPath.row], color: color)
                return cell
        }
}
