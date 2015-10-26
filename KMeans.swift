import Foundation

class KMeans {

        let max_iterations = 100

        var k = 1
        var selected_row = 0

        var molecule_indices = [] as [Int]
        var cluster_for_sample = [] as [Int]

        var should_cluster = true

        init() {
                let sample_indices = [Int](0 ..< state.number_of_samples)
                molecule_indices = [Int](0 ..< state.number_of_molecules)
                var molecule_indices_length = state.number_of_molecules

                knn_molecules_without_missing_values(state.values, state.number_of_molecules, state.number_of_samples, sample_indices, sample_indices.count, &molecule_indices, &molecule_indices_length)
                cluster_for_sample = [Int](count: state.number_of_samples, repeatedValue: 0)
        }

        func set_k(k k: Int) {
                if k != self.k && k >= 1 && k <= state.number_of_samples {
                        self.k = k
                        should_cluster = true
                }
        }

        func cluster() {
                if should_cluster {
                        var distance_square = 0.0
                        k_means_clustering(state.values, molecule_indices, molecule_indices.count, state.number_of_samples, k, max_iterations, &cluster_for_sample, &distance_square)
                }
                should_cluster = false
        }
}
