%{
#include "parser.tab.h"
%}

%%
">" { printf("%s\n", yytext); return GTHAN; }
"</" { printf("%s\n", yytext); return LTHAN_SLASH; }
"<MYHTML>" { printf("%s\n", yytext); return MYHTML; }
"</MYHTML>" { printf("%s\n", yytext); return MYHTML_C; }
"<head>" { printf("%s\n", yytext); return HEAD; }
"</head>" { printf("%s\n", yytext); return HEAD_C; }
"<body>" { printf("%s\n", yytext); return BODY; }
"</body>" { printf("%s\n", yytext); return BODY_C; }
"<title>" { printf("%s\n", yytext); return TITLE; }
"</title>" { printf("%s\n", yytext); return TITLE_C; }
"<meta" { printf("%s\n", yytext); return META; }
"<p" { printf("%s\n", yytext); return P; }
"</p>" { printf("%s\n", yytext); return P_C; }
"<div" { printf("%s\n", yytext); return DIV; }
"</div>" { printf("%s\n", yytext); return DIV_C; }
"<a" { printf("%s\n", yytext); return A; }
"</a>" { printf("%s\n", yytext); return A_C; }
"<img" { printf("%s\n", yytext); return IMG; }
"<form" { printf("%s\n", yytext); return FORM; }
"</form>" { printf("%s\n", yytext); return FORM_C; }
"<label" { printf("%s\n", yytext); return LABEL; }
"</label>" { printf("%s\n", yytext); return LABEL_C; }
"<input" { printf("%s\n", yytext); return INPUT; }
"</input>" { printf("%s\n", yytext); return INPUT_C; }
[ \t\n]+      { /* Ignore whitespace */ }
.             { printf("Unexpected token: %c", yytext[0]); }
%%
