import Foundation

class KNN {

        let comparison_factor_id: Int
        let comparison_level_ids: [Int]
        let comparison_factor_name: String
        let comparison_level_names: [String]

        init(comparison_factor_id: Int, comparison_level_ids: [Int]) {
                self.comparison_factor_id = comparison_factor_id
                self.comparison_level_ids = comparison_level_ids

                let comparison_factor_index = state.factor_ids.indexOf(comparison_factor_id)!
                comparison_factor_name = state.factor_names[comparison_factor_index]
                var level_names = [] as [String]
                for level_id in comparison_level_ids {
                        let level_index = state.level_ids_by_factor[comparison_factor_index].indexOf(level_id)!
                        level_names.append(state.level_names_by_factor[comparison_factor_index][level_index])
                }
                comparison_level_names = level_names

                var sample_indices = [] as [Int]
                var sample_names = [] as [String]
                var sample_comparison_level_id = [] as [Int]
                var number_of_samples_per_comparison_level_id = [:] as [Int: Int]
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












}