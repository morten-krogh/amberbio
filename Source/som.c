#include "c-functions.h"

/*
        Learning rate = learning_rate_inital * exp(- iteration / number_of_iterations)
        learning_rate_initial = 0.5
        Decay function = exp(- dist^2 / 2 sigma(iteration)^2)
        sigma(iteration) = sigma_initial * exp(- iteration / number_of_iterations)
        sigma_initial = max(number_of_rows, number_of_columns)
*/

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
        const long number_of_iterations;
        long iteration;
        double* border_top_right;
        double* border_right;
        double* border_bottom_right;
        double* border_bottom_left;
        double* border_left;
        double* border_top_left;
};

void som_initialize_weights(struct som_state* som_state)
{
        double vec1[som_state->molecule_indices_length], vec2[som_state->molecule_indices_length];
        for (long i = 0; i < som_state->molecule_indices_length; i++) {
                vec1[i] = 0;
                vec2[i] = 0;
        }

        long n1 = som_state->sample_indices_length / 2;
        long n2 = som_state->sample_indices_length - n1;

        for (long i = 0; i < som_state->molecule_indices_length; i++) {
                for (long s = 0; s < som_state->sample_indices_length; s++) {
                        double value = som_state->values[som_state->molecule_indices[i] * som_state->number_of_samples + som_state->sample_indices[s]];
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

        long number_of_units = som_state->number_of_rows * som_state->number_of_columns;
        for (long u = 0; u < number_of_units; u++) {
                double alpha = ((double) u) / ((double) number_of_units);
                long offset = u * som_state->molecule_indices_length;
                for (long i = 0; i < som_state->molecule_indices_length; i++) {
                        som_state->weights[offset + i] = alpha * vec1[i] + (1 - alpha) * vec2[i];
                }
        }
}

long som_closest_unit(struct som_state* som_state, long sample_number)
{
        long closest_unit = 0;
        double min_dist_square = INFINITY;
        for (long u = 0; u < som_state->number_of_rows * som_state->number_of_columns; u++) {
                double dist_square = 0.0;
                long offset = u * som_state->molecule_indices_length;
                for (long i = 0; i < som_state->molecule_indices_length; i++) {
                        double value = som_state->values[som_state->molecule_indices[i] * som_state->number_of_samples + som_state->sample_indices[sample_number]];
                        double diff = som_state->weights[offset + i] - value;
                        dist_square += diff * diff;
                }
                if (dist_square < min_dist_square) {
                        closest_unit = u;
                        min_dist_square = dist_square;
                }
        }
        return closest_unit;
}

void som_assign_row_and_column(struct som_state* som_state)
{
        for (long s = 0; s < som_state->sample_indices_length; s++) {
                long u = som_closest_unit(som_state, s);
                long row = u / som_state->number_of_columns;
                long column = u % som_state->number_of_columns;
                som_state->row_for_sample_number[s] = row;
                som_state->column_for_sample_number[s] = column;
        }
}

static double sqrt_3_2 = 0.8660254037844386;

double som_unit_dist_square(long number_of_columns, long u_0, long u_1)
{
        long row_0 = u_0 / number_of_columns;
        long column_0 = u_0 % number_of_columns;
        long row_1 = u_1 / number_of_columns;
        long column_1 = u_1 % number_of_columns;
        double vertical_dist = 1.5 * (row_1 - row_0);
        double horizontal_dist = 0.0;
        if ((row_1 - row_0) % 2 == 0) {
                horizontal_dist = sqrt_3_2 * (column_1 - column_0);
        } else if (row_0 % 2 == 0) {
                horizontal_dist = sqrt_3_2 * (column_1 + 0.5 - column_0);
        } else {
                horizontal_dist = sqrt_3_2 * (column_0 + 0.5 - column_1);
        }

        return vertical_dist * vertical_dist + horizontal_dist * horizontal_dist;
}

void som_iteration(struct som_state* som_state, long sample_number)
{
        double damper = exp(- ((double) som_state->iteration) / ((double) som_state->number_of_iterations));
        double learning_rate = 0.5 * damper;
        double sigma = ((double) som_state->number_of_rows > som_state->number_of_columns ? som_state->number_of_rows : som_state->number_of_columns) * damper;

        long closest_unit = som_closest_unit(som_state, sample_number);
        for (long u = 0; u < som_state->number_of_rows * som_state->number_of_columns; u++) {
                double dist_square = som_unit_dist_square(som_state->number_of_columns, closest_unit, u);
                double decay = exp(- dist_square / (2 * sigma * sigma));
                double alpha = decay * learning_rate;
                if (alpha >= 1e-6) {
                        for (long i = 0; i < som_state->molecule_indices_length; i++) {
                                double value = som_state->values[som_state->molecule_indices[i] * som_state->number_of_samples + som_state->sample_indices[sample_number]];
                                long offset = u * som_state->molecule_indices_length + i;
                                som_state->weights[offset] = (1 - alpha) * som_state->weights[offset] + alpha * value;
                        }
                }
        }
}

double som_weight_distance(struct som_state* som_state, long u_0, long u_1)
{
        double dist_square = 0.0;
        for (long i = 0; i < som_state->molecule_indices_length; i++) {
                double value_0 = som_state->weights[u_0 * som_state->molecule_indices_length + i];
                double value_1 = som_state->weights[u_1 * som_state->molecule_indices_length + i];
                double diff = value_1 - value_0;
                dist_square += diff * diff;
        }
        return sqrt(dist_square);
}

void som_border_correct(double* value, const double max_dist)
{
        if (isnan(*value)) {
                *value = 1;
        } else {
                *value /= max_dist;
        }
}

void som_border_distances(struct som_state* som_state)
{
        const long number_of_rows = som_state->number_of_rows;
        const long number_of_columns = som_state->number_of_columns;

        double max_dist = 0.0;

        for (long u = 0; u < number_of_rows * number_of_columns; u++) {
                long row = u / number_of_columns;
                long column = u % number_of_columns;
                if (column == 0) {
                        som_state->border_left[u] = nan(NULL);
                }
                if (column == number_of_columns - 1) {
                        som_state->border_right[u] = nan(NULL);
                }
                if (row == 0 || (column == 0 && row % 2 == 0)) {
                        som_state->border_top_left[u] = nan(NULL);
                }
                if (row == 0 || (column == number_of_columns - 1 && row % 2 == 1)) {
                        som_state->border_top_right[u] = nan(NULL);
                }
                if (row == number_of_rows - 1 || (column == 0 && row % 2 == 0)) {
                        som_state->border_bottom_left[u] = nan(NULL);
                }
                if (row == number_of_rows - 1 || (column == number_of_columns - 1 && row % 2 == 1)) {
                        som_state->border_bottom_right[u] = nan(NULL);
                }

                if (column < number_of_columns - 1) {
                        long u_1 = u + 1;
                        double dist = som_weight_distance(som_state, u, u_1);
                        if (dist > max_dist) {
                                max_dist = dist;
                        }
                        som_state->border_right[u] = dist;
                        som_state->border_left[u_1] = dist;
                }

                if (row > 0 && (column > 0 || row % 2 == 1)) {
                        long u_1 = (row - 1) * number_of_columns + column - (row % 2 == 0 ? 1 : 0);
                        double dist = som_weight_distance(som_state, u, u_1);
                        if (dist > max_dist) {
                                max_dist = dist;
                        }
                        som_state->border_top_left[u] = dist;
                        som_state->border_bottom_right[u_1] = dist;
                }

                if (row < number_of_rows - 1 && (column > 0 || row % 2 == 1)) {
                        long u_1 = (row + 1) * number_of_columns + column - (row % 2 == 0 ? 1 : 0);
                        double dist = som_weight_distance(som_state, u, u_1);
                        if (dist > max_dist) {
                                max_dist = dist;
                        }
                        som_state->border_bottom_left[u] = dist;
                        som_state->border_top_right[u_1] = dist;
                }
        }

        if (max_dist > 0) {
                for (long u = 0; u < number_of_rows * number_of_columns; u++) {
                        som_border_correct(som_state->border_right + u, max_dist);
                        som_border_correct(som_state->border_left + u, max_dist);
                        som_border_correct(som_state->border_top_left + u, max_dist);
                        som_border_correct(som_state->border_top_right + u, max_dist);
                        som_border_correct(som_state->border_bottom_left + u, max_dist);
                        som_border_correct(som_state->border_bottom_right + u, max_dist);
                }
        }
}

void som(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* sample_indices, const long sample_indices_length, const long number_of_rows, const long number_of_columns, long* row_for_sample_number, long *column_for_sample_number, double* border_top_right, double* border_right, double* border_bottom_right, double* border_bottom_left, double* border_left, double* border_top_left)
{

        double* weights = malloc(number_of_rows * number_of_columns * molecule_indices_length * sizeof(double));

        long number_of_iterations = sample_indices_length < 50 ? 10 * sample_indices_length : 500;

        struct som_state som_state = {values, molecule_indices, molecule_indices_length, number_of_samples, sample_indices, sample_indices_length, number_of_rows, number_of_columns, row_for_sample_number, column_for_sample_number, weights, number_of_iterations, 0, border_top_right, border_right, border_bottom_right, border_bottom_left, border_left, border_top_left};

        som_initialize_weights(&som_state);

        srand(1970);

        while (som_state.iteration < som_state.number_of_iterations) {
                long sample_number = rand() % sample_indices_length;
                som_iteration(&som_state, sample_number);
                som_state.iteration++;
//                printf("iteration = %li\n", som_state.iteration);
        }

        som_assign_row_and_column(&som_state);
        som_border_distances(&som_state);

        free(weights);
}
