%{

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <string.h>
#include <sstream>

enum Type { Integer, Array };

struct CodeNode {
  std::string code;
  std::string name;
};

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

struct WhileLoop{
    CodeNode *beginLabel;
    CodeNode *endLabel;
};

int yylex();
extern int yylineno;
void yyerror(const char *s);
int tempval = 0;
int labelval = 0;
const Function *emptyfn = new Function;
CodeNode *currentTemp;
CodeNode *currentLabel;
WhileLoop *currentWhileLoop;


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

CodeNode *create_label(){
  struct CodeNode *label = new CodeNode;
  std::stringstream sstm;
  sstm << "__label" << labelval << "__";
  label->name = sstm.str();
  label->code = ". " + std::string(label->name);
  currentLabel = label;
  labelval++;
  return label;
}

// remember that Bison is a bottom up parser: that it parses leaf nodes first before
// parsing the parent nodes. So control flow begins at the leaf grammar nodes
// and propagates up to the parents.
Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
        // Return empty function if not found
        Function *f = new Function;
        return f;
    //printf("***Error. Attempt to call get_function with an empty symbol table\n");
    //printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    //printf("calling 'find' or 'add_variable_to_symbol_table'");
    //exit(1);
  }
  return &symbol_table[last];
}

// find a particular variable using the symbol table.
// grab the most recent function, and linear search to
// find the symbol you are looking for.
// you may want to extend "find" to handle different types of "Integer" vs "Array"
bool find(std::string &value, Type type = Integer) {
  Function *f = get_function();
  if(f == emptyfn) {
    // no function found
    return false;
  }
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value && s->type == type) {
      return true;
    }
  }
  return false;
}

// when you see a function declaration inside the grammar, add
// the function name to the symbol table
void add_function_to_symbol_table(std::string &value) {
  if(symbol_table.size() != 0 && find(value)){
        yyerror("Duplicate Function");
  }

  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

// when you see a symbol declaration inside the grammar, add
// the symbol name as well as some type information to the symbol table
void add_variable_to_symbol_table(std::string &value, Type t) {
  if(symbol_table.size() != 0 && find(value)){
        //yyerror("Duplicate Variable tried to be added to the symbol table");
  }

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

// ========================
// ERROR HANDLING FUNCTIONS
// ========================
void errchk_duplicate_variable(std::string variable_name, Type type = Integer) {
    if(find(variable_name, type)) {
        yyerror(std::string("Duplicate variable: " + variable_name).c_str());
    }
}

void errchk_duplicate_function(std::string function_name) {
    /*
    if(find(function_name)) {
        yyerror(std::string("Duplicate function: " + function_name).c_str());
    }
    */
}

void errchk_using_undeclared_variable(std::string variable_name, Type type = Integer) {
    if(!find(variable_name, type)) {
        yyerror(std::string("Tried to access variable that doesn't exist: " + variable_name).c_str());
    }
}

void errchk_using_undeclared_function(std::string function_name) {
    if(!find(function_name)) {
        yyerror(std::string("Tried to call a function that doesn't exist: " + function_name).c_str());
    }
}

void errchk_does_main_exist() {
    bool foundMain = false;
    //printf("\n\n=========\n");
    for(int i=0; i<symbol_table.size(); i++) {
        if(strcmp(symbol_table[i].name.c_str(), "main") == 0)
        {
            foundMain = true;
        }
    }
    //printf("\n=========\n");
    //printf("%d\n\n", foundMain);
    if(!foundMain) {
        yyerror("There is no main()!");
    }
}

void errchk_assert_variable_is_array(std::string variable_name) {
    if(!find(variable_name, Array) && find(variable_name)) {
        yyerror(std::string("Tried to use a non-array variable: \"" + variable_name + "\" like an array.").c_str());
    }
}

void errchk_assert_non_zero(std::string string_number) {
    int num = std::stoi(string_number);
    if(!(num > 0)) {
        yyerror("Array size must be greater than zero.");
    }
}

%}

%union {
  char *op_value;
  struct CodeNode *code_node;
}

%locations

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
                errchk_does_main_exist();

                printf("%s", node->code.c_str());
                print_symbol_table();
                $$ = node;
}

