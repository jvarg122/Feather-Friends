%{
    #include <stdio.h>
    #include <stdlib.h>
    
    
    int yyerror(char *s);
    int yylex(void);
%}

// Already implemented tokens
%token FUNC RETURN INT PRINT BREAK LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY 
%token COMMA SEMICOLON PLUS SUBTRACT MULTIPLY DIVIDE MODULUS ASSIGN NUMBER

// TODO: Need to implement these still
%token READ WRITE WHILE IF ELSE CONTINUE LEFTBRACKET RIGHTBRACKET
%token LESS LESSEQUAL GREATER GREATEREQUAL EQUALITY NOTEQUAL

%token COMMENT TOKEN_IDENTIFIER

%start program

%%

program: %empty {printf("program -> epsilon\n");}
        | program function {printf("program -> program function\n");}
        | COMMENT {printf("program -> COMMENT\n");}
        ;

//
function: FUNC TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY 
        | FUNC type TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY
        ;

new_parameters: %empty {printf("new_parameters -> epsilon\n");}
          | new_parameter {printf("new_parameters -> new_parameter\n");}
          ;

// int x
// int x, int y
new_parameter: type TOKEN_IDENTIFIER
            | type TOKEN_IDENTIFIER COMMA new_parameter {printf("new_parameter -> type TOKEN_IDENTIFIER COMMA new_parameter\n");}
            ;

parameters: %empty {printf("parameters -> epsilon\n");}
          | parameter {printf("parameters -> parameter\n");}
          ;

// x
// x, y, z 
parameter: TOKEN_IDENTIFIER
        | TOKEN_IDENTIFIER COMMA parameter {printf("parameter -> TOKEN_IDENTIFIER COMMA parameter\n");}
        ;

statements: %empty {printf("statements -> epsilon\n");}
          | statements statement {printf("statements -> statements statement\n");}
          ;

// a = b;
// return a;
// int x;
// int x = 0;
// x = y + 1
statement: new_variable
        | function_call
        | print
        | RETURN TOKEN_IDENTIFIER SEMICOLON {printf("statement -> RETURN TOKEN_IDENTIFIER SEMICOLON\n");}
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON {printf("statement -> TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON\n");}
        | COMMENT {printf("statement -> COMMENT\n");}
        | BREAK SEMICOLON {printf("statement -> BREAK SEMICOLON\n");}
        ;

// int x;
// int x = 0;
new_variable: type TOKEN_IDENTIFIER SEMICOLON
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON
            ;

type: INT

print: PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON {printf("print -> PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON\n");}

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters SEMICOLON {printf("function_call -> TOKEN_IDENTIFIER LEFTPAREN parameters RIGHTPAREN SEMICOLON\n");}

expressions: %empty                 {printf("expressions -> epsilon\n");}
           | expressions expression {printf("expressions -> expressions expression\n");}
           ;

// x + 1 + 2 + y
// x/2 + 1/3
/*
expression: PLUS     {printf("expression -> PLUS\n");}
          | SUBTRACT     {printf("expression -> SUBTRACT\n");}
          | MULTIPLY   {printf("expression -> MULTIPLY\n");}
          | DIVIDE    {printf("expression -> DIVIDE\n");}
          | MODULUS    {printf("expression -> MODULUS\n");}
          | NUMBER  {printf("expression -> NUMBER\n");}
          | TOKEN_IDENTIFIER {printf("expression -> TOKEN_IDENTIFIER\n");}
          ;
*/

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

/*
add:    LEFTPAREN expression PLUS expression RIGHTPAREN {printf("add -> LEFTPAREN expression PLUS expression RIGHTPAREN\n");}
sub:    LEFTPAREN expression SUBTRACT expression RIGHTPAREN {printf("sub -> LEFTPAREN expression SUBTRACT expression RIGHTPAREN\n");}
mult:   LEFTPAREN expression MULTIPLY expression RIGHTPAREN {printf("mult -> LEFTPAREN expression MULTIPLY expression RIGHTPAREN\n");}
div:    LEFTPAREN expression DIVIDE expression RIGHTPAREN {printf("div -> LEFTPAREN expression DIVIDE expression RIGHTPAREN\n");}
mod:    LEFTPAREN expression MODULUS expression RIGHTPAREN {printf("mod -> LEFTPAREN expression MODULUS expression RIGHTPAREN\n");}
*/

expression: NUMBER {printf("expression -> NUMBER\n");}
          | TOKEN_IDENTIFIER {printf("expression -> TOKEN_IDENTIFIER\n");}
          | expression PLUS expression {printf("expression -> expression PLUS expression\n");}
          | expression SUBTRACT expression {printf("expression -> expression SUBTRACT expression\n");}
          | expression MULTIPLY expression {printf("expression -> expression MULTIPLY expression\n");}
          | expression DIVIDE expression {printf("expression -> expression DIVIDE expression\n");}
          | expression MODULUS expression {printf("expression -> expression MODULUS expression\n");}
          ;

//comment: COMMENT { printf("Comment found\n");};
//identifier: TOKEN_IDENTIFIER { printf("Identifier found\n");};

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