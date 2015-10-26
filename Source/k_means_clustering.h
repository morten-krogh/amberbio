#ifndef k_means_clustering_h
#define k_means_clustering_h

#include <stdio.h>

void k_means_clustering(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long k, const long max_iterations, long* cluster_for_sample, double* distance_square);

#endif /* k_means_clustering_h */
