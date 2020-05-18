#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

int main(int argc, char *argv[])
{
	int debug = 0;
	for (int i = 0; i < argc; i++)
		if (strcmp(argv[i], "-d") == 0)
			debug = 1;

	int tube[2];
	pipe(tube);

	if (debug == 1)
		fprintf(stderr, "parent_process>forking...\n");

	int child1 = fork();

	if (debug == 1 && child1 != 0)
		fprintf(stderr, "parent_process>created process with id: %d\n", child1);

	if (child1 == 0)
	{
		if (debug == 1)
			fprintf(stderr, "child1>redirecting stdout to the write end of the pipe…\n");

		close(STDOUT_FILENO);
		dup(tube[1]);
		close(tube[1]);
		char *ls[3];
		ls[0] = "ls";
		ls[1] = "-l";
		ls[2] = NULL;

		if (debug == 1)
			fprintf(stderr, "child1>going to execute cmd: …\n");

		execvp(ls[0], ls);
	}

	if (debug == 1)
		fprintf(stderr, "parent_process>closing the write end of the pipe…\n");

	close(tube[1]);

	int child2 = fork();
	if (debug == 1 && child2 != 0)
		fprintf(stderr, "parent_process>created process with id: %d\n", child2);

	if (child2 == 0)
	{
		if (debug == 1)
			fprintf(stderr, "child2>redirecting stdin to the read end of the pipe…\n");

		close(STDIN_FILENO);
		dup(tube[0]);
		close(tube[0]);
		char *tail[4];
		tail[0] = "tail";
		tail[1] = "-n";
		tail[2] = "2";
		tail[3] = NULL;

		if (debug == 1)
			fprintf(stderr, "child2>going to execute cmd: …\n");

		execvp(tail[0], tail);
	}

	if (debug == 1)
		fprintf(stderr, "parent_process>closing the read end of the pipe…\n");

	close(tube[1]);

	if (debug == 1)
		fprintf(stderr, "parent_process>waiting for child processes to terminate…\n");

	waitpid(child1, NULL, 0);
	waitpid(child2, NULL, 0);

	if (debug == 1)
		fprintf(stderr, "parent_process>exiting…\n");

	exit(0);
}