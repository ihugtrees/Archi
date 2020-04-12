#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void PrintHex(char *buffer, int length)
{
    for (int i = 0; i < length; i++)
        printf("%02hhX ", buffer[i]);
    printf("\n");
}

int main(int argc, char **argv)
{
    char *file_name = argv[1];
    char *buffer;
    int size;

    FILE *input_file = fopen(file_name, "r");
    if (input_file == NULL)
    {
        fputs("File error", stderr);
        exit(1);
    }

    // obtain file size:
    fseek(input_file, 0, SEEK_END);
    size = ftell(input_file);
    rewind(input_file);

    // allocate memory to contain the whole file:
    buffer = (char *)malloc(size * sizeof(char));
    if (buffer == NULL)
    {
        fputs("Memory error", stderr);
        exit(2);
    }

    fread(buffer, 1, size, input_file);
    PrintHex(buffer, size);

    fclose(input_file);
    free(buffer);

    return 0;
}