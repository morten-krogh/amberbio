import Foundation

class KNN {

        var comparison_factor_id = 0
        var comparison_level_ids = [] as [Int]
        var comparison_factor_name = ""
        var comparison_level_names = [] as [String]

        var sample_indices = [] as [Int]
        var sample_names = [] as [String]
        var sample_comparison_level_id = [] as [Int]
        var number_of_samples_per_comparison_level_id = [:] as [Int: Int]

        enum ValidationMethod {
                case TrainingTest
                case LeaveOneOut
                case KFoldCrossValidation
        }
        var validation_method = ValidationMethod.TrainingTest

        var selected_level_ids = [] as Set<Int>
        var selected_sample_indices = [] as Set<Int>
        var training_sample_indices = [] as Set<Int>
        var number_of_training_samples_per_comparison_level_id = [:] as [Int: Int]

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
                        if comparison_level_ids.indexOf(level_id) != nil {
                                sample_indices.append(i)
                                sample_names.append(state.sample_names[i])
                                sample_comparison_level_id.append(level_id)
                                number_of_samples_per_comparison_level_id[level_id]?++
                        }

                }
        }

        func validation_training_test() {
                validation_method = ValidationMethod.TrainingTest
                selected_level_ids = []
                selected_sample_indices = []
                calculate_training_set()
        }

        func toggle_level(level_id level_id: Int) {
                if selected_level_ids.contains(level_id) {
                        selected_level_ids.remove(level_id)
                } else {
                        selected_level_ids.insert(level_id)
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
                training_sample_indices = []
                for level_id in comparison_level_ids {
                        number_of_samples_per_comparison_level_id[level_id] = 0
                }

                for i in 0 ..< sample_indices.count {
                        let sample_index = sample_indices[i]
                        var selected = false

                        selected = selected_sample_indices.contains(sample_index)

                        for i in 0 ..< state.factor_ids.count {
                                if selected {
                                        break
                                }
                                if state.factor_ids[i] == comparison_factor_id {
                                        continue
                                }
                                let level_id = state.level_ids_by_factor_and_sample[i][sample_index]
                                selected = selected_level_ids.contains(level_id)
                        }

                        if selected {
                                training_sample_indices.insert(sample_index)
                                let level_id = sample_comparison_level_id[i]
                                number_of_samples_per_comparison_level_id[level_id]?++
                        }
                }
        }









}