import UIKit

enum ImportType {
        case Project
        case Factors
        case Annotations
}

class ImportTableState: PageState {

        let file_id: Int
        let file_name: String
        let file_data: NSData

        var parser_spreadsheet: ParserSpreadsheetProtocol!

        var type: ImportType?
        var phase = 0

        var selected_cells = [] as [(row: Int, column: Int)]

        var import_message = ""
        var import_message_color = UIColor.blackColor()

        var project_name = "A project"
        var header_0_1 = [] as [String]
        var header_2_3 = [] as [String]
        var values = [] as [Double]

        init(file_id: Int) {
                self.file_id = file_id
                let (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id)!
                self.file_name = file_name
                self.file_data = file_data
                super.init()
                name = "import_table"
                title = astring_body(string: "Import Data")
                info = "Follow the instructions to select and import a rectangular part of the table."

                full_screen = .Conditional

                if file_data.length >= 10_000_000 {
                        prepared = false
                } else {
                        prepare()
                }
        }

        override func prepare() {
                parser_spreadsheet = file_name.hasSuffix("xlsx") ? ParserSpreadsheetXlsx(data: file_data) : ParserSpreadsheetTxt(data: file_data)

                prepared = true
        }
}

class ImportTable: Component, SpreadSheetCellsDelegate, UITextFieldDelegate {

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
        let restart_button = UIButton(type:. System)

        let project_name_text_field = UITextField()
        let create_project_button = UIButton(type: .System)

        let scroll_view = UIScrollView()
        let spread_sheet_cells = SpreadSheetCells()

        var row_heights = [] as [CGFloat]
        let column_width = 100 as CGFloat
        var column_widths = [] as [CGFloat]

        var first_time_set_label_text = true

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

                back_button.addTarget(self, action: "back_action", forControlEvents: .TouchUpInside)
                view.addSubview(back_button)

                label.font = font_body
                label.textAlignment = .Center
                view.addSubview(label)

                import_button.setAttributedTitle(astring_font_size_color(string: "Import", font: nil, font_size: 18, color: nil), forState: .Normal)
                import_button.addTarget(self, action: "import_action", forControlEvents: .TouchUpInside)
                view.addSubview(import_button)

                new_project_button.setAttributedTitle(astring_body(string: "New project"), forState: .Normal)
                new_project_button.addTarget(self, action: "new_project_action", forControlEvents: .TouchUpInside)
                view.addSubview(new_project_button)

                add_factors_button.setAttributedTitle(astring_body(string: "Add factors"), forState: .Normal)
                add_factors_button.setAttributedTitle(astring_font_size_color(string: "Add factors", font: nil, font_size: nil, color: color_disabled), forState: .Disabled)
                add_factors_button.addTarget(self, action: "add_factors_action", forControlEvents: .TouchUpInside)
                view.addSubview(add_factors_button)

                add_annotations_button.setAttributedTitle(astring_body(string: "Add molecule annotations"), forState: .Normal)
                add_annotations_button.setAttributedTitle(astring_font_size_color(string: "Add molecule annotations", font: nil, font_size: nil, color: color_disabled), forState: .Disabled)
                add_annotations_button.addTarget("self", action: "add_annotations_action", forControlEvents: .TouchUpInside)
                view.addSubview(add_annotations_button)

                project_name_text_field.layer.borderWidth = 1
                project_name_text_field.layer.borderColor = UIColor.blueColor().CGColor
                project_name_text_field.layer.cornerRadius = 10
                project_name_text_field.clearButtonMode = .WhileEditing
                project_name_text_field.font = font_body
                project_name_text_field.autocorrectionType = .No
                project_name_text_field.textAlignment = .Center
                project_name_text_field.layer.masksToBounds = true
                project_name_text_field.delegate = self
                view.addSubview(project_name_text_field)

                create_project_button.setAttributedTitle(astring_body(string: "Create the new project"), forState: .Normal)
                create_project_button.addTarget(self, action: "create_project_action", forControlEvents: .TouchUpInside)
                view.addSubview(create_project_button)

                restart_button.setAttributedTitle(astring_body(string: "More imports from this file"), forState: .Normal)
                restart_button.addTarget(self, action: "restart_action", forControlEvents: .TouchUpInside)
                view.addSubview(restart_button)

                scroll_view.addSubview(spread_sheet_cells)

                view.addSubview(scroll_view)

