#include "geo_soft_file_parser.h"

void geo_soft_find_header(const void* bytes, const long length, char* cstring, const long cstring_max_length)
{
        const char* string = (const char*) bytes;

        long position_of_dataset_table_begin = -1;

        for (long i = 0; i < length - 19; i++) {
                if (strncmp(string + i, "!dataset_table_begin", 20) == 0) {
                        position_of_dataset_table_begin = i;
                        break;
                }
        }

        if (position_of_dataset_table_begin == 1) return;

        long header_length = position_of_dataset_table_begin - 1;

        long result_length = cstring_max_length > header_length ? header_length : cstring_max_length;
        memcpy(cstring, bytes, result_length);
        cstring[result_length + 1] = '\0';
}

