#include "c-functions.h"

struct som_state {
        const double* values;
        const long* molecule_indices;
        const long molecule_indices_length;
        const long number_of_samples;
        const long* sample_indices;
        const long sample_indices_length;
        const long number_of_rows;
        const long number_of_columns;
        long* row_for_sample_number;
        long *column_for_sample_number;
        double* weights;
};

void som_initialize_weights(struct som_state som_state)
{
        double vec1[som_state.molecule_indices_length], vec2[som_state.molecule_indices_length];
        for (long i = 0; i < som_state.molecule_indices_length; i++) {
                vec1[i] = 0;
                vec2[i] = 0;
        }

        long n1 = som_state.sample_indices_length / 2;
        long n2 = som_state.sample_indices_length - n1;

        for (long i = 0; i < som_state.molecule_indices_length; i++) {
                for (long s = 0; s < som_state.sample_indices_length; s++) {
                        double value = som_state.values[som_state.molecule_indices[i] * som_state.number_of_samples + som_state.sample_indices[s]];
                        if (s < n1) {
                                vec1[i] += value;
                        } else {
                                vec2[i] += value;
                        }
                }
                if (n1 > 0) {
                        vec1[i] /= n1;
                }
                if (n2 > 0) {
                        vec2[i] /= n2;
                }
        }

        long number_of_units = som_state.number_of_rows * som_state.number_of_columns;
        for (long u = 0; u < number_of_units; u++) {
                double alpha = ((double) u) / ((double) number_of_units);
                long offset = u * som_state.molecule_indices_length;
                for (long i = 0; i < som_state.molecule_indices_length; i++) {
                        som_state.weights[offset + i] = alpha * vec1[i] + (1 - alpha) * vec2[i];
                }
        }
}

long som_closest_unit(struct som_state som_state, long sample_number)
{
        long closest_unit = 0;
        double min_dist_square = INFINITY;
        for (long u = 0; u < som_state.number_of_rows * som_state.number_of_columns; u++) {
                double dist_square = 0.0;
                long offset = u * som_state.molecule_indices_length;
                for (long i = 0; i < som_state.molecule_indices_length; i++) {
                        double value = som_state.values[som_state.molecule_indices[i] * som_state.number_of_samples + som_state.sample_indices[sample_number]];
                        double diff = som_state.weights[offset + i] - value;
                        dist_square += diff * diff;
                }
                if (dist_square < min_dist_square) {
                        closest_unit = u;
                        min_dist_square = dist_square;
                }
        }
        return closest_unit;
}

void som_assign_row_and_column(struct som_state som_state)
{
        for (long s = 0; s < som_state.sample_indices_length; s++) {
                long u = som_closest_unit(som_state, s);
                long row = u / som_state.number_of_rows;
                long column = u % som_state.number_of_rows;
                som_state.row_for_sample_number[s] = row;
                som_state.column_for_sample_number[s] = column;
        }
}

void som(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* sample_indices, const long sample_indices_length, const long number_of_rows, const long number_of_columns, long* row_for_sample_number, long *column_for_sample_number) {

        double* weights = malloc(number_of_rows * number_of_columns * molecule_indices_length * sizeof(double));

        struct som_state som_state = {values, molecule_indices, molecule_indices_length, number_of_samples, sample_indices, sample_indices_length, number_of_rows, number_of_columns, row_for_sample_number, column_for_sample_number, weights};

        som_initialize_weights(som_state);








        som_assign_row_and_column(som_state);

        free(weights);
}
