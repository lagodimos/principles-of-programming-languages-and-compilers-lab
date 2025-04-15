%{
#include <stdio.h>

int yylex();
void yyerror(const char *s);
%}

%define parse.error verbose

%token OPEN_PAIRED_TAG_START
%token SELF_CLOSING_TAG_START
%token OPEN_TAG_END
%token CLOSE_TAG

%token TEXT

%token ATTRIBUTE_NAME
%token EQUALS
%token ATTRIBUTE_VALUE

%start myhtml

%%

myhtml: OPEN_PAIRED_TAG_START OPEN_TAG_END myhtml_content CLOSE_TAG
myhtml_content: head body | body

head: OPEN_PAIRED_TAG_START OPEN_TAG_END head_content CLOSE_TAG
head_content: title optional_meta_tags

title: OPEN_PAIRED_TAG_START OPEN_TAG_END TEXT CLOSE_TAG

optional_meta_tags: meta optional_meta_tags
    | %empty
meta: SELF_CLOSING_TAG_START attributes OPEN_TAG_END

attributes: attribute attributes {}
    | %empty

attribute: ATTRIBUTE_NAME EQUALS ATTRIBUTE_VALUE

body: OPEN_PAIRED_TAG_START OPEN_TAG_END body_content CLOSE_TAG
body_content: TEXT body_content
    | body_content_tag body_content
    | %empty

body_content_tag: OPEN_PAIRED_TAG_START attributes OPEN_TAG_END body_content CLOSE_TAG
    | SELF_CLOSING_TAG_START attributes OPEN_TAG_END

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
