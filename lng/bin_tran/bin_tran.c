#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bin_tran.h"
#include "table.h"

int main(int argc, char* argv[])
{
    if (argc != 2)
    {
        printf ("file is not chosen\n");

        return 0;
    }

    struct tran_t tran = {NULL, NULL, NULL, NULL, 0};

    if (get_src (&tran, argv[1]))
    {
        printf ("can't get_src()\n");
        
        return -1;
    }

    if (translate (&tran))
    {
        printf ("can't translate()\n");

        return -1;
    }

    if (mkelf (&tran))
    {
        printf ("can't mkbin()\n");

        return -1;
    }

    return 0;
}

int get_src (struct tran_t* tran, const char* filename)
{
    if (! (tran && filename))
    {
        printf ("NULL pointer:%d\n\t", __LINE__);

        return -1;
    }

    FILE* file = fopen (filename, "r");

    if (!file)
    {
        printf ("can't open src_file:%d\n\t", __LINE__);

        return -1;
    }

    fseek (file, 0, SEEK_END);
    tran -> src_sz = ftell (file);
    rewind (file);

    tran -> src = calloc (tran -> src_sz, 1);
    if (! (tran -> src))
    {
        printf ("can't alloc mem for src:%d\n\t", __LINE__);

        return -1;
    }

    tran -> src_cur = tran -> src;

    fread (tran -> src, 1, tran -> src_sz, file);

    fclose (file);

    return 0;
}

int translate (struct tran_t* tran)
{
    if (!tran)
    {
        printf ("NULL ptr:%d\n\t", __LINE__);

        return -1;
    }

    tran -> dest = calloc (MAX_BINARY_SZ, 1);

    if (! (tran -> dest))
    {
        printf ("can't allocate mem for dest:%d\n\t", __LINE__);

        return -1;
    }

    tran -> dest_cur = tran -> dest;

    dw (0x8948);    db (0xe5);                  //mov rbp, rsp
    dw (0x8148);    db (0xec);  dd (0x400);     //sub rsp, 1024 (RAM)

    tran -> dest += 10;

    while ((size_t) (tran -> src_cur - tran -> src) < tran -> src_sz)
    {
        int tmp = 0;
        memcpy (&tmp, tran -> src_cur, sizeof (int) );
        tran -> src_cur += 4;
      
        #define DEF_TRAN( cond, cmd )   \
            case (cond):                \
            {                           \
                cmd;                    \
                                        \
                break;                  \
            }

        switch (tmp)
        {
            #include "table.h"
        }
      
        #undef DEF_TRAN
    }
    
    dw (0x8148);    db (0xc5);  dd (0x400);     //add rsp, 1024 (delete RAM)

    free (tran -> src);

    tran -> dest    -= 10;
    tran -> dest_sz = (size_t) (tran -> dest_cur - tran -> dest);

    return 0;
};

int mkelf (struct tran_t* tran)
{
    if (!tran)
    {
        printf ("NULL ptr:%d\n\t", __LINE__);

        return -1;
    }

    void* elf = calloc (tran -> dest_sz + 0xd2, 1);

    if (!elf)
    {
        printf ("can't create elf:%d\n\t", __LINE__);

        return -1;
    }

    memcpy (elf + 0xd2, tran -> dest, tran -> dest_sz);
    free (tran -> dest);
    tran -> dest = elf;
    tran -> dest_cur = elf;

    mkhdr (tran);

    FILE* file = fopen ("elf", "w");

    if (!file)
    {
        printf ("can't create \'elf\':%d\n\t", __LINE__);

        return -1;
    }

    fwrite (tran -> dest, 1, tran -> dest_sz + 0xd2, file);

    fclose (file);

    return 0;
}

void mkhdr (struct tran_t* tran)
{
    /*ELF HEADER*/
    db (0x7f); db ('E'); db ('L'); db ('F');    //sign

    db (0x02);                                  //64-bit format
    db (0x01);                                  //little-endian
    db (0x01);                                  //current version
    db (0x00);                                  //System V

    dq (0x00);                                  //ABIversion + unused bytes
    
    dw (0x02);                                  //executable
    dw (0x3e);                                  //x86-64

    dd (0x01);                                  //e_version

    dq (0x4000b0);                              //e_entry - mem_addr of _start
    dq (0x40);                                  //e_phoff - offs of the phdrtab
    dq (0x00);                                  //e_shoff - offs of the shdrtab (I don't use that)

    dd (0x00);                                  //e_flags - depends on the architecture

    dw (0x40);                                  //e_ehsize - hdr_sz
    dw (0x38);                                  //e_phentsize - phdr_sz
    dw (0x02);                                  //e_phnum - num of phdrs

    dw (0x00);                                  //e_shentsize
    dw (0x00);                                  //e_shnum       (I don't create section hdrs)
    dw (0x00);                                  //e_shstrndx

    /*PROGRAM HEADER TABLE*/
        /*.text header*/
    dd (0x01);                                  //PT_LOAD
    dd (0x05);                                  //R E

    dq (0x00);                                  //offset of the segment
    dq (0x400000);                              //virtual addr of the segment in memory
    dq (0x400000);                              //phys    addr of the segment in memory
    dq (0xd2 + tran -> dest_sz);                //size of segment in file
    dq (0xd2 + tran -> dest_sz);                //size of segment in memory
    dq (0x10);                                  //p_align; ignored, because file is executable

        /*.data header*/
    dd (0x01);                                  //PT_LOAD
    dd (0x06);                                  //RW

    dq (0xb2);                                  //offset of the segment
    dq (0x6000b2);                              //virtual addr of the segment in memory
    dq (0x6000b2);                              //phys    addr of the segment in memory
    dq (0x20);                                  //size of segment in file
    dq (0x20);                                  //size of segment in memory
    dq (0x10);                                  //p_align; ignored, because file is executable

    db (0xeb);                                  //jmp over .data
    db (0x20);

    db ('0');                                   //buffer "0123456789abcdef"
    db ('1');
    db ('2');
    db ('3');
    db ('4');
    db ('5');
    db ('6');
    db ('7');
    db ('8');
    db ('9');
    db ('a');
    db ('b');
    db ('c');
    db ('d');
    db ('e');
    db ('f');
}
