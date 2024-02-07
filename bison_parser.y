%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "heading.h"
    
    int yyerror(char *s);
    int yylex(void);
%}

%token FUNC RETURN INT PRINT READ WRITE WHILE IF ELSE BREAK CONTINUE LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY LEFTBRACKET RIGHTBRACKET
COMMA SEMICOLON PLUS SUBTRACT MULTIPLY DIVIDE MODULUS ASSIGN LESS LESSEQUAL GREATER GREATEREQUAL EQUALITY NOTEQUAL NUMBER

%start program

%%

program: %empty
        | program function
        ;

//
function: FUNC TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTBRACKET statements RIGHTBRACKET 
        | FUNC type TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTBRACKET statements RIGHTBRACKET
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
        | RETURN TOKEN_IDENTIFIER SEMICOLON
        | function_call
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON
        ;

// int x;
// int x = 0;
new_variable: type TOKEN_IDENTIFIER SEMICOLON
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON
            ;

type: INT

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
mod:     LEFTPAREN expression MODULUS expression RIGHTPAREN

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