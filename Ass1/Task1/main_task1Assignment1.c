#include <stdio.h>
#include <string.h>
#include <stdlib.h>		
extern int assFunc(int x,int y);

int main()
{
	char xstr[64];
	fgets(xstr,64,stdin);
	int x;
	sscanf(xstr,"%d",&x);
	
	char ystr[64];
	fgets(ystr,64,stdin);
	int y;
	sscanf(ystr,"%d",&y);
	assFunc(x,y);


    return 0;
}
char c_checkValidity(int x,int y)
{
	if(x<y)
		return '0';
	return '1';
}
