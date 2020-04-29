#include "util.h"

#define STDIN 0
#define STDOUT 1
#define STDERR 2
#define SYS_READ 3
#define SYS_WRITE 4
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_LSEEK 19
#define SYS_GETDENT 141
#define BUFFER_SIZE 8192

extern int system_call();

typedef struct ent {
    int inode;
    int offset;
    short len;
    char buf[1];
} ent;

int
main(int argc, char **argv)
{
    int debug = 0, i, j;
    char *file_prefix;
    char *attach_prefix;

    for (i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-D") == 0)
        {
            debug = 1;
            for (j = 1; j < argc; j++)
            {
                system_call(SYS_WRITE, STDERR, argv[j], strlen(argv[j]));
                system_call(SYS_WRITE, STDERR, "  ", 2);
            }
        }

        if (strncmp(argv[i], "-p", 2) == 0)
        {
            file_prefix = &argv[i][2];
        }

        if (strncmp(argv[i], "-a", 2) == 0)
        {
            attach_prefix = &argv[i][2];
        }
    }

    if (input > -1)
    {
        while ((code = system_call(SYS_READ, input, &c, 1)) > 0)
        {
            if (c == 0)
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