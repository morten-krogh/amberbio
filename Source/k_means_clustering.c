#include "k_means_clustering.h"
#include <stdlib.h>
#include <float.h>

void k_means_clustering_initialize_clusters(long* cluster_for_sample, const long number_of_samples, const long k)
{
        u_int32_t k32 = (u_int32_t) k;
        for (long i = 0; i < number_of_samples; i++) {
                long j = arc4random_uniform(k32);
                cluster_for_sample[i] = j;
        }
}

void k_means_clustering_resolve_empty_clusters(long* cluster_for_sample, const long number_of_samples, const long k)
{
        long size_of_cluster[k];
        for (long i = 0; i < k; i++) {
                size_of_cluster[i] = 0;
        }

        for (long i = 0; i < number_of_samples; i++) {
                size_of_cluster[cluster_for_sample[i]]++;
        }

        long empty_cluster = -1;
        do {
                empty_cluster = -1;
                long largest_cluster = 0;
                for (long i = 0; i < k; i++) {
                        if (size_of_cluster[i] == 0) {
                                empty_cluster = i;
                        }
                        if (size_of_cluster[i] > size_of_cluster[largest_cluster]) {
                                largest_cluster = i;
                        }
                }
                if (empty_cluster != -1) {
                        for (long i = 0; i < number_of_samples; i++) {
                                if (cluster_for_sample[i] == largest_cluster) {
                                        cluster_for_sample[i] = empty_cluster;
                                        break;
                                }
                        }
                }
        } while (empty_cluster != -1);
}

void k_mean_clustering_find_centroids(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* cluster_for_sample, const long k, double* centroids)
{
        for (long i = 0; i < molecule_indices_length * k; i++) {
                centroids[i] = 0;
        }

        for (long i = 0; i < k; i++) {
                long size_of_cluster = 0;
                for (long j = 0; j < number_of_samples; j++) {
                        if (cluster_for_sample[j] == i) {
                                size_of_cluster++;
                                for (long h = 0; h < molecule_indices_length; h++) {
                                        double value = values[molecule_indices[h] * number_of_samples + j];
                                        centroids[h * k + i] += value;
                                }
                        }
                }
                if (size_of_cluster > 0) {
                        for (long h = 0; h < molecule_indices_length; h++) {
                                centroids[i * number_of_samples + h] /= size_of_cluster;
                        }
                }
        }
}

void k_mean_clustering_assign_clusters(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const double* centroids, const long k, long* cluster_for_sample, double* distance_square_for_sample)
{
        for (long i = 0; i < number_of_samples; i++) {
                distance_square_for_sample[i] = DBL_MAX;
                for (long j = 0; j < k; j++) {
                        double dist_sq = 0;
                        for (long h = 0; h < molecule_indices_length; h++) {
                                double value = values[molecule_indices[h] * number_of_samples + i];
                                double centroid_value = centroids[h * k + j];
                                double diff = value - centroid_value;
                                dist_sq += diff * diff;
                        }
                        if (dist_sq < distance_square_for_sample[i]) {
                                cluster_for_sample[i] = j;
                                distance_square_for_sample[i] = dist_sq;
                        }
                }
        }
}




