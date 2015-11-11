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

        var selected_row: (row: Int, column_0: Int, column_1: Int)?
        var selected_column: (column: Int, row_0: Int, row_1: Int)?

        var samples_in_row = false
        var molecules_in_row = true

        init(file_id: Int) {
                self.file_id = file_id
                super.init()
                name = "import_table"
                title = astring_body(string: "Import Data")
                info = ""

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
}

class ImportTable: Component, SpreadSheetCellsDelegate {

        var import_table_state: ImportTableState!

        let scroll_to_top_button = UIButton(type: .System)
        let scroll_to_bottom_button = UIButton(type: .System)
        let cancel_button = UIButton(type: .System)

        let label = UILabel()

        let new_project_button = UIButton(type: .System)
        let add_factors_button = UIButton(type: .System)
        let add_annotations_button = UIButton(type: .System)
        let back_button = UIButton(type: .System)

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

                cancel_button.addTarget(self, action: "cancel_action", forControlEvents: .TouchUpInside)
                view.addSubview(cancel_button)

                label.font = font_body
                label.textAlignment = .Center
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

                var origin_y = CGRectGetMaxY(label.frame) + 20

                back_button.sizeToFit()
                back_button.center = CGPoint(x: width / 2, y: origin_y)

                new_project_button.sizeToFit()
                new_project_button.center = CGPoint(x: width / 2, y: origin_y)
                origin_y += new_project_button.frame.height + 5

                add_factors_button.sizeToFit()
                add_factors_button.center = CGPoint(x: width / 2, y: origin_y)
                origin_y += add_factors_button.frame.height + 5

                add_annotations_button.sizeToFit()
                add_annotations_button.center = CGPoint(x: width / 2, y: origin_y)



                scroll_view.contentSize = CGSize(width: column_widths.reduce(0, combine: +), height: row_heights.reduce(0, combine: +))

                origin_y = import_table_state.phase == 0 ? CGRectGetMaxY(add_annotations_button.frame) : CGRectGetMaxY(back_button.frame)
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
                new_project_button.hidden = true
                add_factors_button.hidden = true
                add_annotations_button.hidden = true

                let label_text: String
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
                default:
                        label_text = "Tap the button to import."
                }

                label.attributedText = astring_font_size_color(string: label_text, font: nil, font_size: 20, color: nil)
                label.textAlignment = .Center

                spread_sheet_cells.delegate = self
                spread_sheet_cells.reload()
                view.setNeedsLayout()
        }

        func cell_background_color(row row: Int, column: Int) -> UIColor {
                let phase = import_table_state.phase
                let type = import_table_state.type
                let selected_cells = import_table_state.selected_cells
                if phase == 2 && row == selected_cells[0].row && column == selected_cells[0].column {
                        return type == .Annotations ? color_selected_molecules : color_selected_samples
                } else if phase >= 3 && row == selected_cells[0].row && row == selected_cells[1].row {
                        let column_min = min(selected_cells[0].column, selected_cells[1].column)
                        let column_max = max(selected_cells[0].column, selected_cells[1].column)
                        if column >= column_min && column <= column_max {
                                return type == .Annotations ? color_selected_molecules : color_selected_samples
                        }
                } else if phase >= 3 && column == selected_cells[0].column && column == selected_cells[1].column {
                        let row_min = min(selected_cells[0].row, selected_cells[1].row)
                        let row_max = max(selected_cells[0].row, selected_cells[1].row)
                        if row >= row_min && row <= row_max {
                                return type == .Annotations ? color_selected_molecules : color_selected_samples
                        }
                } else if phase == 4 && selected_cells[0].row == selected_cells[1].row && row == selected_cells[2].row {
                        if column == selected_cells[2].column {
                                return color_selected_molecules
                        } else if in_interval(end_point_0: selected_cells[0].column, end_point_1: selected_cells[1].column, point: column) {
                                return color_selected_values
                        }
                }


//                if let selected_row = import_table_state.selected_row {
//                        if row == selected_row.row && ((column >= selected_row.column_0 && column <= selected_row.column_1) || (column <= selected_row.column_0 && column >= selected_row.column_1)) {
//                                if import_table_state.samples_in_row && import_table_state.import_type != .Annotations {
//                                        return color_selected_samples
//                                }
//                                if import_table_state.molecules_in_row && import_table_state.import_type != .Factors {
//                                        return color_selected_molecules
//                                }
//                        }
//                }
//
//                if let selected_column = import_table_state.selected_column {
//                        if column == selected_column.column && ((row >= selected_column.row_0 && row <= selected_column.row_1) || (row <= selected_column.row_0 && row >= selected_column.row_1)) {
//                                if !import_table_state.samples_in_row && import_table_state.import_type != .Annotations {
//                                        return color_selected_samples
//                                }
//                                if !import_table_state.molecules_in_row && import_table_state.import_type != .Factors {
//                                        return color_selected_molecules
//                                }
//                        }
//                }
//
//                if let selected_row = import_table_state.selected_row, let selected_column = import_table_state.selected_column {
//                        let column_min = min(selected_row.column_0, selected_row.column_1)
//                        let column_max = max(selected_row.column_0, selected_row.column_1)
//                        let row_min = min(selected_column.row_0, selected_column.row_1)
//                        let row_max = max(selected_column.row_0, selected_column.row_1)
//
//                        if column >= column_min && column <= column_max && row >= row_min && row <= row_max {
//                                return color_selected_values
//                        }
//                }

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
                print("tapped, \(import_table_state.phase)")
                if import_table_state.phase >= 1 && import_table_state.phase <= 4 {
                        let potential_selected_cells = import_table_state.selected_cells + [(row, column)]
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
                                return false
                        }
                }
                return false
        }

        func scroll_to_top_action() {
                scroll_view.contentOffset = CGPoint.zero
        }

        func scroll_to_bottom_action() {
                scroll_view.contentOffset = CGPoint(x: scroll_view.contentSize.width - scroll_view.frame.width, y: scroll_view.contentSize.height - scroll_view.frame.height)
        }

        func cancel_action() {
                let page_state = ImportDataState()
                state.set_page_state(page_state: page_state)
                state.render()
        }

        func back_action() {
                import_table_state.phase--
                if !import_table_state.selected_cells.isEmpty {
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
}
