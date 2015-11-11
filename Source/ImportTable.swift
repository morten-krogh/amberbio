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

        var import_type: ImportType?

        var selected_samples: (row_0: Int, column_0: Int, row_1: Int, column_1: Int)?
        var selected_molecules: (row_0: Int, column_0: Int, row_1: Int, column_1: Int)?

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

                selected_samples = (12, 0, 2, 0)
                selected_molecules = (0, 2, 0, 4)
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

                scroll_view.contentSize = CGSize(width: column_widths.reduce(0, combine: +), height: row_heights.reduce(0, combine: +))


                scroll_view.frame = layout_centered_frame(contentSize: scroll_view.contentSize, rect: CGRect(x: 0, y: 200, width: width, height: height - 200))
                spread_sheet_cells.frame = CGRect(origin: CGPoint.zero, size: scroll_view.contentSize)
        }

        override func render() {
                import_table_state = state.page_state as! ImportTableState

                row_heights = [CGFloat](count: import_table_state.number_of_rows, repeatedValue: 40)
                column_widths = [CGFloat](count: import_table_state.number_of_columns, repeatedValue: column_width)

                spread_sheet_cells.delegate = self
                spread_sheet_cells.reload()
        }

        func cell_background_color(row row: Int, column: Int) -> UIColor {
                if let selected = import_table_state.selected_samples {
                        if row == selected.row_0 && row == selected.row_1 {
                                if (column >= selected.column_0 && column <= selected.column_1) || (column <= selected.column_0 && column >= selected.column_1) {
                                        return color_selected_samples
                                }
                        }

                        if column == selected.column_0 && column == selected.column_1 {
                                if (row >= selected.row_0 && row <= selected.row_1) || (row <= selected.row_0 && row >= selected.row_1) {
                                        return color_selected_samples
                                }
                        }
                }

                if let selected = import_table_state.selected_molecules {
                        if row == selected.row_0 && row == selected.row_1 {
                                if (column >= selected.column_0 && column <= selected.column_1) || (column <= selected.column_0 && column >= selected.column_1) {
                                        return color_selected_molecules
                                }
                        }

                        if column == selected.column_0 && column == selected.column_1 {
                                if (row >= selected.row_0 && row <= selected.row_1) || (row <= selected.row_0 && row >= selected.row_1) {
                                        return color_selected_molecules
                                }
                        }
                }

                if let samples = import_table_state.selected_samples, let molecules = import_table_state.selected_molecules {
                        




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
}
