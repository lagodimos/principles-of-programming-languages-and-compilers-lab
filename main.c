#include <stdio.h>
#include "parser.tab.h"

int main() {
    if (yyparse()) {
        printf("Parsing completed successfully.\n");
    } else {
        printf("Parsing failed.\n");
    }
    return 0;
}
