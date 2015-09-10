//
//  distributions.h
//  Bioinformatics
//
//  Created by Morten Krogh on 12/08/15.
//  Copyright © 2015 Amber Biosicences. All rights reserved.
//

#ifndef distributions_h
#define distributions_h

#include <stdio.h>
#include <math.h>

double beta(double a, double b);
double incomplete_beta_continued_fraction(double a, double b, double x);
double incomplete_beta(double a, double b, double x);
double f_distribution_upper_tail(long degrees_of_freedom_upper, long degrees_of_freedom_lower, double quantile);
double t_distribution_upper_tail(long degrees_of_freedom, double quantile);

#endif /* distributions_h */
