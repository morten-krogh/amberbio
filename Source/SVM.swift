import Foundation

class SVM: SupervisedClassification {

        enum SVMKernel: Int {
                case Linear = 0
                case RBF = 1
        }
        var kernel = SVMKernel.Linear

        let C_default = 1.0
        var linear_C = 1.0

        var rbf_C = 1.0
        var rbf_gamma = 0.0

        var first_training_level_id = 0

        init(comparison_factor_id: Int, comparison_level_ids: [Int]) {
                super.init(supervised_classification_type: .SVM, comparison_factor_id: comparison_factor_id, comparison_level_ids: comparison_level_ids)
        }

        override func validation_training_test() {
                super.validation_training_test()
                rbf_gamma = gamma_default()
        }

        override func validation_leave_one_out() {
                super.validation_leave_one_out()
                rbf_gamma = gamma_default()
        }

        override func validation_k_fold_cross_validation() {
                super.validation_k_fold_cross_validation()
                rbf_gamma = gamma_default()
        }

        func gamma_default() -> Double {
                if molecule_indices.isEmpty {
                        calculate_molecule_indices()
                }

                if molecule_indices.isEmpty {
                        return 1.0
                } else {
                        let value = 1.0 / Double(molecule_indices.count)
                        let str = decimal_string(number: value, significant_digits: 1)
                        return string_to_double(string: str) ?? 1.0
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

                first_training_level_id = training_level_ids[0]

                if molecule_indices.isEmpty {
                        calculate_molecule_indices()
                }

                if molecule_indices.isEmpty {
                        classification_success = false
                        test_sample_classified_level_ids = [Int](count: test_sample_indices.count, repeatedValue: 0)
                        test_sample_decision_values = [Double](count: test_sample_indices.count, repeatedValue: 0)
                        additional_sample_classified_level_ids = [Int](count: additional_sample_indices.count, repeatedValue: 0)
                } else {
                        classification_success = true

                        let classification_sample_indices = test_sample_indices + additional_sample_indices
                        var classification_level_ids = [Int](count: classification_sample_indices.count, repeatedValue: -1)
                        var classification_decision_values = [Double](count: classification_sample_indices.count, repeatedValue: 0)

                        svm_adapter_train_test(state.values, molecule_indices, molecule_indices.count, state.number_of_samples, training_sample_indices, training_level_ids, training_sample_indices.count, classification_sample_indices, classification_sample_indices.count, &classification_level_ids, &classification_decision_values, kernel.rawValue, linear_C, rbf_C, rbf_gamma)

                        test_sample_classified_level_ids = [Int](classification_level_ids[0 ..< test_sample_indices.count])
                        test_sample_decision_values = [Double](classification_decision_values[0 ..< test_sample_indices.count])

                        additional_sample_classified_level_ids = [Int](classification_level_ids[test_sample_indices.count ..< classification_sample_indices.count])
                        additional_sample_decision_values = [Double](classification_decision_values[test_sample_indices.count ..< classification_sample_indices.count])
                }
        }

        override func classify_k_fold_cross_validation() {
                test_sample_indices = []
                test_sample_names = []
                test_sample_level_ids = []
                test_sample_classified_level_ids = []
                test_sample_decision_values = []

                if core_sample_indices.count < 2 {
                        classification_success = false
                        return
                }

                if molecule_indices.isEmpty {
                        calculate_molecule_indices()
                }

                if molecule_indices.isEmpty {
                        classification_success = false
                        return
                }

                var shuffled_numbers = [Int](0 ..< core_sample_indices.count)
                if k_fold < core_sample_indices.count {
                        fisher_yates_shuffle(&shuffled_numbers, shuffled_numbers.count)
                }

                let minimum_size = core_sample_indices.count / k_fold
                let remainder = core_sample_indices.count % k_fold
                var counter = 0

                first_training_level_id = 0

                for i in 0 ..< k_fold {
                        let size = minimum_size + (i < remainder ? 1 : 0)
                        var training_sample_indices = [] as [Int]
                        var training_level_ids = [] as [Int]
                        var classification_sample_indices = [] as [Int]
                        var classification_level_ids = [Int](count: size, repeatedValue: -1)
                        var classification_decision_values = [Double](count: size, repeatedValue: 0)
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

                        svm_adapter_train_test(state.values, molecule_indices, molecule_indices.count, state.number_of_samples, training_sample_indices, training_level_ids, training_sample_indices.count, classification_sample_indices, classification_sample_indices.count, &classification_level_ids, &classification_decision_values, kernel.rawValue, linear_C, rbf_C, rbf_gamma)

                        test_sample_classified_level_ids += classification_level_ids

                        if i == 0 {
                                first_training_level_id = training_level_ids[0]
                        }

                        print(test_sample_names)
                        print(classification_decision_values)
                        print(i)
                        print(first_training_level_id)
                        print(training_level_ids)

                        if comparison_level_ids.count == 2 && first_training_level_id != training_level_ids[0] {
                                print("hej")
                                test_sample_decision_values += classification_decision_values.map { -$0 }
                        } else {
                                test_sample_decision_values += classification_decision_values
                        }

                        counter += size
                }
        }
}
