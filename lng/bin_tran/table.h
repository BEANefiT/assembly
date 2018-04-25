#ifdef DEF_TRAN

DEF_TRAN (0x16, { db (0xb8); dd (0x3c); dw (0x050f); });

#endif /*DEF_TRAN*/


#ifndef __TABLE_H__
#define __TABLE_H__


#define db( value )                     \
do{                                     \
    int tmp = value;                    \
    memcpy (tran -> dest_cur, &tmp, 1); \
    tran -> dest_cur += 1;              \
} while (0)

#define dd( value )                     \
do{                                     \
    int tmp = value;                    \
    memcpy (tran -> dest_cur, &tmp, 2); \
    tran -> dest_cur += 2;              \
} while (0)

#define dw( value )                     \
do{                                     \
    int tmp = value;                    \
    memcpy (tran -> dest_cur, &tmp, 4); \
    tran -> dest_cur += 4;              \
} while (0)

#define dq( value )                     \
do{                                     \
    size_t tmp = value;                 \
    memcpy (tran -> dest_cur, &tmp, 8); \
    tran -> dest_cur += 8;              \
} while (0)


#endif /*__TABLE_H__*/
