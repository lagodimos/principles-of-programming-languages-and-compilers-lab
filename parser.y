%{
#include <stdio.h>

int yylex();
void yyerror(const char *s);
%}

%token LTHAN
%token GTHAN
%token LTHAN_SLASH

%token MYHTML
%token HEAD
%token BODY
%token TITLE
%token META
%token P
%token DIV
%token A
%token IMG
%token FORM
%token LABEL
%token INPUT

%start myhtml

%%

// MYHTML is the token "MYHTML"
// myhtml is the entire myhtml tag
// myhtml: myhtml_open myhtml_content myhtml_close

myhtml: LTHAN MYHTML GTHAN myhtml_content LTHAN_SLASH MYHTML GTHAN
myhtml_content: head body | body

head: LTHAN HEAD head_content LTHAN_SLASH HEAD GTHAN
head_content: title optional_meta_tags

optional_meta_tags: %empty

title: LTHAN TITLE  LTHAN_SLASH TITLE GTHAN

body: %empty

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