function_header: FUNC TOKEN_IDENTIFIER {
        std::string function_name = $2;
        errchk_duplicate_function(function_name);
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
                errchk_duplicate_variable(variable_name);
                add_variable_to_symbol_table(variable_name, Integer);

                struct CodeNode *node = new CodeNode;
                struct CodeNode *type = $1;
                node->code = type->code;
                node->code += std::string(". ") + std::string($2) + std::string("\n");
                $$ = node;
}
            | type TOKEN_IDENTIFIER COMMA new_parameter {
                std::string variable_name = $2;
                errchk_duplicate_variable(variable_name);
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
                std::string variable_name = std::string($1);
                errchk_using_undeclared_variable(variable_name);
        
                struct CodeNode *node = new CodeNode;
                node->code = "param " + std::string($1) + std::string("\n");
                $$ = node;

}
        | TOKEN_IDENTIFIER COMMA parameter {
                std::string variable_name = std::string($1);
                errchk_using_undeclared_variable(variable_name);

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
                struct CodeNode *node = new CodeNode;
                node->code = std::string(":= end") + currentWhileLoop->endLabel->name;
                $$ = node;
}
        | CONTINUE SEMICOLON {
                struct CodeNode *node = new CodeNode;
                node->code = std::string(":= end") + currentWhileLoop->beginLabel->name;
                $$ = node;
}
        ;

if_statement: IF boolean_expressions LEFTCURLY statements RIGHTCURLY else_statement {
    struct CodeNode *node = new CodeNode;
    struct CodeNode *if_label = create_label(); 
    struct CodeNode *else_label = create_label();

    node->code += $2->code;
    node->code += std::string("?:= ") + if_label->name + ", " + $2->name + "\n";
    node->code += $4->code;
    node->code += std::string(":") + if_label->name + "\n";
    node->code += $6->code;
    node->code += std::string(":") + else_label->name + "\n";
    $$ = node;
}

new_array: type LEFTBRACKET NUMBER RIGHTBRACKET TOKEN_IDENTIFIER SEMICOLON {
                std::string variable_name = $5;
                std::string array_size = $3;
                errchk_duplicate_variable(variable_name);
                errchk_assert_non_zero(array_size);

                add_variable_to_symbol_table(variable_name, Array);

                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                node->code += ".[] " + variable_name + ", " + std::string($3) + "\n";
                $$ = node;
}


array_get_pointer: TOKEN_IDENTIFIER LEFTBRACKET NUMBER RIGHTBRACKET {
                // array[1]
                std::string variable_name = $1;
                errchk_using_undeclared_variable(variable_name, Array);
                errchk_assert_variable_is_array(variable_name);

                struct CodeNode *node = new CodeNode;
                struct CodeNode *temp = create_temporary_variable();
                node->code = "=[] " + temp->name + ", " + std::string($1) + ", " + std::string($3) + "\n";
                $$ = node;
}

assign_statement: TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {
                std::string variable_name = $1;
                errchk_using_undeclared_variable(variable_name);

                struct CodeNode *node = new CodeNode;
                node->code += "= " + std::string($1) + ", " +  std::string($3) + "\n";
                $$ = node;
}
        | TOKEN_IDENTIFIER ASSIGN expressions SEMICOLON {
                std::string variable_name = $1;
                errchk_using_undeclared_variable(variable_name);
                
                struct CodeNode *node = new CodeNode;
                node->code += $3->code;
                node->code += "= " + std::string($1) + ", " + currentTemp->name + std::string("\n");
                $$ = node;
} 
        | TOKEN_IDENTIFIER LEFTBRACKET NUMBER RIGHTBRACKET ASSIGN NUMBER SEMICOLON {
                std::string variable_name = $1;
                errchk_using_undeclared_variable(variable_name, Array);
                errchk_assert_variable_is_array(variable_name);
                
                // []= dst, index, src
                // dst[index] = src (index and src are both immediates)
                struct CodeNode *node = new CodeNode;
                node->code += "[]= " + std::string($1) + ", " + std::string($3) + ", " + std::string($6) + std::string("\n");
                $$ = node;
}
        | TOKEN_IDENTIFIER LEFTBRACKET NUMBER RIGHTBRACKET ASSIGN expressions SEMICOLON {
                std::string variable_name = $1;
                errchk_using_undeclared_variable(variable_name, Array);
                errchk_assert_variable_is_array(variable_name);
                
                // []= dst, index, src
                // dst[index] = src (index is an immediate, src is an expression)

                // TODO: need to add two more productions: index is expression, src is immediate [AND] index is expression, src is expression
                struct CodeNode *node = new CodeNode;
                node->code = currentTemp->code + std::string("\n");
                node->code += $6->code;
                node->code += "[]= " + std::string($1) + ", " + std::string($3) + ", " + currentTemp->name + std::string("\n");
                $$ = node;
}
        ;

