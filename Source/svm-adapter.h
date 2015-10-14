//
//  svm-adapter.h
//  Amberbio
//
//  Created by Morten Krogh on 14/10/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

#ifndef svm_adapter_h
#define svm_adapter_h

#include <stdio.h>

#include "svm.h"

void svm_adapter_train_test(const double* values, const long* molecule_indices, const long molecule_indices_length, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples, const long* test_sample_indices, const long number_of_test_samples, long* test_labels, double* test_decision_values, long kernel, double linear_C, double rbf_C, double rbf_gamma);


#endif /* svm_adapter_h */
