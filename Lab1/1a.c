#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
	char c;
	while ((c = fgetc(stdin)) != EOF)
	{
		if (c != '\n')
		{
			if (c >= 'a' || c <= 'z')
			{
				c -= 32;
				fprintf(stdout, "%c", c);
			}
		}
	}
}