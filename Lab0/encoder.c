#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    char c;
    int debug = 0;
    int encodeType = 0;
    char *encodingStr;
    int encodingLength;
    int encodinIndx = 0;
    FILE *input = stdin;
    FILE *output = stdout;

    for (int i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-D") == 0)
        {
            debug = 1;
            for (int j = 1; j < argc; j++)
                fprintf(stderr, "%s\n", argv[j]);
        }
        if (strncmp(argv[i], "+e", 2) == 0)
        {
            encodeType = 1;
            encodingStr = &argv[i][2];
            encodingLength = strlen(encodingStr);
        }
        if (strncmp(argv[i], "-e", 2) == 0)
        {
            encodeType = -1;
            encodingStr = &argv[i][2];
            encodingLength = strlen(encodingStr);
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
                    if (c >= 97 && c <= 122)
                        c -= 32;

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

                if (debug == 1)
                    fprintf(stderr, "%d\n", c);

                if (encodinIndx == encodingLength)
                    encodinIndx = 0;
            }
            else
                encodinIndx = 0;

            fprintf(output, "%c", c);
        }
    }
    else
        fprintf(stderr, "%s\n", "Can't open this file");

    if (input != stdin)
        fclose(input);

    if (output != stdout)
        fclose(output);

    return 0;
}