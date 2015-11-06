#include "c-functions.h"

void som(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* sample_indices, const long sample_indices_length, const long number_of_rows, const long number_of_columns, long* row_for_sample_index, long *column_for_samples_index) {

        double* weights = malloc(number_of_rows * number_of_columns * sizeof(double));










        free(weights);
}
