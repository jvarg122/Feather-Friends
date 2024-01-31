all: print_lexer parser print_parser

print_lexer: lex.yy.c
	gcc -o $@ $< -lfl

parser: lex.yy.c parser.tab.c parser.tab.h
	gcc -o parser parser.tab.c lex.yy.c -lfl -lm

print_parser: lex.yy.c print_parser.tab.c parser.tab.h
	gcc -o print_parser print_parser.tab.c lex.yy.c -lfl -lm

%.yy.c: %.lex
	flex -o$@ $<

%.tab.c %.tab.h: %.y
	bison -t -v -d $<

clean:
	-rm -f *.tab.c *.tab.h *.yy.c *.output print_lexer parser