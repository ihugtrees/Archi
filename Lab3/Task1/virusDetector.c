#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct virus
{
	unsigned short SigSize;
	char virusName[16];
	unsigned char *sig;
} virus;

typedef struct link link;

struct link
{
	link *nextVirus;
	virus *vir;
};

struct fun_desc
{
	char *name;
	void (*fun)();
};

link *global_virus_list = NULL;

void printVirus(virus *virus, FILE *output)
{
	fprintf(output, "Virus name: %s\nVirus size: %u\nsignature:\n", virus->virusName, virus->SigSize);
	for (int i = 0; i < virus->SigSize; i++)
		printf("%02hhX ", virus->sig[i]);
	printf("\n");
	printf("\n");
}

void list_print(link *virus_list, FILE *output)
/* Print the data of every link in list to the given stream. Each item followed by a newline character. */
{
	if (virus_list != NULL && virus_list->vir != NULL && output != NULL)
	{
		link *temp = virus_list;
		printVirus(temp->vir, output);
		while (temp->nextVirus != NULL)
		{
			temp = temp->nextVirus;
			printVirus(temp->vir, output);
		}
	}
	else
	{
		printf("Error in print");
	}
}

link *list_append(link *virus_list, virus *data)
/* Add a new link with the given data to the list 
        (either at the end or the beginning, depending on what your TA tells you),
        and return a pointer to the list (i.e., the first link in the list).
        If the list is null - create a new entry and return a pointer to the entry. */
{
	link *new_link = (link *)malloc(sizeof(link));
	new_link->vir = data;
	new_link->nextVirus = NULL;

	if (virus_list == NULL)
		return new_link;

	else
	{
		new_link->nextVirus = virus_list;
		return new_link;
	}
}
void list_free(link *virus_list) /* Free the memory allocated by the list. */
{
	if (virus_list != NULL)
	{
		if (virus_list->nextVirus != NULL)
			list_free(virus_list->nextVirus);
		if (virus_list->vir != NULL)
			free(virus_list->vir);
		free(virus_list);
	}
}

virus *readVirus(FILE *input)
{
	virus *vir = (virus *)malloc(sizeof(virus));
	if (fread(&vir->SigSize, 2, 1, input) > 0)
	{
		fread(vir->virusName, 16, 1, input);
		vir->sig = (unsigned char *)malloc(vir->SigSize * sizeof(unsigned char));
		fread(vir->sig, vir->SigSize, 1, input);
		return vir;
	}
	return NULL;
}

void load_signatures()
{
	char path[256];
	printf("Enter path or filename for virus signatures: ");
	fgets(path, 256, stdin);
	path[strlen(path) - 1] = '\0';
	printf("Path: %s\n", path);
	FILE *viruses = fopen(path, "r");
	if (viruses != NULL)
	{
		virus *vir;
		while ((vir = readVirus(viruses)) != NULL)
		{
			global_virus_list = list_append(global_virus_list, vir);
		}
		fclose(viruses);
	}
	else
	{
		printf("Bad Path\n");
	}
}

void detect_virus(char *buffer, unsigned int size, link *virus_list)
{
	link *current_virus = virus_list;
	while (current_virus != NULL)
	{
		int sig_size = current_virus->vir->SigSize;
		unsigned char *sig = current_virus->vir->sig;
		for (short i = 0; i < size; i++)
		{
			if (memcmp(buffer + i, sig, sig_size) == 0)
			{
				printf("Starting byte: %u\n", i);
				printf("Virus name: %s\n", current_virus->vir->virusName);
				printf("Signature size: %u\n\n", sig_size);
			}
		}
		current_virus = current_virus->nextVirus;
	}
}

void detect_viruses()
{
	const unsigned short file_size = 10000;
	char buffer[file_size];
	char path[256];
	printf("Enter path or filename for suspected file: ");
	fgets(path, 256, stdin);
	path[strlen(path) - 1] = '\0';
	printf("Path: %s\n", path);

	FILE *suspect = fopen(path, "r");
	if (suspect != NULL)
	{
		fseek(suspect, 0, SEEK_END);
		unsigned short size = ftell(suspect);
		fseek(suspect, 0, SEEK_SET);

		fread(buffer, 1, size, suspect);

		detect_virus(buffer, size, global_virus_list);
		fclose(suspect);
	}
	else
	{
		printf("Bad Path\n");
	}
}

void print_signatures()
{
	list_print(global_virus_list, stdout);
}

void quit()
{
	list_free(global_virus_list);
	printf("Exiting safely\n");
	exit(0);
}

int main(int argc, char **argv)
{
	struct fun_desc menu[] = {{"Load signatures", load_signatures}, {"Print signatures", print_signatures}, {"Detect viruses", detect_viruses}, {"Quit", quit}, {NULL, NULL}};
	int menuLen = sizeof(menu) / sizeof(menu[0]) - 1;
	char userInput[256];
	int userChoise;

	while (1)
	{
		printf("Please choose a function:\n");
		for (int i = 0; i < menuLen; i++)
			printf("%d) %s\n", i, menu[i].name);

		printf("Option: ");
		if (fgets(userInput, 256, stdin) != NULL)
		{
			sscanf(userInput, "%d", &userChoise);
			if (userChoise <= menuLen - 1 && userChoise >= 0)
			{
				printf("Within bounds\n");
				menu[userChoise].fun();
			}
			else
			{
				printf("Not within bounds\n");
				exit(0);
			}
			printf("DONE.\n\n");
		}
	}
}