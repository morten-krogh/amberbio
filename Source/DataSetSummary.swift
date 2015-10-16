import UIKit

class DataSetSummaryState: PageState {

        var minimum = 0 as Double
        var maximum = 0 as Double
        var sum = 0 as Double
        var number_of_present_values = 0
        var missing_values_for_samples = [] as [Int]
        var missing_values_for_molecules = [] as [Int]
        var number_of_samples_without_missing_values = 0
        var number_of_molecules_without_missing_values = 0
        var number_of_missing_values = 0

        override init() {
                super.init()
                name = "data_set_summary"
                title = astring_body(string: "Data set summary")
                info = "A summary of the active data set."

                prepared = false
        }

        override func prepare() {
                minimum = Double.infinity
                maximum = -Double.infinity
                sum = 0
                number_of_present_values = 0
                missing_values_for_samples = [Int](count: state.number_of_samples, repeatedValue: 0)
                missing_values_for_molecules = [Int](count: state.number_of_molecules, repeatedValue: 0)
                for i in 0 ..< state.number_of_molecules {
                        for j in 0 ..< state.number_of_samples {
                                let value = state.values[i * state.number_of_samples + j]
                                if value.isNaN {
                                        missing_values_for_samples[j]++
                                        missing_values_for_molecules[i]++
                                } else {
                                        sum += value
                                        number_of_present_values++
                                        if value < minimum {
                                                minimum = value
                                        }
                                        if value > maximum {
                                                maximum = value
                                        }
                                }
                        }
                }

                number_of_samples_without_missing_values = missing_values_for_samples.filter { $0 == 0 }.count
                number_of_molecules_without_missing_values = missing_values_for_molecules.filter { $0 == 0 }.count
                number_of_missing_values =  state.number_of_molecules * state.number_of_samples - number_of_present_values

                prepared = true
        }
}

class DataSetSummary: Component, UITableViewDataSource, UITableViewDelegate {

        let table_view = UITableView()

        var data_set_summary_state: DataSetSummaryState!

        override func loadView() {
                view = table_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                table_view.registerClass(DataSetSummaryTableViewCell.self, forCellReuseIdentifier: "cell")
                table_view.dataSource = self
                table_view.delegate = self
                table_view.backgroundColor = UIColor.whiteColor()
                table_view.separatorStyle = .None
        }

        override func render() {
                data_set_summary_state = state.page_state as! DataSetSummaryState
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return 10
        }

        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                return 85.0
        }

        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! DataSetSummaryTableViewCell

                let name: String
                let value: String

                switch indexPath.row {
                case 0:
                        name = "Name of data set"
                        value = state.data_set_name
                case 1:
                        name = "Number of samples"
                        value = "\(state.number_of_samples)"
                case 2:
                        name = "Number of molecules"
                        value = "\(state.number_of_molecules)"
                case 3:
                        name = "Samples without missing values"
                        value = "\(data_set_summary_state.number_of_samples_without_missing_values)"
                case 4:
                        name = "Molecules without missing values"
                        value = "\(data_set_summary_state.number_of_molecules_without_missing_values)"
                case 5:
                        name = "Present values"
                        value = "\(data_set_summary_state.number_of_present_values)"
                case 6:
                        name = "Missing values"
                        value = "\(data_set_summary_state.number_of_missing_values)"
                case 7:
                        let average_string = data_set_summary_state.number_of_present_values > 0 ? decimal_string(number: data_set_summary_state.sum / Double(data_set_summary_state.number_of_present_values), fraction_digits: 1) : "NA"
                        name = "Average value"
                        value = "\(average_string)"
                case 8:
                        let maximum_string = data_set_summary_state.number_of_present_values > 0 ? decimal_string(number: data_set_summary_state.maximum, fraction_digits: 1) : "NA"
                        name = "Maximum value"
                        value = "\(maximum_string)"
                case 9:
                        let minimum_string = data_set_summary_state.number_of_present_values > 0 ? decimal_string(number: data_set_summary_state.minimum, fraction_digits: 1) : "NA"
                        name = "Minimum value"
                        value = "\(minimum_string)"
                default:
                        name = "default"
                        value = "default"
                }

                cell.update(name: name, value: value)

                return cell
        }

        func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
                return false
        }
}

class DataSetSummaryTableViewCell: UITableViewCell {

        let inset_view = UIView()

        let name_label = UILabel()
        let value_label = UILabel()

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                inset_view.backgroundColor = UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 1.0)
                inset_view.layer.cornerRadius = 20

                name_label.textAlignment = .Center
                name_label.font = font_headline

                value_label.textAlignment = .Center
                value_label.font = font_body

                contentView.addSubview(inset_view)
                inset_view.addSubview(name_label)
                inset_view.addSubview(value_label)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()
                inset_view.frame = CGRectInset(contentView.bounds, 10, 8)

                let margin = 5 as CGFloat
                let side_width = 50 as CGFloat
                let label_width = inset_view.frame.width - 2.0 * side_width - 2.0 * margin
                let label_height = inset_view.frame.height / 2.0
                name_label.frame = CGRect(x: side_width, y: 0, width: label_width, height: label_height)
                value_label.frame = CGRect(x: side_width, y: label_height, width: label_width, height: label_height)
        }

        func update(name name: String, value: String) {
                name_label.text = name
                value_label.text = value
        }
}
