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
    int out = 0;
    int in = 0;

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
            out = 1;
            output = fopen(&argv[i][2], "w");
        }
        if (strncmp(argv[i], "-i", 2) == 0)
        {
            in = 1;
            input = fopen(&argv[i][2], "r");
            fprintf(stderr, "%s\n", "Can't open this file");
        }
    }

    char c; // to store the current char
    while ((c = fgetc(input)) != EOF)
    {
        // code taken partially from google
        int length = 100;                          //initial size
        char *str = malloc(length * sizeof(char)); //allocate mem for 100 chars
        int count = 0;                             //to keep track of how many chars have been used

        while (c != '\n')
        { //keep reading until a newline
            if (count >= length)
                str = realloc(str, (length += 10) * sizeof(char)); //add room for 10 more chars

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

            str[count++] = c;

            c = getchar();
        }

        if (out == 0)
            printf("%s\n", str);
        else
            fprintf(output, "%s", str);

        encodinIndx = 0;
        memset(str, 0, strlen(str));
        free(str);
    }

    if (input != stdin)
        fclose(input);
    if (output != stdout)
        fclose(output);

    return 0;
}