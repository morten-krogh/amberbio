import UIKit

enum ImportType {
        case Project
        case Factors
        case Annotations
}

class ImportTableState: PageState {

        let file_id: Int
        var file_name = ""
        var file_data = NSData()

        var number_of_rows = 0
        var number_of_columns = 0
        var separator_positions = [] as [Int]

        var type: ImportType?
        var phase = 0

        var selected_cells = [] as [(row: Int, column: Int)]

        var import_message = ""
        var import_message_color = UIColor.blackColor()

        init(file_id: Int) {
                self.file_id = file_id
                super.init()
                name = "import_table"
                title = astring_body(string: "Import Data")
                info = ""

                full_screen = .Conditional

                (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id)!
                if file_data.length >= 10_000_000 {
                        prepared = false
                } else {
                        prepare()
                }
        }

        override func prepare() {
                let separator = parse_find_separator(file_data.bytes, file_data.length)

                parse_number_of_rows_and_columns(file_data.bytes, file_data.length, separator, &number_of_rows, &number_of_columns)

                separator_positions = [Int](count: number_of_rows * number_of_columns, repeatedValue: -1)
                parse_separator_positions(file_data.bytes, file_data.length, separator, number_of_rows, number_of_columns, &separator_positions)

                prepared = true
        }

        func cell_string(row row: Int, column: Int) -> String {
                let index = row * number_of_columns + column

                var position_0 = index > 0 ? separator_positions[index - 1] + 1 : 0
                let position_1 = separator_positions[index]
                if position_0 > position_1 {
                        position_0 = position_1
                }
                var cstring = [CChar](count: position_1 - position_0 + 1, repeatedValue: 0)
                parse_read_cstring(file_data.bytes, position_0, position_1, &cstring)

                let str = String.fromCString(cstring) ?? ""

                return str
        }

        func cell_values_row_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double] {
                var values = [Double](count: (row_1 - row_0 + 1) * (col_1 - col_0 + 1), repeatedValue: Double.NaN)
                parse_read_double_values(file_data.bytes, number_of_rows, number_of_columns, separator_positions, row_0, row_1, col_0, col_1, 1, &values)
                return values
        }

        func cell_values_column_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double] {
                var values = [Double](count: (row_1 - row_0 + 1) * (col_1 - col_0 + 1), repeatedValue: Double.NaN)
                parse_read_double_values(file_data.bytes, number_of_rows, number_of_columns, separator_positions, row_0, row_1, col_0, col_1, 0, &values)
                return values
        }
}

class ImportTable: Component, SpreadSheetCellsDelegate {

        var import_table_state: ImportTableState!

        let scroll_to_top_button = UIButton(type: .System)
        let scroll_to_bottom_button = UIButton(type: .System)
        let scroll_left_button = UIButton(type: .System)
        let scroll_right_button = UIButton(type: .System)
        let cancel_button = UIButton(type: .System)

        let label = UILabel()

        let new_project_button = UIButton(type: .System)
        let add_factors_button = UIButton(type: .System)
        let add_annotations_button = UIButton(type: .System)
        let back_button = UIButton(type: .System)
        let import_button = UIButton(type: .System)

        let scroll_view = UIScrollView()
        let spread_sheet_cells = SpreadSheetCells()

        var row_heights = [] as [CGFloat]
        let column_width = 100 as CGFloat
        var column_widths = [] as [CGFloat]

