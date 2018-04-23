#include <iostream>
#include "../../track/blist/blist.hpp"

struct text
{
    text();
    ~text();

    char*   txt;
    char*   new_txt;
    size_t  size;
    size_t  new_sz;
};

bool    get_src (struct text* a, const char* src);
bool    format (struct text* a);
bool    write (struct text* a, const char* filename);


int main(int argc, char* argv[])
{
    if (argc == 1)
    {
        std::cout << "\nYou didn't choose the file\n";

        return 0;
    }

    text a;

    if (get_src (&a, argv[1]))
    {
        std::cout << "Failed to get_src()\n";

        return 1;
    }

    if (format (&a))
    {
        std::cout << "Failed to format()\n";

        return 1;
    }

    if (write (&a, argv [2]))
    {
        std::cout << "Failed to write()\n";

        return 1;
    }

    return 0;
}

bool get_src (struct text* a, const char* src)
{
    FILE* file = fopen (src, "r");

    if (file == nullptr)
    {
        std::cout << "\nFailed to open the file - \'<< src << \'\n";

        return 1;
    }

    fseek (file, 0, SEEK_END);
    a -> size = ftell (file);
    rewind (file);

    a -> txt = new (std::nothrow) char [a -> size];

    if (a -> txt == nullptr)
    {
        return 1;
    }

    if (fread (a -> txt, sizeof (char), a -> size, file) < a -> size)
    {
        return 1;
    }

    fclose (file);

    return 0;
}

bool format (struct text* a)
{
    auto tmp = new (std::nothrow) char [a -> size];

    if (tmp == nullptr)
    {
        return 1;
    }

    for (int i = 0; i < a -> size; i++)
    {
        if (std::isalpha (a -> txt [i]) || std::isspace (a -> txt[i]))
            tmp [a -> new_sz++] = a -> txt [i];
    }

    delete [] a -> txt;
    a -> txt = nullptr;

    a -> new_txt = new (std::nothrow) char [a -> new_sz + 1];

    if (a -> new_txt == nullptr)
    {
        return 1;
    }

    for (int i = 0; i < a -> new_sz - 1; i++)
    {
        a -> new_txt [i] = std::tolower (tmp [i]);
    }

    a -> new_txt [a -> new_sz] = '\0';

    delete [] tmp;
    tmp = nullptr;

    return 0;
}

bool write (struct text* a, const char* filename)
{
    FILE* file = nullptr;
    if (filename == nullptr)
        file = fopen ("format", "w");
    else
        file = fopen (filename, "w");

    fprintf (file, "%s", a -> new_txt);
    fclose (file);
}

text :: text():
    txt (nullptr),
    new_txt (nullptr),
    size (0),
    new_sz (0)
{}

text :: ~text()
{
    if (txt != nullptr)
    {
        delete[] txt;
        txt = nullptr;
    }

    if (new_txt != nullptr)
    {
        delete[] new_txt;
        new_txt = nullptr;
    }
}