#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>

void sighandler(int signum)
{
    printf("Looper handling %s\n", strsignal(signum));
    raise(signum);
}

int main(int argc, char **argv)
{

    printf("Starting the program\n");
    signal(SIGCONT, sighandler);
    signal(SIGINT, sighandler);
    signal(SIGTSTP, sighandler);

    while (1)
    {
        sleep(2);
    }

    return 0;
}