import UIKit

class ImportTableState: PageState {

        let file_id: Int
        var file_name = ""
        var file_data = NSData()

        var number_of_rows = 0
        var number_of_columns = 0
        var separator_positions = [] as [Int]


        init(file_id: Int) {
                self.file_id = file_id
                super.init()
                name = "import_table"
                title = astring_body(string: "Import Data")
                info = ""

                prepared = false
        }

        override func prepare() {
                (file_name, file_data) = state.select_file_name_and_file_data(file_id: file_id)!

                let separator = parse_find_separator(file_data.bytes, file_data.length)

                parse_number_of_rows_and_columns(file_data.bytes, file_data.length, separator, &number_of_rows, &number_of_columns)

                separator_positions = [Int](count: number_of_rows * number_of_columns, repeatedValue: -1)
                parse_separator_positions(file_data.bytes, file_data.length, separator, number_of_rows, number_of_columns, &separator_positions)


                print(separator, number_of_rows, number_of_columns)
                print(separator_positions)

                for index in 0 ..< separator_positions.count {
                        var position_0 = index > 0 ? separator_positions[index - 1] + 1 : 0
                        let position_1 = separator_positions[index]
                        if position_0 > position_1 {
                                position_0 = position_1
                        }
                        var cstring = [CChar](count: position_1 - position_0 + 1, repeatedValue: 0)
                        parse_read_cstring(file_data.bytes, position_0, position_1, &cstring)

                        let str = String.fromCString(cstring) ?? ""

                        print("cstring")
                        print(cstring)
                        print(str, str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                }

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

        let scroll_view = UIScrollView()
        let spread_sheet_cells = SpreadSheetCells()

        var row_heights = [] as [CGFloat]
        var column_widths = [] as [CGFloat]



        override func viewDidLoad() {
                super.viewDidLoad()

                scroll_to_top_button.setAttributedTitle(astring_body(string: "Scroll to top"), forState: .Normal)
                scroll_to_top_button.addTarget(self, action: "scroll_to_top_action", forControlEvents: .TouchUpInside)
                view.addSubview(scroll_to_top_button)

                scroll_to_bottom_button.setAttributedTitle(astring_body(string: "Scroll to bottom"), forState: .Normal)
                scroll_to_bottom_button.addTarget(self, action: "scroll_to_bottom_action", forControlEvents: .TouchUpInside)
                view.addSubview(scroll_to_bottom_button)

                scroll_view.addSubview(spread_sheet_cells)

                view.addSubview(scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let (width, height) = (view.frame.width, view.frame.height)

                scroll_to_top_button.sizeToFit()
                scroll_to_top_button.frame.origin = CGPoint(x: 20, y: 20)

                scroll_to_bottom_button.sizeToFit()
                scroll_to_bottom_button.frame.origin = CGPoint(x: width - 20 - scroll_to_bottom_button.frame.width, y: 20)

                scroll_view.contentSize = CGSize(width: column_widths.reduce(0, combine: +), height: row_heights.reduce(0, combine: +))


                scroll_view.frame = layout_centered_frame(contentSize: scroll_view.contentSize, rect: CGRect(x: 0, y: 200, width: width, height: height - 200))
                spread_sheet_cells.frame = CGRect(origin: CGPoint.zero, size: scroll_view.contentSize)
        }

        override func render() {
                import_table_state = state.page_state as! ImportTableState

                row_heights = [CGFloat](count: import_table_state.number_of_rows, repeatedValue: 40)
                column_widths = [CGFloat](count: import_table_state.number_of_columns, repeatedValue: 100)

                spread_sheet_cells.delegate = self
                spread_sheet_cells.reload()
        }


        func spread_sheet_cells_row_heights(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat] {
                return row_heights
        }

        func spread_sheet_cells_column_widths(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat] {
                return column_widths
        }

        func spread_sheet_cells_astring(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) -> Astring {
                let cell_string = import_table_state.cell_string(row: row, column: column)
                return astring_body(string: cell_string)
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
}
