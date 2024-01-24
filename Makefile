LEX_FILE = lexico.l
PARSER_FILE = parser.y
TEST_FILE = teste.mini

all : clear lex parser compiling running

lex :
	@echo "generating lex.yy.c"
	@lex $(LEX_FILE)

parser : 
	@echo "generating parser.tab.c"
	@yacc -v -d $(PARSER_FILE)

clear:
	@echo "clearing"
	@clear

compiling : 
	@echo "compiling"
	@gcc y.tab.c

running :
	@echo "running"
	@./a.out < $(TEST_FILE)
