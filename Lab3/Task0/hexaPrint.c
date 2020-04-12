#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    char *file_name = argv + 1;
    FILE *input_file = fopen(file_name, 'r');
    char c;
    while(c = getc(input_file) != '\n')
        printf("%x", c);

    return 0;
}