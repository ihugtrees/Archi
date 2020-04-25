#include <stdio.h>
#include <string.h>
#define MAX_LEN 34 /* maximal input string size */
                   /* enough to get 32-bit string + '\n' + null terminator */
extern int convertor(char *buf);

int main(int argc, char **argv)
{
    char buf[MAX_LEN];

    fgets(buf, MAX_LEN, stdin); /* get user input string */
    printf("%s\n", buf);
    
    while (strcmp(buf, "q") != 0)
    {
        convertor(buf); /* call your assembly function */
        for (size_t i = 0; i < MAX_LEN; i++)
            buf[i] = '\0';

        fgets(buf, MAX_LEN, stdin);
        printf("%s\n", buf);
    }

    return 0;
}