%{
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
COMMENT [#].*\n

%%

"chirp"                     {printf("FUNC\n");}
"migrate"                   {printf("RETURN\n");}
"egg"                       {printf("INT\n");}
"squawk"                    {printf("PRINT\n");}
"survey"                    {printf("READ\n");}
"peck"                      {printf("WRITE\n");}
"nest"                      {printf("WHILE\n");}
"fly"                       {printf("IF\n");}
"land"                      {printf("ELSE\n");}
"roast"                     {printf("BREAK\n");}
"soar"                      {printf("CONTINUE\n");}


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
"V.*$"                      {printf("COMMENT\n");}
{DIGIT}+                    {printf("NUMBER: %s\n", yytext);}
{ALPHA}+                    {printf("TOKEN: %s\n", yytext);}
[ \t\n]                     {}
.                           {printf("Unrecognized character found  %s\n", yytext);}
%%

int main(void) {
    yylex();
}