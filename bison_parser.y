%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "heading.h"
    
    int yyerror(char *s);
    int yylex(void);
%}

// Already implemented tokens
%token FUNC RETURN INT PRINT BREAK LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY 
%token COMMA SEMICOLON PLUS SUBTRACT MULTIPLY DIVIDE MODULUS ASSIGN NUMBER

// TODO: Need to implement these still
%token READ WRITE WHILE IF ELSE CONTINUE LEFTBRACKET RIGHTBRACKET
% LESS LESSEQUAL GREATER GREATEREQUAL EQUALITY NOTEQUAL

%start program

%%

program: %empty
        | program function
        | COMMENT
        ;

//
function: FUNC TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY 
        | FUNC type TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY
        ;

new_parameters: %empty
          | new_parameter
          ;

// int x
// int x, int y
new_parameter: type TOKEN_IDENTIFIER
            | type TOKEN_IDENTIFIER COMMA new_parameter
            ;

parameters: %empty
          | parameter
          ;

// x
// x, y, z 
parameter: TOKEN_IDENTIFIER
        | TOKEN_IDENTIFIER COMMA parameter
        ;

statements: %empty
          | statements statement
          ;

// a = b;
// return a;
// int x;
// int x = 0;
// x = y + 1
statement: new_variable
        | function_call
        | print
        | RETURN TOKEN_IDENTIFIER SEMICOLON
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON
        | COMMENT
        | BREAK SEMICOLON
        ;

// int x;
// int x = 0;
new_variable: type TOKEN_IDENTIFIER SEMICOLON
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON
            ;

type: INT

print: PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters SEMICOLON

expressions: %empty                 {printf("expressions -> epsilon\n");}
           | expressions expression {printf("expressions -> expressions expression\n");}
           ;

// x + 1 + 2 + y
// x/2 + 1/3
expression: add     {printf("expression -> add\n");}
          | sub     {printf("expression -> sub\n");}
          | mult    {printf("expression -> mult\n");}
          | div     {printf("expression -> div\n");}
          | mod     {printf("expression -> mod\n");}
          | NUMBER  {printf("expression -> NUMBER\n");}
          | TOKEN_IDENTIFIER
          ;


// EXAMPLES OF EXPRESSIONS
/* 
expression
=> add
=> (expression + expression)
=> (NUMBER + NUMBER)
*/

/*
expression
=> add
=> (expression + expression)
=> (div + TOKEN_IDENTIFIER)
=> ((expression / expression) + TOKEN_IDENTIFIER)
*/
add:    LEFTPAREN expression PLUS expression RIGHTPAREN
sub:    LEFTPAREN expression SUBTRACT expression RIGHTPAREN
mult:   LEFTPAREN expression MULTIPLY expression RIGHTPAREN
div:    LEFTPAREN expression DIVIDE expression RIGHTPAREN
mod:    LEFTPAREN expression MODULUS expression RIGHTPAREN

%%

int main() {
    yyin = stdin;

    do {
        printf("Parse.\n");
        yyparse();
    } while(!feof(yyin));

    printf("Done parsing.");
    return 0;
}

int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c
  
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}