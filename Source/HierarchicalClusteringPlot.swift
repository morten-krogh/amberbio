import UIKit

class HierarchicalClusteringPlotState: PageState {

        var distance_measure = "correlation"
        var linkage = "average"
        var value_correction = "centered"
        var molecules_shown = "none"
        var order_of_molecules = "correlation"
        var selected_factors = [Bool](count: state.factor_ids.count, repeatedValue: true)
        var selected_samples = [Bool](count: state.number_of_samples, repeatedValue: true)
        var molecule_title_number = 0

        var hierarchical_clustering_drawer: HierarchicalClusteringDrawer?

        init(distance_measure: String, linkage: String, value_correction: String, molecules_shown: String, order_of_molecules: String, selected_factors: [Bool], selected_samples: [Bool], molecule_title_number: Int) {
                super.init()
                name = "hierarchical_clustering_plot"
                title = astring_body(string: "Hierarchical Clustering")
                info = "The samples are clustered with the chosen distance and linkage method.\n\nSee the manual for a full discussion."
                self.distance_measure = distance_measure
                self.linkage = linkage
                self.value_correction = value_correction
                self.molecules_shown = molecules_shown
                self.order_of_molecules = order_of_molecules
                self.selected_factors = selected_factors
                self.selected_samples = selected_samples
                self.molecule_title_number = molecule_title_number

                pdf_enabled = true
                full_screen = true

                prepared = false
        }

        override func prepare() {
                var values_corrected = [] as [Double]
                if value_correction == "original" {
                        values_corrected = state.values
                } else {
                        values_corrected = [Double](count: state.values.count, repeatedValue: 0)
                        calculate_molecule_centered_values(state.values, state.number_of_molecules, state.number_of_samples, &values_corrected)
                }

                let selected_sample_indices = [Int](0 ..< state.sample_ids.count).filter { self.selected_samples[$0] }
                let selected_molecule_indices = calculate_molecule_indices_without_missing_values(values: values_corrected, number_of_molecules: state.number_of_molecules, selected_sample_indices: selected_sample_indices)

                if selected_molecule_indices.count > 0 {

                        let point_distances = calculate_distances(values: values_corrected, total_number_of_samples: state.number_of_samples, selected_sample_indices: selected_sample_indices, selected_molecule_indices: selected_molecule_indices, distance_measure: distance_measure)

                        let hierarchical_clustering = HierarchicalClustering(number_of_points: selected_sample_indices.count, point_distances: point_distances, linkage: linkage)

                        var ordered_sample_indices = [Int](count: selected_sample_indices.count, repeatedValue: -1)
                        var ordered_sample_names = [String](count: selected_sample_indices.count, repeatedValue: "")
                        for i in 0 ..< selected_sample_indices.count {
                                let order = hierarchical_clustering.order[i]
                                let sample_index = selected_sample_indices[i]
                                ordered_sample_indices[order] = sample_index
                                ordered_sample_names[order] = state.sample_names[sample_index]
                        }

                        var plot_factor_names = [] as [String]
                        var plot_level_colors = [] as [[UIColor]]
                        for i in 0 ..< state.factor_ids.count {
                                if selected_factors[i] {
                                        var colors = [] as [UIColor]
                                        let level_colors = state.level_colors_by_factor_and_sample[i]
                                        plot_factor_names.append(state.factor_names[i])
                                        for sample_index in ordered_sample_indices {
                                                let color = color_from_hex(hex: level_colors[sample_index])
                                                colors.append(color)
                                        }
                                        plot_level_colors.append(colors)
                                }
                        }

                        var plot_molecule_indices = [] as [Int]
                        if molecules_shown == "present" {
                                plot_molecule_indices = selected_molecule_indices
                        } else if molecules_shown == "all" {
                                plot_molecule_indices = [Int](0 ..< state.number_of_molecules)
                        }

                        var plot_molecule_names = [] as [String]
                        var plot_values = [] as [[Double]]
                        let molecule_titles = molecule_title_number == 0 ? state.molecule_names : state.molecule_annotation_values[molecule_title_number - 1]
                        for molecule_index in plot_molecule_indices {
                                plot_molecule_names.append(molecule_titles[molecule_index])
                                let offset = molecule_index * state.sample_ids.count
                                var molecule_values = [] as [Double]
                                for sample_index in ordered_sample_indices {
                                        let value = values_corrected[offset + sample_index]
                                        molecule_values.append(value)
                                }
                                plot_values.append(molecule_values)
                        }

                        var ordered_plot_molecule_names = [] as [String]
                        var ordered_plot_values = [] as [[Double]]

                        if order_of_molecules == "correlation" {
                                let order_vector = [Int](0 ..< ordered_sample_indices.count).map { Double($0) }
                                var correlations = [] as [Double]
                                for row in plot_values {
                                        let correlation = calculate_correlation_with_missing(values1: order_vector, values2: row)
                                        correlations.append(correlation)
                                }
                                var molecule_order = [Int](0 ..< plot_values.count)
                                molecule_order.sortInPlace { correlations[$0] < correlations[$1] }
                                for i in molecule_order {
                                        ordered_plot_molecule_names.append(plot_molecule_names[i])
                                        ordered_plot_values.append(plot_values[i])
                                }
                        } else {
                                ordered_plot_molecule_names = plot_molecule_names
                                ordered_plot_values = plot_values
                        }

                        let color_key = ColorKey(values: ordered_plot_values)

                        hierarchical_clustering_drawer = HierarchicalClusteringDrawer(hierarchical_clustering: hierarchical_clustering, sample_names: ordered_sample_names, factor_names: plot_factor_names, level_colors: plot_level_colors, molecule_names: ordered_plot_molecule_names, heatmap_colors: color_key.colors, color_key: color_key)
                }

                prepared = true
        }
}

