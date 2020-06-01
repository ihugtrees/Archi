#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_LEN 128

char user_input[MAX_LEN];

typedef struct
{
    char debug_mode;
    char file_name[128];
    int unit_size;
    unsigned char mem_buf[10000];
    size_t mem_count;
    int display_mode;
} state;

struct menu
{
    char *name;
    void (*fun)(state *s);
} menu;

void toggle_debug_mode(state *s)
{
    if (s->debug_mode == '0')
    {
        s->debug_mode = '1';
        printf("Debug flag now on\n");
    }
    else
    {
        s->debug_mode = '0';
        printf("Debug flag now off\n");
    }
}

void set_file_name(state *s)
{
    printf("New file name:\n");
    fgets(s->file_name, 128, stdin);
    s->file_name[strlen(s->file_name) - 1] = '\0';
    if (s->debug_mode == '1')
        printf("Debug: file name set to %s\n", s->file_name);
}

void set_unit_size(state *s)
{
    printf("New unite size:\n");
    fgets(user_input, 128, stdin);
    int unit_size = strtol(NULL, user_input, 10);
    if (unit_size == 1 || unit_size == 2 || unit_size == 4)
    {
        s->unit_size = unit_size;
        if (s->debug_mode == '1')
        {
            printf("Debug: set size to %d\n", s->unit_size);
        }
    }
    else
    {
        printf("Only 1,2,4\n");
    }
}

void quit(state *s)
{

    if (s->debug_mode == '1')
        printf("quitting\n");
    exit(0);
}

void toggle_display_mode(state *s)
{
    if (s->display_mode == 0)
    {
        s->display_mode = 1;
        printf("Display flag now on, hexadecimal representation\n");
    }
    else
    {
        s->display_mode = 0;
        printf("Display flag now on, decimal representation\n");
    }
}

void printState(state *s)
{
    printf("unit_size: %d \nfile_name: %s mem_count: %d\n", s->unit_size, s->file_name, s->mem_count);
}

char *unit_to_format(int unit)
{
    static char *formats[] = {"%hhd\t%hhX\n", "%hd\t%hX\n", "No such unit", "%d\t%X\n"};
    return formats[unit - 1];
}

void memory_display(state *s)
{
    char *tmp = (char *)s->mem_buf;
    char *end = tmp + s->unit_size * s->mem_count;
    printf("Enter address and length\n");
    while (tmp < end)
    {
        int var = *((int *)(tmp));
        fprintf(stdout, unit_to_format(s->unit_size), var, var);
        tmp += s->unit_size;
    }
}

void fileModify(state *s)
{
    fprintf(stdout, "Please enter <location> <val>\n");
    char buf[128];
    int location;
    int val;

    fgets(buf, 128, stdin);
    sscanf(buf, "%x %x", &location, &val);
    FILE *file = fopen(s->file_name, "r+");
    fseek(file, location, SEEK_SET);

    fwrite(&val, s->unit_size, 1, file);
    fclose(file);
}

void saveIntoFile(state *s)
{
    fprintf(stdout, "Please enter <source-address> <target-location> <length>\n");
    char buf[128];
    int source;
    int target;
    int length;

    fgets(buf, 128, stdin);
    sscanf(buf, "%x %x %d", &source, &target, &length);
    FILE *file = fopen(s->file_name, "r+");
    if (source == 0)
    {
        source = (int)s->mem_buf;
    }
    fseek(file, target, SEEK_SET);
    unsigned char *sourcePtr = (unsigned char *)source;
    fwrite(sourcePtr, s->unit_size, length, file);
    fclose(file);
}

void load_into_memory(state *s)
{
    int location;
    int length;
    if (strcmp(s->file_name, ""))
    {
        fprintf(stderr, "File name can't be empty\n");
        return;
    }
    FILE *file = fopen(s->file_name, "r+");
    if (file == NULL)
    {
        fprintf(stderr, "file don't exist\n");
        return;
    }

    printf("Please enter <location> <length>\n");
    fgets(user_input, 128, stdin);
    sscanf(user_input, "%x %d", &location, &length);

    if (s->debug_mode == 1)
    {
        printf("file_name: %s, location: %x, length: %d");
    }

    fseek(file, location, SEEK_SET);
    fread(s->mem_buf, s->unit_size, length, file);
    s->mem_count = length;
    printf("Loaded %d units into memory", length);
    fclose(file);
}

int main(int argc, char **argv)
{
    struct menu menu[] = {{"Toggle Debug Mode", toggle_debug_mode},
                          {"Set File Name", set_file_name},
                          {"Set Unit Size", set_unit_size},
                          {"Load Into Memory", load_into_memory},
                          {"Toggle Display Mode", toggle_display_mode},
                          {"Memory Display", memory_display},
                          {"Save Into File", saveIntoFile},
                          {"File Modify", fileModify},
                          {"Quit", quit},
                          {NULL, NULL}};
    int menuLen = sizeof(menu) / sizeof(menu[0]) - 1;
    state *stat = malloc(sizeof(state));
    stat->unit_size = 1;
    stat->display_mode = 0;

    while (1)
    {
        printState(stat);

        for (int i = 0; i < menuLen; i++)
            printf("%d-%s\n", i, menu[i].name);

        printf("Option: ");
        fgets(user_input, MAX_LEN, stdin);
        int user_choise = strtol(NULL, user_input, 10);
        if (user_choise >= 0 && user_choise < menuLen)
        {
            printf("Within bounds\n");
            menu[user_choise].fun(stat);
        }
    }
}