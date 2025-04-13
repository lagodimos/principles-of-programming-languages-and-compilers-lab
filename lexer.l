%{
#include "parser.tab.h"
%}

%%
"<" { printf("%s\n", yytext); return LTHAN; }
">" { printf("%s\n", yytext); return GTHAN; }
"</" { printf("%s\n", yytext); return LTHAN_SLASH; }
"MYHTML" { printf("%s\n", yytext); return MYHTML; }
"head" { printf("%s\n", yytext); return HEAD; }
"body" { printf("%s\n", yytext); return BODY; }
"title" { printf("%s\n", yytext); return TITLE; }
"meta" { printf("%s\n", yytext); return META; }
"<p" { printf("%s\n", yytext); return P; }
"div" { printf("%s\n", yytext); return DIV; }
"a" { printf("%s\n", yytext); return A; }
"img" { printf("%s\n", yytext); return IMG; }
"form" { printf("%s\n", yytext); return FORM; }
"label" { printf("%s\n", yytext); return LABEL; }
"input" { printf("%s\n", yytext); return INPUT; }
[ \t\n]+      { /* Ignore whitespace */ }
.             { printf("Unexpected token: %c", yytext[0]); }
%%
