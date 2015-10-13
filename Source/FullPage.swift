import UIKit

class FullPage: Component, UIScrollViewDelegate, UISearchBarDelegate {

        let scroll_view = UIScrollView()
        let header_view = UIView()

        let home_button = HomeButton()
        let active_data_set = ActiveDataSet()
        let info_button = InfoButton()
        let back = Back()
        let forward = Forward()
        let title_label = Title()
        let pdf_button = UIButton(type: UIButtonType.System)
        let png_button = UIButton(type: UIButtonType.System)
        let txt_button = UIButton(type: .System)
        let histogram_button = UIButton(type: .System)
        let search_bar = custom_search_bar()

        let select_button = UIButton(type: .System)
        var molecule_range: MoleculeRange!

        var displayed_page_name = ""
        var page = Component()

        override func loadView() {
                view = scroll_view
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                header_view.backgroundColor = color_header_view
                view.addSubview(header_view)

                add_child_view_controller_to_header(child: home_button)
                add_child_view_controller_to_header(child: active_data_set)
                add_child_view_controller_to_header(child: info_button)
                add_child_view_controller_to_header(child: back)
                add_child_view_controller_to_header(child: title_label)
                add_child_view_controller_to_header(child: forward)

                pdf_button.setAttributedTitle(astring_font_size_color(string: "pdf", font: nil, font_size: 20 as CGFloat, color: nil), forState: .Normal)
                pdf_button.sizeToFit()
                header_view.addSubview(pdf_button)

                png_button.setAttributedTitle(astring_font_size_color(string: "png", font: nil, font_size: 20 as CGFloat, color: nil), forState: .Normal)
                png_button.sizeToFit()
                header_view.addSubview(png_button)

                txt_button.setAttributedTitle(astring_font_size_color(string: "txt", font: nil, font_size: 20 as CGFloat, color: nil), forState: .Normal)
                txt_button.sizeToFit()
                header_view.addSubview(txt_button)
                
                histogram_button.setAttributedTitle(astring_font_size_color(string: "histogram", font: nil, font_size: 20, color: nil), forState: .Normal)
                histogram_button.setAttributedTitle(astring_font_size_color(string: "histogram", font: nil, font_size: 20, color: UIColor.lightGrayColor()), forState: .Disabled)
                histogram_button.sizeToFit()
                header_view.addSubview(histogram_button)

                select_button.setAttributedTitle(astring_font_size_color(string: "select", font: nil, font_size: 20, color: nil), forState: .Normal)
                select_button.sizeToFit()
                view.addSubview(select_button)

                molecule_range = MoleculeRange(delegate: self)
                view.addSubview(molecule_range)
                
                search_bar.delegate = self
                header_view.addSubview(search_bar)
                
                let tap_action: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap_action:")
                header_view.addGestureRecognizer(tap_action)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

                scroll_view.delegate = self
                scroll_view.showsVerticalScrollIndicator = false
        }

        func add_child_view_controller_to_header(child child: UIViewController) {
                self.addChildViewController(child)
                header_view.addSubview(child.view)
                child.didMoveToParentViewController(self)
        }

