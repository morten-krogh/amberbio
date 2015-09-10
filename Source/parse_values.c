#include "parse_values.h"
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <math.h>

void c_parse_number_of_lines_and_longest_row_length(const char* data, long data_length, long* number_of_lines, long* max_row_length)
{
        long current_max_row_length = 0;
        long current_number_of_lines = 0;
        long previous_newline = -1;

        for (long i = 0; i < data_length; i++) {
                if (data[i] == '\n') {
                        long row_length = i - previous_newline - 1;
                        if (row_length > current_max_row_length) {
                                current_max_row_length = row_length;
                        }
                        current_number_of_lines++;
                        previous_newline = i;
                }
        }

        if (data_length > 0 && data[data_length - 1] != '\n') {
                long row_length = data_length - previous_newline - 1;
                if (row_length > current_max_row_length) {
                        current_max_row_length = row_length;
                }
                current_number_of_lines++;
        }

        *number_of_lines = current_number_of_lines;
        *max_row_length = current_max_row_length;
}

void c_parse_newlines(const char* data, long data_length, long* newlines)
{
        long newline_counter = 0;

        for (long i = 0; i < data_length; i++) {
                if (data[i] == '\n') {
                        newlines[newline_counter] = i;
                        newline_counter++;
                }
        }

        if (data_length > 0 && data[data_length - 1] != '\n') {
                newlines[newline_counter] = data_length;
        }
}

long c_parse_number_of_tokens(const char* data, long start, long end)
{
        long number_of_tokens = 1;
        for (long i = start; i < end; i++) {
                if (data[i] == '\t') {
                        number_of_tokens++;
                }
        }
        return number_of_tokens;
}

long c_parse_number_of_empty_rows_at_top(const char* data, long data_length)
{
        long number_of_empty_rows = 0;
        for (long i = 0; i < data_length; i++) {
                switch (data[i]) {
                        case '\n':
                                number_of_empty_rows++;
                                break;
                        case ' ':
                        case '\t':
                        case '\r':
                                break;
                        default:
                                return number_of_empty_rows;
                                break;
                }
        }
        return number_of_empty_rows;
}

long c_parse_number_of_empty_rows_at_bottom(const char* data, long data_length)
{
        long number_of_empty_rows = 0;
        for (long i = data_length - 2; i >= 0; i--) {
                switch (data[i]) {
                        case '\n':
                                number_of_empty_rows++;
                                break;
                        case ' ':
                        case '\t':
                        case '\r':
                                break;
                        default:
                                return number_of_empty_rows;
                                break;
                }
        }
        return number_of_empty_rows;
}

void c_parse_next_token(const char* data, long start, long end, char* token, long* token_length)
{
        long counter = 0;
        for (long i = start; i < end; i++) {
                char ch = data[i];
                if (ch == '\t' || ch == '\n' || ch == '\r') {
                        break;
                } else {
                        token[counter] = ch;
                        counter++;
                }
        }

        *token_length = counter;
}

long c_parse_doubles(const char* data, long start, long end, long skip, double* values, long value_start)
{
        char number_string[50];
        long number_of_doubles = 0;
        long token_counter = 0;
        long token_start = start;
        for (long i = start; i < end; i++) {
                char ch = data[i];
                if (i == end - 1 || ch == '\t' || ch == '\r' || ch == '\n') {
                        long index_after = i == end - 1 ? i + 1 : i;
                        if (token_counter > skip - 1) {
                                if (index_after - token_start < 50) {
                                        for (long j = 0; j < index_after - token_start; j++) {
                                                number_string[j] = data[token_start + j];
                                        }
                                        number_string[index_after - token_start] = '\0';

                                        char* endptr;
                                        double value = strtof(number_string, &endptr);
                                        if (*endptr != '\0' && *endptr != ' ') {
                                                value = nan(NULL);
                                        }

                                        values[value_start + token_counter - skip] = value;
                                        if (!isnan(value)) {
                                                number_of_doubles++;
                                        }
                                }
                        }
                        token_counter++;
                        token_start = i + 1;
                }
        }
        return number_of_doubles;
}
