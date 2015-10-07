import Foundation

class KNN {

        enum ValidationMethod {
                case TrainingTest
                case LeaveOneOut
                case KFoldCrossValidation
        }
        var validation_method = ValidationMethod.TrainingTest

        var comparison_factor_id = 0
        var comparison_factor_name = ""

        var comparison_level_ids = [] as [Int]
        var comparison_level_names = [] as [String]

        var additional_level_ids = [] as [Int]
        var additional_level_names = [] as [String]

        var core_sample_indices = [] as [Int]
        var core_sample_names = [] as [String]
        var core_sample_level_ids = [] as [Int]
        var core_sample_level_names = [] as [String]
        var core_number_of_samples_per_level_id = [:] as [Int: Int]

        var additional_sample_indices = [] as [Int]
        var additional_sample_name = [] as [String]
        var additional_sample_level_ids = [] as [Int]
        var additional_sample_level_names = [] as [String]
        var additional_sample_classified_level_id = [] as [Int]

        var training_level_ids = [] as Set<Int>
        var training_sample_indices = [] as Set<Int>
        var training_number_of_samples_per_comparison_level_id = [:] as [Int: Int]

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
                let comparison_factor_index = state.factor_ids.indexOf(comparison_factor_id)!
                comparison_factor_name = state.factor_names[comparison_factor_index]

                for i in 0 ..< state.level_ids_by_factor[factor_index].count {
                        let level_id = state.level_ids_by_factor[factor_index][i]
                        let level_name = state.level_names_by_factor[factor_index][i]
                        if comparison_level_ids.indexOf(level_id) != nil {
                                self.comparison_level_ids.append(level_id)
                                comparison_level_names.append(level_name)
                        } else {
                                additional_level_ids.append(level_id)
                                additional_level_names.append(level_name)
                        }
                }

                for i in 0 ..< state.number_of_samples {
                        let sample_name = state.sample_names[i]
                        let level_id = state.level_ids_by_factor_and_sample[comparison_factor_index][i]
                        


                }


                for level_id in comparison_level_ids {
                        core_number_of_samples_per_comparison_level_id[level_id] = 0
                }
                for i in 0 ..< state.sample_ids.count {
                        let level_id = state.level_ids_by_factor_and_sample[comparison_factor_index][i]
                        let level_name = state.level_names_by_factor_and_sample[comparison_factor_index][i]
                        if comparison_level_ids.indexOf(level_id) != nil {
                                core_sample_indices.append(i)
                                core_sample_names.append(state.sample_names[i])
                                core_sample_comparison_level_id.append(level_id)
                                core_sample_comparison_level_names.append(level_name)
                                core_number_of_samples_per_comparison_level_id[level_id]?++
                        }

                }

                for level_id in state.level_ids_by_factor[comparison_factor_index] {
                        if comparison_level_ids.indexOf(level_id) == nil {
                                additional_level_id_to_sample_indices[level_id] = []
                        }
                }



        }

        func max_k() -> Int {
                switch validation_method {
                case .TrainingTest:
                        return training_sample_indices.count
                case .LeaveOneOut:
                        return core_sample_indices.count - 1
                default:
                        return core_sample_indices.count - Int(ceil(Double(core_sample_indices.count) / Double(k_fold)))
                }
        }

        func max_k_fold() -> Int {
                return core_sample_indices.count
        }

        func set_k_fold(k_fold k_fold: Int) {
                if k_fold < 2 {
                        self.k_fold = 2
                } else if k_fold > core_sample_indices.count {
                        self.k_fold = core_sample_indices.count
                } else {
                        self.k_fold = k_fold
                }
        }

        func validation_training_test() {
                validation_method = .TrainingTest
                training_level_ids = []
                training_sample_indices = []
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
                for sample_index in core_sample_indices {
                        if state.level_ids_by_factor_and_sample[factor_index][sample_index] == level_id {
                                sample_indices_for_level.append(sample_index)
                        }
                }

                if training_level_ids.contains(level_id) {
                        training_level_ids.remove(level_id)
                        for sample_index in sample_indices_for_level {
                                training_sample_indices.remove(sample_index)
                        }
                } else {
                        training_level_ids.insert(level_id)
                        for sample_index in sample_indices_for_level {
                                training_sample_indices.insert(sample_index)
                        }
                }
                calculate_training_set()
        }

        func toggle_sample(sample_index sample_index: Int) {
                if training_sample_indices.contains(sample_index) {
                        training_sample_indices.remove(sample_index)
                } else {
                        training_sample_indices.insert(sample_index)
                }
                calculate_training_set()
        }

        func calculate_training_set() {
                for level_id in comparison_level_ids {
                        training_number_of_samples_per_comparison_level_id[level_id] = 0
                }

                for i in 0 ..< core_sample_indices.count {
                        let sample_index = core_sample_indices[i]

                        if training_sample_indices.contains(sample_index) {
                                let level_id = core_sample_comparison_level_id[i]
                                training_number_of_samples_per_comparison_level_id[level_id]?++
                        }
                }
        }

        func select_all_samples() {
                for sample_index in core_sample_indices {
                        training_sample_indices.insert(sample_index)
                }
                calculate_training_set()
        }

        func deselect_all_samples() {
                training_sample_indices = []
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

                for i in 0 ..< core_sample_indices.count {
                        let sample_index = core_sample_indices[i]
                        if training_sample_indices.contains(sample_index) {
                                training_sample_indices.append(sample_index)
                                training_labels.append(core_sample_comparison_level_id[i])
                        } else {
                                test_sample_indices.append(sample_index)
                                test_sample_names.append(core_sample_names[i])
                                test_sample_comparison_level_id.append(core_sample_comparison_level_id[i])
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
