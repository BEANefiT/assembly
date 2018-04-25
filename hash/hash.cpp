#ifndef __HASH_CPP__
#define __HASH_CPP__

#include <iostream>
#include <array>
#include "../../track/bexcept/bexcept.hpp"
#include "../../track/blist/blist.hpp"
#include "H4.hpp"
#include "text.hpp"

void    get_src (struct text* a, const char* src);
void    test_func (struct text* a);
void    mkplot (struct text* a);

int main(int argc, char* argv[])
{
    try
    {
        if (argc == 1)
        {
            bexcept_throw ("You didn't choose the file");
        }

        text txt;

        get_src (&txt, argv[1]);

        test_func (&txt);

        mkplot (&txt);
    }

    catch (bexcept* e)
    {
        e -> dump();
    }

    return 0;
}

void get_src (struct text* a, const char* src)
{
    FILE* file = fopen (src, "r");

    if (file == nullptr)
    {
        bexcept_throw ("Failed to open the file");
    }

    fseek (file, 0, SEEK_END);
    a -> size = ftell (file);
    rewind (file);

    a -> txt = new (std::nothrow) char [a -> size];

    if (a -> txt == nullptr)
    {
        bexcept_throw ("Cannot allocate buffer");
    }

    if (fread (a -> txt, sizeof (char), a -> size, file) < a -> size)
    {
        bexcept_throw ("Loss of data");
    }

    fclose (file);
}

void test_func (struct text* a)
{
    try
    {
        for (int i = 0; i < a->size; i++) {
            while ((a -> txt [i++]) == ' ')
                ;

            if (i >= a -> size - 1)
                break;

            int j = i;

            while ((a -> txt[i]) != ' ')
                i++;

            auto str = new char [i - j + 1];

            for (int k = 0; k < i - j; k++)
                str[k] = a -> txt[j + k];

            str[i - j] = '\0';

            a->in(count_hash(str) % ARRAY_SZ, str);
        }
    }

    catch (bexcept* e){ bexcept_throw_without_msg (e); }
}

void mkplot (struct text* a)
{
    FILE* buffer = fopen ("buf.dat", "w");

    if (buffer == nullptr)
    {
        bexcept_throw ("cannot open \'buf.dat\'");
    }

    for (int i = 0; i < ARRAY_SZ; i++)
        fprintf (buffer, "%d\t\t%zd\n", i, a -> array[i].size());

    fclose (buffer);

    FILE* plot = fopen ("mkplot", "w");

    if (plot == nullptr)
    {
        bexcept_throw ("cannot open \'mkplot\'");
    }

    fprintf (plot, "set term png size 1024, 768\n"
                   "set output \'plot.png\'\n"
                   "set xrange [0:%d]\n"
                   "set auto y\n"
                   "set style data boxes\n"
                   "set style histogram cluster gap 1\n"
                   "set style fill solid border -1\n"
                   "set boxwidth 0.9\n"
                   "plot \'buf.dat\'\n", ARRAY_SZ);

    fclose (plot);
    system ("gnuplot mkplot");
    system ("eog plot.png");
}

#endif //__HASH_CPP__