        override func viewDidLoad() {
                super.viewDidLoad()

                scroll_to_top_button.addTarget(self, action: "scroll_to_top_action", forControlEvents: .TouchUpInside)
                view.addSubview(scroll_to_top_button)

                scroll_to_bottom_button.addTarget(self, action: "scroll_to_bottom_action", forControlEvents: .TouchUpInside)
                view.addSubview(scroll_to_bottom_button)

                scroll_left_button.addTarget(self, action: "scroll_left_action", forControlEvents: .TouchUpInside)
                view.addSubview(scroll_left_button)

                scroll_right_button.addTarget(self, action: "scroll_right_action", forControlEvents: .TouchUpInside)
                view.addSubview(scroll_right_button)

                cancel_button.addTarget(self, action: "cancel_action", forControlEvents: .TouchUpInside)
                view.addSubview(cancel_button)

                import_button.setAttributedTitle(astring_font_size_color(string: "Import", font: nil, font_size: 18, color: nil), forState: .Normal)
                import_button.addTarget(self, action: "import_action", forControlEvents: .TouchUpInside)
                view.addSubview(import_button)

                label.font = font_body
                label.textAlignment = .Center
                label.numberOfLines = 0
                view.addSubview(label)

                back_button.setAttributedTitle(astring_body(string: "Back"), forState: .Normal)
                back_button.addTarget(self, action: "back_action", forControlEvents: .TouchUpInside)
                view.addSubview(back_button)

                new_project_button.setAttributedTitle(astring_body(string: "New project"), forState: .Normal)
                new_project_button.addTarget(self, action: "new_project_action", forControlEvents: .TouchUpInside)
                view.addSubview(new_project_button)

                add_factors_button.setAttributedTitle(astring_body(string: "Add factors"), forState: .Normal)
                add_factors_button.addTarget(self, action: "add_factors_action", forControlEvents: .TouchUpInside)
                view.addSubview(add_factors_button)

                add_annotations_button.setAttributedTitle(astring_body(string: "Add molecule annotations"), forState: .Normal)
                add_annotations_button.addTarget("self", action: "add_annotations_action", forControlEvents: .TouchUpInside)
                view.addSubview(add_annotations_button)

                scroll_view.addSubview(spread_sheet_cells)

                view.addSubview(scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let (width, height) = (view.frame.width, view.frame.height)

                scroll_to_top_button.setAttributedTitle(astring_max_width(string: "Scroll to top", max_width: (width - 40) / 3), forState: .Normal)
                scroll_to_top_button.sizeToFit()
                scroll_to_top_button.frame.origin = CGPoint(x: 20, y: 30 - scroll_to_top_button.frame.height / 2)

                scroll_to_bottom_button.setAttributedTitle(astring_max_width(string: "Scroll to bottom", max_width: (width - 40) / 3), forState: .Normal)
                scroll_to_bottom_button.sizeToFit()
                scroll_to_bottom_button.frame.origin = CGPoint(x: width - 20 - scroll_to_bottom_button.frame.width, y: 30 - scroll_to_bottom_button.frame.height / 2)

                cancel_button.setAttributedTitle(astring_max_width(string: "Cancel", max_width: (width - 40) / 3), forState: .Normal)
                cancel_button.sizeToFit()
                cancel_button.frame.origin = CGPoint(x: (width - cancel_button.frame.width) / 2, y: 30 - cancel_button.frame.height / 2)

                label.frame = CGRect(x: 0, y: 50, width: width, height: 40)

                var origin_y = 80 as CGFloat

                scroll_left_button.setAttributedTitle(astring_body(string: "Scroll left"), forState: .Normal)
                scroll_left_button.sizeToFit()
                scroll_left_button.frame.origin = CGPoint(x: 20, y: origin_y - scroll_left_button.frame.height / 2)

                scroll_right_button.setAttributedTitle(astring_body(string: "Scroll right"), forState: .Normal)
                scroll_right_button.sizeToFit()
                scroll_right_button.frame.origin = CGPoint(x: width - scroll_right_button.frame.width - 20, y: origin_y - scroll_right_button.frame.height / 2)

                origin_y = CGRectGetMaxY(label.frame) + 20

                back_button.sizeToFit()
                back_button.center = CGPoint(x: width / 2, y: origin_y)

                new_project_button.sizeToFit()
                new_project_button.center = CGPoint(x: width / 2, y: origin_y)



                origin_y += new_project_button.frame.height + 5

                import_button.sizeToFit()
                import_button.center = CGPoint(x: width / 2, y: origin_y)

                add_factors_button.sizeToFit()
                add_factors_button.center = CGPoint(x: width / 2, y: origin_y)
                origin_y += add_factors_button.frame.height + 5

                add_annotations_button.sizeToFit()
                add_annotations_button.center = CGPoint(x: width / 2, y: origin_y)

                scroll_view.contentSize = CGSize(width: column_widths.reduce(0, combine: +), height: row_heights.reduce(0, combine: +))

                if import_table_state.phase == 0 {
                        origin_y = CGRectGetMaxY(add_annotations_button.frame)
                } else {
                        origin_y = CGRectGetMaxY(import_button.frame)
                }
                origin_y += 20
                scroll_view.frame = layout_centered_frame(contentSize: scroll_view.contentSize, rect: CGRect(x: 0, y: origin_y, width: width, height: height - origin_y))
                spread_sheet_cells.frame = CGRect(origin: CGPoint.zero, size: scroll_view.contentSize)
        }

        override func render() {
                import_table_state = state.page_state as! ImportTableState

                row_heights = [CGFloat](count: import_table_state.number_of_rows, repeatedValue: 40)
                column_widths = [CGFloat](count: import_table_state.number_of_columns, repeatedValue: column_width)
                render_after_change()
        }

        func render_after_change() {

                back_button.hidden = false
                import_button.hidden = true
                new_project_button.hidden = true
                add_factors_button.hidden = true
                add_annotations_button.hidden = true

                let label_text: String
                var label_color = nil as UIColor?
                switch import_table_state.phase {
                case 0:
                        label_text = "Select the type of import"
                        back_button.hidden = true
                        new_project_button.hidden = false
                        add_factors_button.hidden = false
                        add_annotations_button.hidden = false
                case 1:
                        if import_table_state.type == .Annotations {
                                label_text = "Tap the first molecule name"
                        } else {
                                label_text = "Tap the first sample name"
                        }
                case 2:
                        if import_table_state.type == .Annotations {
                                label_text = "Tap the last molecule name"
                        } else {
                                label_text = "Tap the last sample name"
                        }
                case 3:
                        if import_table_state.type == .Project {
                                label_text = "Tap the first molecule name"
                        } else if import_table_state.type == .Factors {
                                label_text = "Tap the first factor name"
                        } else {
                                label_text = "Tap the first molecule annotation name"
                        }
                case 4:
                        if import_table_state.type == .Project {
                                label_text = "Tap the last molecule name"
                        } else if import_table_state.type == .Factors {
                                label_text = "Tap the last factor name"
                        } else {
                                label_text = "Tap the last molecule annotation name"
                        }
                case 5:
                        label_text = "Tap the button to import"
                        import_button.hidden = false
                default:
                        label_text = import_table_state.import_message
                        label_color = import_table_state.import_message_color
                }

                label.attributedText = astring_font_size_color(string: label_text, font: nil, font_size: 20, color: label_color)
                label.textAlignment = .Center

                spread_sheet_cells.delegate = self
                spread_sheet_cells.reload()
                view.setNeedsLayout()
        }

        func cell_background_color(row row: Int, column: Int) -> UIColor {
                let phase = import_table_state.phase
                let selected_cells = import_table_state.selected_cells
                if phase == 2 && row == selected_cells[0].row && column == selected_cells[0].column {
                        return color_selected_headers
                } else if phase >= 3 && row == selected_cells[0].row && row == selected_cells[1].row {
                        let column_min = min(selected_cells[0].column, selected_cells[1].column)
                        let column_max = max(selected_cells[0].column, selected_cells[1].column)
                        if column >= column_min && column <= column_max {
                                return color_selected_headers
                        }
                } else if phase >= 3 && column == selected_cells[0].column && column == selected_cells[1].column {
                        let row_min = min(selected_cells[0].row, selected_cells[1].row)
                        let row_max = max(selected_cells[0].row, selected_cells[1].row)
                        if row >= row_min && row <= row_max {
                                return color_selected_headers
                        }
                } else if phase == 4 && selected_cells[0].row == selected_cells[1].row && row == selected_cells[2].row {
                        if column == selected_cells[2].column {
                                return color_selected_headers
                        } else if in_interval(end_point_0: selected_cells[0].column, end_point_1: selected_cells[1].column, point: column) {
                                return color_selected_values
                        }
                } else if phase == 4 && selected_cells[0].column == selected_cells[1].column && column == selected_cells[2].column {
                        if row == selected_cells[2].row {
                                return color_selected_headers
                        } else if in_interval(end_point_0: selected_cells[0].row, end_point_1: selected_cells[1].row, point: row) {
                                return color_selected_values
                        }
                } else if phase >= 5 && selected_cells[0].row == selected_cells[1].row {
                        if column == selected_cells[2].column && in_interval(end_point_0: selected_cells[2].row, end_point_1: selected_cells[3].row, point: row) {
                                return color_selected_headers
                        } else if in_interval(end_point_0: selected_cells[0].column, end_point_1: selected_cells[1].column, point: column) && in_interval(end_point_0: selected_cells[2].row, end_point_1: selected_cells[3].row, point: row) {
                                return color_selected_values
                        }
                } else if phase >= 5 && selected_cells[0].column == selected_cells[1].column {
                        if row == selected_cells[2].row && in_interval(end_point_0: selected_cells[2].column, end_point_1: selected_cells[3].column, point: column) {
                                return color_selected_headers
                        } else if in_interval(end_point_0: selected_cells[0].row, end_point_1: selected_cells[1].row, point: row) && in_interval(end_point_0: selected_cells[2].column, end_point_1: selected_cells[3].column, point: column) {
                                return color_selected_values
                        }
                }

                return UIColor.whiteColor()
        }

        func spread_sheet_cells_row_heights(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat] {
                return row_heights
        }

        func spread_sheet_cells_column_widths(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat] {
                return column_widths
        }

        func spread_sheet_cells_astring(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) -> Astring {
                let cell_string = import_table_state.cell_string(row: row, column: column)
                let astring = astring_max_width(string: cell_string, max_width: column_width - 20)
                return astring
        }

        func spread_sheet_cells_background_color(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) -> UIColor {
                return cell_background_color(row: row, column: column)
        }

        func spread_sheet_cells_tapable(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> Bool {
                return true
        }

        func spread_sheet_cells_tapped(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) {
                if import_table_state.phase >= 1 && import_table_state.phase <= 4 {
                        let row_column = (row,column) as (row: Int, column: Int)
                        let potential_selected_cells = import_table_state.selected_cells + [row_column]
                        if valid_selected_cells(selected_cells: potential_selected_cells) {
                                import_table_state.selected_cells = potential_selected_cells
                                import_table_state.phase++
                                render_after_change()
                        }
                }
        }

        func in_interval(end_point_0 end_point_0: Int, end_point_1: Int, point: Int) -> Bool {
                return (point >= end_point_0 && point <= end_point_1) || (point >= end_point_1 && point <= end_point_0)
        }

        func valid_selected_cells(selected_cells selected_cells: [(row: Int, column: Int)]) -> Bool {
                if selected_cells.count <= 1 {
                        return true
                } else if selected_cells[0].row == selected_cells[1].row {
                        if selected_cells.count == 2 {
                                return true
                        } else if selected_cells.count == 3 {
                                if selected_cells[2].row == selected_cells[0].row {
                                        return false
                                } else {
                                        return !in_interval(end_point_0: selected_cells[0].column, end_point_1: selected_cells[1].column, point: selected_cells[2].column)
                                }
                        } else if selected_cells.count == 4 {
                                if selected_cells[2].column != selected_cells[3].column {
                                        return false
                                }
                                if in_interval(end_point_0: selected_cells[0].column, end_point_1: selected_cells[1].column, point: selected_cells[2].column) {
                                        return false
                                }
                                if in_interval(end_point_0: selected_cells[2].row, end_point_1: selected_cells[3].row, point: selected_cells[0].row) {
                                        return false
                                }
                                return true
                        }
                } else if selected_cells[0].column == selected_cells[1].column {
                        if selected_cells.count == 2 {
                                return true
                        } else if selected_cells.count == 3 {
                                if selected_cells[2].column == selected_cells[0].column {
                                        return false
                                } else {
                                        return !in_interval(end_point_0: selected_cells[0].row, end_point_1: selected_cells[1].row, point: selected_cells[2].row)
                                }
                        } else if selected_cells.count == 4 {
                                if selected_cells[2].row != selected_cells[3].row {
                                        return false
                                }
                                if in_interval(end_point_0: selected_cells[0].row, end_point_1: selected_cells[1].row, point: selected_cells[2].row) {
                                        return false
                                }
                                if in_interval(end_point_0: selected_cells[2].column, end_point_1: selected_cells[3].column, point: selected_cells[0].column) {
                                        return false
                                }
                                return true
                        }
                }
                return false
        }

        func scroll_to_top_action() {
                scroll_view.contentOffset.y = 0
        }

        func scroll_to_bottom_action() {
                scroll_view.contentOffset.y = scroll_view.contentSize.height - scroll_view.frame.height
        }

        func scroll_left_action() {
                scroll_view.contentOffset.x = 0
        }

        func scroll_right_action() {
                scroll_view.contentOffset.x = scroll_view.contentSize.width - scroll_view.frame.width
        }

        func cancel_action() {
                let page_state = ImportDataState()
                state.set_page_state(page_state: page_state)
                state.render()
        }

        func back_action() {
                import_table_state.phase--
                if import_table_state.phase > 0 && import_table_state.phase < 5 {
                        import_table_state.selected_cells.removeLast()
                }
                render_after_change()
        }

        func new_project_action() {
                import_table_state.type = .Project
                import_table_state.phase = 1
                render_after_change()
        }

        func add_factors_action() {
                import_table_state.type = .Factors
                import_table_state.phase = 1
                render_after_change()
        }

        func add_annotations_action() {
                import_table_state.type = .Annotations
                import_table_state.phase = 1
                render_after_change()
        }

        func get_row_of_cells(row row: Int, column_0: Int, column_1: Int) -> [String] {
                var strings = [] as [String]
                for i in 0 ..< column_1 - column_0 + 1 {
                        strings.append(import_table_state.cell_string(row: row, column: column_0 + i))
                }
                return strings
        }

        func get_column_of_cells(column column: Int, row_0: Int, row_1: Int) -> [String] {
                var strings = [] as [String]
                for i in 0 ..< row_1 - row_0 + 1 {
                        strings.append(import_table_state.cell_string(row: row_0 + i, column: column))
                }
                return strings
        }

        func find_duplicate(strings strings: [String]) -> String? {
                var set = Set<String>()
                for string in strings {
                        if set.contains(string) {
                                return string
                        } else {
                                set.insert(string)
                        }
                }
                return nil
        }

        func any_empty(strings strings: [String]) -> Bool {
                for string in strings {
                        if string.isEmpty {
                                return true
                        }
                }
                return false
        }

        func missing_name(strings strings: [String], names: [String]) -> String? {
                var set = Set<String>()
                for string in strings {
                        set.insert(string)
                }
                for name in names {
                        if !set.contains(name) {
                                return name
                        }
                }
                return nil
        }

        func import_action() {
                let date_0 = NSDate()
                print("import")
                let selected_cells = import_table_state.selected_cells
                let row_0_1_min = min(selected_cells[0].row, selected_cells[1].row)
                let row_0_1_max = max(selected_cells[0].row, selected_cells[1].row)
                let col_0_1_min = min(selected_cells[0].column, selected_cells[1].column)
                let col_0_1_max = max(selected_cells[0].column, selected_cells[1].column)
                let row_2_3_min = min(selected_cells[2].row, selected_cells[3].row)
                let row_2_3_max = max(selected_cells[2].row, selected_cells[3].row)
                let col_2_3_min = min(selected_cells[2].column, selected_cells[3].column)
                let col_2_3_max = max(selected_cells[2].column, selected_cells[3].column)

                let header_0_1: [String]
                if row_0_1_min == row_0_1_max {
                        header_0_1 = get_row_of_cells(row: row_0_1_min, column_0: col_0_1_min, column_1: col_0_1_max)
                } else {
                        header_0_1 = get_column_of_cells(column: col_0_1_min, row_0: row_0_1_min, row_1: row_0_1_max)
                }

                if let duplicate = find_duplicate(strings: header_0_1) {
                        if import_table_state.type != .Annotations {
                                import_table_state.import_message = "\(duplicate) is a duplicate sample name"
                        } else {
                                import_table_state.import_message = "\(duplicate) is a duplicate molecule name"
                        }
                        import_table_state.import_message_color = UIColor.redColor()
                        import_table_state.phase = 6
                        render_after_change()
                        return
                }

                if any_empty(strings: header_0_1) {
                        if import_table_state.type != .Annotations {
                                import_table_state.import_message = "There is an empty sample name"
                        } else {
                                import_table_state.import_message = "There is an empty molecule name"
                        }
                        import_table_state.import_message_color = UIColor.redColor()
                        import_table_state.phase = 6
                        render_after_change()
                        return
                }

                if import_table_state.type == .Factors {
                        if let name = missing_name(strings: header_0_1, names: state.sample_names) {
                                import_table_state.import_message = "The sample name \(name) is missing"
                                import_table_state.import_message_color = UIColor.redColor()
                                import_table_state.phase = 6
                                render_after_change()
                                return
                        }
                }

                if import_table_state.type == .Annotations {
                        if let name = missing_name(strings: header_0_1, names: state.molecule_names) {
                                import_table_state.import_message = "The molecule name \(name) is missing"
                                import_table_state.import_message_color = UIColor.redColor()
                                import_table_state.phase = 6
                                render_after_change()
                                return
                        }
                }




                let header_2_3: [String]
                if row_2_3_min == row_2_3_max {
                        header_2_3 = get_row_of_cells(row: row_2_3_min, column_0: col_2_3_min, column_1: col_2_3_max)
                } else {
                        header_2_3 = get_column_of_cells(column: col_2_3_min, row_0: row_2_3_min, row_1: row_2_3_max)
                }

                if let duplicate = find_duplicate(strings: header_2_3) {
                        if import_table_state.type == .Project {
                                import_table_state.import_message = "\(duplicate) is a duplicate molecule name"
                        } else if import_table_state.type == .Factors {
                                import_table_state.import_message = "\(duplicate) is a duplicate factor name"
                        } else if import_table_state.type == .Annotations {
                                import_table_state.import_message = "\(duplicate) is a duplicate molecule annotation name"
                        }
                        import_table_state.import_message_color = UIColor.redColor()
                        import_table_state.phase = 6
                        render_after_change()
                        return
                }

                if any_empty(strings: header_2_3) {
                        if import_table_state.type == .Project {
                                import_table_state.import_message = "There is an empty molecule name"
                        } else if import_table_state.type == .Factors {
                                import_table_state.import_message = "There is an empty factor name"
                        } else if import_table_state.type == .Annotations {
                                import_table_state.import_message = "There is an empty molecule annotation name"
                        }
                        import_table_state.import_message_color = UIColor.redColor()
                        import_table_state.phase = 6
                        render_after_change()
                        return
                }












                if import_table_state.type == .Project {
                        let values: [Double]
                        if (row_0_1_min == row_0_1_max) {
                                values = import_table_state.cell_values_row_major(row_0: row_2_3_min, row_1: row_2_3_max, col_0: col_0_1_min, col_1: col_0_1_max)
                        } else {
                                values = import_table_state.cell_values_column_major(row_0: row_0_1_min, row_1: row_0_1_max, col_0: col_2_3_min, col_1: col_2_3_max)
                        }
                        print(values)
                }





//                print(header_0_1)
//                print(header_2_3)




                let time_interval = NSDate().timeIntervalSinceDate(date_0)
                print(time_interval)
        }


}