        override func render() {
                let page_name = state.page_state.name

                scroll_view.contentOffset = CGPoint(x: 0, y: state.full_page_scroll_offset)

                home_button.render()
                info_button.render()
                back.render()
                forward.render()
                title_label.render()

                if page_name != displayed_page_name {
                        molecule_range.reset()
                        page.finish()
                        remove_child_view_controller(child: page)

                        switch page_name {
                        case "home":
                                page = Home()
                        case "manual":
                                page = Manual()
                        case "feedback":
                                page = Feedback()
                        case "user":
                                page = User()
                        case "data_set_selection":
                                page = DataSetSelection()
                        case "import_data":
                                page = ImportData()
                        case "export_projects":
                                page = ExportProjects()
                        case "edit_project":
                                page = EditProject()
                        case "project_notes":
                                page = ProjectNotes()
                        case "data_set_table":
                                page = DataSetTable()
                        case "data_set_summary":
                                page = DataSetSummary()
                        case "factor_chart":
                                page = FactorChart()
                        case "result_files":
                                page = ResultFiles()
                        case "sample_names":
                                page = SampleNames()
                        case "molecule_annotations":
                                page = MoleculeAnnotations()
                        case "color_selection_level":
                                page = ColorSelectionLevel()
                        case "color_selection_picker":
                                page = ColorSelectionPicker()
                        case "edit_factors":
                                page = EditFactors()
                        case "edit_factor":
                                page = EditFactor()
                        case "factor_association":
                                page = FactorAssociation()
                        case "factor_contingency_table":
                                page = FactorContingencyTable()
                        case "factor_summary":
                                page = FactorSummary()
                        case "factor_summary_detail":
                                page = FactorSummaryDetail()
                        case "missing_values_for_samples":
                                page = MissingValuesForSamples()
                        case "anova_factor_selection":
                                page = AnovaFactorSelection()
                        case "anova_table":
                                page = AnovaTable()
                        case "anova_plot":
                                page = AnovaPlot()
                        case "pairwise_factor":
                                page = PairwiseFactor()
                        case "pairwise_level":
                                page = PairwiseLevel()
                        case "pairwise_table":
                                page = PairwiseTable()
                        case "paired_pairing_factor":
                                page = PairedPairingFactor()
                        case "paired_comparison_factor":
                                page = PairedComparisonFactor()
                        case "paired_level":
                                page = PairedLevel()
                        case "paired_table":
                                page = PairedTable()
                        case "paired_plot":
                                page = PairedPlot()
                        case "linear_regression_selection":
                                page = LinearRegressionsSelection()
                        case "linear_regression_table":
                                page = LinearRegressionTable()
                        case "linear_regression_plot":
                                page = LinearRegressionPlot()
                        case "p_value_histogram":
                                page = PValueHistogram()
                        case "logarithm_transform":
                                page = LogarithmTransform()
                        case "sample_normalization":
                                page = SampleNormalization()
                        case "factor_elimination":
                                page = FactorElimination()
                        case "remove_samples":
                                page = RemoveSamples()
                        case "remove_molecules":
                                page = RemoveMolecules()
                        case "filter_molecules":
                                page = FilterMolecules()
                        case "single_molecule_plot_table":
                                page = SingleMoleculePlotTable()
                        case "single_molecule":
                                page = SingleMolecule()
                        case "multiple_molecule_plot":
                                page = MultipleMoleculePlot()
                        case "hierarchical_clustering_selection":
                                page = HierarchicalClusteringSelection()
                        case "hierarchical_clustering_plot":
                                page = HierarchicalClusteringPlot()
                        case "pca":
                                page = PCA()
                        case "supervised_classification_factor_selection":
                                page = SupervisedClassificationFactorSelection()
                        case "supervised_classification_validation_selection":
                                page = SupervisedClassificationValidationSelection()
                        case "knn_training_selection":
                                page = KNNTrainingSelection()
                        case "knn_k_selection":
                                page = KNNKSelection()
                        case "knn_result":
                                page = KNNResult()


                        default:
                                print("Remember to update render in FullPage for \(page_name)")
                                page = Component()
                        }

                        add_child_view_controller(parent: self, child: page)
                        displayed_page_name = page_name
                }

                pdf_button.removeTarget(nil, action: "pdf_action", forControlEvents: UIControlEvents.TouchUpInside)
                if state.page_state.pdf_enabled {
                        pdf_button.addTarget(page, action: "pdf_action", forControlEvents: .TouchUpInside)
                }

                png_button.removeTarget(nil, action: "png_action", forControlEvents: UIControlEvents.TouchUpInside)
                if state.page_state.png_enabled {
                        png_button.addTarget(page, action: "png_action", forControlEvents: .TouchUpInside)
                }

                txt_button.removeTarget(nil, action: "txt_action", forControlEvents: UIControlEvents.TouchUpInside)
                if state.page_state.txt_enabled {
                        txt_button.addTarget(page, action: "txt_action", forControlEvents: .TouchUpInside)
                }
                
                histogram_button.removeTarget(nil, action: "histogram_action", forControlEvents: UIControlEvents.TouchUpInside)
                if state.page_state.histogram_enabled {
                        histogram_button.addTarget(page, action: "histogram_action", forControlEvents: .TouchUpInside)
                }

                select_button.removeTarget(nil, action: "select_action", forControlEvents: .TouchUpInside)
                if state.page_state.select_enabled {
                        select_button.addTarget(self, action: "molecule_range_select", forControlEvents: .TouchUpInside)
                }

                molecule_range_active = false
                render_buttons()
                page.render()
                active_data_set.render()
                view.setNeedsLayout()
        }

