//
//  values.h
//  Bioinformatics
//
//  Created by Morten Krogh on 10/06/15.
//  Copyright (c) 2015 Amber Biosicences. All rights reserved.
//

#ifndef __Bioinformatics__values__
#define __Bioinformatics__values__

#include <stdio.h>
#include <math.h>

void calculate_molecule_centered_values(const double* values, const long number_of_molecules, const long number_of_samples, double* values_corrected);

void calculate_molecules_without_missing_values(const double* values, const long number_of_molecules, const long number_of_samples, const long* selected_sample_indices, const long number_of_selected_samples, long* number_of_present_molecules, long* is_present_molecule);

void calculate_factor_elimination(const double* values, const long number_of_molecules, const long number_of_samples, const long* sample_level, const long number_of_levels, double* values_eliminated);


#endif /* defined(__Bioinformatics__values__) */
