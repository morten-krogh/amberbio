import UIKit

let home_page_name_to_section_row = [
        "module_store": (0, 0),
        "manual": (0, 1),
        "feedback": (0, 2),
        "user": (0, 3),
        "import_data": (1, 0),
        "export_projects": (1, 1),
        "result_files": (1, 2),
        "data_set_selection": (2, 0),
        "project_notes": (2, 1),
        "data_set_table": (3, 0),
        "data_set_summary": (3, 1),
        "factor_chart": (3, 2),
        "factor_association": (3, 3),
        "factor_summary": (3, 4),
        "missing_values_for_samples": (3, 5),
        "single_molecule_plot_table": (3, 6),
        "multiple_molecule_plot": (3, 7),
        "anova_factor_selection": (4, 0),
        "pairwise_factor": (4, 1),
        "paired_pairing_factor": (4, 2),
        "linear_regression_selection": (4, 3),
        "hierarchical_clustering_selection": (5, 0),
        "pca": (5, 1),
        "knn_factor_selection": (6, 0),
        "svm_factor_selection": (6, 1),
        "logarithm_transform": (7, 0),
        "sample_normalization": (7, 1),
        "factor_elimination": (7, 2),
        "remove_samples": (7, 3),
        "remove_molecules": (7, 4),
        "filter_molecules": (7, 5),
        "edit_project": (8, 0),
        "sample_names": (8, 1),
        "molecule_annotations": (8, 2),
        "color_selection_level": (8, 3),
        "edit_factors": (8, 4)] as [String: (section: Int, row: Int)]

class HomeHelper {

        var index_path_to_page_name = [:] as [NSIndexPath: String]

        init() {
                for (page_name, section_row) in home_page_name_to_section_row {
                        let index_path = NSIndexPath(forRow: section_row.row, inSection: section_row.section)
                        index_path_to_page_name[index_path] = page_name
                }
        }
}

let home_helper = HomeHelper()

class HomeState: PageState {

        override init() {
                super.init()
                name = "home"
                title = astring_body(string: "Home")
                info = "The home screen is used for navigation and can be reached by tapping on the home icon in the upper left corner.\n\nTap a button to navigate to another page."
        }
}

class Home: Component, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

        let cell_width = 105 as CGFloat
        let cell_height = 60 as CGFloat

        let header_names = ["Info", "Import/export", "Projects and data sets", "Visualize data set", "Statistical tests", "Unsupervised classification", "Supervised classification", "Create new data sets", "Edit project"]

        let page_titles = [
                ["Module\nStore", "Manual", "Feedback", "User"],
                ["Import\nData", "Export Projects", "Result Files"],
                ["Data Set Selection", "Project Notes" ],
                ["Data Set Table", "Data Set Summary", "Factor\nChart", "Factor Association", "Factor Summary", "Missing Values for Samples", "Single Molecule Plots", "Multiple Molecule Plot"],
                ["Anova", "Pairwise Test", "Paired Test", "Linear Regression"],
                ["Hierarchical Clustering", "PCA"],
                ["k nearest neighbor", "Support vector machine"],
                ["Logarithm Transform", "Sample Normalization", "Factor Elimination", "Remove Samples", "Remove Molecules", "Filter Molecules"],
                ["Edit Project", "Sample Names", "Molecule Annotations", "Color Selection", "Edit Factors"]
        ]

        var view_will_layout_subviews_was_called = false

        func section_row_to_page_state(section section: Int, row: Int) -> PageState {
                switch (section, row) {
                case (0, 0):
                        return ModuleStoreState()
                case (0, 1):
                        return ManualState()
                case (0, 2):
                        return FeedbackState()
                case (0, 3):
                        return UserState()
                case (1, 0):
                        return ImportDataState()
                case (1, 1):
                        return ExportProjectsState()
                case (1, 2):
                        return ResultFilesState()
                case (2, 0):
                        return DataSetSelectionState()
                case (2, 1):
                        return ProjectNotesState()
                case (3, 0):
                        return DataSetTableState()
                case (3, 1):
                        return DataSetSummaryState()
                case (3, 2):
                        return FactorChartState()
                case (3, 3):
                        return FactorAssociationState()
                case (3, 4):
                        return FactorSummaryState()
                case (3, 5):
                        return MissingValuesForSamplesState()
                case (3, 6):
                        return SingleMoleculePlotTableState()
                case (3, 7):
                        return MultipleMoleculePlotState()
                case (4, 0):
                        return AnovaFactorSelectionState()
                case (4, 1):
                        return PairwiseFactorState()
                case (4, 2):
                        return PairedPairingFactorState()
                case (4, 3):
                        return LinearRegressionSelectionState()
                case (5, 0):
                        return HierarchicalClusteringSelectionState()
                case (5, 1):
                        return PCAState()
                case (6, 0):
                        return SupervisedClassificationFactorSelectionState(supervised_classification_type: .KNN)
                case (6, 1):
                        return SupervisedClassificationFactorSelectionState(supervised_classification_type: .SVM)
                case (7, 0):
                        return LogarithmTransformState()
                case (7, 1):
                        return SampleNormalizationState()
                case (7, 2):
                        return FactorEliminationState()
                case (7, 3):
                        return RemoveSamplesState()
                case (7, 4):
                        return RemoveMoleculesState()
                case (7, 5):
                        return FilterMoleculesState()
                case (8, 0):
                        return EditProjectState()
                case (8, 1):
                        return SamplesNamesState()
                case (8, 2):
                        return MoleculeAnnotationsState()
                case (8, 3):
                        return ColorSelectionLevelState()
                case (8, 4):
                        return EditFactorsState()

                default:
                        return PageState()
                }
        }

        var collection_view: UICollectionView!

        override func viewDidLoad() {
                super.viewDidLoad()

                let collection_view_layout = UICollectionViewFlowLayout()

                collection_view = UICollectionView(frame: CGRect.zero, collectionViewLayout: collection_view_layout)

                collection_view.backgroundColor = UIColor.whiteColor()
                collection_view.registerClass(HomeCellView.self, forCellWithReuseIdentifier: "cell")
                collection_view.registerClass(HomeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
                collection_view.dataSource = self
                collection_view.delegate = self

                view.addSubview(collection_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()
                view_will_layout_subviews_was_called = true
                collection_view.frame = view.bounds
                collection_view.contentOffset = state.home_content_offset
        }

        func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
                return header_names.count
        }

        func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
                let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! HomeHeaderView

                let header_name = header_names[indexPath.section]

                header.update(title: header_name)

                return header
        }

        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                return page_titles[section].count
        }

        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! HomeCellView

                let title = page_titles[indexPath.section][indexPath.row]
                let previously_selected = state.home_selected_index_path == indexPath
                let page_name = home_helper.index_path_to_page_name[indexPath]!
                let locked = state.store.locked_page_names.contains(page_name)

                cell.update(title: title, section: indexPath.section, border: previously_selected, locked: locked)

                return cell
        }

        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
                return CGSize(width: view.frame.width, height: 50)
        }

        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
                return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)

        }

        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
                return CGSize(width: cell_width, height: cell_height)
        }

        func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! HomeCellView
                cell.highlight()
        }

        func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! HomeCellView
                cell.dehighlight()
        }

        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
                let page_state = section_row_to_page_state(section: indexPath.section, row: indexPath.row)
                state.navigate(page_state: page_state)
                state.render()
        }

        func scrollViewDidScroll(scrollView: UIScrollView) {
                if !view_will_layout_subviews_was_called {
                        state.home_content_offset = collection_view.contentOffset
                } else {
                        view_will_layout_subviews_was_called = false
                }
        }
}

