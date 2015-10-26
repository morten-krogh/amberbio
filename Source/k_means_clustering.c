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
        long empty_cluster = -1;

        do {
                for (long q = 0; q < number_of_samples; q++) {
//                        printf("hej123 %li\n", cluster_for_sample[q]);
                }

                for (long i = 0; i < k; i++) {
                        size_of_cluster[i] = 0;
                }
                for (long i = 0; i < number_of_samples; i++) {
                        size_of_cluster[cluster_for_sample[i]]++;
                }

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

void k_means_clustering_find_centroids(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* cluster_for_sample, const long k, double* centroids)
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
//                                printf("centroid: %li %f\n", i, centroids[h * k + i]);
                                centroids[h * k + i] /= size_of_cluster;
//                                printf("centroid: %li %f\n", i, centroids[h * k + i]);
                        }
                }
//                printf("size %li, %li\n", i, size_of_cluster);
        }
}

void k_means_clustering_assign_clusters(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const double* centroids, const long k, long* cluster_for_sample, double* distance_square_for_sample)
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
//                        printf("hej5 %li, %li, %f\n", i, j, dist_sq);
                }
        }
}

void k_means_clustering(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long k, const long max_iterations, long* cluster_for_sample, double* distance_square)
{
        long cluster_for_sample_1[number_of_samples], cluster_for_sample_2[number_of_samples];
        double centroids[molecule_indices_length * k];
        double distance_square_for_sample[number_of_samples];

        k_means_clustering_initialize_clusters(cluster_for_sample_1, number_of_samples, k);
        for (long i = 0; i < number_of_samples; i++) {
//                printf("initial %li\n", cluster_for_sample_1[i]);
        }

        for (long iter = 0; iter < max_iterations; iter++) {
                k_means_clustering_resolve_empty_clusters(cluster_for_sample_1, number_of_samples, k);
                for (long i = 0; i < number_of_samples; i++) {
//                        printf("cluster_sample_1 %li %li\n", i, cluster_for_sample_1[i]);
                }

                k_means_clustering_find_centroids(values, molecule_indices, molecule_indices_length, number_of_samples, cluster_for_sample_1, k, centroids);
                for (long w = 0; w < k * molecule_indices_length; w++) {
//                        printf("centroid, %li %f\n", w, centroids[w]);
                }

                k_means_clustering_assign_clusters(values, molecule_indices, molecule_indices_length, number_of_samples, centroids, k, cluster_for_sample_2, distance_square_for_sample);

                for (long i = 0; i < number_of_samples; i++) {
//                        printf("hej4 %li\n", cluster_for_sample_2[i]);
                }


                long equal_clusterings = 1;
                for (long i = 0; i < number_of_samples; i++) {
                        if (cluster_for_sample_1[i] != cluster_for_sample_2[i]) {
                                equal_clusterings = 0;
                                cluster_for_sample_1[i] = cluster_for_sample_2[i];
                        }
                }
//                printf("equal clusterings %li\n", equal_clusterings);
                if (equal_clusterings) {
                        printf("iter %li\n", iter);
                        break;
                }
        }

        *distance_square = 0;
        for (long i = 0; i < number_of_samples; i++) {
                double dsq = distance_square_for_sample[i];
                *distance_square += dsq * dsq;
                cluster_for_sample[i] = cluster_for_sample_1[i];
        }
}
