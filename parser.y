%{
#include <stdio.h>

int yylex();
void yyerror(const char *s);
%}

%token GTHAN
%token LTHAN_SLASH

%token MYHTML
%token MYHTML_C
%token HEAD
%token HEAD_C
%token BODY
%token BODY_C
%token TITLE
%token TITLE_C
%token META
%token P
%token P_C
%token DIV
%token DIV_C
%token A
%token A_C
%token IMG
%token FORM
%token FORM_C
%token LABEL
%token LABEL_C
%token INPUT
%token INPUT_C

%token TEXT

%start myhtml

%%

// MYHTML: "<MYHTML>", MYHTML_C: "</MYHTML>"
// myhtml is the entire myhtml tag

myhtml: MYHTML myhtml_content MYHTML_C
myhtml_content: head body | body

head: HEAD head_content HEAD_C
head_content: title optional_meta_tags

optional_meta_tags: %empty

title: TITLE TEXT TITLE_C

body: %empty

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
