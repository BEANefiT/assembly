#ifndef __BIN_TRAN_H__
#define __BIN_TRAN_H__

#define MAX_BINARY_SZ 2048

struct tran_t
{
    void*   src;
    void*   src_cur;
    void*   dest;
    void*   dest_cur;

    size_t  src_sz;
};

int get_src (struct tran_t*, const char*);
int translate (struct tran_t *);
int mkbin (struct tran_t*);





#endif /*__BIN_TRAN_H__*/
