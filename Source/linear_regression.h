//
//  linear_regression.h
//  Bioinformatics
//
//  Created by Morten Krogh on 01/09/15.
//  Copyright © 2015 Amber Biosicences. All rights reserved.
//

#ifndef linear_regression_h
#define linear_regression_h

#include <stdio.h>
#include <math.h>
#include "distributions.h"

void linear_regression(const double* x_values, const double* y_values, const long number_of_values, double* intercept, double* slope, double* p_value);

#endif /* linear_regression_h */