                let tap_recognizer = UITapGestureRecognizer(target: self, action: "tap_recognizer_action")
                tap_recognizer.cancelsTouchesInView = false
                view.addGestureRecognizer(tap_recognizer)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let (width, height) = (view.frame.width, view.frame.height)

                var origin_y = 30 as CGFloat

                scroll_to_top_button.setAttributedTitle(astring_max_width(string: "Scroll to top", max_width: (width - 40) / 3), forState: .Normal)
                scroll_to_top_button.sizeToFit()
                scroll_to_top_button.frame.origin = CGPoint(x: 20, y: origin_y - scroll_to_top_button.frame.height / 2)

                scroll_to_bottom_button.setAttributedTitle(astring_max_width(string: "Scroll to bottom", max_width: (width - 40) / 3), forState: .Normal)
                scroll_to_bottom_button.sizeToFit()
                scroll_to_bottom_button.frame.origin = CGPoint(x: width - 20 - scroll_to_bottom_button.frame.width, y: origin_y - scroll_to_bottom_button.frame.height / 2)

                cancel_button.setAttributedTitle(astring_max_width(string: "Cancel", max_width: (width - 40) / 3), forState: .Normal)
                cancel_button.sizeToFit()
                cancel_button.frame.origin = CGPoint(x: (width - cancel_button.frame.width) / 2, y: origin_y - cancel_button.frame.height / 2)

                origin_y = CGRectGetMaxY(cancel_button.frame) + 20

                scroll_left_button.setAttributedTitle(astring_max_width(string: "Scroll left", max_width: (width - 40) / 3), forState: .Normal)
                scroll_left_button.sizeToFit()
                scroll_left_button.frame.origin = CGPoint(x: 20, y: origin_y - scroll_left_button.frame.height / 2)

                scroll_right_button.setAttributedTitle(astring_max_width(string: "Scroll right", max_width: (width - 40) / 3), forState: .Normal)
                scroll_right_button.sizeToFit()
                scroll_right_button.frame.origin = CGPoint(x: width - scroll_right_button.frame.width - 20, y: origin_y - scroll_right_button.frame.height / 2)

                back_button.setAttributedTitle(astring_max_width(string: "Back", max_width: (width - 40) / 3), forState: .Normal)
                back_button.sizeToFit()
                back_button.frame.origin = CGPoint(x: (width - back_button.frame.width) / 2, y: origin_y - back_button.frame.height / 2)

                origin_y = CGRectGetMaxY(scroll_left_button.frame) + 5

                label.sizeToFit()
                let label_width = label.frame.width + 10
                label.frame = CGRect(x: (width - label_width) / 2, y: origin_y, width: label_width, height: label.frame.height + 15)

                origin_y = CGRectGetMaxY(label.frame) + 25

                if !new_project_button.hidden {
                        new_project_button.sizeToFit()
                        new_project_button.center = CGPoint(x: width / 2, y: origin_y)
                        origin_y = CGRectGetMaxY(new_project_button.frame) + 15

                        add_factors_button.sizeToFit()
                        add_factors_button.center = CGPoint(x: width / 2, y: origin_y + 5)
                        origin_y = CGRectGetMaxY(add_factors_button.frame) + 15

                        add_annotations_button.sizeToFit()
                        add_annotations_button.center = CGPoint(x: width / 2, y: origin_y + 5)
                        origin_y = CGRectGetMaxY(add_annotations_button.frame)
                }

                if !project_name_text_field.hidden {
                        project_name_text_field.sizeToFit()
                        let text_field_width = min(width - 100, 450)
                        project_name_text_field.frame = CGRect(x: (width - text_field_width) / 2, y: origin_y, width: text_field_width, height: project_name_text_field.frame.height + 20)
                        create_project_button.sizeToFit()
                        create_project_button.center = CGPoint(x: width / 2, y: origin_y + project_name_text_field.frame.height + 30)
                        origin_y = CGRectGetMaxY(create_project_button.frame)
                }

                if !import_button.hidden {
                        import_button.sizeToFit()
                        import_button.center = CGPoint(x: width / 2, y: origin_y)
                        origin_y = CGRectGetMaxY(import_button.frame)
                }

                if !restart_button.hidden {
                        restart_button.sizeToFit()
                        restart_button.center = CGPoint(x: width / 2, y: origin_y)
                        origin_y = CGRectGetMaxY(restart_button.frame)
                }

                origin_y += 10

