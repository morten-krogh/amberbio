import Foundation

class KNN {

        var comparison_factor_id = 0
        var comparison_level_ids = [] as [Int]
        var comparison_factor_name = ""
        var comparison_level_names = [] as [String]

        var sample_indices = [] as [Int]
        var sample_names = [] as [String]
        var sample_comparison_level_id = [] as [Int]
        var sample_comparison_level_names = [] as [String]
        var number_of_samples_per_comparison_level_id = [:] as [Int: Int]

        enum ValidationMethod {
                case TrainingTest
                case LeaveOneOut
                case KFoldCrossValidation
        }
        var validation_method = ValidationMethod.TrainingTest

        var selected_level_ids = [] as Set<Int>
        var selected_sample_indices = [] as Set<Int>
        var number_of_training_samples_per_comparison_level_id = [:] as [Int: Int]

        var k = 1

        var k_fold = 2

        var classification_success = true

        var test_sample_indices = [] as [Int]
        var test_sample_names = [] as [String]
        var test_sample_comparison_level_id = [] as [Int]
        var test_sample_classified_labels = [] as [Int]

        var test_sample_indices_per_level = [] as [[Int]]

        init(comparison_factor_id: Int, comparison_level_ids: [Int]) {
                self.comparison_factor_id = comparison_factor_id
                self.comparison_level_ids = comparison_level_ids

                let comparison_factor_index = state.factor_ids.indexOf(comparison_factor_id)!
                comparison_factor_name = state.factor_names[comparison_factor_index]
                for level_id in comparison_level_ids {
                        let level_index = state.level_ids_by_factor[comparison_factor_index].indexOf(level_id)!
                        comparison_level_names.append(state.level_names_by_factor[comparison_factor_index][level_index])
                }

                for level_id in comparison_level_ids {
                        number_of_samples_per_comparison_level_id[level_id] = 0
                }
                for i in 0 ..< state.sample_ids.count {
                        let level_id = state.level_ids_by_factor_and_sample[comparison_factor_index][i]
                        let level_name = state.level_names_by_factor_and_sample[comparison_factor_index][i]
                        if comparison_level_ids.indexOf(level_id) != nil {
                                sample_indices.append(i)
                                sample_names.append(state.sample_names[i])
                                sample_comparison_level_id.append(level_id)
                                sample_comparison_level_names.append(level_name)
                                number_of_samples_per_comparison_level_id[level_id]?++
                        }

                }
        }

        func max_k() -> Int {
                switch validation_method {
                case .TrainingTest:
                        return selected_sample_indices.count
                case .LeaveOneOut:
                        return sample_indices.count - 1
                default:
                        return sample_indices.count - Int(ceil(Double(sample_indices.count) / Double(k_fold)))
                }
        }

        func max_k_fold() -> Int {
                return sample_indices.count
        }

        func set_k_fold(k_fold k_fold: Int) {
                if k_fold < 2 {
                        self.k_fold = 2
                } else if k_fold > sample_indices.count {
                        self.k_fold = sample_indices.count
                } else {
                        self.k_fold = k_fold
                }
        }

        func validation_training_test() {
                validation_method = .TrainingTest
                selected_level_ids = []
                selected_sample_indices = []
                calculate_training_set()
        }

        func validation_leave_one_out() {
                validation_method = .LeaveOneOut
        }

        func validation_k_fold_cross_validation() {
                validation_method = .KFoldCrossValidation
        }

        func toggle_level(factor_index factor_index: Int, level_id: Int) {
                var sample_indices_for_level = [] as [Int]
                for sample_index in sample_indices {
                        if state.level_ids_by_factor_and_sample[factor_index][sample_index] == level_id {
                                sample_indices_for_level.append(sample_index)
                        }
                }

                if selected_level_ids.contains(level_id) {
                        selected_level_ids.remove(level_id)
                        for sample_index in sample_indices_for_level {
                                selected_sample_indices.remove(sample_index)
                        }
                } else {
                        selected_level_ids.insert(level_id)
                        for sample_index in sample_indices_for_level {
                                selected_sample_indices.insert(sample_index)
                        }
                }
                calculate_training_set()
        }

        func toggle_sample(sample_index sample_index: Int) {
                if selected_sample_indices.contains(sample_index) {
                        selected_sample_indices.remove(sample_index)
                } else {
                        selected_sample_indices.insert(sample_index)
                }
                calculate_training_set()
        }

        func calculate_training_set() {
                for level_id in comparison_level_ids {
                        number_of_training_samples_per_comparison_level_id[level_id] = 0
                }

                for i in 0 ..< sample_indices.count {
                        let sample_index = sample_indices[i]

                        if selected_sample_indices.contains(sample_index) {
                                let level_id = sample_comparison_level_id[i]
                                number_of_training_samples_per_comparison_level_id[level_id]?++
                        }
                }
        }

        func select_all_samples() {
                for sample_index in sample_indices {
                        selected_sample_indices.insert(sample_index)
                }
                calculate_training_set()
        }

        func deselect_all_samples() {
                selected_sample_indices = []
                calculate_training_set()
        }

        func classify() {
                switch validation_method {
                case .TrainingTest:
                        classify_training_test()
                default:
                        break
                }
                summarize()
        }

        func classify_training_test() {
                var training_sample_indices = [] as [Int]
                var training_labels = [] as [Int]
                test_sample_indices = []
                test_sample_names = []
                test_sample_comparison_level_id = []

                for i in 0 ..< sample_indices.count {
                        let sample_index = sample_indices[i]
                        if selected_sample_indices.contains(sample_index) {
                                training_sample_indices.append(sample_index)
                                training_labels.append(sample_comparison_level_id[i])
                        } else {
                                test_sample_indices.append(sample_index)
                                test_sample_names.append(sample_names[i])
                                test_sample_comparison_level_id.append(sample_comparison_level_id[i])
                        }
                }

                test_sample_classified_labels = [Int](count: test_sample_indices.count, repeatedValue: -1)

                if k > training_sample_indices.count {
                        k = training_sample_indices.count
                } else if k < 1 {
                        k = 1
                }

                let success = knn_classify_training_test(state.values, state.number_of_molecules, state.number_of_samples, training_sample_indices, training_labels, training_sample_indices.count, test_sample_indices, test_sample_indices.count, k, &test_sample_classified_labels)

                classification_success = success == 0
        }

        func test_sample_indices_for_level_label(level_id level_id: Int, label: Int) -> [Int] {
                var sample_indices = [] as [Int]
                for i in 0 ..< test_sample_indices.count {
                        if test_sample_comparison_level_id[i] == level_id && test_sample_classified_labels[i] == label {
                                sample_indices.append(test_sample_indices[i])
                        }
                }
                return sample_indices
        }

        func summarize() {
                test_sample_indices_per_level = []
                for level_id in comparison_level_ids {
                        var sample_indices_per_level = [] as [Int]
                        for label in comparison_level_ids + [-1] {
                                sample_indices_per_level += test_sample_indices_for_level_label(level_id: level_id, label: label)
                        }
                        test_sample_indices_per_level.append(sample_indices_per_level)
                }
        }
}
