import Foundation

class SVM: SupervisedClassification {

        enum SVMKernel {
                case Linear
                case RBF
        }
        var kernel = SVMKernel.Linear

        let C_default = 1.0
        var C = 1.0

        var gamma = 0.0

        init(comparison_factor_id: Int, comparison_level_ids: [Int]) {
                super.init(supervised_classification_type: .SVM, comparison_factor_id: comparison_factor_id, comparison_level_ids: comparison_level_ids)


        }

        override func validation_training_test() {
                super.validation_training_test()
                gamma = gamma_default()
        }

        override func validation_leave_one_out() {
                super.validation_leave_one_out()
                gamma = gamma_default()
        }

        override func validation_k_fold_cross_validation() {
                super.validation_k_fold_cross_validation()
                gamma = gamma_default()
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

                let classification_sample_indices = test_sample_indices + additional_sample_indices
                var classification_level_ids = [Int](count: classification_sample_indices.count, repeatedValue: -1)

//                let success = knn_classify_training_test(state.values, state.number_of_molecules, state.number_of_samples, training_sample_indices, training_level_ids, training_sample_indices.count, classification_sample_indices, classification_sample_indices.count, k, &classification_level_ids)

//                if success {
//                        classification_success = true
//                        test_sample_classified_level_ids = [Int](classification_level_ids[0 ..< test_sample_indices.count])
//                        additional_sample_classified_level_ids = [Int](classification_level_ids[test_sample_indices.count ..< classification_sample_indices.count])
//                } else {
//                        classification_success = false
//                        test_sample_classified_level_ids = [Int](count: test_sample_indices.count, repeatedValue: 0)
//                        additional_sample_classified_level_ids = [Int](count: additional_sample_indices.count, repeatedValue: 0)
//                }
        }


}
