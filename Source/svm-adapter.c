//
//  svm-adapter.c
//  Amberbio
//
//  Created by Morten Krogh on 14/10/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

#include <stdlib.h>
#include "svm-adapter.h"

struct svm_problem* svm_adapter_problem_create(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples)
{
        struct svm_problem *problem = malloc(sizeof(struct svm_problem));
        int l = (int)number_of_training_samples;
        problem->l = l;

        problem->y = malloc(l * sizeof(double));
        for (int i = 0; i < l; i++) {
                problem->y[i] = (double)training_labels[i];
        }

        problem->x = malloc(l * sizeof(struct svm_node*));
        for (int i = 0; i < l; i++) {
                long sample_index = training_sample_indices[i];
                problem->x[i] = malloc((molecule_indices_length + 1) * sizeof(struct svm_node));
                for (long j = 0; j < molecule_indices_length; j++) {
                        long molecule_index = molecule_indices[j];
                        long offset = molecule_index * number_of_samples + sample_index;
                        double value = values[offset];
                        problem->x[i][j].index = (int)j + 1;
                        problem->x[i][j].value = value;
                }
                problem->x[i][molecule_indices_length].index = -1;
                problem->x[i][molecule_indices_length].value = 0;
        }

        return problem;
}

void svm_adapter_problem_free(struct svm_problem* problem)
{
        free(problem->y);
        for (int i = 0; i < problem->l; i++) {
                free(problem->x[i]);
        }
        free(problem->x);
        free(problem);
}

void svm_adapter_train_test_linear(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples, const long* test_sample_indices, const long number_of_test_samples, double C, long* test_labels)
{
        struct svm_problem* problem = svm_adapter_problem_create(values, molecule_indices, molecule_indices_length, number_of_samples, training_sample_indices, training_labels, number_of_training_samples);

        struct svm_parameter parameter;

        parameter.svm_type = C_SVC;
        parameter.kernel_type = LINEAR;
        parameter.cache_size = 10;
        parameter.eps = 0.001;
        parameter.C = C;
        parameter.nr_weight = 0;

        const char* error_msg = svm_check_parameter(problem, &parameter);

        if (error_msg != NULL) {
                printf("%s\n", error_msg);
        }

//        struct svm_model *svm_train(const struct svm_problem *prob, const struct svm_parameter *param);

        svm_adapter_problem_free(problem);
}



