#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include "LineParser.h"
#include <errno.h>
#include <linux/limits.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>

#define INPUT_MAX 2048

#define TERMINATED -1
#define RUNNING 1
#define SUSPENDED 0

int debug = 0;

typedef struct process
{
	cmdLine *cmd;		  /* the parsed command line*/
	pid_t pid;			  /* the process id that is running the command*/
	int status;			  /* status of the process: RUNNING/SUSPENDED/TERMINATED */
	struct process *next; /* next process in chain */
} process;

typedef struct var
{
	char *x;
	char *y;
	struct var *next;
} var;

process *global_processes = NULL;
var *global_vars = NULL;

void addVar(var **vars, char *x, char *y)
{
	var *curr = *vars;
	while (curr != NULL)
	{
		if (strcmp(curr->x, x) == 0)
		{
			free(curr->y);
			curr->y = strdup(y);
			return;
		}
		curr = curr->next;
	}

	var *new_var = (var *)malloc(sizeof(var));
	new_var->x = strdup(x);
	new_var->y = strdup(y);
	new_var->next = *vars;
	*vars = new_var;
}

void printVars(var **vars)
{
	var *curr = *vars;
	while (curr != NULL)
	{
		printf("x: %s, y: %s\n", curr->x, curr->y);
		curr = curr->next;
	}
}

char *getVarValue(var *vars, char *x)
{
	char *value = NULL;
	var *curr = vars;
	while (curr != NULL)
	{
		if (strcmp(curr->x, x) == 0)
		{
			value = curr->y;
			break;
		}
		curr = curr->next;
	}
	return value;
}

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
		int pid = waitpid(curr->pid, &curr->status, WNOHANG | WUNTRACED | WCONTINUED);
		//printf("PID: %d, Curr PID: %d\n", pid, curr->pid);

		if (pid < 0)
		{
			curr->status = TERMINATED;
			//printf("pid < 0\n");
		}
		//printf("status: %d\n", curr->status);

		if (pid > 0)
		{
			if (WIFSTOPPED(curr->status))
			{
				curr->status = SUSPENDED;
				continue;
				printf("WIFSTOPPED\n");
			}
			else if (WIFCONTINUED(curr->status))
			{
				curr->status = RUNNING;
				continue;
				printf("WIFCONTINUED\n");
			}
			else if (WIFEXITED(curr->status) || WIFSIGNALED(curr->status))
			{
				curr->status = TERMINATED;
				printf("WIFEXITED\n");
			}
		}

		curr = curr->next;
	}
}

void printProcessList(process **process_list)
{
	updateProcessList(process_list);
	process *curr = *process_list, *prev = NULL;
	int idx = 0;
	printf("Index \t PID \t STATUS \t COMMAND \n");
	while (curr != NULL)
	{
		printf("%d \t %d \t", idx, curr->pid);

		if (curr->status == RUNNING)
			printf("RUNNING \t");
		else if (curr->status == SUSPENDED)
			printf("SUSPENDED \t");
		else if (curr->status == TERMINATED)
			printf("TERMINATED \t");

		for (size_t i = 0; i < curr->cmd->argCount; i++)
		{
			printf("%s ", curr->cmd->arguments[i]);
		}
		printf("\n");
		idx++;

		if (curr->status == TERMINATED)
		{
			if (prev == NULL)
			{
				process *temp = curr;
				curr = curr->next;
				*process_list = curr;
				freeCmdLines(temp->cmd);
				free(temp);
			}
			else
			{
				process *temp = curr;
				prev->next = curr->next;
				freeCmdLines(temp->cmd);
				free(temp);
				curr = NULL;
			}
		}
		else
		{
			prev = curr;
			curr = curr->next;
		}
	}
}

