import Foundation

class SupervisedClassification {

        let supervised_classification_type: SupervisedClassificationType

        enum SupervisedClassificationValidationMethod {
                case TrainingTest
                case LeaveOneOut
                case KFoldCrossValidation
        }

        var validation_method = SupervisedClassificationValidationMethod.TrainingTest

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

        var additional_sample_indices = [] as [Int]
        var additional_sample_names = [] as [String]
        var additional_sample_level_ids = [] as [Int]
        var additional_sample_level_names = [] as [String]
        var additional_sample_classified_level_ids = [] as [Int]

        var number_of_samples_per_level_id = [:] as [Int: Int]

        var training_level_id_set = [] as Set<Int>
        var training_sample_index_set = [] as Set<Int>
        var training_number_of_samples_per_comparison_level_id = [:] as [Int: Int]

        var k_fold = 2

        var classification_success = true

        var test_sample_indices = [] as [Int]
        var test_sample_names = [] as [String]
        var test_sample_level_ids = [] as [Int]
        var test_sample_classified_level_ids = [] as [Int]

        init(supervised_classification_type: SupervisedClassificationType, comparison_factor_id: Int, comparison_level_ids: [Int]) {
                self.supervised_classification_type = supervised_classification_type
                self.comparison_factor_id = comparison_factor_id
                let comparison_factor_index = state.factor_ids.indexOf(comparison_factor_id)!
                comparison_factor_name = state.factor_names[comparison_factor_index]

                for i in 0 ..< state.level_ids_by_factor[comparison_factor_index].count {
                        let level_id = state.level_ids_by_factor[comparison_factor_index][i]
                        let level_name = state.level_names_by_factor[comparison_factor_index][i]
                        if comparison_level_ids.indexOf(level_id) != nil {
                                self.comparison_level_ids.append(level_id)
                                comparison_level_names.append(level_name)
                        } else {
                                additional_level_ids.append(level_id)
                                additional_level_names.append(level_name)
                        }

                        number_of_samples_per_level_id[level_id] = 0
                }

                for i in 0 ..< state.number_of_samples {
                        let sample_name = state.sample_names[i]
                        let level_id = state.level_ids_by_factor_and_sample[comparison_factor_index][i]
                        let level_name = state.level_names_by_factor_and_sample[comparison_factor_index][i]
                        if comparison_level_ids.indexOf(level_id) != nil {
                                core_sample_indices.append(i)
                                core_sample_names.append(sample_name)
                                core_sample_level_ids.append(level_id)
                                core_sample_level_names.append(level_name)
                        } else {
                                additional_sample_indices.append(i)
                                additional_sample_names.append(sample_name)
                                additional_sample_level_ids.append(level_id)
                                additional_sample_level_names.append(level_name)
                                additional_sample_classified_level_ids.append(0)
                        }
                        number_of_samples_per_level_id[level_id]?++
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
                training_level_id_set = []
                training_sample_index_set = []
                calculate_training_number_of_samples()
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

                if training_level_id_set.contains(level_id) {
                        training_level_id_set.remove(level_id)
                        for sample_index in sample_indices_for_level {
                                training_sample_index_set.remove(sample_index)
                        }
                } else {
                        training_level_id_set.insert(level_id)
                        for sample_index in sample_indices_for_level {
                                training_sample_index_set.insert(sample_index)
                        }
                }
                calculate_training_number_of_samples()
        }

        func toggle_sample(sample_index sample_index: Int) {
                if training_sample_index_set.contains(sample_index) {
                        training_sample_index_set.remove(sample_index)
                } else {
                        training_sample_index_set.insert(sample_index)
                }
                calculate_training_number_of_samples()
        }

        func calculate_training_number_of_samples() {
                for level_id in comparison_level_ids {
                        training_number_of_samples_per_comparison_level_id[level_id] = 0
                }

                for i in 0 ..< core_sample_indices.count {
                        let sample_index = core_sample_indices[i]

                        if training_sample_index_set.contains(sample_index) {
                                let level_id = core_sample_level_ids[i]
                                training_number_of_samples_per_comparison_level_id[level_id]?++
                        }
                }
        }

        func select_all_samples() {
                for sample_index in core_sample_indices {
                        training_sample_index_set.insert(sample_index)
                }
                calculate_training_number_of_samples()
        }

        func deselect_all_samples() {
                training_sample_index_set = []
                training_level_id_set.removeAll()
                calculate_training_number_of_samples()
        }
        
        //        func classify() {
        //                switch validation_method {
        //                case .TrainingTest:
        //                        classify_training_test()
        //                case .LeaveOneOut:
        //                        k_fold = core_sample_indices.count
        //                        classify_k_fold_cross_validation()
        //                default:
        //                        classify_k_fold_cross_validation()
        //                }
        //        }
        //
        //        func classify_training_test() {
        //                var training_sample_indices = [] as [Int]
        //                var training_level_ids = [] as [Int]
        //                test_sample_indices = []
        //                test_sample_names = []
        //                test_sample_level_ids = []
        //
        //                for i in 0 ..< core_sample_indices.count {
        //                        let sample_index = core_sample_indices[i]
        //                        if training_sample_index_set.contains(sample_index) {
        //                                training_sample_indices.append(sample_index)
        //                                training_level_ids.append(core_sample_level_ids[i])
        //                        } else {
        //                                test_sample_indices.append(sample_index)
        //                                test_sample_names.append(core_sample_names[i])
        //                                test_sample_level_ids.append(core_sample_level_ids[i])
        //                        }
        //                }
        //
        //                if k > training_sample_indices.count {
        //                        k = training_sample_indices.count
        //                } else if k < 1 {
        //                        k = 1
        //                }
        //
        //                let classification_sample_indices = test_sample_indices + additional_sample_indices
        //                var classification_level_ids = [Int](count: classification_sample_indices.count, repeatedValue: -1)
        //
        //                let success = knn_classify_training_test(state.values, state.number_of_molecules, state.number_of_samples, training_sample_indices, training_level_ids, training_sample_indices.count, classification_sample_indices, classification_sample_indices.count, k, &classification_level_ids)
        //
        //                if success {
        //                        classification_success = true
        //                        test_sample_classified_level_ids = [Int](classification_level_ids[0 ..< test_sample_indices.count])
        //                        additional_sample_classified_level_ids = [Int](classification_level_ids[test_sample_indices.count ..< classification_sample_indices.count])
        //                } else {
        //                        classification_success = false
        //                        test_sample_classified_level_ids = [Int](count: test_sample_indices.count, repeatedValue: 0)
        //                        additional_sample_classified_level_ids = [Int](count: additional_sample_indices.count, repeatedValue: 0)
        //                }
        //        }
        //
        //        func classify_k_fold_cross_validation() {
        //                test_sample_indices = []
        //                test_sample_names = []
        //                test_sample_level_ids = []
        //                test_sample_classified_level_ids = []
        //
        //                if core_sample_indices.count < 2 {
        //                        classification_success = false
        //
        //                }
        //
        //                var shuffled_numbers = [Int](0 ..< core_sample_indices.count)
        //                if k_fold < core_sample_indices.count {
        //                        fisher_yates_shuffle(&shuffled_numbers, shuffled_numbers.count)
        //                }
        //
        //                let minimum_size = core_sample_indices.count / k_fold
        //                let remainder = core_sample_indices.count % k_fold
        //                classification_success = true
        //                var counter = 0
        //                for i in 0 ..< k_fold {
        //                        let size = minimum_size + (i < remainder ? 1 : 0)
        //                        var training_sample_indices = [] as [Int]
        //                        var training_level_ids = [] as [Int]
        //                        var classification_sample_indices = [] as [Int]
        //                        var classification_level_ids = [Int](count: size, repeatedValue: -1)
        //                        for i in 0 ..< core_sample_indices.count {
        //                                let j = shuffled_numbers[i]
        //                                if i >= counter && i < counter + size {
        //                                        classification_sample_indices.append(core_sample_indices[j])
        //                                        test_sample_indices.append(core_sample_indices[j])
        //                                        test_sample_names.append(core_sample_names[j])
        //                                        test_sample_level_ids.append(core_sample_level_ids[j])
        //                                } else {
        //                                        training_sample_indices.append(core_sample_indices[j])
        //                                        training_level_ids.append(core_sample_level_ids[j])
        //                                }
        //                        }
        //
        //                        let success = knn_classify_training_test(state.values, state.number_of_molecules, state.number_of_samples, training_sample_indices, training_level_ids, training_sample_indices.count, classification_sample_indices, size, k, &classification_level_ids)
        //                        
        //                        if success && classification_success {
        //                                test_sample_classified_level_ids += classification_level_ids
        //                        } else {
        //                                classification_success = false
        //                        }
        //                        
        //                        counter += size
        //                }
        //        }
}
