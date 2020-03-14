#include <stdio.h>

int main(int argc, char **argv)
{

  int i = 0;
  //fgets(str_buf, MAX_LEN, stdin);	/* get user input string */
  for (i = 1; i < argc; i++)
  {
    printf("%s ", argv[i]);
  }

  return 0;
}