#include "c-functions.h"

double parse_double(const char* str, const long str_len)
{
        char* endptr = NULL;
        double value = strtod(str, &endptr);
        return endptr == str + str_len ? value : nanf(NULL);
}

char parse_find_separator(const void* bytes, const long length)
{
        const char* string = (const char*) bytes;
        long comma_found = 0;
        for (long i = 0; i < length; i++) {
                if (string[i] == '\t') {
                        return '\t';
                } else if (string[i] == ',') {
                        comma_found = 1;
                }
        }
        return comma_found ? ',' : '\t';
}

void parse_number_of_rows_and_columns(const void* bytes, const long length, const char separator, long* number_of_rows, long* number_of_columns)
{
        if (length == 0) {
                *number_of_rows = 0;
                *number_of_columns = 0;
                return;
        }

        const char* string = (const char*) bytes;

        long current_row = 0;
        long current_column = 0;
        long max_ncols = 0;
        char previous_char = 0;
        for (long i = 0; i < length; i++) {
                if (string[i] == separator) {
                        current_column++;
                } else if (string[i] == '\r' || (string[i] == '\n' && previous_char != '\r')) {
                        if (current_column + 1 > max_ncols) {
                                max_ncols = current_column + 1;
                        }
                        current_row++;
                        current_column = 0;
                }
                previous_char = string[i];
        }

        *number_of_rows = current_row + (previous_char == '\r' || previous_char == '\n' ? 0 : 1);
        *number_of_columns = max_ncols;
}

void parse_separator_positions(const void* bytes, const long length, const char separator, const long number_of_rows, const long number_of_columns, long* separator_positions)
{
        if (length == 0) {
                return;
        }

        const char* string = (const char*) bytes;

        long current_row = 0;
        long current_column = 0;
        char previous_char = 0;
        for (long i = 0; i < length; i++) {
                if (string[i] == separator) {
                        separator_positions[current_row * number_of_columns + current_column] = i;
                        current_column++;
                } else if (string[i] == '\r' || (string[i] == '\n' && previous_char != '\r')) {
                        for (long j = current_column; j < number_of_columns; j++) {
                                separator_positions[current_row * number_of_columns + j] = i;
                        }
                        current_row++;
                        current_column = 0;
                }
                previous_char = string[i];
        }
        if (current_row == number_of_rows - 1) {
                for (long j = current_column; j < number_of_columns; j++) {
                        separator_positions[current_row * number_of_columns + j] = length;
                }
        }
}

void parse_read_cstring(const void* bytes, const long position_0, const long position_1, char* cstring)
{
        if (position_0 >= position_1) {
                cstring[0] = '\0';
                return;
        }
        const char* string = (const char*) bytes;
        long start_index = string[position_0] == '\n' ? position_0 + 1 : position_0;
        for (long i = start_index; i < position_1; i++) {
                cstring[i - start_index] = string[i];
        }
        cstring[position_1 - position_0] = '\0';
}

double parse_parse_double(char* cstring)
{
        for (char* cursor = cstring; *cursor != '\0'; cursor++) {
                if (*cursor == ',') {
                        *cursor = '.';
                }
        }

        char* endptr;

        double value = strtod(cstring, &endptr);

        if (endptr == cstring) {
                return nanf(NULL);
        } else if (*endptr == '\0') {
                return value;
        } else {
                for (char* cursor = endptr; *cursor != '\0'; cursor++) {
                        if (*cursor != ' ') {
                                return nanf(NULL);
                        }
                }
                return value;
        }
}

void parse_read_double_values(const void* bytes, const long number_of_rows, const long number_of_columns, const long* separator_positions, long row_0, long row_1, long col_0, long col_1, long row_major, double* values)
{
        long max_cstring_size = 100;
        char cstring[max_cstring_size];

        for (long row = row_0; row < row_1 + 1; row++) {
                for (long col = col_0; col < col_1 + 1; col++) {
                        long index = row * number_of_columns + col;
                        long position_0 = index > 0 ? separator_positions[index - 1] + 1 : 0;
                        long position_1 = separator_positions[index];

                        double value;
                        if (position_0 >= position_1 || position_1 - position_0 >= max_cstring_size) {
                                value = nanf(NULL);
                        } else {
                                parse_read_cstring(bytes, position_0, position_1, cstring);
                                value = parse_parse_double(cstring);
                        }

                        if (row_major == 1) {
                                values[(row - row_0) * (col_1 - col_0 + 1) + col - col_0] = value;
                        } else {
                                values[(col - col_0) * (row_1 - row_0 + 1) + row - row_0] = value;
                        }
                }
        }
}
