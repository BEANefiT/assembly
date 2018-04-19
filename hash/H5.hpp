#ifndef __H_5__
#define __H_5__

#define count_hash( str )                               \
({                                                      \
    size_t hash = 0;                                    \
    char* tmp = str;                                    \
                                                        \
    while (*tmp)                                        \
        hash = ((hash >> 1) | (hash << 63)) ^ *tmp++;   \
                                                        \
    hash;                                               \
})

#endif //__H_5__