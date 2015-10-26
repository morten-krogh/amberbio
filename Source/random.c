#include "random.h"
#include <stdlib.h>

void fisher_yates_shuffle(long* values, const long values_length)
{
        u_int32_t n = (u_int32_t) values_length;
        for (u_int32_t i = 0; i < n - 1; i++) {
                long j = arc4random_uniform(n - i) + i;
                long tmp = values[i];
                values[i] = values[j];
                values[j] = tmp;
        }
}
