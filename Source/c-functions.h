#ifndef c_functions_h
#define c_functions_h

#include <stdlib.h>
#include <float.h>
#include <stdio.h>
#include <math.h>
#include <stdbool.h>

#include "svm.h"

double parse_double(const char* str, const long str_len);
char parse_find_separator(const void* data, const long data_length);
void parse_number_of_rows_and_columns(const void* bytes, const long length, const char separator, long* number_of_rows, long* number_of_columns);
void parse_separator_positions(const void* bytes, const long length, const char separator, const long number_of_rows, const long number_of_columns, long* separator_positions);
double parse_parse_double(char* cstring);
void parse_read_cstring(const void* bytes, const long position_0, const long position_1, char* cstring);
void parse_read_double_values(const void* bytes, const long number_of_rows, const long number_of_columns, const long* separator_positions, long row_0, long row_1, long col_0, long col_1, long row_major, double* values);



double distribution_beta(double a, double b);
double distribution_incomplete_beta_continued_fraction(double a, double b, double x);
double distribution_incomplete_beta(double a, double b, double x);
double distribution_f_upper_tail(long degrees_of_freedom_upper, long degrees_of_freedom_lower, double quantile);
double distribution_t_upper_tail(long degrees_of_freedom, double quantile);


void k_means_clustering(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long k, const long max_iterations, long* cluster_for_sample, double* distance_square);

bool knn_classify_training_test(const double* values, const long number_of_molecules, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples, const long* test_sample_indices, const long number_of_test_samples, long k, long* test_labels);

void linear_regression(const double* x_values, const double* y_values, const long number_of_values, double* intercept, double* slope, double* p_value);

void svm_adapter_train_test(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples, const long* test_sample_indices, const long number_of_test_samples, long* test_labels, double* test_decision_values, long kernel, double linear_C, double rbf_C, double rbf_gamma);

void values_molecules_without_missing_values(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_indices, const long sample_indices_length, long* molecule_indices, long* molecule_indices_length);
void values_calculate_molecule_centered_values(const double* values, const long number_of_molecules, const long number_of_samples, double* values_corrected);
void values_calculate_molecules_without_missing_values(const double* values, const long number_of_molecules, const long number_of_samples, const long* selected_sample_indices,const long number_of_selected_samples, long* number_of_present_molecules, long* is_present_molecule);
void values_calculate_factor_elimination(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_level, const long number_of_levels, double* values_eliminated);
void values_calculate_missing_values_and_std_devs(const double* values, const long number_of_molecules, const long number_of_samples, long* missing_values_per_molecule, double* std_dev_per_molecule);
void values_distances_euclidean(const double* values, const long number_of_samples, const long* molecule_indeces, const long molecule_indices_length, const long* sample_indeces, const long sample_indices_length, double* distances);
void values_indices_of_k_largest(double* values, const long values_length, const long k, long* indices);

void random_fisher_yates_shuffle(long* values, const long values_length);

long sammon_map(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_indices, const long sample_indices_length, const long dimension, double* sammon_points);

void som(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* sample_indices, const long sample_indices_length, const long number_of_rows, const long number_of_columns, long* row_for_sample_number, long *column_for_sample_number, double* border_top_right, double* border_right, double* border_bottom_right, double* border_bottom_left, double* border_left, double* border_top_left);

char* gunzip(const char* input, const int input_size, int* output_size);



#endif /* c_functions_h */