return_statement: RETURN TOKEN_IDENTIFIER SEMICOLON {
                std::string variable_name = $2;
                errchk_using_undeclared_variable(variable_name);
                
                struct CodeNode *node = new CodeNode;
                node->code = std::string("ret ") + std::string($2) + std::string("\n");
                $$ = node;
}
        ;

else_statement: ELSE LEFTCURLY statement RIGHTCURLY {
                struct CodeNode *node = new CodeNode;
                struct CodeNode *else_label = create_label();
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
    struct WhileLoop *loop = new WhileLoop;
    struct CodeNode *begin_loop_label = create_label();
    struct CodeNode *end_loop_label = create_label();
    loop->beginLabel = begin_loop_label;
    loop->endLabel = end_loop_label;
    currentWhileLoop = loop;

    node->code = ":" + begin_loop_label->name + "\n";
    node->code += $2->code; 
    node->code += "?:= " + end_loop_label->name + ", " + $2->name + "\n";
    node->code += $4->code; 
    node->code += ":= " + begin_loop_label->name + "\n";
    node->code += ":" + end_loop_label->name + "\n";
    $$ = node;
}
        ;

read_statement: READ LEFTPAREN TOKEN_IDENTIFIER RIGHTPAREN SEMICOLON {
                std::string variable_name = $3;
                errchk_using_undeclared_variable(variable_name);
                
		      struct CodeNode *node = new CodeNode;
          node->code = std::string(".< ") + std::string($3);
		      $$ = node;
			}

boolean_expressions: expression GREATER expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code = temp->code;
                node->code += $1->code;
                node->code += $3->code + "\n";
                node->code += std::string("> ") + temp->name + std::string(", ") + $1->name + std::string(", ") + $3->name + "\n";

                node->name = temp->name;
                $$ = node;		
			}
                   | expression LESS expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code = temp->code;
                node->code += $1->code;
                node->code += $3->code + "\n";
                node->code += std::string("< ") + temp->name + std::string(", ") + $1->name + std::string(", ") + $3->name + "\n";

                node->name = temp->name;
                $$ = node;		
			}
                   | expression LESSEQUAL expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code += $1->code;
                node->code += $3->code + "\n";
                node->code = std::string("<= ") + temp->name + std::string(", ") + $1->name + std::string(", ") + $3->name + "\n";

                node->name = temp->name;
                $$ = node;		
			}
                   | expression GREATEREQUAL expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code += $1->code;
                node->code += $3->code + "\n";
                node->code = std::string(">= ") + temp->name + std::string(", ") + $1->name + std::string(", ") + $3->name + "\n";

                node->name = temp->name;
                $$ = node;		
			}
                   | expression EQUALITY expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code += $1->code;
                node->code += $3->code + "\n";
                node->code = std::string("= ") + temp->name + std::string(", ") + $1->name + std::string(", ") + $3->name + "\n";

                node->name = temp->name;
                $$ = node;		
			}
                   | expression NOTEQUAL expression {
		struct CodeNode *node = new CodeNode;
		struct CodeNode *temp = create_temporary_variable();
		node->code += temp->code;
                node->code += $1->code;
                node->code += $3->code + "\n";
                node->code = std::string("!= ") + temp->name + std::string(", ") + $1->name + std::string(", ") + $3->name + "\n";

                node->name = temp->name;
                $$ = node;		
			}
                   ;

