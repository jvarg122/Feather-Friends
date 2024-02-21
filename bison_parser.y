%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string>
    
    int yyerror(char *s);
    int yylex(void);

    enum Type { Integer, Array };

    std::vector <Function> symbol_table;

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

    //
    // Helper functions, from the Phase 3 practice portion:
	//

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
        struct CodeNode *node = new CodeNode;
        $$ = node;
}
        | program function {
                struct CodeNode *program = $1;
                struct CodeNode *function = $2;
                struct CodeNode *node = new CodeNode;
                node->code = program->code + function->code;
                $$ = node;
}
        | COMMENT {
                struct CodeNode *node = new CodeNode;
                $$ = node;
}
                
        ;

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
        ;

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
                node->code += std::string(". ") + std::string($2);
                $$ = node;
}
            | type TOKEN_IDENTIFIER COMMA new_parameter {
                struct CodeNode *node = new CodeNode;
                struct CodeNode *type = $1;
                struct CodeNode *new_parameter = $4;
                node->code = type->code;
                node->code += std::string(". ") + std::string($2);
                node->code += new_parameter->code;
                $$ = node;
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