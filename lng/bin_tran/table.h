#ifdef DEF_TRAN

/*RET*/
DEF_TRAN (0x16, { db (0xc3); });

/*EXIT*/
DEF_TRAN (0x1d, { db (0xb8); dd (0x3c); dw (0x8948); db (0xc7); dd (0x050f); });

/*PUSH*/
DEF_TRAN (0x01, {   
                    long long value = 0;
                    memcpy (&value, tran -> src_cur, 8);
                    tran -> src_cur += 8;
                    
                    dw (0xb848); dq (value); db (0x50); 
                });

/*OUT*/
DEF_TRAN (0x0c, {
                    db (0x58);
                    dw (0xbe48);    dq (0x6000c1);

                    dw (0x06c6);    db (0x0a);
                    db (0xbb);      dd (0x0f);

                    dw (0xff48);    db (0xce);
                    db (0x50);
                    dw (0x2148);    db (0xd8);
                    dw (0x8348);    db (0xc0);  db (0x30);
                    db (0x88);      db (0x06);
                    db (0x58);
                    dw (0xc148);    db (0xe8);  db (0x04);
                    dw (0x8348);    db (0xf8);  db (0x00);
                    db (0x75);      db (0xe8);

                    db (0xbf);      dd (0x01);
                    db (0xba);      dd (0x10);
                    db (0xb8);      dd (0x01);
                    dw (0x050f);
                });


#endif /*DEF_TRAN*/


#ifndef __TABLE_H__
#define __TABLE_H__


#define db( value )                     \
do{                                     \
    int tmp = value;                    \
    memcpy (tran -> dest_cur, &tmp, 1); \
    tran -> dest_cur += 1;              \
} while (0)

#define dw( value )                     \
do{                                     \
    int tmp = value;                    \
    memcpy (tran -> dest_cur, &tmp, 2); \
    tran -> dest_cur += 2;              \
} while (0)

#define dd( value )                     \
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
