#ifndef __TEXT_HPP__
#define __TEXT_HPP__

#define ARRAY_SZ 1000
#include "string.h"
#include "../track/blist/blist.hpp"
#include "../track/bexcept/bexcept.hpp"

#define bstrcmp( str1, str2 )                       \
   ({   int str1_len = 0, str2_len = 0, result = -2;\
                                                    \
        while (str1 [str1_len++])                   \
            ;                                       \
                                                    \
        while (str2 [str2_len++])                   \
            ;                                       \
                                                    \
        __asm__                                     \
        (                                           \
            ".intel_syntax noprefix\n\t"            \
            "repe cmpsb\n"                          \
            "jg $+0x0b\n\t"                         \
            "jl $+0x10\n\t"                         \
            "mov %0, 0\n\t"                         \
            "jmp $+0x0e\n"                          \
            "mov %0, 1\n\t"                         \
            "jmp $+0x07\n"                          \
            "mov %0, -1\n\t"                        \
            ".att_syntax prefix\n"                  \
            : "=g" (result)                                                 \
            : "D" (str1), "S" (str2), "c" (std::min (str1_len, str2_len))   \
            :                                                               \
        );                                                                  \
        result;                                                             \
    })

struct text
{
    text();
    ~text();

    char*       txt;
    size_t      size;
    std::array <blist <char*>, ARRAY_SZ> array;

    bool        in (size_t index, char* str);
};

text :: text():
        txt (nullptr),
        size (0)
{}

text :: ~text()
{
    if (txt != nullptr)
    {
        delete[] txt;
        txt = nullptr;
    }

}

bool text :: in (size_t index, char* str)
{
    try
    {
        if (array[index].size() == 0) {
            array[index].insert((int)0, str);

            return 0;
        }

        if (bstrcmp (str, array[index].get_tail() -> get_elem()) > 0) {
            array[index].push_back(str);
            return 0;
        }

        auto count = array[index].get_head();

        for (int k = 0; k < array[index].size(); k++)
        {
            char* str2 = count -> get_elem();

            int result = bstrcmp (str, str2);

            if (result == -2)
            {
                bexcept_throw ("err while doing bstrcmp");
            }

            if (result < 0)
            {
                array[index].insert(count, str);
                break;
            }

            if (result == 0)
                break;

            if (result > 0)
                count = count->get_next();
        }

        return 0;
    }

    catch (bexcept* e)
    {
        bexcept_throw_without_msg (e);
    }
}

#endif //__TEXT_HPP__