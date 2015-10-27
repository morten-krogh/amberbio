#include "c-functions.h"

void calculate_missing_values_and_std_devs(const double* values, const long number_of_molecules, const long number_of_samples, long* missing_values_per_molecule, double* std_dev_per_molecule)
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
