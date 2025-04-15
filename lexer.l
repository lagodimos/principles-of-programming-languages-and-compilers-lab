%{
#include "parser.tab.h"
%}

%x ATTRIBUTES

%%

"<"[a-zA-Z][a-zA-Z0-9]* {
    char tag_name[10];
    sscanf(yytext+1, "%9[a-zA-Z0-9]", tag_name);

    const char* self_closing_tags[] = {"meta", "img", "input"};
    int num_tags = sizeof(self_closing_tags) / sizeof(self_closing_tags[0]);

    for (int i = 0; i < num_tags; i++) {
        if (strcmp(tag_name, self_closing_tags[i]) == 0) {
            printf("SELF_CLOSING_TAG_START:\t|%s\n", yytext);
            BEGIN(ATTRIBUTES);
            return SELF_CLOSING_TAG_START;
        }
    }

    printf("OPEN_PAIRED_TAG_START:\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return OPEN_PAIRED_TAG_START;
}

<ATTRIBUTES>">" {
    printf("OPEN_TAG_END:\t\t|%s\n", yytext);
    BEGIN(INITIAL);
    return OPEN_TAG_END;
}

"</"[a-zA-Z][a-zA-Z0-9]*">" {
    printf("CLOSE_TAG:\t\t|%s\n", yytext);
    return CLOSE_TAG;
}

<INITIAL>[^< \t\n][^<]* {
    printf("TEXT:\t\t\t|%s\n", yytext);
    return TEXT;
}

<ATTRIBUTES>[a-zA-Z]+ {
    printf("ATTRIBUTE_NAME:\t|%s\n", yytext);
    return ATTRIBUTE_NAME;
}

<ATTRIBUTES>"=" {
    printf("EQUALS:\t\t\t|%s\n", yytext);
    return EQUALS;
}

<ATTRIBUTES>\"[^"]*\" {
    printf("ATTRIBUTE_VALUE:\t|%s\n", yytext);
    return ATTRIBUTE_VALUE;
}

<ATTRIBUTES>'[^']*' {
    printf("ATTRIBUTE_VALUE:\t|%s\n", yytext);
    return ATTRIBUTE_VALUE;
}

[ \t\n]+ {
    /* Ignore whitespace */
}

. {
    printf("Unexpected token: %c", yytext[0]);
}

%%
