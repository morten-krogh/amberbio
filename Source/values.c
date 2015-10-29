#include "c-functions.h"

void values_molecules_without_missing_values(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_indices, const long sample_indices_length, long* molecule_indices, long* molecule_indices_length)
{
        long counter = 0;
        for (long i = 0; i < number_of_molecules; i++) {
                long offset = i * number_of_samples;
                long missing = 0;
                for (long j = 0; j < sample_indices_length; j++) {
                        double value = values[offset + sample_indices[j]];
                        if (isnan(value)) {
                                missing = 1;
                                break;
                        }
                }
                if (missing == 0) {
                        molecule_indices[counter] = i;
                        counter++;
                }
        }
        *molecule_indices_length = counter;
}

void values_calculate_missing_values_and_std_devs(const double* values, const long number_of_molecules, const long number_of_samples, long* missing_values_per_molecule, double* std_dev_per_molecule)
{
        for (long i = 0; i < number_of_molecules; i++) {
                long offset = i * number_of_samples;
                long number_of_present_values = 0;
                double sum = 0;
                double sum_of_squares = 0;
                for (long j = 0; j < number_of_samples; j++) {
                        double value = values[offset + j];
                        if (!isnan(value)) {
                                number_of_present_values++;
                                sum += value;
                                sum_of_squares += value * value;
                        }
                }
                missing_values_per_molecule[i] = number_of_samples - number_of_present_values;
                if (number_of_present_values >= 2) {
                        double variance = (sum_of_squares - sum * sum / number_of_present_values) / (number_of_present_values - 1);
                        if (variance < 0) {
                                std_dev_per_molecule[i] = 0;
                        } else {
                                std_dev_per_molecule[i] = sqrtf(variance);
                        }
                } else {
                        std_dev_per_molecule[i] = 0;
                }
        }
}

void values_calculate_molecule_centered_values(const double* values, const long number_of_molecules, const long number_of_samples, double* values_corrected)
{
        for (long i = 0; i < number_of_molecules; i++) {
                long offset = i * number_of_samples;
                long counter = 0;
                double sum = 0;
                for (long j = 0; j < number_of_samples; j++) {
                        double value = values[offset + j];
                        if (!isnan(value)) {
                                counter++;
                                sum += value;
                        }
                }
                double mean = counter == 0 ? nan(NULL) : sum / counter;
                for (long j = 0; j < number_of_samples; j++) {
                        values_corrected[offset + j] = values[offset + j] - mean;
                }
        }
}

void values_calculate_molecules_without_missing_values(const double* values, const long number_of_molecules, const long number_of_samples, const long* selected_sample_indices, const long number_of_selected_samples, long* number_of_present_molecules, long* is_present_molecule)
{
        *number_of_present_molecules = 0;
        for (long i = 0; i < number_of_molecules; i++) {
                long offset = i * number_of_samples;
                long present = 1;
                for (long j = 0; j < number_of_selected_samples; j++) {
                        double value = values[offset + selected_sample_indices[j]];
                        if (isnan(value)) {
                                present = 0;
                                break;
                        }
                }

                is_present_molecule[i] = present;
                if (present == 1) {
                        (*number_of_present_molecules)++;
                }
        }
}

void values_calculate_factor_elimination(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_level, const long number_of_levels, double* values_eliminated)
{
        long number_of_present_values[number_of_levels];
        double sum_of_present_values[number_of_levels];
        double corrections[number_of_levels];
        long total_number_of_present_values;
        double total_sum_of_present_values;

        for (long i = 0; i < number_of_molecules; i++) {
                long offset = i * number_of_samples;

                for (long j = 0; j < number_of_levels; j++) {
                        number_of_present_values[j] = 0;
                        sum_of_present_values[j] = 0;
                }

                total_number_of_present_values = 0;
                total_sum_of_present_values = 0;

                for (long j = 0; j < number_of_samples; j++) {
                        double value = values[offset + j];
                        if (!isnan(value)) {
                                long level = sample_level[j];
                                number_of_present_values[level]++;
                                sum_of_present_values[level] += value;

                                total_number_of_present_values++;
                                total_sum_of_present_values += value;
                        }
                }

                double total_mean = 0;
                if (total_number_of_present_values > 0) {
                        total_mean = total_sum_of_present_values / total_number_of_present_values;
                }

                for (long j = 0; j < number_of_levels; j++) {
                        if (number_of_present_values[j] != 0) {
                                double mean = sum_of_present_values[j] / number_of_present_values[j];
                                double correction = mean - total_mean;
                                corrections[j] = correction;
                        }
                }

                for (long j = 0; j < number_of_samples; j++) {
                        double value = values[offset + j];
                        if (!isnan(value)) {
                                long level = sample_level[j];
                                values_eliminated[offset + j] = value - corrections[level];
                        } else {
                                values_eliminated[offset + j] = nan(NULL);
                        }
                }
        }
}

void values_distances_euclidean(const double* values, const long number_of_samples, const long* molecule_indeces, const long molecule_indices_length, const long* sample_indeces, const long sample_indices_length, double* distances)
{
        long n = sample_indices_length;
        for (long i = 0; i < n - 1; i++) {
                for (long j = i + 1; j < n; j++) {
                        double distance_square = 0.0;
                        for (long h = 0; h < molecule_indices_length; h++) {
                                double value_i = values[molecule_indeces[h] * number_of_samples + sample_indeces[i]];
                                double value_j = values[molecule_indeces[h] * number_of_samples + sample_indeces[j]];
                                double diff = value_i - value_j;
                                distance_square += diff * diff;
                        }
                        distances[i * (2 * n - 1 - i) / 2 + j - i - 1] = sqrt(distance_square);
                }
        }
}

void values_indices_of_k_largest(double* values, const long values_length, const long k, long* indices)
{
        for (long i = 0; i < k; i++) {
                indices[i] = i;
        }

        if (k <= 0 || values_length <= k) return;

        long minimum_index = 0;
        double minimum_value = values[0];
        for (long i = 0; i < k; i++) {
                if (values[i] < minimum_value) {
                        minimum_index = i;
                        minimum_value = values[i];
                }
        }

        for (long j = k; j < values_length; j++) {
                if (values[j] > minimum_value) {
                        indices[minimum_index] = j;
                        minimum_index = 0;
                        minimum_value = values[indices[0]];
                        for (long i = 0; i < k; i++) {
                                if (values[indices[i]] < minimum_value) {
                                        minimum_index = i;
                                        minimum_value = values[indices[i]];
                                }
                        }
                }
        }

        for (long i = 0; i < k - 1; i++) {
                for (long j = i + 1; j < k; j++) {
                        if (values[indices[i]] < values[indices[j]]) {
                                long tmp = indices[i];
                                indices[i] = indices[j];
                                indices[j] = tmp;
                        }
                }
        }
}
