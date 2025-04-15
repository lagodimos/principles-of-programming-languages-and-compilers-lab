%{
#include <stdio.h>

int yylex();
void yyerror(const char *s);
%}

%define parse.error verbose

%define api.value.type {char*}

%token MYHTML_OPEN
%token MYHTML_CLOSE
%token HEAD_OPEN
%token HEAD_CLOSE
%token TITLE_OPEN
%token TITLE_CLOSE
%token META_START
%token BODY_OPEN
%token BODY_CLOSE
%token P_OPEN_START
%token P_CLOSE
%token A_OPEN_START
%token A_CLOSE
%token IMG_START
%token FORM_OPEN_START
%token FORM_CLOSE
%token DIV_OPEN_START
%token DIV_CLOSE
%token INPUT_START
%token LABEL_OPEN_START
%token LABEL_CLOSE

%token TAG_END

%token TEXT

%token ATTRIBUTE_NAME
%token EQUALS
%token ATTRIBUTE_VALUE

%start myhtml

%%

myhtml: MYHTML_OPEN myhtml_content MYHTML_CLOSE
myhtml_content: head body | body

head: HEAD_OPEN head_content HEAD_CLOSE
head_content: title optional_meta_tags

title: TITLE_OPEN TEXT TITLE_CLOSE

optional_meta_tags: %empty
    | meta optional_meta_tags
meta: META_START attributes TAG_END

body: BODY_OPEN body_content BODY_CLOSE
body_content: %empty
    | TEXT body_content
    | p body_content
    | a body_content
    | img body_content
    | form body_content
    | div body_content
    | input body_content
    | label body_content

p: P_OPEN_START attributes TAG_END body_content P_CLOSE
a: A_OPEN_START attributes TAG_END body_content A_CLOSE
img: IMG_START attributes TAG_END
form: FORM_OPEN_START attributes TAG_END form_content FORM_CLOSE
form_content: label optional_form_content
            | input optional_form_content
optional_form_content: %empty
    | label form_content
    | input form_content
div: DIV_OPEN_START attributes TAG_END body_content DIV_CLOSE
input: INPUT_START attributes TAG_END
label: LABEL_OPEN_START attributes TAG_END TEXT LABEL_CLOSE

attributes: %empty
    | attribute attributes

attribute: ATTRIBUTE_NAME EQUALS ATTRIBUTE_VALUE

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
