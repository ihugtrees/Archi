#include "util.h"

#define STDIN 0
#define STDOUT 1
#define STDERR 2
#define SYS_READ 3
#define SYS_WRITE 4
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_LSEEK 19

extern int system_call();

int main(int argc, char **argv)
{
    char c;
    int debug = 0, code, i, j;
    int output = STDOUT;
    int input = STDIN;

    for (i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-D") == 0)
        {
            debug = 1;
            for (j = 1; j < argc; j++)
            {
                system_call(SYS_WRITE, STDOUT, argv[j], strlen(argv[j]));
                system_call(SYS_WRITE, STDOUT, "\n", 1);
            }
        }

        if (strncmp(argv[i], "-o", 2) == 0)
        {
            output = system_call(SYS_OPEN, &argv[i][2], 65, 0777);
        }

        if (strncmp(argv[i], "-i", 2) == 0)
        {
            input = system_call(SYS_OPEN, &argv[i][2], 0, 0777);
        }
    }

    if (input > -1)
    {
        while ((code = system_call(SYS_READ, input, &c, 1)) > 0)
        {
            if(c == 0)
                break;
            char *stderr_print;
            if (debug == 1)
            {
                stderr_print = itoa(SYS_READ);
                system_call(SYS_WRITE, STDERR, stderr_print, strlen(stderr_print));
                system_call(SYS_WRITE, STDERR, "\t", 1);

                stderr_print = itoa(code);
                system_call(SYS_WRITE, STDERR, stderr_print, strlen(stderr_print));
                system_call(SYS_WRITE, STDERR, "\n", 1);
            }

            if (c >= 97 && c <= 122)
                c -= 32;

            code = system_call(SYS_WRITE, output, &c, 1);
            if (debug == 1)
            {
                stderr_print = itoa(SYS_WRITE);
                system_call(SYS_WRITE, STDERR, stderr_print, strlen(stderr_print));
                system_call(SYS_WRITE, STDERR, "\t", 1);

                stderr_print = itoa(code);
                system_call(SYS_WRITE, STDERR, stderr_print, strlen(stderr_print));
                system_call(SYS_WRITE, STDERR, "\n", 1);
            }
        }
    }
    else
        system_call(SYS_WRITE, STDERR, "Can't open input\n", strlen("Can't open input\n"));

    system_call(SYS_WRITE, STDERR, "\n", 1);
    if (output > -1 && output != STDOUT)
        system_call(SYS_CLOSE, output);

    if (input > -1 && input != STDIN)
        system_call(SYS_CLOSE, input);

    return 0;
}