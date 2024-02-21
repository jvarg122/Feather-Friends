nclude <stdio.h>
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
                struct CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
}
          | parameter {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node
}
          ;

// x
// x, y, z 
parameter: TOKEN_IDENTIFIER {
                struct CodeNode *node = new CodeNode;
                node->code = std::string($1);
                $$ = node;

}
        | TOKEN_IDENTIFIER COMMA parameter {
                struct CodeNode *node = new CodeNode;
                node->code = std::string($1) + ", " + $3->code;
                $$ = node;
}
        ;

statements: %empty {
                struct CodeNode *node = new CodeNode;
                node->code = "";
                $$ = node;
}
          | statements statement {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + $2->code;
                $$ = node;
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
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + ";";
                $$ = node;
}
        | print {
            struct CodeNode *node = new CodeNode;
            node->code = "printf(\"%d\", " + std::string($3->code) + ");";
            $$ = node;
}

// ====================
// TODO: Jen Hua
// ====================
        | RETURN TOKEN_IDENTIFIER SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string("return ") + std::string($2) + std::string(";");
                $$ = node;
}
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string($1) + std::string(" = ")  + $3->code + std::string()";";
                $$ = node;
}
        | COMMENT {
                struct CodeNode *node = new CodeNode;
                node->code = std::string("VV ") + $1->code + std::string(";");
                $$ = node;
}
        | BREAK SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string("break;");
                $$ = node;
}
        ;

// int x;
// int x = 0;
new_variable: type TOKEN_IDENTIFIER SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + std::string(" ") + std::string($2) + std::string(";");
                $$ = node;
}
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + " " + $2->code + " = " + std::to_string($4) + std::string(";");
                $$ = node;
}
            ;

type: INT {
                struct CodeNode *node = new CodeNode;
                node->code = "int";
                $$ = node;      
}

print: PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = "printf(\"%d\", " + std::string($3) + ");";
                $$ = node;
}

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string($1) + "(" + $3->code + ");";
                $$ = node;
}

// ====================
// TODO: Alejandro
// ====================
expressions: %empty {
                struct CodeNode *node = new CodeNode;
                $$ = node;

}
           | expressions expression {
                struct CodeNode *expr = $2;
                struct CodeNode *exprs = $1;
                struct CodeNode *node = new CodeNode;
                node->code = exprs->code + expr->code;
                $$ = node;
}
           ;

expression: NUMBER {
                struct CodeNode *node = new CodeNode;
                node->code = std::to_string($1);
                $$ = node;
}
          | TOKEN_IDENTIFIER {
                struct CodeNode *node = new CodeNode;
                node->code = std::string($1);
                $$ = node;
}
          | expression PLUS expression {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + " + " + $3->code;
                $$ = node;
}
          | expression SUBTRACT expression {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + " - " + $3->code;
                $$ = node;
}
          | expression MULTIPLY expression {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + " * " + $3->code;
                $$ = node;
}
          | expression DIVIDE expression {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + " / " + $3->code;
                $$ = node;
}
          | expression MODULUS expression {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + " % " + $3->code;
                $$ = node;

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


