#include <stdio.h>
#define MAX_LEN 256 /* maximal input string size */

extern void assFunc(int x, int y);

extern char c_checkValidity(int x, int y){
    if(x>=y)
        return 1;
    return 0;
}

int main(int argc, char **argv)
{
    char str_x[MAX_LEN];
    char str_y[MAX_LEN];
    int x;
    int y;

    printf("Enter 2 integers seperated by enter");
    fgets(str_x, MAX_LEN, stdin); /* get user input string */
    fgets(str_y, MAX_LEN, stdin); /* get user input string */
    sscanf(str_x, "%d %d", x, y);
    assFunc(x, y); /* call your assembly function */

    return 0;
}