import UIKit

class DataSetSelectionState: PageState {

        override init() {
                super.init()
                name = "data_set_selection"
                let color = state.active_data_set ? UIColor.blackColor() : UIColor.redColor()
                set_title(color: color)
                info = "The active data set is the data set on which all analysis is done.\n\nActivate a data set by tapping.\n\nThe axtive data set is colored green."
        }

        func set_title(color color: UIColor) {
                title = astring_font_size_color(string: "Select a data set", color: color)
        }
}

class DataSetSelection: Component, UITableViewDataSource, UITableViewDelegate {

        var first_appearance = true

        var (project_ids, project_names, project_dates) = ([], [], []) as ([Int], [String], [String])
        var (data_set_ids, data_set_names, data_set_dates_of_creation) = ([], [], []) as ([[Int]], [[String]], [[String]])

        let table_view = UITableView()

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()
                table_view.registerClass(CenteredHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                table_view.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
                table_view.registerClass(NameDateTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
        }

        override func render() {
                (project_ids, project_names, project_dates) = state.get_projects()
                (data_set_ids, data_set_names, data_set_dates_of_creation) = ([], [], [])

                var selected_section: Int?
                var selected_row: Int?

                for section in 0 ..< project_ids.count {
                        let (ids, names, dates_of_creation) = state.get_data_sets(project_id: project_ids[section])
                        data_set_ids.append(ids)
                        data_set_names.append(names)
                        data_set_dates_of_creation.append(dates_of_creation)
                        for row in 0 ..< ids.count {
                                if state.data_set_id == ids[row] {
                                        selected_section = section
                                        selected_row = row
                                }
                        }
                }

                table_view.reloadData()

                if first_appearance, let section = selected_section, let row = selected_row {
                        let previous_row = row > 2 ? (row - 2) : 0
                        let indexPath = NSIndexPath(forRow: previous_row, inSection: section)
                        table_view.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                }

                first_appearance = false
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return project_ids.count
        }

        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return centered_header_footer_view_height - 30
        }

        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CenteredHeaderFooterView

                let text = project_names[section]
                view.update_normal(text: text)

                return view
        }

        func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return 25
        }

        func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier("footer")
                footer?.contentView.backgroundColor = UIColor.whiteColor()
                return footer
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return data_set_ids[section].count
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return 70
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! NameDateTableViewCell

                let id = data_set_ids[indexPath.section][indexPath.row]
                let name = data_set_names[indexPath.section][indexPath.row]
                let date = date_from_sqlite_timestamp(timestamp: data_set_dates_of_creation[indexPath.section][indexPath.row])

                if state.data_set_id == id {
                        cell.update_selected(name: name, date: date)
                } else {
                        cell.update_unselected(name: name, date: date)
                }
                
                return cell
        }

        func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
                return UITableViewCellEditingStyle.None
        }

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let data_set_id = data_set_ids[indexPath.section][indexPath.row]

                if let page_state = state.page_state as? DataSetSelectionState {
                        page_state.set_title(color: UIColor.blackColor())
                }

                if data_set_id != state.data_set_id {
                        state.render_type = RenderType.activity_indicator
                        state.activity_indicator_info = "The data set is prepared"
                        state.render()

                        let serial_queue = dispatch_queue_create("data set selection", DISPATCH_QUEUE_SERIAL)

                        dispatch_async(serial_queue, {
                                dispatch_async(dispatch_get_main_queue(), {
                                        state.set_active_data_set(data_set_id: data_set_id)
                                        state.render_type = RenderType.full_page
                                        state.render()
                                })
                        })
                }
        }
}