        func render_buttons() {
                if molecule_range_active {
                        molecule_range.hidden = false
                        molecule_range.render()
                        search_bar.hidden = true
                        pdf_button.hidden = true
                        png_button.hidden = true
                        txt_button.hidden = true
                        histogram_button.hidden = true
                        select_button.hidden = true
                } else {
                        molecule_range.reset()
                        molecule_range.hidden = true
                        search_bar.hidden = !state.page_state.search_enabled
                        pdf_button.hidden = !state.page_state.pdf_enabled
                        png_button.hidden = !state.page_state.png_enabled
                        txt_button.hidden = !state.page_state.txt_enabled
                        histogram_button.hidden = !state.page_state.histogram_enabled
                        select_button.hidden = !state.page_state.select_enabled
                }

                search_bar.text = state.page_state.search_string
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                var (origin_x, origin_y) = (0, 0) as (CGFloat, CGFloat)
                
                home_button.view.frame = CGRect(x: 20, y: 0, width: 40, height: 40)
                info_button.view.frame = CGRect(x: width - 50, y: 10, width: 30, height: 30)
                active_data_set.view.frame = CGRect(x: 70, y: 5, width: width - 120, height: 35)
                
                origin_y = 45

                back.view.frame = CGRect(x: 20, y: origin_y, width: 43, height: 35)
                forward.view.frame = CGRect(x: width - 87, y: origin_y, width: 67, height: 35)
                title_label.view.frame = CGRect(x: 87, y: origin_y, width: width - 174, height: 35)
                
                origin_y += 35
                
                origin_x = width - 20
                
                let height_of_row = max(pdf_button.frame.height, txt_button.frame.height)

                if state.page_state.select_enabled {
                        molecule_range.frame = CGRect(x: 0, y: origin_y, width: width, height: height_of_row)
                }

                if state.page_state.pdf_enabled {
                        pdf_button.frame = CGRect(x: origin_x - pdf_button.frame.width, y: origin_y + (height_of_row - pdf_button.frame.height) / 2, width: pdf_button.frame.width, height: pdf_button.frame.height)
                        origin_x -= pdf_button.frame.width + 20
                }

                if state.page_state.png_enabled {
                        png_button.frame = CGRect(x: origin_x - png_button.frame.width, y: origin_y + (height_of_row - png_button.frame.height) / 2, width: png_button.frame.width, height: png_button.frame.height)
                        origin_x -= png_button.frame.width + 20
                }

                if state.page_state.txt_enabled {
                        txt_button.frame = CGRect(x: origin_x - txt_button.frame.width, y: origin_y + (height_of_row - txt_button.frame.height) / 2, width: txt_button.frame.width, height: txt_button.frame.height)
                        origin_x -= txt_button.frame.width + 20
                }
                
                if state.page_state.histogram_enabled {
                        histogram_button.frame = CGRect(x: origin_x - histogram_button.frame.width, y: origin_y + (height_of_row - histogram_button.frame.height) / 2, width: histogram_button.frame.width, height: histogram_button.frame.height)
                        origin_x -= histogram_button.frame.width + 20
                }

                if state.page_state.select_enabled {
                        select_button.frame = CGRect(x: origin_x - select_button.frame.width, y: origin_y + (height_of_row - select_button.frame.height) / 2, width: select_button.frame.width, height: select_button.frame.height)
                        origin_x -= select_button.frame.width + 20
                }
                
                if state.page_state.search_enabled {
                        search_bar.frame.origin = CGPoint(x: 20, y: origin_y + (height_of_row - search_bar.frame.height) / 2)
                        let available_width_for_search_bar = origin_x - 40
                        if available_width_for_search_bar < custom_search_bar_size.width {
                                search_bar.frame.size.width = available_width_for_search_bar
                        } else {
                                search_bar.frame.size.width = custom_search_bar_size.width
                        }
                }

                let row_of_buttons = state.page_state.select_enabled || state.page_state.pdf_enabled || state.page_state.png_enabled || state.page_state.txt_enabled || state.page_state.histogram_enabled || state.page_state.search_enabled
                let header_height = origin_y + (row_of_buttons ? height_of_row : 3)
                header_view.frame = CGRect(x: 0, y: 0, width: width, height: header_height)

                let middle_margin = 50 as CGFloat
                
                if state.page_state.full_screen {
                        page.view.frame = CGRect(x: 0, y: header_height, width: width, height: height - middle_margin)
                        scroll_view.contentSize = CGSize(width: width, height: header_height + height - middle_margin)
                } else {
                        page.view.frame = CGRect(x: 0, y: header_height, width: width, height: height - header_height)
                        scroll_view.contentSize = CGSize(width: width, height: height)
                }
        }

        func scrollViewDidScroll(scrollView: UIScrollView) {
                state.full_page_scroll_offset = scrollView.contentOffset.y
        }

        override func molecule_range_select() {
                molecule_range_active = true
                page.molecule_range_select()
                render_buttons()
        }

        override func molecule_range_cancel() {
                molecule_range_active = false
                page.molecule_range_cancel()
                render_buttons()
        }

        override func molecule_range_create_data_set(index1 index1: Int, index2: Int) {
                page.molecule_range_create_data_set(index1: index1, index2: index2)
        }

        func searchBarSearchButtonClicked(searchBar: UISearchBar) {
                search_bar.resignFirstResponder()
        }
        
        func searchBarTextDidEndEditing(searchBar: UISearchBar) {
                let search_text = searchBar.text ?? ""
                page.search_action(search_string: search_text)
        }
        
        func tap_action(recognizer: UITapGestureRecognizer) {
                search_bar.resignFirstResponder()
        }

        func keyboardDidShow(notification: NSNotification) {
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                        scroll_view.contentInset.bottom = keyboardSize.height
                        scroll_view.scrollIndicatorInsets.bottom = keyboardSize.height
                }
        }

        func keyboardWillHide(notification: NSNotification) {
                scroll_view.contentInset.bottom = 0
                scroll_view.scrollIndicatorInsets.bottom = 0
        }
}
