%{
    #include <stdio.h>
    #include <stdlib.h>
    
    
    int yyerror(char *s);
    int yylex(void);
%}


%token FUNC RETURN INT PRINT BREAK LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY 
%token COMMA SEMICOLON PLUS SUBTRACT MULTIPLY DIVIDE MODULUS ASSIGN NUMBER
%token READ WRITE WHILE IF ELSE CONTINUE LEFTBRACKET RIGHTBRACKET
%token LESS LESSEQUAL GREATER GREATEREQUAL EQUALITY NOTEQUAL
%token COMMENT TOKEN_IDENTIFIER

%start program

%%

// ====================
// TODO: Dalton Witt
// ====================
program: %empty {printf("program -> epsilon\n");}
        | program function {printf("program -> program function\n");}
        | COMMENT {printf("program -> COMMENT\n");}
        ;

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

// ====================
// TODO: Josue
// ====================
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
statement: new_variable {printf("statement -> new_variable\n");}
        | function_call {printf("statement -> function_call\n");}
        | print {printf("statement -> print\n");}

// ====================
// TODO: Jen Hua
// ====================
        | RETURN TOKEN_IDENTIFIER SEMICOLON {printf("statement -> RETURN TOKEN_IDENTIFIER SEMICOLON\n");}
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON {printf("statement -> TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON\n");}
        | COMMENT {printf("statement -> COMMENT\n");}
        | BREAK SEMICOLON {printf("statement -> BREAK SEMICOLON\n");}
        ;

// int x;
// int x = 0;
new_variable: type TOKEN_IDENTIFIER SEMICOLON {printf("new_variable -> type TOKEN_IDENTIFIER SEMICOLON\n");}
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {printf("new_variable -> type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON\n");}
            ;

type: INT

print: PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON {printf("print -> PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON\n");}

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters SEMICOLON {printf("function_call -> TOKEN_IDENTIFIER LEFTPAREN parameters RIGHTPAREN SEMICOLON\n");}

// ====================
// TODO: Alejandro
// ====================
expressions: %empty                 {printf("expressions -> epsilon\n");}
           | expressions expression {printf("expressions -> expressions expression\n");}
           ;

expression: NUMBER {printf("expression -> NUMBER\n");}
          | TOKEN_IDENTIFIER {printf("expression -> TOKEN_IDENTIFIER\n");}
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