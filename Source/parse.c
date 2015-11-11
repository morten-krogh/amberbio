#include "c-functions.h"

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
