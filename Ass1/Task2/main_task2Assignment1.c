#include <stdio.h>
#include <memory.h>


#define	MAX_LEN 34			/* maximal input string size */
					/* enough to get 32-bit string + '\n' + null terminator */
extern int convertor(char* str);

int main(int argc, char** argv)
{
 while(1)
 {	
  char str[34];
	fgets(str,34,stdin);
	int x;
	sscanf(str,"%d",&x);		/* get user input string */ 
  if(str[0]=='q')
  	break;
  if(str[0]!= 0x0a)
  convertor(str);			/* call your assembly function */
}
  return 0;
}