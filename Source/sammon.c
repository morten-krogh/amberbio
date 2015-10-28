#include "c-functions.h"

long sammon_map(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_indices, const long sample_indices_length, const long dimension, double* sammon_points)
{
        long molecule_indices[number_of_molecules];
        long molecule_indices_length = 0;

        values_molecules_without_missing_values(values, number_of_molecules, number_of_samples, sample_indices, sample_indices_length, molecule_indices, &molecule_indices_length);

        if (molecule_indices_length <= dimension) {
                for (long h = 0; h < molecule_indices_length; h++) {
                        for (long j = 0; j < sample_indices_length; j++) {
                                double value = values[molecule_indices[h] * number_of_samples + sample_indices[j]];
                                sammon_points[h * sample_indices_length + j] = value;
                        }
                }

                for (long h = molecule_indices_length; h < dimension; h++) {
                        for (long j = 0; j < sample_indices_length; j++) {
                                sammon_points[h * sample_indices_length + j] = 0.0;
                        }
                }

                return molecule_indices_length;
        }

        double variances[molecule_indices_length];
        for (long i = 0; i < molecule_indices_length; i++) {
                double sum = 0.0;
                double sum_of_squares = 0.0;
                for (long j = 0; j < sample_indices_length; j++) {
                        double value = values[molecule_indices[i] * number_of_samples + sample_indices[j]];
                        sum += value;
                        sum_of_squares += value * value;
                }
                variances[i] = sample_indices_length < 2 ? 0.0 : (sum_of_squares - sum * sum / sample_indices_length) / (sample_indices_length - 1);
        }

        
        



        return molecule_indices_length;
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

