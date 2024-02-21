%{
    #include <stdio.h>
    #include <stdlib.h>
    
    extern void yyerror(const char* s);
    extern int yylex(void);
    extern FILE* yyin;
%}

%define parse.error verbose

%token FUNC RETURN INT PRINT BREAK LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY 
%token COMMA SEMICOLON PLUS SUBTRACT MULTIPLY DIVIDE MODULUS ASSIGN NUMBER
%token LEFTBRACKET RIGHTBRACKET IF ELSE READ WRITE 
%token LESS LESSEQUAL GREATER GREATEREQUAL EQUALITY NOTEQUAL
%token COMMENT TOKEN_IDENTIFIER
%token WHILE CONTINUE


%start program

%%

program: %empty {printf("program -> epsilon\n");}
        | program function {printf("program -> program function\n");}
        | COMMENT program {printf("program -> COMMENT program\n");}
        ;

function: FUNC TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY {printf("function -> FUNC TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY\n");}
        | FUNC type TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY {printf("function -> FUNC type TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY\n");}
        ;

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters RIGHTPAREN {printf("function_call -> TOKEN_IDENTIFIER LEFTPAREN parameters RIGHTPAREN\n");}

new_parameters: %empty {printf("new_parameters -> epsilon\n");}
          | new_parameter {printf("new_parameters -> new_parameter\n");}
          | new_parameters COMMA new_parameter {printf("new_parameters -> new_parameters COMMA new_parameter\n");}
          ;

// int x
new_parameter: type TOKEN_IDENTIFIER {printf("new_parameter -> type TOKEN_IDENTIFIER\n");}

parameters: %empty {printf("parameters -> epsilon\n");}
          | expressions {printf("parameters -> expressions\n");}
          | expressions COMMA expressions {printf("parameters -> expressions COMMA expressions\n");}
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
        | RETURN expressions SEMICOLON {printf("statement -> RETURN TOKEN_IDENTIFIER SEMICOLON\n");}
        | COMMENT {printf("statement -> COMMENT\n");}
        | BREAK SEMICOLON {printf("statement -> BREAK SEMICOLON\n");}
        | CONTINUE SEMICOLON {printf("statement -> CONTINUE SEMICOLON\n");}
        | if_statement {printf("statement -> if_statement\n");}
        | while_statement {printf("statement -> while_statement\n");}
        | read_statement {printf("statement -> read_statement\n");}
        | write_statement {printf("statement -> write_statement\n");}
        | assignment {printf("statement -> assignment\n");}
        ;

// int x;
// int x = 0;
new_variable: type TOKEN_IDENTIFIER SEMICOLON {printf("new_variable -> type TOKEN_IDENTIFIER SEMICOLON\n");}
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {printf("new_variable -> type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON\n");}
            ;

variable: NUMBER {printf("variable -> NUMBER\n");}
          | TOKEN_IDENTIFIER {printf("variable -> TOKEN_IDENTIFIER\n");}
          | array_get_pointer {printf("variable -> array_get_pointer\n");}
          | function_call {printf("variable -> function_call\n");}
          ;

// egg[4] array;
new_array: type LEFTBRACKET NUMBER RIGHTBRACKET TOKEN_IDENTIFIER SEMICOLON {printf("new_array -> type LEFTBRACKET NUMBER RIGHTBRACKET SEMICOLON TOKEN_IDENTIFIER\n");}

// somearray[0]
array_get_pointer: TOKEN_IDENTIFIER LEFTBRACKET NUMBER RIGHTBRACKET {printf("array_get_pointer -> TOKEN_IDENTIFIER LEFTBRACKET NUMBER RIGHTBRACKET\n");}

type: INT {printf("type -> INT\n");}

print: PRINT LEFTPAREN variable RIGHTPAREN SEMICOLON {printf("print -> PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON\n");}

assignment: TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON {printf("statement -> TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON\n");}
        | array_get_pointer ASSIGN expressions SEMICOLON {printf("statement -> array_get_pointer ASSIGN expressions SEMICOLON\n");}
        ;

expressions: %empty                 {printf("expressions -> epsilon\n");}
           | expressions expression {printf("expressions -> expressions expression\n");}
           ;

// x + 1 + 2 + y
// x/2 + 1/3
expression: variable
          | LEFTPAREN expression RIGHTPAREN {printf("expression -> LEFTPAREN expression RIGHTPAREN\n");}
          | expression PLUS expression {printf("expression -> expression PLUS expression\n");}
          | expression SUBTRACT expression {printf("expression -> expression SUBTRACT expression\n");}
          | expression MULTIPLY expression {printf("expression -> expression MULTIPLY expression\n");}
          | expression DIVIDE expression {printf("expression -> expression DIVIDE expression\n");}
          | expression MODULUS expression {printf("expression -> expression MODULUS expression\n");}
          ;

boolean_expressions: expression GREATER expression {printf("boolean_expressions -> expression GREATER expression\n");}
                   | expression LESS expression {printf("boolean_expressions -> expression LESS expression\n");}
                   | expression LESSEQUAL expression {printf("boolean_expressions -> expression LESSEQUAL expression\n");}
                   | expression GREATEREQUAL expression {printf("boolean_expressions -> expression GREATEREQUAL expression\n");}
                   | expression EQUALITY expression {printf("boolean_expressions -> expression EQUALITY expression\n");}
                   | expression NOTEQUAL expression {printf("boolean_expressions -> expression NOTEQUAL expression\n");}
                   ;

if_statement: IF LEFTPAREN boolean_expressions RIGHTPAREN LEFTCURLY statements RIGHTCURLY else_statement {printf("statement -> IF LEFTPAREN boolean_expressions RIGHTPAREN LEFTCURLY statement RIGHTCURLY else_statement\n");}
        | IF boolean_expressions LEFTCURLY statements RIGHTCURLY else_statement {printf("statement -> IF boolean_expressions LEFTCURLY statement RIGHTCURLY else_statement\n");}
        ;

else_statement: ELSE LEFTCURLY statement RIGHTCURLY {printf("else_statement -> ELSE LEFTCURLY statement RIGHTCURLY\n");}
             | %empty {printf("else_statement -> epsilon\n");}
             ;

while_statement: WHILE boolean_expressions LEFTCURLY statements RIGHTCURLY {printf("statement -> WHILE boolean_expressions LEFTCURLY statements RIGHTCURLY\n");}
        | WHILE LEFTPAREN boolean_expressions RIGHTPAREN LEFTCURLY statements RIGHTCURLY {printf("statement -> WHILE LEFTPAREN boolean_expressions RIGHTPAREN LEFTCURLY statements RIGHTCURLY\n");}
        ;

read_statement: READ LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON {printf("read_statement -> READ LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON\n");}

write_statement: WRITE LEFTPAREN expressions RIGHTPAREN SEMICOLON {printf("write_statement -> WRITE LEFTPAREN expressions RIGHTPAREN SEMICOLON\n");}

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

void yyerror(const char* s) {
  fprintf(stderr, "Parse error: %s!\n", s);
  exit(1);
}