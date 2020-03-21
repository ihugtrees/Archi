#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
    int debug = 0;
    FILE *input = stdin;
    FILE *output = stdout;
    int encodeType = 0;
    char *encodingStr;
    int encodingLength;
    int encodinIndx = 0;
    char c;

    void encStr(int i)
    {
        encodingStr = &argv[i][2];
        encodingLength = strlen(encodingStr);
    }

    for (int i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-D") == 0)
        {
            debug = 1;
            fprintf(stderr, "%s\n", "-D");
        }
        if (strncmp(argv[i], "+e", 2) == 0)
        {
            encodeType = 1;
            encStr(i);
        }
        if (strncmp(argv[i], "-e", 2) == 0)
        {
            encodeType = -1;
            encStr(i);
        }
        if (strncmp(argv[i], "-o", 2) == 0)
        {
            output = fopen(&argv[i][2], "w");
        }
        if (strncmp(argv[i], "-i", 2) == 0)
        {
            input = fopen(&argv[i][2], "r");
            fprintf(stderr, "%s\n", "Can't open this file");
        }
    }

    while ((c = fgetc(input)) != EOF)
    {
            if (debug == 1)
                printf("%d\t", c);

            if (c >= 97 && c <= 122)
                c -= 32;

            if (debug == 1)
                printf("%d\n", c);

            if (encodeType == 1)
            {
                c += encodingStr[encodinIndx] - '0';
                encodinIndx++;
            }
            if (encodeType == -1)
            {
                c -= encodingStr[encodinIndx] - '0';
                encodinIndx++;
            }
            if (encodinIndx == encodingLength)
                encodinIndx = 0;

            c = getchar();
        

        fprintf(output, "%c", c);

        encodinIndx = 0;
    }

    free(str);
    if (input != stdin)
        fclose(input);
    if (output != stdout)
        fclose(output);

    return 0;
}