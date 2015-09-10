import UIKit

class PairWiseLevelState: PageState {

        var factor_id = 0
        var factor_name = ""

        var level_ids = [] as [Int]
        var level_names = [] as [String]
        var level_id_pairs = [] as [(Int, Int)]

        var table_zoom_scale: CGFloat?

        init(factor_id: Int, level_id_pairs: [(Int, Int)]) {
                super.init()
                name = "pairwise_level"
                title = astring_body(string: "Pairwise test")
                info = "Select the pairwise comparisons by tapping the cells in the table.\n\nA green circle means that a pair is selected.\n\nAt least one pair must be selected."
                self.factor_id = factor_id
                self.level_id_pairs = level_id_pairs
                let factor_index = state.factor_ids.indexOf(factor_id)!
                factor_name = state.factor_names[factor_index]
                level_ids = state.level_ids_by_factor[factor_index]
                level_names = state.level_names_by_factor[factor_index]
        }
}

class PairwiseLevel: Component {

        var pairwise_level_state: PairWiseLevelState!

        let factor_label = UILabel()
        let perform_test_button = UIButton(type: .System)
        let tiled_scroll_view = TiledScrollView()
        var pair_table: PairTable?

        override func viewDidLoad() {
                super.viewDidLoad()

                factor_label.textAlignment = .Center
                view.addSubview(factor_label)

                perform_test_button.setAttributedTitle(astring_body(string: "Perform pairwise test"), forState: .Normal)
                perform_test_button.setAttributedTitle(astring_font_size_color(string: "Select at least one pair of levels", color: color_disabled), forState: .Disabled)
                perform_test_button.addTarget(self, action: "perform_test_action", forControlEvents: .TouchUpInside)
                perform_test_button.sizeToFit()
                view.addSubview(perform_test_button)

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                var origin_y = 20 as CGFloat

                factor_label.sizeToFit()
                factor_label.frame = CGRect(x: 0, y: origin_y, width: width, height: factor_label.frame.height)
                origin_y += factor_label.frame.height + 20

                perform_test_button.sizeToFit()
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
                        tiled_scroll_view.scroll_view.zoomScale = pairwise_level_state.table_zoom_scale ?? max(0.6, scale_min)
                }
        }

        override func render() {
                pairwise_level_state = state.page_state as! PairWiseLevelState

                perform_test_button.enabled = !pairwise_level_state.level_id_pairs.isEmpty

                factor_label.text = "\(pairwise_level_state.factor_name)"

                var selected_pairs = [] as [(Int, Int)]
                for (level_id_1, level_id_2) in pairwise_level_state.level_id_pairs {
                        if let i = pairwise_level_state.level_ids.indexOf(level_id_1), let j = pairwise_level_state.level_ids.indexOf(level_id_2) {
                                selected_pairs.append((i, j) as (Int, Int))
                        }
                }

                pair_table = PairTable(names: pairwise_level_state.level_names, selected_pairs: selected_pairs, tap_action: { [unowned self] (row: Int, col:Int) in
                        self.pairwise_level_state.level_id_pairs  = self.pair_table!.selected_pairs.map { (i, j) in (self.pairwise_level_state.level_ids[i], self.pairwise_level_state.level_ids[j]) }
                        self.perform_test_button.enabled = !self.pairwise_level_state.level_id_pairs.isEmpty
                        self.view.setNeedsLayout()
                }, zoom_action: {
                        [unowned self] (zoom_scale: CGFloat) in
                        self.pairwise_level_state.table_zoom_scale = zoom_scale
                })
        }

        func perform_test_action() {
                let pairwise_table_state = PairwiseTableState(factor_id: pairwise_level_state.factor_id, level_id_pairs: pairwise_level_state.level_id_pairs)
                state.navigate(page_state: pairwise_table_state)
                state.render()
        }
}
