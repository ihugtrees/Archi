#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <elf.h>
 #include <sys/types.h>
       #include <sys/stat.h>
       #include <unistd.h>
#define MAX_LENGTH 128


struct fun_desc {
    char *name;
    void (*fun)();
};
int debugMode = 0;

void toggle_debug_mode() {
    if(debugMode ==0){
        debugMode =1;
    }else
    {
        debugMode = 0;
    }
    
}
char * fileName;
void print_sections(){
     //code from course website
    int Currentfd;
   void *map_start; /* will point to the start of the memory mapped file */
   struct stat fd_stat; /* this is needed to  the size of the file */
   Elf32_Ehdr *header; /* this will point to the header structure */
   int num_of_section_headers;
  
   if( (Currentfd = open(fileName, O_RDWR)) < 0 ) {
      perror("error in open");
      exit(-1);
   }

   if( fstat(Currentfd, &fd_stat) != 0 ) {
      perror("stat failed");
      exit(-1);
   }

   if ( (map_start = mmap(0, fd_stat.st_size, PROT_READ | PROT_WRITE , MAP_SHARED, Currentfd, 0)) == MAP_FAILED ) {
      perror("mmap failed");
      exit(-4);
   }

   /* now, the file is mapped starting at map_start.
    * all we need to do is tell *header to point at the same address:
    */

   header = (Elf32_Ehdr *) map_start;
   /* now we can do whatever we want with header!!!!
    * for example, the number of section header can be obtained like this:
    */
   Elf32_Shdr* sh = (Elf32_Shdr*) (map_start + header->e_shoff);
    Elf32_Shdr* strHeader = &sh[header->e_shstrndx]; 
    char* str = (char*) (map_start + strHeader->sh_offset);  
    fprintf(stdout,"section\n");
    for(int i=0;i<header->e_shnum;i++){
        fprintf(stdout,"%d\t%s\t%x\t%x\t%x\t%d\n",i,&str[sh[i].sh_name],sh[i].sh_addr,sh[i].sh_offset,sh[i].sh_size,sh[i].sh_type);
    }

   munmap(map_start, fd_stat.st_size);
}
void examine_elf(){
    //code from course website
       int Currentfd;
       
   void *map_start; /* will point to the start of the memory mapped file */
   struct stat fd_stat; /* this is needed to  the size of the file */
   Elf32_Ehdr *header; /* this will point to the header structure */
   int num_of_section_headers;
  
   if( (Currentfd = open(fileName, O_RDWR)) < 0 ) {
      perror("error in open");
      exit(-1);
   }

   if( fstat(Currentfd, &fd_stat) != 0 ) {
      perror("stat failed");
      exit(-1);
   }

   if ( (map_start = mmap(0, fd_stat.st_size, PROT_READ | PROT_WRITE , MAP_SHARED, Currentfd, 0)) == MAP_FAILED ) {
      perror("mmap failed");
      exit(-4);
   }

   /* now, the file is mapped starting at map_start.
    * all we need to do is tell *header to point at the same address:
    */

   header = (Elf32_Ehdr *) map_start;
   /* now we can do whatever we want with header!!!!
    * for example, the number of section header can be obtained like this:
    */
   num_of_section_headers = header->e_shnum;
   fprintf(stdout,"%#x\n",header->e_entry);
   fprintf(stdout,"%x %x %x\n",header->e_ident[0],header->e_ident[1],header->e_ident[2]);
    fprintf(stdout,"%d\n",header->e_shoff);
      fprintf(stdout,"%d\n",header->e_shnum);
        fprintf(stdout,"%d\n",header->e_shentsize);
          fprintf(stdout,"%d\n",header->e_phoff);
           fprintf(stdout,"%d\n",header->e_phnum);
            fprintf(stdout,"%d\n",header->e_phentsize);
   /* now, we unmap the file */
   munmap(map_start, fd_stat.st_size);


}
void print_symbols(){
    //code from course website
       int Currentfd;
       
   void *map_start; /* will point to the start of the memory mapped file */
   struct stat fd_stat; /* this is needed to  the size of the file */
   Elf32_Ehdr *header; /* this will point to the header structure */
   int num_of_section_headers;
  
   if( (Currentfd = open(fileName, O_RDWR)) < 0 ) {
      perror("error in open");
      exit(-1);
   }

   if( fstat(Currentfd, &fd_stat) != 0 ) {
      perror("stat failed");
      exit(-1);
   }

   if ( (map_start = mmap(0, fd_stat.st_size, PROT_READ | PROT_WRITE , MAP_SHARED, Currentfd, 0)) == MAP_FAILED ) {
      perror("mmap failed");
      exit(-4);
   }

   /* now, the file is mapped starting at map_start.
    * all we need to do is tell *header to point at the same address:
    */

   header = (Elf32_Ehdr *) map_start;
   /* now we can do whatever we want with header!!!!
    * for example, the number of section header can be obtained like this:
    */
   
    Elf32_Shdr* sh = (Elf32_Shdr*) (map_start + header->e_shoff);
    Elf32_Shdr* strHeader = &sh[header->e_shstrndx]; 
    char* str = (char*) (map_start + strHeader->sh_offset);  
    for (size_t i = 0; i < header->e_shnum; i++){
        if(sh[i].sh_type == SHT_DYNSYM || sh[i].sh_type == SHT_SYMTAB){
           Elf32_Shdr*  symSh = (sh + i);
           char * symStr = (char*)(map_start + sh[i+1].sh_offset);
            Elf32_Sym* sym = (Elf32_Sym* ) (map_start+symSh->sh_offset);
            fprintf(stdout,"%s\n",&str[sh[i].sh_name]);
            for(int j=0;j<symSh->sh_size/sizeof(Elf32_Sym);j++){
                if(sym[j].st_shndx<=header->e_shnum){
                     fprintf(stdout,"%d:\t%x\t%d\t%s\t%s\n",j,sym[j].st_value,sym[j].st_shndx,&str[sh[sym[j].st_shndx].sh_name],&symStr[sym[j].st_name]);
                }else{
                    fprintf(stdout,"%d:\t%x\t%d\t%s\t%s\n",j,sym[j].st_value,sym[j].st_shndx,"NULL",&symStr[sym[j].st_name]);
                }
            }
        }
        
            
        
    }

}
void quit(){
    exit(0);
}
int main(int argc, char **argv){
    
    if(argc>=1){
    fileName = argv[1];
    }else{
        fprintf(stdout,"no file name");
        exit(-1);
    }
    char input [MAX_LENGTH];
    struct fun_desc menu[] = { { "Toggle Debug Mode",toggle_debug_mode}, { "Examine ELF File",examine_elf},{"Print Section Names",print_sections},{"Print Symbols",print_symbols},{ "Quit", quit}, {NULL,NULL} };
    int size= sizeof(menu)/(sizeof(*menu));
    int i=0;
    

    while(1) {
        
        printf("Please choose a function:\n");
        while (menu[i].name!=NULL && menu[i].fun!=NULL) {
            printf("%d) %s\n",i,menu[i].name);
            i++;
        }
        printf("Option: ");
        fgets(input, MAX_LENGTH, stdin);
        int char_= atoi(input);
        if (char_>=0 && char_<= size-2){
            printf("Within bounds\n");
            menu[char_].fun();
            printf("DONE.\n");
            
        }
        else{
            
        }
        i=0;
    }
}
