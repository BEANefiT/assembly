#ifndef __H_2__
#define __H_2__

#define count_hash( str )   \
({                          \
    size_t i = 0;           \
    char* tmp = str;        \
    while (*tmp++)          \
        i++;                \
                            \
    i;                      \
})

#endif //__H_2__