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
    int size;
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
    printf("New unit size:\n");
    fgets(user_input, 128, stdin);
    int unit_size = strtol(user_input, NULL, 10);
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

void load_into_memory(state *s)
{
    int location, length;
    if (strcmp(s->file_name, "") == 0)
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
        printf("file_name: %s, location: %x, length: %d\n", s->file_name, location, length);
    }

    fseek(file, 0, SEEK_END);
    s->size = ftell(file);
    fseek(file, 0, SEEK_SET);

    fseek(file, location, SEEK_SET);
    int copied = fread(s->mem_buf, s->unit_size, length, file);
    s->mem_count = length;
    printf("Loaded %d units into memory\n", copied);
    fclose(file);
}

void memory_display(state *s)
{
    int location, length, value;
    printf("Enter address and length\n");
    fgets(user_input, 128, stdin);
    sscanf(user_input, "%x %d", &location, &length);

    char *start = (char *)s->mem_buf + location;
    static char *dec_format[] = {"%hhd\n", "%hd\n", "", "%d\n"};
    static char *hex_format[] = {"%hhX\n", "%hX\n", "", "%X\n"};

    if (s->display_mode == 0)
    {
        printf("Decimal\n=======\n");
        for (size_t i = 0; i < length; i++)
        {
            value = *((int *)(start));
            printf(dec_format[s->unit_size - 1], value);
            start += s->unit_size;
        }
    }
    else
    {
        printf("Hexadecimal\n=======\n");
        for (size_t i = 0; i < length; i++)
        {
            value = *((int *)(start));
            printf(hex_format[s->unit_size - 1], value);
            start += s->unit_size;
        }
    }
}

void save_into_file(state *s)
{
    printf("Please enter <source-address> <target-location> <length>\n");
    int source, target, length;

    fgets(user_input, 128, stdin);
    sscanf(user_input, "%x %x %d", &source, &target, &length);
    FILE *file = fopen(s->file_name, "r+");

    if (file == NULL)
    {
        fprintf(stderr, "error opening file\n");
        return;
    }
    if (s->size <= target)
    {
        fprintf(stderr, "target is too big\n");
        return;
    }

    char *start = (char *)s->mem_buf + source;

    fseek(file, target, SEEK_SET);
    fwrite(start, s->unit_size, length, file);
    fclose(file);
}

void memory_modify(state *s)
{
    fprintf(stdout, "Please enter <location> <val>\n");
    int location, val;

    fgets(user_input, 128, stdin);
    sscanf(user_input, "%x %x", &location, &val);

    if (s->debug_mode == 1)
    {
        fprintf(stderr, "location: %x, val: %x\n", location, val);
    }

    // switch (s->unit_size)
    // {
    // case 1:
    //     if (val > 255)
    //         fprintf(stderr, "val too big\n");
    //     return;
    // case 2:
    //     if (val > 65535)
    //         fprintf(stderr, "val too big\n");
    //     return;
    // case 4:
    //     if (val > 4294967295)
    //         fprintf(stderr, "val too big\n");
    //     return;

    // default:
    //     break;
    // }
    
    // printf("starting to open file");
    // FILE *file = fopen("temp.txt", "w+");
    // if(file == NULL)
    // {
    //     fprintf(stderr, "error creating file");
    // }
    // fprintf(file, "%d", val);

    char *start = (char *)s->mem_buf + location;
    *((int *)(start)) = val;
    
    // fread(start, s->unit_size, 1, file);
    // fclose(file);
    //remove("test");
}

int main(int argc, char **argv)
{
    struct menu menu[] = {{"Toggle Debug Mode", toggle_debug_mode},
                          {"Set File Name", set_file_name},
                          {"Set Unit Size", set_unit_size},
                          {"Load Into Memory", load_into_memory},
                          {"Toggle Display Mode", toggle_display_mode},
                          {"Memory Display", memory_display},
                          {"Save Into File", save_into_file},
                          {"Memory Modify", memory_modify},
                          {"Quit", quit},
                          {NULL, NULL}};

    int menuLen = sizeof(menu) / sizeof(menu[0]) - 1;
    state *stat = malloc(sizeof(state));
    stat->unit_size = 1;
    stat->display_mode = 0;
    stat->debug_mode = '0';

    while (1)
    {
        for (int i = 0; i < menuLen; i++)
            printf("%d-%s\n", i, menu[i].name);

        printf("Option: ");
        fgets(user_input, MAX_LEN, stdin);
        int user_choise = strtol(user_input, NULL, 10);
        if (user_choise >= 0 && user_choise < menuLen)
        {
            menu[user_choise].fun(stat);
        }
    }
}