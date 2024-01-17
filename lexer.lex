%{
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
COMMENT [#].*\n

%%

"func"                      {printf("chirp\n");}
"return"                    {printf("migrate\n");}
"int"                       {printf("egg\n");}
"print"                     {printf("squawk\n");}
"read"                      {printf("survey\n");}
"while"                     {printf("nest\n");}
"if"                        {printf("fly\n");}
"else"                      {printf("land\n");}
"break"                     {printf("roast\n");}
"continue"                  {printf("soar\n");}

"("                         {printf("LEFTPAREN\n");}
")"                         {printf("RIGHTPAREN\n");}
"{"                         {printf("LEFTCURLY\n");}
"}"                         {printf("RIGHTPAREN\n");}
"["                         {printf("LEFTBRACKET\n");}
"]"                         {printf("RIGHTBRACKET\n");}
","                         {printf("COMMA\n");}
";"                         {printf("SEMICOLON\n");}
"+"                         {printf("PLUS\n");}
"-"                         {printf("SUBTRACT\n");}
"*"                         {printf("MULTIPLY\n");}
"/"                         {printf("DIVIDE\n");}
"%"                         {printf("MODULUS\n");}
"="                         {printf("ASSIGN\n");}
"<"                         {printf("LESS\n");}
"<="                        {printf("LESSEQUAL\n");}
">"                         {printf("GREATER\n");}
">="                        {printf("GREATEREQUAL\n");}
"=="                        {printf("EQUALITY\n");}
"!="                        {printf("NOTEQUAL\n");}
"{comment}"                 {printf("V*\n");}
{DIGIT}+                    {printf("NUMBER: %s\n", yytext);}
{ALPHA}+                    {printf("TOKEN: %s\n", yytext);}
{COMMENT}                   {}
[ \t\n]                     {}
.                           {}
%%

int main(void) {
    yylex();
}