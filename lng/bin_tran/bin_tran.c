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

    if (mkbin (&tran))
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

   while ((size_t) (tran -> src_cur - tran -> src) < tran -> src_sz)
   {
      int tmp = 0;
      memcpy (&tmp, tran -> src_cur, sizeof (int) );
      tran -> src_cur += 4;
      
      #define DEF_TRAN( cond, cmd ) \
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

   free (tran -> src);

   return 0;
};

int mkbin (struct tran_t* tran)
{
    if (!tran)
    {
        printf ("NULL ptr:%d\n\t", __LINE__);

        return -1;
    }

    FILE* file = fopen ("elf", "w");

    if (!file)
    {
        printf ("can't create \'elf\':%d\n\t", __LINE__);

        return -1;
    }

    fwrite (tran -> dest, 1, (size_t) (tran -> dest_cur - tran -> dest), file);

    fclose (file);

    return 0;
}
