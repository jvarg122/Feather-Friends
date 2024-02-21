%{
#include <stdio.h>
#include "parser.tab.h"

char *create_string(char *text, int len) {
  char *string_value = new char[len + 1];
  strcpy(string_value, text);
  return string_value;
}
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
COMMENT [#].*\n
IDENTIFIER [a-zA-Z][a-zA-Z0-9]*
INVALIDIDENTIFIER [0-9]+{IDENTIFIER}

%%

"chirp"                     {return FUNC;}
"migrate"                   {return RETURN;}
"egg"                       {return INT;}
"squawk"                    {return PRINT;}
"survey"                    {return READ;}
"peck"                      {return WRITE;}
"nest"                      {return WHILE;}
"fly"                       {return IF;}
"land"                      {return ELSE;}
"roast"                     {return BREAK;}
"soar"                      {return CONTINUE;}


"("                         {return LEFTPAREN;}
")"                         {return RIGHTPAREN;}
"{"                         {return LEFTCURLY;}
"}"                         {return RIGHTCURLY;}
"["                         {return LEFTBRACKET;}
"]"                         {return RIGHTBRACKET;}
","                         {return COMMA;}
";"                         {return SEMICOLON;}
"+"                         {return PLUS;}
"-"                         {return SUBTRACT;}
"*"                         {return MULTIPLY;}
"/"                         {return DIVIDE;}
"%"                         {return MODULUS;}
"="                         {return ASSIGN;}
"<"                         {return LESS;}
"<="                        {return LESSEQUAL;}
">"                         {return GREATER;}
">="                        {return GREATEREQUAL;}
"=="                        {return EQUALITY;}
"!="                        {return NOTEQUAL;}
[V].*[\n]                   {}
{INVALIDIDENTIFIER}+        {printf("Invalid identifier found: %s\n", yytext);}
{DIGIT}+                    {yylval.op_value = create_string(yytext, yyleng); return NUMBER;}
{IDENTIFIER}+               {yylval.op_value = create_string(yytext, yyleng); return TOKEN_IDENTIFIER;}
[ \t\n]                     {}
.                           {printf("Unrecognized character found  %s\n", yytext);}
%%