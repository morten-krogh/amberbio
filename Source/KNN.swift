import Foundation

class KNN: SupervisedClassification {

        var k = 1

        init(comparison_factor_id: Int, comparison_level_ids: [Int]) {
                super.init(supervised_classification_type: .KNN, comparison_factor_id: comparison_factor_id, comparison_level_ids: comparison_level_ids)
        }

        func max_k() -> Int {
                switch validation_method {
                case .TrainingTest:
                        return training_sample_index_set.count
                case .LeaveOneOut:
                        return core_sample_indices.count - 1
                default:
                        return core_sample_indices.count - Int(ceil(Double(core_sample_indices.count) / Double(k_fold)))
                }
        }

        override func classify_training_test() {
                var training_sample_indices = [] as [Int]
                var training_level_ids = [] as [Int]
                test_sample_indices = []
                test_sample_names = []
                test_sample_level_ids = []

                for i in 0 ..< core_sample_indices.count {
                        let sample_index = core_sample_indices[i]
                        if training_sample_index_set.contains(sample_index) {
                                training_sample_indices.append(sample_index)
                                training_level_ids.append(core_sample_level_ids[i])
                        } else {
                                test_sample_indices.append(sample_index)
                                test_sample_names.append(core_sample_names[i])
                                test_sample_level_ids.append(core_sample_level_ids[i])
                        }
                }

                if k > training_sample_indices.count {
                        k = training_sample_indices.count
                } else if k < 1 {
                        k = 1
                }

                let classification_sample_indices = test_sample_indices + additional_sample_indices
                var classification_level_ids = [Int](count: classification_sample_indices.count, repeatedValue: -1)

                let success = knn_classify_training_test(state.values, state.number_of_molecules, state.number_of_samples, training_sample_indices, training_level_ids, training_sample_indices.count, classification_sample_indices, classification_sample_indices.count, k, &classification_level_ids)

                if success {
                        classification_success = true
                        test_sample_classified_level_ids = [Int](classification_level_ids[0 ..< test_sample_indices.count])
                        additional_sample_classified_level_ids = [Int](classification_level_ids[test_sample_indices.count ..< classification_sample_indices.count])
                } else {
                        classification_success = false
                        test_sample_classified_level_ids = [Int](count: test_sample_indices.count, repeatedValue: 0)
                        additional_sample_classified_level_ids = [Int](count: additional_sample_indices.count, repeatedValue: 0)
                }
        }

        override func classify_k_fold_cross_validation() {
                test_sample_indices = []
                test_sample_names = []
                test_sample_level_ids = []
                test_sample_classified_level_ids = []

                if core_sample_indices.count < 2 {
                        classification_success = false
                }

                var shuffled_numbers = [Int](0 ..< core_sample_indices.count)
                if k_fold < core_sample_indices.count {
                                fisher_yates_shuffle(&shuffled_numbers, shuffled_numbers.count)
                }

                let minimum_size = core_sample_indices.count / k_fold
                let remainder = core_sample_indices.count % k_fold
                classification_success = true
                var counter = 0
                for i in 0 ..< k_fold {
                        let size = minimum_size + (i < remainder ? 1 : 0)
                        var training_sample_indices = [] as [Int]
                        var training_level_ids = [] as [Int]
                        var classification_sample_indices = [] as [Int]
                        var classification_level_ids = [Int](count: size, repeatedValue: -1)
                        for i in 0 ..< core_sample_indices.count {
                                let j = shuffled_numbers[i]
                                if i >= counter && i < counter + size {
                                        classification_sample_indices.append(core_sample_indices[j])
                                        test_sample_indices.append(core_sample_indices[j])
                                        test_sample_names.append(core_sample_names[j])
                                        test_sample_level_ids.append(core_sample_level_ids[j])
                                } else {
                                        training_sample_indices.append(core_sample_indices[j])
                                        training_level_ids.append(core_sample_level_ids[j])
                                }
                        }

                        let success = knn_classify_training_test(state.values, state.number_of_molecules, state.number_of_samples, training_sample_indices, training_level_ids, training_sample_indices.count, classification_sample_indices, size, k, &classification_level_ids)

                        if success && classification_success {
                                test_sample_classified_level_ids += classification_level_ids
                        } else {
                                classification_success = false
                        }

                        counter += size
                }
        }
}
