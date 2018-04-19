#ifndef __H_4__
#define __H_4__

#define count_hash( str )              \
({                                      \
    size_t hash = 0;                    \
    char* tmp = str;                    \
                                        \
    while (*tmp)                        \
        hash += (hash << 5) + *tmp++;   \
                                        \
    hash;                               \
})

#endif //__H_4__