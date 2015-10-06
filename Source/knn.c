#include "knn.h"
#include <stdlib.h>
#include <math.h>

void knn_molecules_without_missing_values(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_indices, const long sample_indices_length, long* molecule_indices, long* molecule_indices_length)
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

double knn_distance_square(const double* values, const long number_of_samples, const long* molecule_indices, const long molecule_indices_length, const long sample_index_1, const long sample_index_2)
{
        double distance_square = 0;
        for (long i = 0; i < molecule_indices_length; i++) {
                long offset = molecule_indices[i] * number_of_samples;
                double value_1 = values[offset + sample_index_1];
                double value_2 = values[offset + sample_index_2];
                double diff = value_2 - value_1;
                distance_square += diff * diff;
        }
        return distance_square;
}

int knn_cmp_label(const void* a, const void* b)
{
                return (int)(*(long*)a - *(long*)b);
}

long knn_majority_label(const double* distances, const long* labels, const long number_of_samples, const long k, const long majority) {

        long short_list[k];
        long max_index = 0;
        for (long i = 0; i < k; i++) {
                short_list[i] = i;
                if (distances[i] > distances[max_index]) {
                        max_index = i;
                }
        }

        for (long i = k; i < number_of_samples; i++) {
                if (distances[i] < distances[max_index]) {
                        short_list[max_index] = i;
                }
                max_index = i;
                for (long j = 0; j < k; j++) {
                        if (distances[j] > distances[max_index]) {
                                max_index = j;
                        }
                }
        }

        if (k == 1) {
                return labels[short_list[0]];
        }

        long short_list_of_labels[k];
        for (long i = 0; i < k; i++) {
                short_list_of_labels[i] = labels[short_list[i]];
        }

        qsort(short_list_of_labels, k, sizeof(long), knn_cmp_label);

        long label = short_list_of_labels[0];
        long counter = 1;
        for (long i = 1; i < k; i++) {
                if (short_list_of_labels[i] == label) {
                        counter++;
                        if (counter >= majority) {
                                return label;
                        }
                } else {
                        label = short_list_of_labels[i];
                        counter = 1;
                }
        }

        return -1;
}

long knn_classify_training_test(const double* values, const long number_of_molecules, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples, const long* test_sample_indices, const long number_of_test_samples, long k, long* test_labels)
{
        long majority = k % 2 == 0 ? k /2 + 1 : (k + 1) / 2;

        long sample_indices[number_of_training_samples + number_of_test_samples];

        for (long i = 0; i < number_of_training_samples; i++) {
                sample_indices[i] = training_sample_indices[i];
        }
        for (long i = 0; i < number_of_test_samples; i++) {
                sample_indices[number_of_training_samples + i] = test_sample_indices[i];
        }

        long molecule_indices[number_of_molecules];
        long molecule_indices_length = 0;

        knn_molecules_without_missing_values(values, number_of_molecules, number_of_samples, sample_indices, number_of_training_samples + number_of_test_samples, molecule_indices, &molecule_indices_length);

        if (molecule_indices_length == 0) {
                return -1;
        }

        for (long i = 0; i < number_of_test_samples; i++) {
                double distances[number_of_training_samples];
                for (long j = 0; j < number_of_training_samples; j++) {
                        distances[j] = knn_distance_square(values, number_of_samples, molecule_indices, molecule_indices_length, training_sample_indices[j], test_sample_indices[i]);
                }
                test_labels[i] = knn_majority_label(distances, training_labels, number_of_training_samples, k, majority);
        }

        return 0;
}
