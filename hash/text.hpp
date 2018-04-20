#ifndef __TEXT_HPP__
#define __TEXT_HPP__

#define ARRAY_SZ 1000
#include "string.h"
#include "../../track/blist/blist.hpp"
#include "../../track/bexcept/bexcept.hpp"

#define bstrcmp( str1, str2 )                       \
   ({   int result = -2;                            \
                                                    \
        __asm__ __volatile__                                    \
        (                                           \
            ".intel_syntax noprefix\n"            \
            "mov ch, byte ptr [rdi]\n"              \
            "cmpsb\n"                                   \
            "jg $+0x10\n"                                   \
            "jl $+0x15\n"                             \
            "cmp ch, 0x0\n"                   \
            "jne $-0x0a\n"                         \
            "mov %0, 0\n"                         \
            "jmp $+0x0e\n"                          \
            "mov %0, -1\n"                          \
            "jmp $+0x07\n"                          \
            "mov %0, 1\n"                          \
            ".att_syntax prefix\n"                  \
            : "=g" (result)                                                 \
            : "D" (str1), "S" (str2)                                        \
            : "%rcx"                                                        \
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