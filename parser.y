%{
    #include <stdio.h>
    #include <stdlib.h>
    
    
    extern void yyerror(const char *s);
    extern int yylex(void);
    extern FILE* yyin;
%}

// Already implemented tokens
%token FUNC RETURN INT PRINT BREAK LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY 
%token COMMA SEMICOLON PLUS SUBTRACT MULTIPLY DIVIDE MODULUS ASSIGN NUMBER
%token LEFTBRACKET RIGHTBRACKET

// TODO: Need to implement these still
%token READ WRITE WHILE IF ELSE CONTINUE
%token LESS LESSEQUAL GREATER GREATEREQUAL EQUALITY NOTEQUAL

%token COMMENT TOKEN_IDENTIFIER INVALID_IDENTIFIER UNRECOGNIZED_CHARACTER

%start program

%%

program: %empty {printf("program -> epsilon\n");}
        | program function {printf("program -> program function\n");}
        | COMMENT program {printf("program -> COMMENT program\n");}
        ;

//
function: FUNC TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY {printf("function -> FUNC TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY\n");}
        | FUNC type TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY {printf("function -> FUNC type TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY\n");}
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
          | parameter COMMA parameter {printf("parameters -> parameter COMMA parameter\n");}
          ;

// x
// x, y, z 
// somearray[0]
parameter: TOKEN_IDENTIFIER {printf("parameter -> TOKEN_IDENTIFIER\n");}
        | array_get_pointer {printf("parameter -> array_get_pointer\n");}
        ;

statements: %empty {printf("statements -> epsilon\n");}
          | statements statement {printf("statements -> statements statement\n");}
          ;

// a = b;
// return a;
// int x;
// int x = 0;
// x = y + 1
statement: new_variable {printf("statement -> new_variable\n");}
        | new_array {printf("statement -> new_array\n");}
        | function_call {printf("statement -> function_call\n");}
        | print {printf("statement -> print\n");}
        | RETURN TOKEN_IDENTIFIER SEMICOLON {printf("statement -> RETURN TOKEN_IDENTIFIER SEMICOLON\n");}
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON {printf("statement -> TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON\n");}
        | array_get_pointer ASSIGN expressions SEMICOLON {printf("statement -> array_get_pointer ASSIGN expressions SEMICOLON\n");}
        | COMMENT {printf("statement -> COMMENT\n");}
        | BREAK SEMICOLON {printf("statement -> BREAK SEMICOLON\n");}
        ;

// int x;
// int x = 0;
new_variable: type TOKEN_IDENTIFIER SEMICOLON {printf("new_variable -> type TOKEN_IDENTIFIER SEMICOLON\n");}
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {printf("new_variable -> type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON\n");}
            ;

// egg[4] array;
new_array: type LEFTBRACKET NUMBER RIGHTBRACKET TOKEN_IDENTIFIER SEMICOLON {printf("new_array -> type LEFTBRACKET NUMBER RIGHTBRACKET SEMICOLON TOKEN_IDENTIFIER\n");}

// somearray[0]
array_get_pointer: TOKEN_IDENTIFIER LEFTBRACKET NUMBER RIGHTBRACKET {printf("array_get_pointer -> TOKEN_IDENTIFIER LEFTBRACKET NUMBER RIGHTBRACKET\n");}

type: INT {printf("type -> INT\n");}

print: PRINT LEFTPAREN parameter RIGHTPAREN SEMICOLON {printf("print -> PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON\n");}

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters SEMICOLON {printf("function_call -> TOKEN_IDENTIFIER LEFTPAREN parameters RIGHTPAREN SEMICOLON\n");}

expressions: %empty                 {printf("expressions -> epsilon\n");}
           | expressions expression {printf("expressions -> expressions expression\n");}
           ;

// x + 1 + 2 + y
// x/2 + 1/3
expression: NUMBER {printf("expression -> NUMBER\n");}
          | TOKEN_IDENTIFIER {printf("expression -> TOKEN_IDENTIFIER\n");}
          | array_get_pointer {printf("expression -> array_get_pointer\n");}
          | LEFTPAREN expression RIGHTPAREN {printf("expression -> LEFTPAREN expression RIGHTPAREN\n");}
          | expression PLUS expression {printf("expression -> expression PLUS expression\n");}
          | expression SUBTRACT expression {printf("expression -> expression SUBTRACT expression\n");}
          | expression MULTIPLY expression {printf("expression -> expression MULTIPLY expression\n");}
          | expression DIVIDE expression {printf("expression -> expression DIVIDE expression\n");}
          | expression MODULUS expression {printf("expression -> expression MODULUS expression\n");}
          ;
%%

int main() {
    yyin = stdin;

    do {
        printf("Start parsing...\n=====================================\n");
        yyparse();
    } while(!feof(yyin));

    printf("=====================================\nDone parsing!");
    return 0;
}

void yyerror(const char* s)
{
  fprintf(stderr, "Parse error: %s. \n");
  exit(1);
}