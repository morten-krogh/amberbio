#include "c-functions.h"

void calculate_molecule_centered_values(const double* values, const long number_of_molecules, const long number_of_samples, double* values_corrected)
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

void calculate_molecules_without_missing_values(const double* values, const long number_of_molecules, const long number_of_samples, const long* selected_sample_indices, const long number_of_selected_samples, long* number_of_present_molecules, long* is_present_molecule)
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

void calculate_factor_elimination(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_level, const long number_of_levels, double* values_eliminated)
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
