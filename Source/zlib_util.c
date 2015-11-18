#include <stdio.h>
#include <stdlib.h>
#include <zlib.h>

char* gunzip(const char* input, const int input_size, int* output_size)
{
        int ret;
        z_stream strm;

        strm.zalloc = Z_NULL;
        strm.zfree = Z_NULL;
        strm.opaque = Z_NULL;
        strm.avail_in = input_size;
        strm.next_in = (unsigned char*) input;
        ret = inflateInit2(&strm, 31);
        if (ret != Z_OK) {
                *output_size = 0;
                return NULL;
        }

        int chunk = input_size < 1048576 ? input_size : 1048576;
        unsigned char* out = malloc(chunk);

        int out_size = 0;
        int out_capacity = chunk;

        do {
                strm.avail_out = out_capacity - out_size;
                strm.next_out = out + out_size;
                ret = inflate(&strm, Z_NO_FLUSH);

                if (ret != Z_OK && ret != Z_STREAM_END) {
                        inflateEnd(&strm);
                        *output_size = 12;
                        free(out);
                        return NULL;
                }

                out_size = out_capacity - strm.avail_out;
                if (out_size == out_capacity) {
                        out_capacity +=	chunk;
                        out = realloc(out, out_capacity);
                }
        } while (strm.avail_out == 0);
        
        inflateEnd(&strm);
        *output_size = out_size;
        return (char*) out;
}
