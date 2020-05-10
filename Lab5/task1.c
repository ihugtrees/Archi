#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <linux/limits.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include "LineParser.h"
#include <errno.h>

#define INPUT_MAX 2048

int debug = 0;

void execute(cmdLine *pCmdLine)
{
	if (strncmp(pCmdLine->arguments[0], "quit", 4) == 0)
	{
		freeCmdLines(pCmdLine);
		exit(0);
	}

	if (strncmp(pCmdLine->arguments[0], "cd", 2) == 0)
	{
		if (chdir(pCmdLine->arguments[1]) < 0)
		{
			perror("*** Error - chdir failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(pCmdLine);
			exit(errno);
		}
		freeCmdLines(pCmdLine);
	}
	else
	{
		int pid = fork(), exec_Code;

		if (debug == 1)
			fprintf(stderr, "Command: fork, Pid: %d\n", pid);

		if (pid == 0)
		{
			if (debug == 1)
				fprintf(stderr, "Command: execvp, Pid: %d\n", pid);

			if ((exec_Code = execvp(pCmdLine->arguments[0], pCmdLine->arguments) < 0))
			{
				perror("*** Error - execvp failed, errno: ");
				fprintf(stderr, "%d\n", errno);
				freeCmdLines(pCmdLine);
				_exit(errno);
			}
		}

		if (pid < 0)
		{
			perror("*** Error - fork failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(pCmdLine);
			exit(errno);
		}

		if (pCmdLine->blocking == 1)
		{
			if (debug == 1)
				fprintf(stderr, "Command: waitpid, Pid: %d\n", pid);

			if (waitpid(pid, NULL, 0) < 0)
			{
				perror("*** Error - waitpid failed, errno: ");
				fprintf(stderr, "%d\n", errno);
				freeCmdLines(pCmdLine);
				exit(errno);
			}
		}
		freeCmdLines(pCmdLine);
	}
}

int main(int argc, char **argv)
{
	char path[PATH_MAX], user_input[INPUT_MAX];

	for (int i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "-d") == 0)
		{
			debug = 1;
		}
	}

	while (1)
	{
		getcwd(path, PATH_MAX);
		printf("Path: %s\n", path);

		if (fgets(user_input, INPUT_MAX, stdin) != NULL)
		{
			execute(parseCmdLines(user_input));
		}
	}
}