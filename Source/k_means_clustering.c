#include "k_means_clustering.h"
#include <stdlib.h>

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

void k_mean_clustering_find_centroids(const double* values, const long* row_indices, const long row_indices_length, const long* col_indices, const long col_indices_length, const long* cluster_for_sample, const long k, double* centroids)
{
        



}
