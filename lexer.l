%{
#include "parser.tab.h"
%}

%x ATTRIBUTES

%%

"<"[a-zA-Z][a-zA-Z0-9]* {
    printf("OPEN_TAG_START:\t\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return OPEN_TAG_START;
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

<<EOF>> {
    printf("EOF\n");
    return TEOF;
}

%%
