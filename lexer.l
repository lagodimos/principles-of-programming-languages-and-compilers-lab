%{
#include "parser.tab.h"

#include "parser.h"

#define MAX_NAME_VAL 30

extern Array attributes_array;

extern char text[];
%}

%x ATTRIBUTES

%%

"<MYHTML>" {
    printf("MYHTML_OPEN:\t\t|%s\n", yytext);
    return MYHTML_OPEN;
}

"</MYHTML>" {
    printf("MYHTML_CLOSE:\t\t|%s\n", yytext);
    return MYHTML_CLOSE;
}

"<head>" {
    printf("HEAD_OPEN:\t\t|%s\n", yytext);
    return HEAD_OPEN;
}

"</head>" {
    printf("HEAD_CLOSE:\t\t|%s\n", yytext);
    return HEAD_CLOSE;
}

"<title>" {
    printf("TITLE_OPEN:\t\t|%s\n", yytext);
    return TITLE_OPEN;
}

"</title>" {
    printf("TITLE_CLOSE:\t\t|%s\n", yytext);
    return TITLE_CLOSE;
}

"<meta " {
    printf("META_START:\t\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return META_START;
}

"<body>" {
    printf("BODY_OPEN:\t\t|%s\n", yytext);
    return BODY_OPEN;
}

"</body>" {
    printf("HEAD_CLOSE:\t\t|%s\n", yytext);
    return BODY_CLOSE;
}

"<p " {
    printf("P_OPEN_START:\t\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return P_OPEN_START;
}

"</p>" {
    printf("P_CLOSE:\t\t|%s\n", yytext);
    return P_CLOSE;
}

"<a " {
    printf("A_OPEN_START:\t\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return A_OPEN_START;
}

"</a>" {
    printf("A_CLOSE:\t\t|%s\n", yytext);
    return A_CLOSE;
}

"<img " {
    printf("IMG_START:\t\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return IMG_START;
}

"<form " {
    printf("FORM_OPEN_START:\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return FORM_OPEN_START;
}

"</form>" {
    printf("FORM_CLOSE:\t\t|%s\n", yytext);
    return FORM_CLOSE;
}

"<div " {
    printf("DIV_OPEN_START:\t\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return DIV_OPEN_START;
}

"</div>" {
    printf("DIV_CLOSE:\t\t|%s\n", yytext);
    return DIV_CLOSE;
}

"<input " {
    printf("INPUT_START:\t\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return INPUT_START;
}

"<label " {
    printf("LABEL_OPEN_START:\t|%s\n", yytext);
    BEGIN(ATTRIBUTES);
    return LABEL_OPEN_START;
}

"</label>" {
    printf("LABEL_CLOSE:\t\t|%s\n", yytext);
    return LABEL_CLOSE;
}

<INITIAL,ATTRIBUTES>"<!--"([^-]|-[^-])*"-->" {
    if (YYSTATE == ATTRIBUTES) {
        printf("Comments are not allowed inside of start/end tags attributes.\n");
        exit(1);
    }
}

<ATTRIBUTES>">" {
    printf("OPEN_TAG_END:\t\t|%s\n", yytext);
    BEGIN(INITIAL);
    return TAG_END;
}

<INITIAL>[^< \t\n][^<]* {
    printf("TEXT:\t\t\t|%s\n", yytext);
    strcpy(text, yytext);
    return TEXT;
}

<ATTRIBUTES>[a-zA-Z]+ {
    Attribute *attributes = attributes_array.values;

    char *attribute = malloc(sizeof(char) * MAX_NAME_VAL);
    strcpy(attribute, yytext);

    attributes[*attributes_array.size].name = attribute;
    (*attributes_array.size)++;

    printf("ATTRIBUTE_NAME:\t|%s\n", yytext);
    return ATTRIBUTE_NAME;
}

<ATTRIBUTES>"=" {
    printf("EQUALS:\t\t\t|%s\n", yytext);
    return EQUALS;
}

<ATTRIBUTES>\"[^"]*\"|'[^']*' {
    /* Matches single or double quoted strings */

    Attribute *attributes = attributes_array.values;

    char *value = malloc(sizeof(char) * MAX_NAME_VAL);
    strcpy(value, &yytext[1]);
    value[strlen(value) - 1] = '\0';

    attributes[*attributes_array.size - 1].value = value;

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
