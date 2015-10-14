import Foundation

class SVM: SupervisedClassification {

        enum SVMKernel {
                case Linear
                case RBF
        }
        var kernel = SVMKernel.Linear

        let C_default = 1.0
        var C = 1.0

        var gamma_default = 1.0
        var gamma = 1.0

        init(comparison_factor_id: Int, comparison_level_ids: [Int]) {
                super.init(supervised_classification_type: .SVM, comparison_factor_id: comparison_factor_id, comparison_level_ids: comparison_level_ids)


        }



}
