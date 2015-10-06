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

long knn_majority_label(const double* distances, const long* labels, const long number_of_samples, const long k, const long majority) {

        long* short_list = malloc(k * sizeof(long));
        long max_index = 0;
        for (long i = 0; i < k; i++) {
                short_list[i] = i;
                if (distances[i] > distances[max_index]) {
                        max_index = i;
                }
        }

        for (long i = k; i < number_of_samples; i++) {


                
        }





        free(short_list);

        return -1;
}
