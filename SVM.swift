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
                        return 1.0 / Double(molecule_indices.count)
                }
        }
}
