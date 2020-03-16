#include <stdio.h>

int main(int argc, char **argv)
{

  //char* s = "abc";
  //scanf("%s", s);
  for (int i = 1; i < argc; i++)
  {
    printf("%s ", argv[i]);
  }

  return 0;
}