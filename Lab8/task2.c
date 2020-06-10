#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <elf.h>
#include <sys/stat.h>

#define MAX_LENGTH 128

int debugMode = 0;
char fileName[MAX_LENGTH];

int Currentfd = -1;
void *map_start;
struct stat fd_stat;
Elf32_Ehdr *header;

struct fun_desc
{
    char *name;
    void (*fun)();
};

void toggle_debug_mode()
{
    if (debugMode == 0)
    {
        debugMode = 1;
    }
    else
    {
        debugMode = 0;
    }
}

void print_sections()
{
    if (Currentfd < 0)
    {
        fprintf(stderr, "No opened file");
        return;
    }

    Elf32_Shdr *sh = (Elf32_Shdr *)(map_start + header->e_shoff);
    Elf32_Shdr *strHeader = &sh[header->e_shstrndx];

    char *str = (char *)(map_start + strHeader->sh_offset);

    for (int i = 0; i < header->e_shnum; i++)
    {
        fprintf(stdout, "[%d] %s %x %x %x %d\n", i, &str[sh[i].sh_name], sh[i].sh_addr, sh[i].sh_offset, sh[i].sh_size, sh[i].sh_type);
    }
}

void examine_elf()
{
    if (Currentfd >= 0)
    {
        munmap(map_start, fd_stat.st_size);
        close(Currentfd);
    }

    printf("Enter filename: ");
    fgets(fileName, MAX_LENGTH, stdin);
    fileName[strlen(fileName) - 1] = 0;

    if ((Currentfd = open(fileName, O_RDWR)) < 0)
    {
        perror("error in file open");
        Currentfd = -1;
        return;
    }

    if (fstat(Currentfd, &fd_stat) != 0)
    {
        perror("stat failed");
        Currentfd = -1;
        return;
    }

    if ((map_start = mmap(0, fd_stat.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, Currentfd, 0)) == MAP_FAILED)
    {
        perror("mmap failed");
        Currentfd = -1;
        return;
    }

    header = (Elf32_Ehdr *)map_start;

    fprintf(stdout, "3 Magic Numbers: %x %x %x\n", header->e_ident[0], header->e_ident[1], header->e_ident[2]);
    fprintf(stdout, "Data encoding scheme: %d\n", header->e_type);
    fprintf(stdout, "Entry point: %#x\n", header->e_entry);
    fprintf(stdout, "Section header table file offset: %d\n", header->e_shoff);
    fprintf(stdout, "Section header table entry count: %d\n", header->e_shnum);
    fprintf(stdout, "Section header table entry size: %d\n", header->e_shentsize);
    fprintf(stdout, "Program header table file offset: %d\n", header->e_phoff);
    fprintf(stdout, "Program header table entry count: %d\n", header->e_phnum);
    fprintf(stdout, "Program header table entry size: %d\n", header->e_phentsize);
}

void print_symbols()
{
    if (Currentfd < 0)
    {
        fprintf(stderr, "No opened file");
        return;
    }

    Elf32_Shdr *sh = (Elf32_Shdr *)(map_start + header->e_shoff);
    Elf32_Shdr *strHeader = &sh[header->e_shstrndx];
    char *str = (char *)(map_start + strHeader->sh_offset);

    for (size_t i = 0; i < header->e_shnum; i++)
    {
        if (sh[i].sh_type == SHT_DYNSYM || sh[i].sh_type == SHT_SYMTAB)
        {
            Elf32_Shdr *symSh = (sh + i);
            char *symStr = (char *)(map_start + sh[i + 1].sh_offset);
            Elf32_Sym *sym = (Elf32_Sym *)(map_start + symSh->sh_offset);

            fprintf(stdout, "Symbol table: %s\n", &str[sh[i].sh_name]);

            for (int j = 0; j < symSh->sh_size / sizeof(Elf32_Sym); j++)
            {
                if (sym[j].st_shndx <= header->e_shnum)
                {
                    fprintf(stdout, "[%d] %x %d %s %s\n", j, sym[j].st_value, sym[j].st_shndx, &str[sh[sym[j].st_shndx].sh_name], &symStr[sym[j].st_name]);
                }
                else
                {
                    fprintf(stdout, "[%d] %x %d %s %s\n", j, sym[j].st_value, sym[j].st_shndx, "NULL", &symStr[sym[j].st_name]);
                }
            }
        }
    }
}

void quit()
{
    if (Currentfd >= 0)
    {
        munmap(map_start, fd_stat.st_size);
        close(Currentfd);
    }
    exit(0);
}

int main(int argc, char **argv)
{
    char input[MAX_LENGTH];
    struct fun_desc menu[] = {{"Toggle Debug Mode", toggle_debug_mode},
                              {"Examine ELF File", examine_elf},
                              {"Print Section Names", print_sections},
                              {"Print Symbols", print_symbols},
                              {"Quit", quit},
                              {NULL, NULL}};

    int menuSize = sizeof(menu) / (sizeof(*menu)) - 1;
    printf("menusize: %d", menuSize);

    while (1)
    {
        printf("Choose action:\n");
        for (size_t i = 0; i < menuSize; i++)
        {
            printf("%d-%s\n", i, menu[i].name);
        }
        printf("Option: ");
        fgets(input, MAX_LENGTH, stdin);
        int choise = strtol(input, NULL, 10);
        if (choise >= 0 && choise < menuSize)
        {
            printf("\n");
            menu[choise].fun();
            printf("\n");
        }
    }
}