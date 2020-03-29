
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

	for (size_t i = 0; i < array_length; i++)
	{
		mapped_array[i] = f(array[i]);
	}

	return mapped_array;
}

int main(int argc, char **argv)
{
	// char arr1[] = {'H', 'E', 'Y', '!'};
	// char *arr2 = map(arr1, 4, censor);
	// printf("%s\n", arr2);
	// free(arr2);

	int base_len = 5;
	char arr1[base_len];
	char *arr2 = map(arr1, base_len, my_get);
	char *arr3 = map(arr2, base_len, encrypt);
	char *arr4 = map(arr3, base_len, dprt);
	char *arr5 = map(arr4, base_len, decrypt);
	char *arr6 = map(arr5, base_len, cprt);
	free(arr2);
	free(arr3);
	free(arr4);
	free(arr5);
	free(arr6);
}