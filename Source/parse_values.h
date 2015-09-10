//
//  parse_values.h
//  Bioinformatics
//
//  Created by Morten Krogh on 16/06/15.
//  Copyright © 2015 Amber Biosicences. All rights reserved.
//

#ifndef parse_values_c
#define parse_values_c

#include <stdio.h>

void c_parse_number_of_lines_and_longest_row_length(const char* data, long data_length, long* number_of_lines, long* max_row_length);
void c_parse_newlines(const char* data, long data_length, long* newlines);
long c_parse_number_of_tokens(const char* data, long start, long end);
void c_parse_next_token(const char* data, long start, long end, char* token, long* token_length);
long c_parse_number_of_empty_rows_at_top(const char* data, long data_length);
long c_parse_number_of_empty_rows_at_bottom(const char* data, long data_length);
long c_parse_doubles(const char* data, long start, long end, long skip, double* values, long value_start);

#endif /* parse_values_c */
