#ifdef DEF_TRAN

/*RET*/
DEF_TRAN (0x16, { db (0xc3); });

/*EXIT*/
DEF_TRAN (0x1d, { db (0xb8); dd (0x3c); dw (0x3148); db (0xff); dw (0x050f); });

/*PUSH*/
DEF_TRAN (0x01, { db (0xb8); dd (getint()); db (0x50); });

/*PUSHR*/
DEF_TRAN (0x02, { db (0x50 + getint()); });

/*POPR*/
DEF_TRAN (0x05, { db (0x58 + getint()); });

/*ADD*/
DEF_TRAN (0x08, { db (0x58); db (0x5b); dw (0x0148); db (0xd8); db (0x50); });

/*SUB*/
DEF_TRAN (0x0b, { db (0x58); db (0x5b); dw (0x2948); db (0xd8); db (0x50); });

/*MUL*/
DEF_TRAN (0x09, { db (0x58); db (0x5b); dw (0xf748); db (0xe3); db (0x50); });

/*DIV*/
DEF_TRAN (0x0a, { db (0x58); db (0x5b); dw (0xf748); db (0xf3); db (0x50); });

/*OUT*/
DEF_TRAN (0x0c, {
                    db (0x58);
                    dw (0xbe48);    dq (0x6000d1);

                    dw (0x06c6);    db (0x0a);
                    db (0xbb);      dd (0x0f);

                    dw (0xff48);    db (0xce);
                    db (0x50);
                    dw (0x2148);    db (0xd8);
                    dw (0x0548);    dd (0x6000b2);
                    db (0x8a);      db (0x00);
                    db (0x88);      db (0x06);
                    db (0x58);
                    dw (0xc148);    db (0xe8);  db (0x04);
                    dw (0x8348);    db (0xf8);  db (0x00);
                    db (0x75);      db (0xe4);

                    dw (0xba48);    dq (0x6000d2);
                    dw (0x2948);    db (0xf2);

                    db (0xbf);      dd (0x01);
                    db (0xb8);      dd (0x01);
                    dw (0x050f);
                });

/*JMP*/
DEF_TRAN (0x0e, { jmp (0x79); });

/*JE*/
DEF_TRAN (0x0f, { db (0x5b); db (0x58); dw (0x3948); db (0xd8); jmp (2); });

/*JNE*/
DEF_TRAN (0x10, { db (0x5b); db (0x58); dw (0x3948); db (0xd8); jmp (3); });

/*JA*/
DEF_TRAN (0x11, { db (0x5b); db (0x58); dw (0x3948); db (0xd8); jmp (5); });

/*JAE*/
DEF_TRAN (0x12, { db (0x5b); db (0x58); dw (0x3948); db (0xd8); jmp (1); });

/*JB*/
DEF_TRAN (0x13, { db (0x5b); db (0x58); dw (0x3948); db (0xd8); jmp (0); });

/*JBE*/
DEF_TRAN (0x14, { db (0x5b); db (0x58); dw (0x3948); db (0xd8); jmp (4); });

/*CALL*/
DEF_TRAN (0x15, {
                    tran -> src_cur += 4;
                    int offs = getint() - (int)(tran -> dest_cur)
                                        + (int)(tran -> dest);

                    db (0xe8); dd (offs - 5);
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

#define getint()                                    \
({                                                  \
    int result = 0;                                 \
    memcpy (&result, tran -> src_cur, sizeof (int));\
    tran -> src_cur += 4;                           \
    result;                                         \
})

#define jmp( num )                                      \
do{                                                     \
    tran -> src_cur += 4;                               \
    int offs = getint() - (int)(tran -> dest_cur)       \
                        + (int)(tran -> dest);          \
    db (0x72 + num); db (offs - 2);                     \
} while (0)
#endif /*__TABLE_H__*/
