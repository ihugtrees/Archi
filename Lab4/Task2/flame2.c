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
extern void infector();

typedef struct dirent
{
    int inode;
    int offset;
    short length;
    char name[];
} dirent;

void print_debug(int call, int value)
{
    char *stderr_print = itoa(call);
    system_call(SYS_WRITE, STDERR, "Code: ", strlen("Code: "));
    system_call(SYS_WRITE, STDERR, stderr_print, strlen(stderr_print));

    stderr_print = itoa(value);
    system_call(SYS_WRITE, STDERR, " Value: ", strlen(" Value: "));
    system_call(SYS_WRITE, STDERR, stderr_print, strlen(stderr_print));
    system_call(SYS_WRITE, STDERR, "\n", 1);
}

int main(int argc, char **argv)
{
    int debug = 0, i, j, bytes_read = 0, bytes_wrote = 0, directory, file_pointer = 0, cmp_rslt, p = 0, a = 0;
    char buffer[BUFFER_SIZE];
    char *prefix = "";
    dirent *dir;

    for (i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-D") == 0)
        {
            debug = 1;
            for (j = 1; j < argc; j++)
            {
                system_call(SYS_WRITE, STDERR, argv[j], strlen(argv[j]));
                system_call(SYS_WRITE, STDERR, " ", 1);
            }
            system_call(SYS_WRITE, STDERR, "\n", 1);
        }

        if (strncmp(argv[i], "-p", 2) == 0)
        {
            p = 1;
            prefix = &argv[i][2];
        }
        else
        {
            if (strncmp(argv[i], "-a", 2) == 0)
            {
                a = 1;
                prefix = &argv[i][2];
            }
        }
    }

    directory = system_call(SYS_OPEN, ".", 0, 0777);
    if (debug == 1)
        print_debug(SYS_OPEN, directory);
    if (directory == -1)
        system_call(1, 0x55);

    bytes_read = system_call(SYS_GETDENT, directory, buffer, BUFFER_SIZE);
    if (debug == 1)
        print_debug(SYS_GETDENT, bytes_read);
    if (bytes_read == -1)
        system_call(1, 0x55);
    if (bytes_read == 0)
        system_call(1, 0);

    while (file_pointer < bytes_read)
    {
        dir = (dirent *)&buffer[file_pointer];

        if ((cmp_rslt = strncmp(dir->name, prefix, strlen(prefix)) == 0))
        {
            bytes_wrote = system_call(SYS_WRITE, STDOUT, "Name: ", strlen("Name: "));
            bytes_wrote += system_call(SYS_WRITE, STDOUT, dir->name, strlen(dir->name));
            bytes_wrote += system_call(SYS_WRITE, STDOUT, "\n", 1);

            if (debug == 1)
            {
                print_debug(SYS_WRITE, bytes_wrote);

                char *file_length = itoa(dir->length);
                bytes_wrote = system_call(SYS_WRITE, STDERR, "Length: ", strlen("Length: "));
                bytes_wrote += system_call(SYS_WRITE, STDERR, file_length, strlen(file_length));
                bytes_wrote += system_call(SYS_WRITE, STDERR, "\n", 1);

                print_debug(SYS_WRITE, bytes_wrote);
            }

            if (p == 1)
            {
                int type = buffer[file_pointer + dir->length - 1];
                bytes_wrote = system_call(SYS_WRITE, STDOUT, "Type: ", strlen("Type: "));
                switch (type)
                {
                case 0:
                    bytes_wrote += system_call(SYS_WRITE, STDOUT, "Unknown", strlen("Unknown"));
                    break;
                case 1:
                    bytes_wrote += system_call(SYS_WRITE, STDOUT, "FIFO", strlen("FIFO"));
                    break;
                case 2:
                    bytes_wrote += system_call(SYS_WRITE, STDOUT, "character", strlen("Character"));
                    break;
                case 4:
                    bytes_wrote += system_call(SYS_WRITE, STDOUT, "directory", strlen("directory"));
                    break;
                case 6:
                    bytes_wrote += system_call(SYS_WRITE, STDOUT, "block device", strlen("block device"));
                    break;
                case 8:
                    bytes_wrote += system_call(SYS_WRITE, STDOUT, "regular file", strlen("regular file"));
                    break;
                case 10:
                    bytes_wrote += system_call(SYS_WRITE, STDOUT, "symbolic link", strlen("symbolic link"));
                    break;
                case 12:
                    bytes_wrote += system_call(SYS_WRITE, STDOUT, "UNIX domain socket", strlen("UNIX domain socket"));
                    break;
                case 14:
                    bytes_wrote += system_call(SYS_WRITE, STDOUT, "whiteout inode", strlen("whiteout inode"));
                    break;
                }

                bytes_wrote += system_call(SYS_WRITE, STDOUT, "\n", 1);

                if (debug == 1)
                {
                    print_debug(SYS_WRITE, bytes_wrote);
                }
                bytes_wrote += system_call(SYS_WRITE, STDOUT, "\n", 1);
            }

            if (a == 1)
            {
                infector(dir->name);
            }
        }
        file_pointer += dir->length;
    }

    system_call(6, directory);

    return 0;
}