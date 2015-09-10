import UIKit

class PairedLevelState: PageState {

        var pairing_factor_id = 0
        var comparison_factor_id = 0
        var level_id_pairs = [] as [(Int, Int)]

        var table_zoom_scale: CGFloat?

        init(pairing_factor_id: Int, comparison_factor_id: Int, level_id_pairs: [(Int, Int)]) {
                super.init()
                name = "paired_level"
                title = astring_body(string: "Paired test")
                info = "Select the pairwise comparisons by tapping the cells in the table.\n\nA green circle means that a pair is selected.\n\nAt least one pair must be selected."
                self.pairing_factor_id = pairing_factor_id
                self.comparison_factor_id = comparison_factor_id
                self.level_id_pairs = level_id_pairs
        }
}

class PairedLevel: Component {

        var paired_level_state: PairedLevelState!

        var level_ids = [] as [Int]
        var level_names = [] as [String]

        let pairing_factor_label = UILabel()
        let comparison_factor_label = UILabel()

        let perform_test_button = UIButton(type: .System)

        let tiled_scroll_view = TiledScrollView()
        var pair_table: PairTable?

        override func viewDidLoad() {
                super.viewDidLoad()

                pairing_factor_label.textAlignment = .Center
                view.addSubview(pairing_factor_label)

                comparison_factor_label.textAlignment = .Center
                view.addSubview(comparison_factor_label)

                perform_test_button.setAttributedTitle(astring_body(string: "Perform paired test"), forState: .Normal)
                perform_test_button.setAttributedTitle(astring_font_size_color(string: "Select at least one pair of levels", color: color_disabled), forState: .Disabled)
                perform_test_button.addTarget(self, action: "perform_test_action", forControlEvents: .TouchUpInside)
                view.addSubview(perform_test_button)

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                var origin_y = 20 as CGFloat

                
                pairing_factor_label.sizeToFit()
                pairing_factor_label.frame = CGRect(x: 0, y: origin_y, width: width, height: pairing_factor_label.frame.height)
                origin_y += pairing_factor_label.frame.height + 20

                comparison_factor_label.sizeToFit()
                comparison_factor_label.frame = CGRect(x: 0, y: origin_y, width: width, height: comparison_factor_label.frame.height)
                origin_y += comparison_factor_label.frame.height + 20

                perform_test_button.frame.origin = CGPoint(x: (width - perform_test_button.frame.width) / 2, y: origin_y)
                origin_y += perform_test_button.frame.height + 20

                let height_table = height - origin_y
                tiled_scroll_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height_table)
                if let table_of_attributed_strings = pair_table {
                        let scale_x = width / table_of_attributed_strings.content_size.width
                        let scale_y = height_table / table_of_attributed_strings.content_size.height
                        let scale_min = min(1, scale_x, scale_y)
                        let scale_max = max(1, scale_x, scale_y)
                        table_of_attributed_strings.minimum_zoom_scale = scale_min
                        table_of_attributed_strings.maximum_zoom_scale = scale_max
                        tiled_scroll_view.delegate = table_of_attributed_strings
                        tiled_scroll_view.scroll_view.zoomScale = paired_level_state.table_zoom_scale ?? max(0.6, scale_min)
                }
        }

        override func render() {
                paired_level_state = state.page_state as! PairedLevelState

                perform_test_button.enabled = !paired_level_state.level_id_pairs.isEmpty
                perform_test_button.sizeToFit()

                let pairing_factor_index = state.factor_ids.indexOf(paired_level_state.pairing_factor_id)!
                let pairing_factor_name = state.factor_names[pairing_factor_index]

                pairing_factor_label.attributedText = astring_body(string: "The pairing factor is \(pairing_factor_name)")

                let comparison_factor_index = state.factor_ids.indexOf(paired_level_state.comparison_factor_id)!
                let comparison_factor_name = state.factor_names[comparison_factor_index]

                comparison_factor_label.attributedText = astring_body(string: "The comparison factor is \(comparison_factor_name)")

                level_ids = state.level_ids_by_factor[comparison_factor_index]
                level_names = state.level_names_by_factor[comparison_factor_index]

                var selected_pairs = [] as [(Int, Int)]
                for (level_id_1, level_id_2) in paired_level_state.level_id_pairs {
                        if let i = level_ids.indexOf(level_id_1), let j = level_ids.indexOf(level_id_2) {
                                selected_pairs.append((i, j) as (Int, Int))
                        }
                }

                pair_table = PairTable(names: level_names, selected_pairs: selected_pairs, tap_action: { [unowned self] (row: Int, col:Int) in
                        self.paired_level_state.level_id_pairs  = self.pair_table!.selected_pairs.map { (i, j) in (self.level_ids[i], self.level_ids[j]) }
                        self.perform_test_button.enabled = !self.paired_level_state.level_id_pairs.isEmpty
                        self.view.setNeedsLayout()
                        }, zoom_action: {
                                [unowned self] (zoom_scale: CGFloat) in
                                self.paired_level_state.table_zoom_scale = zoom_scale
                })
        }

        func perform_test_action() {
                let paired_table_state = PairedTableState(pairing_factor_id: paired_level_state.pairing_factor_id, comparison_factor_id: paired_level_state.comparison_factor_id, level_id_pairs: paired_level_state.level_id_pairs)
                state.navigate(page_state: paired_table_state)
                state.render()
        }
}
