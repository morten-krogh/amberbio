//
//  geo_soft_file_parser.h
//  Amberbio
//
//  Created by Morten Krogh on 13/11/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

#ifndef geo_soft_file_parser_h
#define geo_soft_file_parser_h

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

double parse_double(const char* str, const long str_len);


struct gds;

struct gds* gds_new(const void* bytes, const long length);

bool gds_valid(struct gds* gds);
char* gds_header(struct gds* gds);
long gds_number_of_samples(struct gds* gds);
char** gds_samples_names(struct gds* gds);
long gds_number_of_molecules(struct gds* gds);
double* gds_values(struct gds* gds);






#endif /* geo_soft_file_parser_h */