void freeProcessList(process *process_list)
{
	while (process_list != NULL)
	{
		process *temp = process_list;
		process_list = process_list->next;
		freeCmdLines(temp->cmd);
		free(temp);
	}
}
void freeVars(var *vars)
{
	while (vars != NULL)
	{
		var *temp = vars;
		vars = vars->next;
		free(temp->x);
		free(temp->y);
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

void replaceCmdlineVars(cmdLine *pCmdLine)
{
	for (size_t i = 0; i < pCmdLine->argCount; i++)
	{
		if (pCmdLine->arguments[i][0] == '$')
		{
			char *toReplace = getVarValue(global_vars, &pCmdLine->arguments[i][1]);
			if (toReplace != NULL)
			{
				replaceCmdArg(pCmdLine, i, toReplace);
			}
			else
			{
				perror("*** Error - Activating a variable that does not exist\n");
				freeCmdLines(pCmdLine);
				exit(1);
			}
		}
	}
}

void startPiping(cmdLine *pCmdLine)
{
	printf("starting to pipe\n");
	
	int tube[2], exec_Code;
	pipe(tube);
	int child1 = fork();

	if (debug == 1)
		fprintf(stderr, "Command: fork pipes 1, Pid: %d\n", child1);

	if (child1 < 0)
	{
		perror("*** Error - fork failed, errno: ");
		fprintf(stderr, "%d\n", errno);
		freeCmdLines(pCmdLine);
		exit(errno);
	}

	replaceCmdlineVars(pCmdLine);
	addProcess(&global_processes, pCmdLine, child1);

	if (child1 == 0)
	{
		int input = -1;

		close(STDOUT_FILENO);
		dup(tube[1]);
		close(tube[1]);

		if (pCmdLine->inputRedirect != NULL)
		{
			input = open(pCmdLine->inputRedirect, O_RDONLY);
			close(STDIN_FILENO);

			if (dup(input) == -1)
			{
				perror("*** Error - dup stdin failed, errno: ");
				fprintf(stderr, "%d\n", errno);
				freeCmdLines(pCmdLine);
				_exit(errno);
			}
		}

		if ((exec_Code = execvp(pCmdLine->arguments[0], pCmdLine->arguments) < 0))
		{
			perror("*** Error - execvp failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(pCmdLine);
			_exit(errno);
		}
	}
	close(tube[1]);

	cmdLine *secondCmdLine = pCmdLine->next;

	int child2 = fork();

	if (debug == 1)
		fprintf(stderr, "Command: fork pipes 1, Pid: %d\n", child2);

	if (child2 < 0)
	{
		perror("*** Error - fork failed, errno: ");
		fprintf(stderr, "%d\n", errno);
		freeCmdLines(secondCmdLine);
		exit(errno);
	}

	replaceCmdlineVars(secondCmdLine);
	addProcess(&global_processes, secondCmdLine, child2);

	if (child2 == 0)
	{
		int output = -1;
		close(STDIN_FILENO);
		dup(tube[0]);
		close(tube[0]);

		if (pCmdLine->outputRedirect != NULL)
		{
			output = open(pCmdLine->outputRedirect, O_CREAT | O_WRONLY, S_IRWXU);
			close(STDOUT_FILENO);

			if (dup(output) == -1)
			{
				perror("*** Error - dup stdout failed, errno: ");
				fprintf(stderr, "%d\n", errno);
				freeCmdLines(pCmdLine);
				_exit(errno);
			}
		}

		if ((exec_Code = execvp(secondCmdLine->arguments[0], secondCmdLine->arguments) < 0))
		{
			perror("*** Error - execvp failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(secondCmdLine);
			_exit(errno);
		}
	}
	close(tube[0]);
	waitpid(child1, NULL, 0);
	waitpid(child2, NULL, 0);
}

void execute(cmdLine *pCmdLine)
{
	if (strcmp(pCmdLine->arguments[0], "quit") == 0)
	{
		freeCmdLines(pCmdLine);
		freeVars(global_vars);
		freeProcessList(global_processes);
		exit(0);
	}

	if (strcmp(pCmdLine->arguments[0], "cd") == 0)
	{
		if (debug == 1)
			fprintf(stderr, "Command: cd\n");

		if (pCmdLine->arguments[1][0] == '~')
		{
			char *homePath = getenv("HOME");
			if (homePath != NULL)
				replaceCmdArg(pCmdLine, 1, homePath);
			else
			{
				perror("*** Error - getenv = home \n");
				freeCmdLines(pCmdLine);
				exit(1);
			}
		}

		if (chdir(pCmdLine->arguments[1]) < 0)
		{
			perror("*** Error - chdir failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(pCmdLine);
			exit(errno);
		}
		freeCmdLines(pCmdLine);
	}
	else if (strcmp(pCmdLine->arguments[0], "procs") == 0)
	{
		if (debug == 1)
			fprintf(stderr, "Command: procs\n");

		printProcessList(&global_processes);
		freeCmdLines(pCmdLine);
	}
	else if (strcmp(pCmdLine->arguments[0], "suspend") == 0)
	{
		if (debug == 1)
			fprintf(stderr, "Command: suspend\n");

		int pid = strtol(pCmdLine->arguments[1], NULL, 10);

		if (kill(pid, SIGTSTP) < 0)
		{
			perror("*** Error - kill - suspend failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(pCmdLine);
			exit(errno);
		}
		freeCmdLines(pCmdLine);
	}
	else if (strcmp(pCmdLine->arguments[0], "kill") == 0)
	{
		if (debug == 1)
			fprintf(stderr, "Command: kill\n");

		int pid = strtol(pCmdLine->arguments[1], NULL, 10);

		if (kill(pid, SIGINT) < 0)
		{
			perror("*** Error - kill - kill failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(pCmdLine);
			exit(errno);
		}
		freeCmdLines(pCmdLine);
	}
	else if (strcmp(pCmdLine->arguments[0], "wake") == 0)
	{
		if (debug == 1)
			fprintf(stderr, "Command: wake\n");

		int pid = strtol(pCmdLine->arguments[1], NULL, 10);

		if (kill(pid, SIGCONT) < 0)
		{
			perror("*** Error - kill - wake failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(pCmdLine);
			exit(errno);
		}
		freeCmdLines(pCmdLine);
	}
	else if (strcmp(pCmdLine->arguments[0], "set") == 0)
	{
		if (debug == 1)
			fprintf(stderr, "Command: set\n");

		addVar(&global_vars, pCmdLine->arguments[1], pCmdLine->arguments[2]);
		freeCmdLines(pCmdLine);
	}
	else if (strcmp(pCmdLine->arguments[0], "vars") == 0)
	{
		if (debug == 1)
			fprintf(stderr, "Command: vars\n");

		printVars(&global_vars);
		freeCmdLines(pCmdLine);
	}
	else if (pCmdLine->next != NULL)
	{
		startPiping(pCmdLine);		
	}
	else
	{
		int pid = fork(), exec_Code;

		if (debug == 1)
			fprintf(stderr, "Command: fork without pipes, Pid: %d\n", pid);

		if (pid < 0)
		{
			perror("*** Error - fork failed, errno: ");
			fprintf(stderr, "%d\n", errno);
			freeCmdLines(pCmdLine);
			exit(errno);
		}

		replaceCmdlineVars(pCmdLine);
		addProcess(&global_processes, pCmdLine, pid);

		if (pid == 0)
		{
			int input, output = -1;

			if (pCmdLine->inputRedirect != NULL)
			{
				input = open(pCmdLine->inputRedirect, O_RDONLY);
				close(STDIN_FILENO);

				if (dup(input) == -1)
				{
					perror("*** Error - dup stdin failed, errno: ");
					fprintf(stderr, "%d\n", errno);
					freeCmdLines(pCmdLine);
					_exit(errno);
				}
			}

			if (pCmdLine->outputRedirect != NULL)
			{
				output = open(pCmdLine->outputRedirect, O_CREAT | O_WRONLY, S_IRWXU);
				close(STDOUT_FILENO);

				if (dup(output) == -1)
				{
					perror("*** Error - dup stdout failed, errno: ");
					fprintf(stderr, "%d\n", errno);
					freeCmdLines(pCmdLine);
					_exit(errno);
				}
			}

			if (debug == 1)
				fprintf(stderr, "Command: execvp\n");

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

			if (waitpid(pid, 0, 0) < 0)
			{
				perror("*** Error - waitpid failed, errno: ");
				fprintf(stderr, "%d\n", errno);
				freeCmdLines(pCmdLine);
				exit(errno);
			}
		}
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