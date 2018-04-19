#ifndef __H_3__
#define __H_3__

#define count_hash( str )   \
({                          \
    size_t summ = 0;        \
    char* tmp = str;        \
                            \
    while (*tmp)            \
        summ += *tmp++;     \
                            \
    summ;                   \
})

#endif //__H_3__