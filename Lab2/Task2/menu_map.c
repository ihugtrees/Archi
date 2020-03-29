
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char censor(char c)
{
	if (c == '!')
		return '.';
	else
		return c;
}

char encrypt(char c) /* Gets a char c and returns its encrypted form by adding 3 to its value. If c is not between 0x20 and 0x7E it is returned unchanged */
{
	if (c >= 32 && c <= 126)
		c = c + 3;
	return c;
}

char decrypt(char c) /* Gets a char c and returns its decrypted form by reducing 3 to its value. If c is not between 0x20 and 0x7E it is returned unchanged */
{
	if (c >= 32 && c <= 126)
		c = c - 3;
	return c;
}

char dprt(char c) /* dprt prints the value of c in a decimal representation followed by a  new line, and returns c unchanged. */
{
	printf("%u\n", c);
	return c;
}

char cprt(char c) /* If c is a number between 0x20 and 0x7E, cprt prints the character of ASCII value c followed by a new line. 
                     Otherwise, cprt prints the dot ('.') character. After printing, cprt returns the value of c unchanged. */
{
	if (c >= 32 && c <= 126)
		printf("%c\n", c);
	else
		printf(".\n");
	return c;
}

char my_get(char c) /* Ignores c, reads and returns a character from stdin using fgetc. */
{
	return fgetc(stdin);
}

char *map(char *array, int array_length, char (*f)(char))
{
	char *mapped_array = (char *)(malloc(array_length * sizeof(char)));

	for (int i = 0; i < array_length; i++)
	{
		mapped_array[i] = f(array[i]);
	}

	return mapped_array;
}

char quit(char c) /* Gets a char c, and if the char is 'q', ends the program with exit code 0. Otherwise returns c. */
{
	if (c == 'q')
		exit(0);
	else
		return c;
}

struct fun_desc
{
	char *name;
	char (*fun)(char);
};

int main(int argc, char **argv)
{
	// char arr1[] = {'H', 'E', 'Y', '!'};
	// char *arr2 = map(arr1, 4, censor);
	// printf("%s\n", arr2);
	// free(arr2);

	int base_len = 5;
	char *carray;
	char array[base_len];
	carray = array;
	char userInput[256];
	int userChoise;
	struct fun_desc menu[] = {{"Censor", censor}, {"Encrypt", encrypt}, {"Decrypt", decrypt}, {"Print dec", dprt}, {"Print string", cprt}, {"Get string", my_get}, {"Quit", quit}, {NULL, NULL}};
	int menuLen = sizeof(menu) / sizeof(menu[0]) - 1;

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
				carray = map(carray, base_len, menu[userChoise].fun);
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