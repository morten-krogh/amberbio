#ifndef __Bioinformatics__remove_molecules__
#define __Bioinformatics__remove_molecules__

#include <math.h>
#include <stdio.h>

void calculate_missing_values_and_std_devs(const double* values, const long number_of_molecules, const long number_of_samples, long* missing_values_per_molecule, double* std_dev_per_molecule);

#endif /* defined(__Bioinformatics__remove_molecules__) */
