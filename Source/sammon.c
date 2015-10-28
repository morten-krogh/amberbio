#include "c-functions.h"

long sammon_map(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_indices, const long sample_indices_length, const long dimension, double* sammon_points)
{




        return 0;
}










//                var missing_values_per_molecule = [Int](count: state.number_of_samples, repeatedValue: 0)
//                var std_dev_per_molecule = [Double](count: state.number_of_samples, repeatedValue: 0.0)
//
//                values_calculate_missing_values_and_std_devs(state.values, state.number_of_molecules, state.number_of_samples, &missing_values_per_molecule, &std_dev_per_molecule)
//
//                for i in 0 ..< state.number_of_samples {
//                        if missing_values_per_molecule[i] == 0 {
//                                molecule_indices.append(i)
//                        }
//                }
//
//                let molecule_indices_sorted_after_std_dev = molecule_indices.sort({
//                        std_dev_per_molecule[$0] - std_dev_per_molecule[$1] >= 0
//                })
//
//                if molecule_indices.count >= 2 {
//                        let molecule_index_0 = molecule_indices_sorted_after_std_dev[0]
//                        let molecule_index_1 = molecule_indices_sorted_after_std_dev[1]
//
//                        for i in 0 ..< state.number_of_samples {
//                                let point = [state.values[molecule_index_0 * state.number_of_samples + i], state.values[molecule_index_1 * state.number_of_samples + i]]
//                                sammon_points_2d.append(point)
//                        }
//                }
//
//                if molecule_indices.count >= 3 {
//                        let molecule_index_0 = molecule_indices_sorted_after_std_dev[0]
//                        let molecule_index_1 = molecule_indices_sorted_after_std_dev[1]
//                        let molecule_index_2 = molecule_indices_sorted_after_std_dev[2]
//
//
//                        for i in 0 ..< state.number_of_samples {
//                                let point = [state.values[molecule_index_0 * state.number_of_samples + i], state.values[molecule_index_1 * state.number_of_samples + i], state.values[molecule_index_2 * state.number_of_samples + i]]
//                                sammon_points_3d.append(point)
//                        }
//                }
//
//                var distances = [Double](count: state.number_of_samples, repeatedValue: 0.0)
//
//                values_distances_euclidean(state.values, state.number_of_samples, molecule_indices, molecule_indices.count, &distances)

