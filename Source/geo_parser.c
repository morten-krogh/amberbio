#include "geo_parser.h"


struct gds {
        bool valid;
        char* header;
        long feature_count;

};

bool gds_valid(struct gds* gds)
{
        return gds->valid;
}

char* gds_header(struct gds* gds)
{
        return gds->header;
}


struct gds* gds_init(const void* bytes, const long length)
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
