%{

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <string>
#include <sstream>

struct CodeNode {
  std::string code;
  std::string name;
};

int yylex();
void yyerror(const char *s);
enum Type { Integer, Array };
int tempval = 0;
CodeNode *currentTemp;

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;

CodeNode *create_temporary_variable(){
  struct CodeNode *temp = new CodeNode;
  std::stringstream sstm;
  sstm << "__temp" << tempval << "__";
  temp->name = sstm.str();
  temp->code = ". " + std::string(temp->name);
  currentTemp = temp;
  tempval++;
  return temp;
}

// remember that Bison is a bottom up parser: that it parses leaf nodes first before
// parsing the parent nodes. So control flow begins at the leaf grammar nodes
// and propagates up to the parents.
Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
    printf("***Error. Attempt to call get_function with an empty symbol table\n");
    printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    printf("calling 'find' or 'add_variable_to_symbol_table'");
    exit(1);
  }
  return &symbol_table[last];
}

// find a particular variable using the symbol table.
// grab the most recent function, and linear search to
// find the symbol you are looking for.
// you may want to extend "find" to handle different types of "Integer" vs "Array"
bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

// when you see a function declaration inside the grammar, add
// the function name to the symbol table
void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

// when you see a symbol declaration inside the grammar, add
// the symbol name as well as some type information to the symbol table
void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

// a function to print out the symbol table to the screen
// largely for debugging purposes.
void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

%}

%union {
  char *op_value;
  struct CodeNode *code_node;
}

%define parse.error verbose

%token FUNC RETURN INT PRINT BREAK LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY 
%token COMMA SEMICOLON PLUS SUBTRACT MULTIPLY DIVIDE MODULUS ASSIGN
%token READ WRITE WHILE IF ELSE CONTINUE LEFTBRACKET RIGHTBRACKET
%token LESS LESSEQUAL GREATER GREATEREQUAL EQUALITY NOTEQUAL
%token <op_value> NUMBER
%token <op_value> TOKEN_IDENTIFIER

%type <code_node> program
%type <code_node> function
%type <code_node> new_parameters
%type <code_node> new_parameter
%type <code_node> statements
%type <code_node> statement
%type <code_node> new_variable
%type <code_node> print
%type <code_node> function_call
%type <code_node> expressions
%type <code_node> expression
%type <code_node> parameters
%type <code_node> parameter
%type <code_node> type

%start program

%%

// ====================
// TODO: Dalton Witt
// ====================
program: %empty {
        struct CodeNode *node = new CodeNode;
        $$ = node;
}
        | program function {
                struct CodeNode *program = $1;
                struct CodeNode *function = $2;
                struct CodeNode *node = new CodeNode;
                node->code = program->code + function->code;
                printf("%s", node->code.c_str());
                print_symbol_table();
                $$ = node;
}

function: FUNC TOKEN_IDENTIFIER LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY {
        struct CodeNode *node = new CodeNode;
        struct CodeNode *new_parameters = $4;
        struct CodeNode *statements = $7;
        node->code = std::string("func ") + std::string($2) + std::string("\n");
        node->code += new_parameters->code;
        node->code += statements->code;
        node->code += std::string("endfunc\n\n");
        $$ = node;
}

new_parameters: %empty {
        struct CodeNode *node = new CodeNode;
        $$ = node;
}
          | new_parameter {
                struct CodeNode *new_parameter = $1;
                $$ = new_parameter;
}
          ;

// int x
// int x, int y
new_parameter: type TOKEN_IDENTIFIER {
                struct CodeNode *node = new CodeNode;
                struct CodeNode *type = $1;
                node->code = type->code;
                node->code += std::string(". ") + std::string($2) + std::string("\n");
                $$ = node;
}
            | type TOKEN_IDENTIFIER COMMA new_parameter {
                struct CodeNode *node = new CodeNode;
                struct CodeNode *type = $1;
                struct CodeNode *new_parameter = $4;
                node->code = type->code;
                node->code += std::string(". ") + std::string($2) + std::string("\n");
                node->code += new_parameter->code;
                $$ = node;
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
                $$ = node;
}
          ;

// x
// x, y, z 
parameter: TOKEN_IDENTIFIER {
                struct CodeNode *node = new CodeNode;
                node->code = "param " + std::string($1) + std::string("\n");
                $$ = node;

}
        | TOKEN_IDENTIFIER COMMA parameter {
                struct CodeNode *node = new CodeNode;
                node->code = "param " + std::string($1) + std::string("\n");
                node->code += $3->code;
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
                node->code = $1->code;
                $$ = node;
}
        | print {
            struct CodeNode *node = new CodeNode;
            node->code = $1->code;
            $$ = node;
}

