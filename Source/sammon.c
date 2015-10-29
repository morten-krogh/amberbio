#include "c-functions.h"

void sammon_iteration(const double* distances, const long dimension, const long sample_indices_length, const double lambda, double* sammon_points)
{
        // delta_r_i = lambda * (d_ij - ||r_i - r_j||) * normalized(r_i - r_j)

        long n = sample_indices_length;
        for (long i = 0; i < n - 1; i++) {
                for (long j = i + 1; j < n; j++) {
                        double d_ij = distances[i * (2 * n - 1 - i) / 2 + j - i - 1];
                        double r_ij[dimension];
                        double norm_square = 0.0;
                        for (long d = 0; d < dimension; d++) {
                                double diff = sammon_points[d * n + i] - sammon_points[d * n + j];
                                r_ij[d] = diff;
                                norm_square += diff * diff;
                        }
                        double norm = sqrt(norm_square);
                        if (norm == 0) continue;
                        double multiplier = lambda * (d_ij - norm);
                        for (long d = 0; d < dimension; d++) {
                                double delta = multiplier * r_ij[d] / norm;
                                sammon_points[d * n + i] += delta;
                                sammon_points[d * n + j] -= delta;
                        }
                }
        }
}

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

        long indices_of_largest_variances[dimension];
        values_indices_of_k_largest(variances, molecule_indices_length, dimension, indices_of_largest_variances);

        for (long d = 0; d < dimension; d++) {
                for (long j = 0; j < sample_indices_length; j++) {
                        double value = values[molecule_indices[indices_of_largest_variances[d]] * number_of_samples + sample_indices[j]];
                        sammon_points[d * sample_indices_length + j] = value;
                }
        }

        double distances[sample_indices_length * (sample_indices_length - 1) / 2];
        values_distances_euclidean(values, number_of_samples, molecule_indices, molecule_indices_length, sample_indices, sample_indices_length, distances);

        double lambda_initial = 0.4;
        double lambda_last = 0.0001;
        double number_of_iterations = 10000;
        double lambda_damper = exp(log(lambda_last / lambda_initial) / number_of_iterations);
        double lambda = lambda_initial;

        printf("%f\n", lambda_damper);

        for (long iter = 0; iter < number_of_iterations; iter++) {
                sammon_iteration(distances, dimension, sample_indices_length, lambda, sammon_points);
                lambda *= lambda_damper;
        }

        values_calculate_molecule_centered_values(sammon_points, dimension, sample_indices_length, sammon_points);

        return molecule_indices_length;
}
