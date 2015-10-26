//
//  svm-adapter.c
//  Amberbio
//
//  Created by Morten Krogh on 14/10/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

#include <stdlib.h>
#include "svm-adapter.h"

struct svm_node* svm_adapter_nodes_create(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long sample_index)
{
        struct svm_node* nodes = malloc((molecule_indices_length + 1) * sizeof(struct svm_node));
        for (long j = 0; j < molecule_indices_length; j++) {
                long molecule_index = molecule_indices[j];
                long offset = molecule_index * number_of_samples + sample_index;
                double value = values[offset];
                nodes[j].index = (int)j + 1;
                nodes[j].value = value;
        }
        nodes[molecule_indices_length].index = -1;
        nodes[molecule_indices_length].value = 0;

        return nodes;
}

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
                problem->x[i] = svm_adapter_nodes_create(values, molecule_indices, molecule_indices_length, number_of_samples, sample_index);
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

void svm_adapter_train_test(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples, const long* test_sample_indices, const long number_of_test_samples, long* test_labels, double* test_decision_values, long kernel, double linear_C, double rbf_C, double rbf_gamma)
{
        struct svm_problem* problem = svm_adapter_problem_create(values, molecule_indices, molecule_indices_length, number_of_samples, training_sample_indices, training_labels, number_of_training_samples);

        struct svm_parameter parameter;

        parameter.svm_type = C_SVC;
        if (kernel == 0) {
                parameter.kernel_type = LINEAR;
                parameter.C = linear_C;
                parameter.gamma = 1.0;
        } else {
                parameter.kernel_type = RBF;
                parameter.C = rbf_C;
                parameter.gamma = rbf_gamma;
        }
        parameter.degree = 0;
        parameter.coef0 = 1;
        parameter.cache_size = 10;
        parameter.eps = 0.001;
        parameter.nr_weight = 0;
        parameter.nu = 0;
        parameter.p = 0;
        parameter.shrinking = 0;
        parameter.probability = 0;

        const char* error_msg = svm_check_parameter(problem, &parameter);

        if (error_msg != NULL) {
                printf("%s\n", error_msg);
        }

        struct svm_model* model = svm_train(problem, &parameter);

        for (long i = 0; i < number_of_test_samples; i++) {
                struct svm_node* nodes = svm_adapter_nodes_create(values, molecule_indices, molecule_indices_length, number_of_samples, test_sample_indices[i]);
                double label = 0;
                double decision_value = 0;
                if (model->nr_class == 2) {
                        label = svm_predict_values(model, nodes, &decision_value);
                } else {
                        label = svm_predict(model, nodes);
                }
                test_labels[i] = (long)(label + 0.1);
                test_decision_values[i] = decision_value;
                free(nodes);
        }

        svm_free_and_destroy_model(&model);
        svm_adapter_problem_free(problem);

}


