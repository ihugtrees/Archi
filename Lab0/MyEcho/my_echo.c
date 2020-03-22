#include <stdio.h>

int main(int argc, char **argv)
{
  for (int i = 1; i < argc; i++)
  {
    fprintf(stdout, "%s ", argv[i]);
  }
  fprintf(stdout, "%c", '\n');

  return 0;
}