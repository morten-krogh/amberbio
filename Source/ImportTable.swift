import UIKit

class ImportTableState: PageState {

        let file_id: Int

        init(file_id: Int) {
                print(file_id)
                self.file_id = file_id
                super.init()
                name = "import_table"
                title = astring_body(string: "Import Data")
                info = ""

                prepared = false
        }

        override func prepare() {
                

                prepared = true
        }
}

class ImportTable: Component, SpreadSheetCellsDelegate {

        var import_table_state: ImportTableState!

        let scroll_view = UIScrollView()
        let spread_sheet_cells = SpreadSheetCells()

        var column_widths = [CGFloat](count: 5, repeatedValue: 100)
        var row_heights = [CGFloat](count: 12000, repeatedValue: 50)

        override func viewDidLoad() {
                super.viewDidLoad()

                spread_sheet_cells.delegate = self
                scroll_view.addSubview(spread_sheet_cells)

                view.addSubview(scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let (width, height) = (view.frame.width, view.frame.height)

                scroll_view.contentSize = CGSize(width: column_widths.reduce(0, combine: +), height: row_heights.reduce(0, combine: +))


                scroll_view.frame = layout_centered_frame(contentSize: scroll_view.contentSize, rect: CGRect(x: 0, y: 200, width: width, height: height - 200))
                spread_sheet_cells.frame = CGRect(origin: CGPoint.zero, size: scroll_view.contentSize)
        }

        override func render() {
                import_table_state = state.page_state as! ImportTableState

                spread_sheet_cells.reload()
        }


        func spread_sheet_cells_row_heights(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat] {
                return row_heights
        }

        func spread_sheet_cells_column_widths(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> [CGFloat] {
                return column_widths
        }

        func spread_sheet_cells_astring(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) -> Astring {
                return astring_body(string: "cell")
        }

        func spread_sheet_cells_tapable(spread_sheet_cells spread_sheet_cells: SpreadSheetCells) -> Bool {
                return true
        }

        func spread_sheet_cells_tapped(spread_sheet_cells spread_sheet_cells: SpreadSheetCells, row: Int, column: Int) {

        }
}