new_variable: type TOKEN_IDENTIFIER SEMICOLON {
                std::string variable_name = $2;
                errchk_duplicate_variable(variable_name);
                add_variable_to_symbol_table(variable_name, Integer);

                struct CodeNode *node = new CodeNode;
                node->code = std::string(". ") + std::string($2) + std::string("\n");
                $$ = node;
}
            | type TOKEN_IDENTIFIER ASSIGN NUMBER SEMICOLON {
                std::string variable_name = $2;
                errchk_duplicate_variable(variable_name);
                add_variable_to_symbol_table(variable_name, Integer);
                
                struct CodeNode *node = new CodeNode;
                node->code = $1->code + ". " + std::string($2); 
                node->code += "= " + std::string($2) + ", " + std::string($4) + std::string("\n");
                $$ = node;
}
            ;


variable: NUMBER {
                struct CodeNode *node = new CodeNode;
                //node->code = std::string($1);
                node->name = std::string($1);
                $$ = node;
}
          | TOKEN_IDENTIFIER {
                std::string variable_name = std::string($1);
                errchk_using_undeclared_variable(variable_name);

                struct CodeNode *node = new CodeNode;
                //node->code = std::string($1);
                node->name = std::string($1);
                $$ = node;
}
          | array_get_pointer {
                struct CodeNode *node = new CodeNode;
                node->code = currentTemp->code + "\n";
                node->code += $1->code;
                node->name = std::string(currentTemp->name);
                $$ = node;
}
          | function_call {
                struct CodeNode *node = new CodeNode;
                node->code = currentTemp->code + "\n";
                node->code += $1->code;
                node->name = std::string(currentTemp->name);
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
                node->code = $3->code;
                node->code += ".> " + currentTemp->name + std::string("\n");
                $$ = node;
}
            ;

function_call: TOKEN_IDENTIFIER LEFTPAREN parameters RIGHTPAREN {
                std::string function_name = $1;
                errchk_using_undeclared_function(function_name);

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
                node->name = $1->name;
                $$ = node;
}
          | expression PLUS expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                node->code += $3->code;
                node->name = currentTemp->name;
                node->code += temp->code + "\n";;
                node->code += "+ " + temp->name + ", " + $1->name + ", " + $3->name + std::string("\n");
                $$ = node;
}
          | expression SUBTRACT expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                node->code += $3->code;
                node->name = currentTemp->name;
                node->code += temp->code + "\n";;
                node->code += "- " + temp->name + ", " + $1->name + ", " + $3->name + std::string("\n");
                $$ = node;
}
          | expression MULTIPLY expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                node->code += $3->code;
                node->name = currentTemp->name;
                node->code += temp->code + "\n";;
                node->code += "* " + temp->name + ", " + $1->name + ", " + $3->name + std::string("\n");
                $$ = node;
}
          | expression DIVIDE expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                node->code += $3->code;
                node->name = currentTemp->name;
                node->code += temp->code + "\n";;
                node->code += "/ " + temp->name + ", " + $1->name + ", " + $3->name + std::string("\n");
                $$ = node;
}
          | expression MODULUS expression {
                struct CodeNode *temp = create_temporary_variable();
                struct CodeNode *node = new CodeNode;
                node->code = $1->code;
                node->code += $3->code;
                node->name = currentTemp->name;
                node->code += temp->code + "\n";
                node->code += "% " + temp->name + ", " + $1->name + ", " + $3->name + std::string("\n");
                $$ = node;

}         | LEFTPAREN expression RIGHTPAREN {
                struct CodeNode *node = new CodeNode;
                node->code = $2->code;
                node->name = $2->name;
                $$ = node;
          }
          ;
%%

int main(void) {
  yyparse();
}

void yyerror(const char *s) {
  fprintf(stderr,"Error | Line: %d\n%s\n",yylineno,s);
}