                scroll_view.contentSize = CGSize(width: column_widths.reduce(0, combine: +), height: row_heights.reduce(0, combine: +))
                scroll_view.frame = layout_centered_frame(contentSize: scroll_view.contentSize, rect: CGRect(x: 0, y: origin_y, width: width, height: height - origin_y))
                spread_sheet_cells.frame = CGRect(origin: CGPoint.zero, size: scroll_view.contentSize)
        }

        override func render() {
                import_table_state = state.page_state as! ImportTableState

                row_heights = [CGFloat](count: import_table_state.parser_spreadsheet.number_of_rows, repeatedValue: 40)
                column_widths = [CGFloat](count: import_table_state.parser_spreadsheet.number_of_columns, repeatedValue: column_width)
                render_after_change()
        }

        func render_after_change() {
                back_button.hidden = false
                import_button.hidden = true
                new_project_button.hidden = true
                add_factors_button.hidden = true
                add_annotations_button.hidden = true
                project_name_text_field.hidden = true
                create_project_button.hidden = true
                restart_button.hidden = true

                let label_text: String
                var label_color = nil as UIColor?
                switch import_table_state.phase {
                case 0:
                        label_text = "Select the type of import"
                        back_button.hidden = true
                        new_project_button.hidden = false
                        add_factors_button.hidden = false
                        add_annotations_button.hidden = false
                        add_factors_button.enabled = state.active_data_set
                        add_annotations_button.enabled = state.active_data_set
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
                        label_text = "Tap the import button"
                        import_button.hidden = false
                case 6:
                        label_text = import_table_state.import_message
                        label_color = import_table_state.import_message_color
                        restart_button.hidden = false
                default:
                        label_text = "Type a project title"
                        project_name_text_field.text = import_table_state.project_name
                        project_name_text_field.hidden = false
                        create_project_button.hidden = false
                }

                set_label_text(text: label_text, color: label_color)

                spread_sheet_cells.delegate = self
                spread_sheet_cells.reload()
                view.setNeedsLayout()
        }

        func set_label_text(text text: String, color: UIColor?) {
                label.attributedText = astring_font_size_color(string: text, font: nil, font_size: 20, color: color)
                label.textAlignment = .Center

                if first_time_set_label_text {
                        label.layer.backgroundColor = color_yellow.CGColor
                } else if color == nil {
                        label.layer.backgroundColor = color_blue.CGColor
                        UIView.animateWithDuration(0.4, animations: {
                                self.label.layer.backgroundColor = color_yellow.CGColor
                        })
                } else {
                        label.layer.backgroundColor = UIColor.whiteColor().CGColor
                }

                first_time_set_label_text = false
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
                let cell_string = import_table_state.parser_spreadsheet.cell_string(row: row, column: column)
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

        func textFieldShouldReturn(textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }

        func textFieldDidEndEditing(textField: UITextField) {
                import_table_state.project_name = textField.text ?? ""
        }

        func tap_recognizer_action() {
                project_name_text_field.resignFirstResponder()
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
                project_name_text_field.resignFirstResponder()
                if import_table_state.phase == 7 {
                        import_table_state.phase = 5
                } else {
                        import_table_state.phase--
                        if import_table_state.phase > 0 && import_table_state.phase < 5 {
                                import_table_state.selected_cells.removeLast()
                        }
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

        func restart_action() {
                import_table_state.type = nil
                import_table_state.phase = 0
                import_table_state.selected_cells = []
                render_after_change()
        }

        func get_row_of_cells(row row: Int, column_0: Int, column_1: Int) -> [String] {
                var strings = [] as [String]
                for i in 0 ..< column_1 - column_0 + 1 {
                        strings.append(import_table_state.parser_spreadsheet.cell_string(row: row, column: column_0 + i))
                }
                return strings
        }

        func get_column_of_cells(column column: Int, row_0: Int, row_1: Int) -> [String] {
                var strings = [] as [String]
                for i in 0 ..< row_1 - row_0 + 1 {
                        strings.append(import_table_state.parser_spreadsheet.cell_string(row: row_0 + i, column: column))
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
                        import_table_state.header_0_1 = header_0_1
                        import_table_state.header_2_3 = header_2_3

                        let values: [Double]
                        if (row_0_1_min == row_0_1_max) {
                                values = import_table_state.parser_spreadsheet.cell_values_row_major(row_0: row_2_3_min, row_1: row_2_3_max, col_0: col_0_1_min, col_1: col_0_1_max)
                        } else {
                                values = import_table_state.parser_spreadsheet.cell_values_column_major(row_0: row_0_1_min, row_1: row_0_1_max, col_0: col_2_3_min, col_1: col_2_3_max)
                        }

                        import_table_state.values = values

                        import_table_state.phase = 7
                        render_after_change()
                        return
                }

                if import_table_state.type == .Factors {
                        var number_of_factors = 0
                        for i in 0 ..< header_2_3.count {
                                let factor_name = header_2_3[i]
                                if state.factor_names.indexOf(factor_name) != nil {
                                        continue
                                }
                                number_of_factors++

                                let levels: [String]
                                if row_0_1_min == row_0_1_max {
                                        levels = get_row_of_cells(row: row_2_3_min + i, column_0: col_0_1_min, column_1: col_0_1_max)
                                } else {
                                        levels = get_column_of_cells(column: col_2_3_min + i, row_0: row_0_1_min, row_1: row_0_1_max)
                                }
                                var sample_name_to_level = [:] as [String: String]
                                for i in 0 ..< header_0_1.count {
                                        sample_name_to_level[header_0_1[i]] = levels[i]
                                }

                                let level_names_of_samples = state.sample_names.map { sample_name_to_level[$0]! }

                                state.insert_factor(project_id: state.project_id, factor_name: factor_name, level_names_of_samples: level_names_of_samples)
                        }

                        if number_of_factors == 0 {
                                import_table_state.import_message = "There were no new factors"
                                import_table_state.import_message_color = UIColor.redColor()
                        } else {
                                import_table_state.import_message = (number_of_factors == 1 ? "One factor has" : "\(number_of_factors) factors have")  + " been added"
                                import_table_state.import_message_color = UIColor.blackColor()
                        }

                        import_table_state.phase = 6
                        render_after_change()
                }

                if import_table_state.type == .Annotations {
                        var number_of_annotations = 0
                        var annotation_names = [] as [String]
                        var annotation_values_array = [] as [[String]]

                        for i in 0 ..< header_2_3.count {
                                let annotation_name = header_2_3[i]
                                if state.molecule_annotation_names.indexOf(annotation_name) != nil {
                                        continue
                                }
                                number_of_annotations++

                                let values: [String]
                                if row_0_1_min == row_0_1_max {
                                        values = get_row_of_cells(row: row_2_3_min + i, column_0: col_0_1_min, column_1: col_0_1_max)
                                } else {
                                        values = get_column_of_cells(column: col_2_3_min + i, row_0: row_0_1_min, row_1: row_0_1_max)
                                }
                                var molecule_name_to_annotation_value = [:] as [String: String]
                                for i in 0 ..< header_0_1.count {
                                        molecule_name_to_annotation_value[header_0_1[i]] = values[i]
                                }

                                let annotation_values = state.molecule_names.map { molecule_name_to_annotation_value[$0]! }

                                annotation_names.append(annotation_name)
                                annotation_values_array.append(annotation_values)
                        }

                        state.insert_molecule_annotations(project_id: state.project_id, molecule_annotation_names: annotation_names, molecule_annotation_values: annotation_values_array)

                        if number_of_annotations == 0 {
                                import_table_state.import_message = "There were no new annotations"
                                import_table_state.import_message_color = UIColor.redColor()
                        } else {
                                import_table_state.import_message = (number_of_annotations == 1 ? "One annotation has" : "\(number_of_annotations) annotations have")  + " been added"
                                import_table_state.import_message_color = UIColor.blackColor()
                        }

                        import_table_state.phase = 6
                        render_after_change()
                }
        }

        func create_project_action() {
                project_name_text_field.resignFirstResponder()
                let corrected_project_name = import_table_state.project_name == "" ? "A project" : import_table_state.project_name
                let project_id = state.insert_project(project_name: corrected_project_name, data_set_name: "Original data set", values: import_table_state.values, sample_names: import_table_state.header_0_1, molecule_names: import_table_state.header_2_3)

                import_table_state.header_0_1 = []
                import_table_state.header_2_3 = []
                import_table_state.values = []

                let data_set_id = state.get_original_data_set_id(project_id: project_id)
                state.set_active_data_set(data_set_id: data_set_id)

                import_table_state.import_message = "The new project \"\(corrected_project_name)\" is active"
                import_table_state.import_message_color = UIColor.blueColor()

                import_table_state.phase = 6
                state.render()
        }
}
