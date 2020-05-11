#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>

void sighandler(int signum)
{
    printf("Looper handling %s\n", strsignal(signum));
    signal(signum, SIG_DFL);
    raise(signum);
}

int main(int argc, char **argv)
{
    printf("Starting the program\n");
    signal(SIGINT, sighandler);
    signal(SIGCONT, sighandler);
    signal(SIGTSTP, sighandler);

    while (1)
    {
        printf("loop\n");
        sleep(4);
    }

    return 0;
}