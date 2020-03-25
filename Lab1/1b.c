#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    char c;
    int debug = 0;

    for (int i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-D") == 0)
        {
            debug = 1;
            for (int j = 1; j < argc; j++)
            {
                fprintf(stdout, "%s\n", argv[j]);
            }
        }
    }

    while ((c = fgetc(stdin)) != EOF)
    {
        if (c != '\n')
        {
            if (debug == 1)
                fprintf(stderr, "%d\t", c);

            if (c >= 'a' || c <= 'z')
                c -= 32;

            if (debug == 1)
                fprintf(stderr, "%d\n", c);
        }
        fprintf(stdout, "%c", c);
    }
}