class HomeHeaderView: UICollectionReusableView {

        let label = UILabel()

        override init(frame: CGRect) {
                super.init(frame: frame)

                label.textAlignment = .Center
                addSubview(label)
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()
                label.frame = bounds
        }

        func update(title title: String) {
                let attributed_text = astring_font_size_color(string: title, font: font_headline, font_size: 20, color: nil)
                label.attributedText = attributed_text
                label.textAlignment = .Center
        }
}

class HomeCellView: UICollectionViewCell {

        var color_normal = UIColor.redColor()

        let label = UILabel()
        let lock_label = UILabel()

        override init(frame: CGRect) {
                super.init(frame: frame)

                contentView.layer.cornerRadius = 10

                lock_label.attributedText = astring_font_size_color(string: "\u{1F512}", font: nil, font_size: 30, color: nil)
                lock_label.textAlignment = .Center
                contentView.addSubview(lock_label)

                label.numberOfLines = 0
                label.textAlignment = .Center
                contentView.addSubview(label)
        }

        required init(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
                super.layoutSubviews()

                if lock_label.hidden {
                        label.frame = bounds
                } else {
                        lock_label.sizeToFit()
                        let separator_x = bounds.width - lock_label.frame.width
                        lock_label.frame.origin = CGPoint(x: separator_x, y: (bounds.height - lock_label.frame.height) / 2)
                        label.frame = CGRect(x: 0, y: 0, width: separator_x, height: bounds.height)
                }
        }

        func update(title title: String, section: Int, border: Bool, locked: Bool) {
                let attributed_text = astring_font_size_color(string: title, font: font_body, font_size: 16, color: nil)
                label.attributedText = attributed_text
                label.textAlignment = .Center
                color_normal = color_from_hex(hex: color_brewer_qualitative_9_pastel1[section])
                contentView.backgroundColor = color_normal
                if border {
                        contentView.layer.borderWidth = 2
                        contentView.layer.borderColor = UIColor.blackColor().CGColor
                } else {
                        contentView.layer.borderWidth = 0
                        contentView.layer.borderColor = UIColor.whiteColor().CGColor
                }
                lock_label.hidden = !locked
                setNeedsLayout()
        }

        func highlight() {
                contentView.backgroundColor = color_normal.colorWithAlphaComponent(0.5)
        }

        func dehighlight() {
                contentView.backgroundColor = color_normal
        }
}
