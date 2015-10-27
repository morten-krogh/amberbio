#ifndef c_functions_h

#include <stdlib.h>
#include <float.h>
#include <stdio.h>
#include <math.h>
#include <stdbool.h>

#include "svm.h"

double distribution_beta(double a, double b);
double distribution_incomplete_beta_continued_fraction(double a, double b, double x);
double distribution_incomplete_beta(double a, double b, double x);
double distribution_f_upper_tail(long degrees_of_freedom_upper, long degrees_of_freedom_lower, double quantile);
double distribution_t_upper_tail(long degrees_of_freedom, double quantile);


void k_means_clustering(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long k, const long max_iterations, long* cluster_for_sample, double* distance_square);



void knn_molecules_without_missing_values(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_indices, const long sample_indices_length, long* molecule_indices, long* molecule_indices_length);

bool knn_classify_training_test(const double* values, const long number_of_molecules, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples, const long* test_sample_indices, const long number_of_test_samples, long k, long* test_labels);



void linear_regression(const double* x_values, const double* y_values, const long number_of_values, double* intercept, double* slope, double* p_value);

void svm_adapter_train_test(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples, const long* test_sample_indices, const long number_of_test_samples, long* test_labels, double* test_decision_values, long kernel, double linear_C, double rbf_C, double rbf_gamma);


void calculate_molecule_centered_values(const double* values, const long number_of_molecules, const long number_of_samples, double* values_corrected);
void calculate_molecules_without_missing_values(const double* values, const long number_of_molecules, const long number_of_samples, const long* selected_sample_indices, const long number_of_selected_samples, long* number_of_present_molecules, long* is_present_molecule);
void calculate_factor_elimination(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_level, const long number_of_levels, double* values_eliminated);


void calculate_missing_values_and_std_devs(const double* values, const long number_of_molecules, const long number_of_samples, long* missing_values_per_molecule, double* std_dev_per_molecule);


void random_fisher_yates_shuffle(long* values, const long values_length);

#define c_functions_h


#endif /* c_functions_h */
