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
%token READ WHILE IF ELSE CONTINUE LEFTBRACKET RIGHTBRACKET
%token LESS LESSEQUAL GREATER GREATEREQUAL EQUALITY NOTEQUAL
%token <op_value> NUMBER
%token <op_value> TOKEN_IDENTIFIER
%type <op_value> function_header

%type <code_node> program
%type <code_node> function
%type <code_node> new_parameters
%type <code_node> new_parameter
%type <code_node> statements
%type <code_node> statement
%type <code_node> return_statement
%type <code_node> assign_statement
%type <code_node> if_statement
%type <code_node> else_statement
%type <code_node> while_statement
%type <code_node> read_statement
%type <code_node> new_variable
%type <code_node> print
%type <code_node> function_call
%type <code_node> boolean_expressions
%type <code_node> expressions
%type <code_node> expression
%type <code_node> parameters
%type <code_node> parameter
%type <code_node> type
%type <code_node> new_array
%type <code_node> array_get_pointer
%type <code_node> variable


%start program

%%
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

function_header: FUNC TOKEN_IDENTIFIER {
        std::string function_name = $2;
        add_function_to_symbol_table(function_name);
        $$ = $2;
}

function: function_header LEFTPAREN new_parameters RIGHTPAREN LEFTCURLY statements RIGHTCURLY {
        struct CodeNode *node = new CodeNode;
        struct CodeNode *new_parameters = $3;
        struct CodeNode *statements = $6;
        node->code = std::string("func ") + std::string($1) + std::string("\n");
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

new_parameter: type TOKEN_IDENTIFIER {
                std::string variable_name = $2;
                add_variable_to_symbol_table(variable_name, Integer);

                struct CodeNode *node = new CodeNode;
                struct CodeNode *type = $1;
                node->code = type->code;
                node->code += std::string(". ") + std::string($2) + std::string("\n");
                $$ = node;
}
            | type TOKEN_IDENTIFIER COMMA new_parameter {
                std::string variable_name = $2;
                add_variable_to_symbol_table(variable_name, Integer);

                struct CodeNode *node = new CodeNode;
                struct CodeNode *type = $1;
                struct CodeNode *new_parameter = $4;
                node->code = type->code;
                node->code += std::string(". ") + std::string($2) + std::string("\n");
                node->code += new_parameter->code;
                $$ = node;
}
            ;

parameters: %empty {
                struct CodeNode *node = new CodeNode;
                $$ = node;
}
          | parameter {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node;
}
          ;

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
                $$ = node;
}
          | statements statement {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + $2->code;
                $$ = node;
}
          ;

statement: new_variable {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node;
}
        | new_array {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node;
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
        | if_statement {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node;
}
        | while_statement {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node;
}
        | read_statement {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node;
}
        | return_statement {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node;
}
        | assign_statement {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                $$ = node;
}
        | BREAK SEMICOLON {
                // TODO
                struct CodeNode *node = new CodeNode;
                node->code = std::string("TODO: break") + std::string("\n");
                $$ = node;
}
        | CONTINUE SEMICOLON {
                // TODO
                struct CodeNode *node = new CodeNode;
                node->code = std::string("TODO: continue") + std::string("\n");
                $$ = node;
}
        ;

if_statement: IF boolean_expressions LEFTCURLY statements RIGHTCURLY else_statement {
    struct CodeNode *node = new CodeNode;
    struct CodeNode *if_label = create_temporary_variable(); 
    struct CodeNode *else_label = create_temporary_variable(); 
    node->code += $2->code;
    node->code += std::string("?:= ") + if_label->name + ", " + else_label->name + "\n";
    node->code += $4->code;
    node->code += std::string(":") + if_label->name + "\n";
    node->code += $6->code;
    node->code += std::string(":") + else_label->name + "\n";
    $$ = node;
}

new_array: type LEFTBRACKET NUMBER RIGHTBRACKET TOKEN_IDENTIFIER SEMICOLON {
                // TODO
                struct CodeNode *node = new CodeNode;
                $$ = node;
}


array_get_pointer: TOKEN_IDENTIFIER LEFTBRACKET NUMBER RIGHTBRACKET {
                // TODO
                struct CodeNode *node = new CodeNode;
                $$ = node;
}

assign_statement: TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code += "= " + std::string($1) + ", " +  std::string($3) + std::string("\n");
                $$ = node;
}
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = currentTemp->code + std::string("\n");
                node->code += $3->code;
                node->code += "= " + std::string($1) + ", " + currentTemp->name + std::string("\n");
                $$ = node;
} 
        | array_get_pointer ASSIGN expressions SEMICOLON {
                // TODO
                struct CodeNode *node = new CodeNode;
                $$ = node;
}
        ;

return_statement: RETURN TOKEN_IDENTIFIER SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string("ret ") + std::string($2) + std::string("\n");
                $$ = node;
}
        ;

else_statement: ELSE LEFTCURLY statement RIGHTCURLY {
                struct CodeNode *node = new CodeNode;
                struct CodeNode *else_label = create_temporary_variable();
                node->code += ":=" + else_label->name + "\n"; 
                node->code += $3->code; 
                $$ = node;
}
             | %empty {
                struct CodeNode *node = new CodeNode;
                $$ = node;
}
             ;

while_statement: WHILE boolean_expressions LEFTCURLY statements RIGHTCURLY {
struct CodeNode *node = new CodeNode;
    struct CodeNode *begin_loop_label = create_temporary_variable();
    struct CodeNode *end_loop_label = create_temporary_variable();
    node->code += ":" + begin_loop_label->name + "\n";
    node->code += $2->code; 
    node->code += "?:= " + end_loop_label->name + ", " + $2->name + "\n";
    node->code += $4->code; 
    node->code += ":= " + begin_loop_label->name + "\n";
    node->code += ":" + end_loop_label->name + "\n";
    $$ = node;
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

new_variable: type TOKEN_IDENTIFIER SEMICOLON {
                std::string variable_name = $2;
                add_variable_to_symbol_table(variable_name, Integer);

                struct CodeNode *node = new CodeNode;
                node->code = std::string(". ") + std::string($2) + std::string("\n");
                $$ = node;
}
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {
                std::string variable_name = $2;
                add_variable_to_symbol_table(variable_name, Integer);
                
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + ". " + std::string($2); 
                node->code += "= " + std::string($2) + ", " + std::string($4) + std::string("\n");
                $$ = node;
}
            ;


variable: NUMBER {
                struct CodeNode *node = new CodeNode;
                node->code = std::string($1);
                $$ = node;
}
          | TOKEN_IDENTIFIER {
                struct CodeNode *node = new CodeNode;
                node->code = std::string($1);
                $$ = node;
}
          | array_get_pointer {
                struct CodeNode *node = new CodeNode;
                $$ = node;
}
          | function_call {
                struct CodeNode *node = new CodeNode;
                $$ = node;
}
          ;

type: INT {
                struct CodeNode *node = new CodeNode;
                $$ = node;
}
            ;

print: PRINT LEFTPAREN variable RIGHTPAREN SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code += ".> " + $3->code + std::string("\n");
                $$ = node;
}
            ;

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters SEMICOLON {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = $3->code;
                node->code += temp->code;
                node->code += "call " + std::string($1) + ", " + temp->name + std::string("\n");
                $$ = node;
}
            ;

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

expression: variable {
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
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



