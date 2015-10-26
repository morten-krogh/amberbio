import Foundation

class KMeans {

        let max_iterations = 100

        var k = 1
        var selected_row = 0

        var molecule_indices = [] as [Int]
        var cluster_for_sample = [] as [Int]

        var can_cluster = true
        var should_cluster = true

        var clusters = [] as [[Int]]

        init() {
                let sample_indices = [Int](0 ..< state.number_of_samples)
                molecule_indices = [Int](0 ..< state.number_of_molecules)
                var molecule_indices_length = state.number_of_molecules

                knn_molecules_without_missing_values(state.values, state.number_of_molecules, state.number_of_samples, sample_indices, sample_indices.count, &molecule_indices, &molecule_indices_length)

                can_cluster = molecule_indices_length != 0
                molecule_indices = [Int](molecule_indices[0 ..< molecule_indices_length])

                cluster_for_sample = [Int](count: state.number_of_samples, repeatedValue: 0)

                if max_k() >= 2 {
                        k = 2
                }
        }

        func set_k(k k: Int) {
                if k != self.k && k >= 1 && k <= state.number_of_samples {
                        self.k = k
                        should_cluster = true
                }
        }

        func max_k() -> Int {
                return state.number_of_samples
        }

        func cluster() {
                if can_cluster && should_cluster {
                        var distance_square = 0.0
                        k_means_clustering(state.values, molecule_indices, molecule_indices.count, state.number_of_samples, k, max_iterations, &cluster_for_sample, &distance_square)

                        cluster_for_sample[0] = 1

                        clusters = []
                        for i in 0 ..< k {
                                var sample_indices = [] as [Int]
                                for j in 0 ..< cluster_for_sample.count {
                                        if cluster_for_sample[j] == i {
                                                sample_indices.append(j)
                                        }
                                }
                                clusters.append(sample_indices)
                        }
                }
                should_cluster = false
        }
}
