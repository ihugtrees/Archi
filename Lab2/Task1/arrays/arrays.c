#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    int iarray[3];
    float farray[3];
    double darray[3];
    char carray[3];

    int intarray[] = {1, 3, 5};
    char charray[] = {'a', 'b', 'c'};
    int *intarrayPtr = &intarray[0];
    char *charrayPtr = &charray[0];
    int *p;

    printf(
        "iarray:   %p\n"
        "iarray+1: %p\n"
        "farray:   %p\n"
        "farray+1: %p\n"
        "darray:   %p\n"
        "darray+1: %p\n"
        "carray:   %p\n"
        "carray+1: %p\n",
        iarray, iarray + 1, farray, farray + 1,
        darray, darray + 1, carray, carray + 1);

    printf("intarray[0]: %d\n"
           "intarray[1]: %d\n"
           "intarray[2]: %d\n"
           "charray[0]: %c\n"
           "charray[1]: %c\n"
           "charray[2]: %c\n"
           "p: %p\n",
           *(intarrayPtr + 0), *(intarrayPtr + 1), *(intarrayPtr + 2),
           charrayPtr[0], charrayPtr[1], charrayPtr[2], &p);

    return 0;
}