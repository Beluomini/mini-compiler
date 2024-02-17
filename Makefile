LEX_FILE = lexico.l
PARSER_FILE = parser.y
TEST_FILE = teste.mini
TEST_FILE2 = bib.mini

all : clear lex parser compiling running

clear:
	@clear
	@echo "MINI COMPILER ---------------------"

lex :
	@echo "\n-> generating lex.yy.c"
	@lex $(LEX_FILE)

parser : 
	@echo "\n-> generating parser.tab.c"
	@yacc -v -d $(PARSER_FILE)

compiling : 
	@echo "\n-> compiling"
	@gcc y.tab.c

running :
	@echo "\n-> running..."
	@./a.out $(TEST_FILE) $(TEST_FILE2)
