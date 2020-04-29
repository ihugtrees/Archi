#include "util.h"

#define STDIN 0
#define STDOUT 1
#define SYS_READ 3
#define SYS_WRITE 4
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_LSEEK 19

int main(int argc, char *argv[])
{
	int i, input, filesize = 6;
	char *path = argv[1];
	char *name = argv[2];
	char *size;
    char shira = "Shira";
    char name_from_file[5];

    input = system_call(SYS_OPEN, path, 2, 0777);
	filesize = system_call(SYS_LSEEK, input, 0, 2);
	size = itoa(filesize);
	filesize = system_call(SYS_LSEEK, input, 0, 0);

	system_call(SYS_WRITE, STDOUT, "path: ", 6);
	system_call(SYS_WRITE, STDOUT, path, strlen(path));
	system_call(SYS_WRITE, STDOUT, "\n", 1);

	system_call(SYS_WRITE, STDOUT, "size: ", 6);
	system_call(SYS_WRITE, STDOUT, size, strlen(size));
	system_call(SYS_WRITE, STDOUT, "\n", 1);

    while (system_call(SYS_READ, input, name_from_file, 5) > 0)
    {
        if(strncmp(shira,name_from_file,5) == 0)
        {
            break;
        }
    }

        return 0;
}