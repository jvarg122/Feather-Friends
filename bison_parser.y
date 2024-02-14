%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string>

    struct CodeNode {
        std::string code;
        std::string name;
    }
    
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
program: %empty {
        
}
        | program function {
                
}
        | COMMENT {

}
        ;

function: FUNC TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY {

}
        | FUNC type TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY {

}
        ;

new_parameters: %empty {

}
          | new_parameter {

}
          ;

// int x
// int x, int y
new_parameter: type TOKEN_IDENTIFIER {

}
            | type TOKEN_IDENTIFIER COMMA new_parameter {

}
            ;

// ====================
// TODO: Josue
// ====================
parameters: %empty {

}
          | parameter {

}
          ;

// x
// x, y, z 
parameter: TOKEN_IDENTIFIER {

}
        | TOKEN_IDENTIFIER COMMA parameter {

}
        ;

statements: %empty {

}
          | statements statement {

}
          ;

// a = b;
// return a;
// int x;
// int x = 0;
// x = y + 1
statement: new_variable {

}
        | function_call {

}
        | print {

}

// ====================
// TODO: Jen Hua
// ====================
        | RETURN TOKEN_IDENTIFIER SEMICOLON {

}
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON {

}
        | COMMENT {

}
        | BREAK SEMICOLON {

}
        ;

// int x;
// int x = 0;
new_variable: type TOKEN_IDENTIFIER SEMICOLON {

}
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {

}
            ;

type: INT {
        
}

print: PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON {

}

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters SEMICOLON {

}

// ====================
// TODO: Alejandro
// ====================
expressions: %empty {

}
           | expressions expression {

}
           ;

expression: NUMBER {

}
          | TOKEN_IDENTIFIER {

}
          | expression PLUS expression {

}
          | expression SUBTRACT expression {

}
          | expression MULTIPLY expression {

}
          | expression DIVIDE expression {

}
          | expression MODULUS expression {

}
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