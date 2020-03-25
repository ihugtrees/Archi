#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    char c;
    int debug = 0;
    int encodeType = 0;
    char *encodeStr;
    int encodeLen = 0;
    int encodeIndx = 0;
    FILE *output = stdout;
    FILE *input = stdin;

    for (int i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-D") == 0)
        {
            debug = 1;
            for (int j = 1; j < argc; j++)
                fprintf(stdout, "%s\n", argv[j]);
        }

        if (strncmp(argv[i], "+e", 2) == 0)
        {
            encodeType = 1;
            encodeStr = &argv[i][2];
            encodeLen = strlen(encodeStr);
        }

        if (strncmp(argv[i], "-e", 2) == 0)
        {
            encodeType = -1;
            encodeStr = &argv[i][2];
            encodeLen = strlen(encodeStr);
        }

        if (strncmp(argv[i], "-o", 2) == 0)
        {
            output = fopen(&argv[i][2], "w");
        }

        if (strncmp(argv[i], "-i", 2) == 0)
        {
            input = fopen(&argv[i][2], "r");
        }
    }

    if (input != NULL)
    {
        while ((c = fgetc(input)) != EOF)
        {
            if (c != '\n')
            {
                if (debug == 1)
                    fprintf(stderr, "%d\t", c);

                if (encodeType == 0)
                    if (c >= 97 || c <= 122)
                        c -= 32;

                if (encodeType == 1)
                {
                    c += encodeStr[encodeIndx] - '0';
                    encodeIndx++;
                }

                if (encodeType == -1)
                {
                    c -= encodeStr[encodeIndx] - '0';
                    encodeIndx++;
                }

                if (encodeIndx == encodeLen)
                    encodeIndx = 0;

                if (debug == 1)
                    fprintf(stderr, "%d\n", c);
            }
            else
                encodeIndx = 0;

            fprintf(output, "%c", c);
        }
    }
    else
        fprintf(stderr, "%s", "Can't open input");

    if (output != NULL && output != stdout)
        fclose(output);

    if (input != NULL && input != stdout)
        fclose(input);
        
    return 0;
}