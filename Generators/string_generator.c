#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void generate_passwords(int length, char *prefix) {
    if (length == 0) {
        printf("%s\n", prefix);
        return;
    }
    for (char c = ' '; c <= '~'; c++) {
        char *new_prefix = (char*) malloc(sizeof(char) * (strlen(prefix) + 2));
        sprintf(new_prefix, "%s%c", prefix, c);
        generate_passwords(length - 1, new_prefix);
        free(new_prefix);
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <length>\n", argv[0]);
        return 1;
    }
    int length = atoi(argv[1]);
    char *prefix = (char*) malloc(sizeof(char) * 2);
    prefix[0] = '\0';
    generate_passwords(length, prefix);
    free(prefix);
    return 0;
}
