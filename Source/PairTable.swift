import UIKit

class PairTable: TableOfAttributedStrings {

        let unicode_circle_green = astring_font_size_color(string: "\u{25cf}", font: font_body, font_size: 45, color: circle_color_green)
        let unicode_circle_gray = astring_font_size_color(string: "\u{25cf}", font: font_body, font_size: 45, color: circle_color_gray)

        var selected_pairs: [(Int, Int)]
        var zoom_action: ((zoom_scale: CGFloat) -> Void)?

        init (names: [String], selected_pairs: [(Int, Int)], tap_action: ((row: Int, col: Int) -> ())?, zoom_action: ((zoom_scale: CGFloat) -> Void)?) {
                let number_of_rows = names.count + 1
                self.selected_pairs = selected_pairs

                var astrings = constant_table(number_of_rows: number_of_rows, number_of_columns: number_of_rows, repeated_value: nil) as [[Astring?]]
                var horizontal_cells = constant_table(number_of_rows: number_of_rows, number_of_columns: number_of_rows, repeated_value: true) as [[Bool]]

                for i in 0 ..< names.count {
                        astrings[0][i + 1] = astring_body(string: names[i])
                        astrings[i + 1][0] = astring_body(string: names[i])
                        astrings[i + 1][i + 1] = unicode_circle_gray
                        horizontal_cells[0][i + 1] = false
                }

                for (i, j): (Int, Int) in selected_pairs {
                        astrings[i + 1][j + 1] = unicode_circle_green
                }

                super.init(attributed_strings: astrings, horizontal_cells: horizontal_cells, margin_vertical: 10, tap_action: nil)

                self.tap_action = { [unowned self] (row: Int, col: Int) in
                        if row != 0 && col != 0 && row != col {
                                var astrings = self.attributed_strings
                                astrings[row][col] = astrings[row][col] == nil ? self.unicode_circle_green : nil as Astring?
                                self.attributed_strings[row][col] = astrings[row][col]

                                var selected_pairs = [] as [(Int, Int)]
                                for i in 1 ..< self.number_of_rows {
                                        for j in 1 ..< self.number_of_rows {
                                                if i != j && astrings[i][j] != nil {
                                                        let tuple = (i - 1, j - 1) as (Int, Int)
                                                        selected_pairs.append(tuple)
                                                }
                                        }
                                }
                                self.selected_pairs = selected_pairs
                        }
                        tap_action?(row: row, col: col)
                }

                self.zoom_action = zoom_action
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {
                zoom_action?(zoom_scale: zoom_scale)
        }
}
