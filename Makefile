all: print_lexer parser print_parser

print_lexer: print_lexer.yy.c
	g++ -o $@ $< -lfl -std=c++11

parser: lexer.yy.c parser.tab.c parser.tab.h
	g++ -o parser parser.tab.c lexer.yy.c -lfl -lm -std=c++11

print_parser: lexer.yy.c print_parser.tab.c parser.tab.h
	g++ -o print_parser print_parser.tab.c lexer.yy.c -lfl -lm -std=c++11

%.yy.c: %.lex
	flex -o$@ $<

%.tab.c %.tab.h: %.y
	bison -t -v -d $<

clean:
	-rm -f *.tab.c *.tab.h *.yy.c *.output print_lexer parser