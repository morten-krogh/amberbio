#include "geo_parser.h"


struct gds {
        bool valid;
        char* header;
        long feature_count;
        long number_of_headers;
        char** headers;

};

bool gds_valid(struct gds* gds)
{
        return gds->valid;
}

char* gds_header(struct gds* gds)
{
        return gds->header;
}


struct gds* gds_new(const void* bytes, const long length)
{
        struct gds* gds = malloc(sizeof(*gds));
        gds->valid = false;

        const char* string = (const char*) bytes;
        const char* end = string + length;
        if (*(end - 1) != '\n') return gds;

        const char* position_of_dataset_title = strnstr(string, "!dataset_title", length);
        if (position_of_dataset_title == NULL) return gds;

        const char* position_of_caret_after_dataset_title = strnstr(position_of_dataset_title, "^", end - position_of_dataset_title);
        if (position_of_caret_after_dataset_title == NULL) return gds;

        long header_length = position_of_caret_after_dataset_title - position_of_dataset_title;
        gds->header = malloc(header_length + 1);
        memcpy(gds->header, position_of_dataset_title, header_length);
        gds->header[header_length] = '\0';

        const char* position_of_feature_count = strnstr(position_of_dataset_title, "!dataset_feature_count", end - position_of_dataset_title);
        gds->feature_count = strtol(position_of_feature_count + 25, NULL, 10);

        const char* position_dataset_table_begin = strnstr(position_of_caret_after_dataset_title, "!dataset_table_begin", end - position_of_caret_after_dataset_title);
        if (position_dataset_table_begin == NULL) return gds;
        const char* position_headers = position_dataset_table_begin + 21;
        if (position_headers - string > length - 1) return gds;
        gds->number_of_headers = 1;
        for (const char* c = position_headers; *c != '\n'; c++) {
                if (*c == '\t') gds->number_of_headers++;
        }
        gds->headers = malloc(gds->number_of_headers * sizeof(*gds->headers));
        const char* position_header_start = position_headers;
        for (long i = 0; i < gds->number_of_headers; i++) {
                const char* position;
                for (position = position_header_start; *position != '\t' && *position != '\n'; position++);
                long header_length = position - position_header_start;
                char* header = malloc(header_length + 1);
                memcpy(header, position_header_start, header_length);
                header[header_length] = '\0';
                gds->headers[i] = header;
                position_header_start = position + 1;
        }

        for (long i = 0; i < gds->number_of_headers; i++) {
                printf("%s\n", gds->headers[i]);
        }






//
//        long position_of_dataset_table_begin = -1;
//
//        for (long i = 0; i < length - 19; i++) {
//                if (strncmp(string + i, "!dataset_table_begin", 20) == 0) {
//                        position_of_dataset_table_begin = i;
//                        break;
//                }
//        }





//        if (position_of_dataset_table_begin == 1) return;

//        long header_length = position_of_dataset_table_begin - 1;




//        long result_length = cstring_max_length > header_length ? header_length : cstring_max_length;
//        memcpy(cstring, bytes, result_length);
//        cstring[result_length + 1] = '\0';

        gds->valid = true;

        return gds;
}
