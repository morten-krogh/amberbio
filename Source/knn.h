//
//  knn.h
//  Amberbio
//
//  Created by Morten Krogh on 06/10/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

#ifndef knn_h
#define knn_h

#include <stdio.h>
#include <stdbool.h>

bool knn_classify_training_test(const double* values, const long number_of_molecules, const long number_of_samples, const long* training_sample_indices, const long* training_labels, const long number_of_training_samples, const long* test_sample_indices, const long number_of_test_samples, long k, long* test_labels);


#endif /* knn_h */
