#include <stdio.h>
#include "parser.tab.h"

extern FILE *yyin;

int main(int argc, char **argv) {
    FILE *input_file;

    input_file = fopen(argv[1], "r");

    if (input_file) {
        yyin = input_file;
    }
    else {
        printf("Unable to open %s.\n", argv[1]);
        return -1;
    }

    if (yyparse() == 0) {
        printf("Parsing completed successfully.\n");
    } else {
        printf("Parsing failed.\n");
    }

    return 0;
}