// ====================
// TODO: Jen Hua
// ====================
        | RETURN TOKEN_IDENTIFIER SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string("return ") + std::string($2) + std::string("\n");
                $$ = node;
}
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = currentTemp->code + std::string("\n");
                node->code += $3->code;
                node->code += "= " + std::string($1) + ", " + currentTemp->name + std::string("\n");
                $$ = node;
}
        | TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code += "= " + std::string($1) + ", " +  std::string($3) + std::string("\n");
                $$ = node;
}
        | BREAK SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string("TODO: break") + std::string("\n");
                $$ = node;
}
        | CONTINUE SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string("TODO: continue") + std::string("\n");
                $$ = node;
}
        | if_statement {printf("statement -> if_statement\n");}
        | while_statement {printf("statement -> while_statement\n");}
        | read_statement {printf("statement -> read_statement\n");}
        ;

if_statement: IF boolean_expressions LEFTCURLY statements RIGHTCURLY else_statement {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_label();
		node->code += temp->code;
                node->code = std::string("?:= ") + temp->name + std::string(", ") + std::string($2);
		$$ = node;
 
}
        ;

else_statement: ELSE LEFTCURLY statement RIGHTCURLY {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_label();
		node->code += temp->code;
                node->code = std::string(":= ") + temp->name;
		$$ = node;
}
             ;

while_statement: WHILE boolean_expressions LEFTCURLY statements RIGHTCURLY {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_label();
		node->code += temp->code;
                node->code = std::string("?:= ") + temp->name + std::string(", ") + std::string($2);
		$$ = node;
 
}
}
        ;

read_statement: READ LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON {
		struct CodeNode *node = new CodeNode;
                node->code = std::string(".< ") + std::string($3);
		$$ = node;
			}


boolean_expressions: expression GREATER expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code = std::string("> ") + temp->name + std::string(", ") + $1->code + std::string(", ") + $3->code;
                $$ = node;		
			}
                   | expression LESS expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code = std::string("< ") + temp->name + std::string(", ") + $1->code + std::string(", ") + $3->code;
                $$ = node;		
			}
                   | expression LESSEQUAL expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code = std::string("<= ") + temp->name + std::string(", ") + $1->code + std::string(", ") + $3->code;
                $$ = node;		
			}
                   | expression GREATEREQUAL expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code = std::string(">= ") + temp->name + std::string(", ") + $1->code + std::string(", ") + $3->code;
                $$ = node;		
			}
                   | expression EQUALITY expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code = std::string("= ") + temp->name + std::string(", ") + $1->code + std::string(", ") + $3->code;
                $$ = node;		
			}
                   | expression NOTEQUAL expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code = std::string("!= ") + temp->name + std::string(", ") + $1->code + std::string(", ") + $3->code;
                $$ = node;		
			}
                   ;

// int x;
// int x = 0;
new_variable: type TOKEN_IDENTIFIER SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string(". ") + std::string($2) + std::string("\n");
                $$ = node;
}
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + ". " + std::string($2); 
                node->code += "= " + std::string($2) + ", " + std::string($4) + std::string("\n");
                $$ = node;
}
            ;

type: INT {
                struct CodeNode *node = new CodeNode;
                $$ = node;
}

print: PRINT LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = ".> " + std::string($3) + std::string("\n");
                $$ = node;
}

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters SEMICOLON {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = $3->code;
                node->code += temp->code;
                node->code += "call " + std::string($1) + ", " + temp->name + std::string("\n");
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
                node->code = std::string($1);
                $$ = node;
}
          | TOKEN_IDENTIFIER {
                struct CodeNode *node = new CodeNode;
                node->code = std::string($1);
                $$ = node;
}
          | expression PLUS expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = "+ " + temp->name + ", " + $1->code + ", " + $3->code + std::string("\n");
                $$ = node;
}
          | expression SUBTRACT expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = "- " + temp->name + ", " + $1->code + ", " + $3->code + std::string("\n");
                $$ = node;
}
          | expression MULTIPLY expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = "* " + temp->name + ", " + $1->code + ", " + $3->code + std::string("\n");
                $$ = node;
}
          | expression DIVIDE expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = "/ " + temp->name + ", " + $1->code + ", " + $3->code + std::string("\n");
                $$ = node;
}
          | expression MODULUS expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = "% " + temp->name + ", " + $1->code + ", " + $3->code + std::string("\n");
                $$ = node;

}
          ;
%%

int main(void) {
  yyparse();
}

void yyerror(const char *s) {
  printf("Error: %s\n", s);
}