class HierarchicalClusteringPlot: Component {

        var hierarchical_clustering_plot_state: HierarchicalClusteringPlotState!

        let tiled_scroll_view = TiledScrollView(frame: CGRect.zero)

        override func viewDidLoad() {
                super.viewDidLoad()

                view.addSubview(tiled_scroll_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                set_zoom_level()
                tiled_scroll_view.frame = view.bounds
                if let hierarchical_clustering_drawer = hierarchical_clustering_plot_state.hierarchical_clustering_drawer {
                        tiled_scroll_view.scroll_view.zoomScale = hierarchical_clustering_drawer.minimum_zoom_scale
                }
        }

        override func render() {
                hierarchical_clustering_plot_state = state.page_state as! HierarchicalClusteringPlotState

                if let hierarchical_clustering_drawer = hierarchical_clustering_plot_state.hierarchical_clustering_drawer {
                        tiled_scroll_view.delegate = hierarchical_clustering_drawer
                }
        }

        func set_zoom_level() {
                if let hierarchical_clustering_drawer = hierarchical_clustering_plot_state.hierarchical_clustering_drawer {
                        let width = view.frame.width
                        let height = view.frame.height
                        let min_zoom_width = min(1, width / hierarchical_clustering_drawer.content_size.width)
                        let min_zoom_height = min(1, height / hierarchical_clustering_drawer.content_size.height)
                        let min_zoom = min(max(min_zoom_width, 0.4 * min_zoom_height), max(min_zoom_height, 0.4 * min_zoom_width))
                        hierarchical_clustering_drawer.minimum_zoom_scale = min_zoom
                }
        }

        func pdf_action() {
                let file_name_stem = "hierarchical-clustering-plot"

                var description = "Distance measure: \(hierarchical_clustering_plot_state.distance_measure)\n"
                description += "Linkage: \(hierarchical_clustering_plot_state.linkage)\n"
                if hierarchical_clustering_plot_state.molecules_shown != "none" {
                        description += "Order of molecules: \(hierarchical_clustering_plot_state.order_of_molecules)\n"
                }

                if let hierarchical_clustering_drawer = hierarchical_clustering_plot_state.hierarchical_clustering_drawer {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: hierarchical_clustering_drawer.content_size, draw: hierarchical_clustering_drawer.draw)
                }
                state.render()
        }
}

func calculate_distances(values values: [Double], total_number_of_samples: Int, selected_sample_indices: [Int], selected_molecule_indices: [Int], distance_measure: String) -> [Double] {
        var distances = [] as [Double]
        var value1 = [Double](count: selected_molecule_indices.count, repeatedValue: 0)
        var value2 = [Double](count: selected_molecule_indices.count, repeatedValue: 0)

        for i in 1 ..< selected_sample_indices.count {
                for k in 0 ..< selected_molecule_indices.count {
                        let offset = total_number_of_samples * selected_molecule_indices[k]
                        value1[k] = values[offset + selected_sample_indices[i]]
                }
                for j in 0 ..< i {
                        for k in 0 ..< selected_molecule_indices.count {
                                let offset = total_number_of_samples * selected_molecule_indices[k]
                                value2[k] = values[offset + selected_sample_indices[j]]
                        }
                        let distance = distance_measure == "euclidean" ? distance_euclidean(values1: value1, values2: value2) : distance_correlation(values1: value1, values2: value2)
                        distances.append(distance)
                }
        }

        return distances
}
