#include <stdio.h>
#define MAX_LEN 10 /* maximal int size */

extern void assFunc(int x, int y);

extern char c_checkValidity(int x, int y){
    if(x>=y)
        return '1';
    return '0';
}

int main(int argc, char **argv)
{
    char str_int[MAX_LEN];
    int x;
    int y;

    printf("Enter 2 integers\n");
    fgets(str_int, MAX_LEN, stdin);
    sscanf(str_int, "%d", &x);

    fgets(str_int, MAX_LEN, stdin);
    sscanf(str_int, "%d", &y);
    assFunc(x, y); 

    return 0;
}