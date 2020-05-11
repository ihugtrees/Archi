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

#define TERMINATED -1
#define RUNNING 1
#define SUSPENDED 0

int debug = 0;

typedef struct process
{
	cmdLine *cmd;         /* the parsed command line*/
	pid_t pid;            /* the process id that is running the command*/
	int status;           /* status of the process: RUNNING/SUSPENDED/TERMINATED */
	struct process *next; /* next process in chain */
} process;

process *global_processes;

void addProcess(process **process_list, cmdLine *cmd, pid_t pid)
{
	process *new_process = (process *)malloc(sizeof(process));
	new_process->cmd = cmd;
	new_process->pid = pid;
	new_process->status = RUNNING;
	new_process->next = *process_list;
	*process_list = new_process;
}

void updateProcessList(process **process_list)
{
	process *curr = *process_list;
	while (curr != NULL)
	{
		int pid = waitpid(curr->pid, &curr->status, WNOHANG);

		if (pid == -1)
			curr->status = TERMINATED;
		else if (WIFCONTINUED(curr->status) > 0)
			curr->status = RUNNING;
		else if (WIFSTOPPED(curr->status) > 0)
			curr->status = SUSPENDED;

		curr = curr->next;
	}
}

void printProcessList(process **process_list)
{
	updateProcessList(process_list);
	int index = 0;
	process *curr = *process_list, *prev = NULL;
	printf("Index\tPID\tSTATUS\tCOMMAND\n");
	while (curr != NULL)
	{
		printf("%d\t%d\t", index, curr->pid);
		switch (curr->status)
		{
		case RUNNING:
			printf("RUNNING\t");
			break;

		case SUSPENDED:
			printf("SUSPENDED\t");
			break;

		case TERMINATED:
			printf("TERMINATED\t");
			break;
		}

		for (size_t i = 0; i < curr->cmd->argCount; i++)
		{
			printf("%s ", curr->cmd->arguments[i]);
		}
		printf("\n");

		if (curr->status == TERMINATED)
		{
			if (prev == NULL)
			{
				freeCmdLines(curr->cmd);
				process *temp = curr;
				curr = curr->next;
				free(temp);
			}
			else
			{
				freeCmdLines(curr->cmd);
				process *temp = curr;
				prev->next = curr->next;
				free(temp);
			}
		}
		prev = curr;
		curr = curr->next;
	}
}

void freeProcessList(process *process_list)
{
	while (process_list != NULL)
	{
		process *temp = process_list;
		freeCmdLines(process_list);
		process_list = process_list->next;
		free(temp);
	}
}

void updateProcessStatus(process *process_list, int pid, int status)
{
	while (process_list != NULL)
	{
		if (process_list->pid == pid)
		{
			process_list->status = status;
			break;
		}
		process_list = process_list->next;
	}
}

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
	else if (strncmp(pCmdLine->arguments[0], "proc", 4) == 0)
	{
		printProcessList(&global_processes);
		freeCmdLines(pCmdLine);
	}
	else
	{
		int pid = fork(), exec_Code;

		if (debug == 1)
			fprintf(stderr, "Command: fork, Pid: %d\n", pid);

		if (pid < 0)
		{
			perror("*** Error - fork failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(pCmdLine);
			exit(errno);
		}
		
		addProcess(&global_processes, pCmdLine, pid);

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
		else if (pCmdLine->blocking == 1)
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