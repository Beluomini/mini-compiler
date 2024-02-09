%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
    #include"lex.yy.c"

    void yyerror(const char *s);
    int yylex();
    int yywrap();

    void add(char);
    void insert_type();
    int search(char *);
    void insert_type();
    void printtree(struct node*);
    void printInorder(struct node *);

    struct node* mknode(struct node *left, struct node *right, char *token);

    struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
    } symbolTable[40];

    int count=0;
    int q;
    char type[10];
    extern int countn;
    struct node *head;
    struct node { 
	struct node *left; 
	struct node *right; 
	char *token; 
    };
%}

%union { 
	struct var_name { 
		char name[100]; 
		struct node* nd;
	} nd_obj; 
} 

%token  TOKEN_VOID
%token	<nd_obj>	TOKEN_INT_NUM TOKEN_FLOAT_NUM TOKEN_CHAR_VAL TOKEN_STR_VAL TOKEN_VAR_ID 
					TOKEN_CLASS_ID TOKEN_CLASS TOKEN_START_METHOD TOKEN_MAIN TOKEN_START_FUNC
					TOKEN_INT TOKEN_FLOAT TOKEN_CHAR TOKEN_STR
					TOKEN_ADD TOKEN_MULT TOKEN_DIV TOKEN_SUB
					TOKEN_PRINTF TOKEN_SCANF TOKEN_WHILE TOKEN_IF TOKEN_ELSE  
					TOKEN_MENOR_IGUAL TOKEN_MAIOR_IGUAL TOKEN_IGUAL TOKEN_DIFERENTE 
					TOKEN_MAIOR TOKEN_MENOR TOKEN_AND TOKEN_OR 
					TOKEN_INCLUDE TOKEN_RETURN

%type	<nd_obj>	program headers body header main
					structs struct classes class methods method methodCall
					functions function functionCall params param actions action
					variableDefinition variableAssignment loop print scan
					comparation comparator
					valueType value arithmetic expression return

%%

program: headers body {
	$$.nd = mknode($1.nd, $2.nd, "program"); 
	head = $$.nd; 
}

headers: header headers { $$.nd = mknode($1.nd, $2.nd, "headers"); }
| {$$.nd = NULL;}
;

header: TOKEN_INCLUDE { add('H'); $$.nd = mknode(NULL, NULL, $1.name); }
;

body: structs main '(' ')' '{'  actions return '}'
{ 
	$2.nd = mknode($6.nd, $7.nd, "main");
    $$.nd = mknode($1.nd, $2.nd, "body"); 
}
;

main: valueType TOKEN_MAIN { add('F'); }
;

structs: struct structs
{
	$$.nd = mknode($1.nd, $2.nd, "structs");
}
| {$$.nd = NULL;}
;

struct: functions
| classes
;

classes: class classes
{
	$$.nd = mknode($1.nd, $2.nd, "classes");
}
| {$$.nd = NULL;}
;

class: TOKEN_CLASS TOKEN_CLASS_ID { add('G'); } '{' actions methods '}'
{
	$$.nd = mknode($5.nd, $6.nd, "class");
}
;

methods: method methods
{
	$$.nd = mknode($1.nd, $2.nd, "methods");
}
| {$$.nd = NULL;}
;

method: TOKEN_START_METHOD { add('K'); } valueType TOKEN_VAR_ID { add('M'); } '(' params ')' '{' actions return '}'
{
	$$.nd = mknode($7.nd, $10.nd, "method");
}
;

methodCall: TOKEN_CLASS_ID '.' TOKEN_VAR_ID '(' params ')'
{
	$$.nd = mknode($5.nd, NULL, "methodCall");
}

functions: function functions
{
	$$.nd = mknode($1.nd, $2.nd, "functions");
}
| {$$.nd = NULL;}

function: TOKEN_START_FUNC { add('K'); } valueType TOKEN_VAR_ID { add('F'); } '(' params ')' '{' actions return '}'
{
	$$.nd = mknode($7.nd, $10.nd, "function");
}
;

functionCall: TOKEN_VAR_ID '(' params ')'
{
	$$.nd = mknode($3.nd, NULL, "functionCall");
}
;

params: param ',' params
{
	$$.nd = mknode($1.nd, $3.nd, "params");
}
| {$$.nd = NULL;}
;

param: valueType TOKEN_VAR_ID { add('V'); }
{
	$$.nd = mknode(NULL, NULL, "param");
}
;

actions: action actions
{
	$$.nd = mknode($1.nd, $2.nd, "actions");
}
| {$$.nd = NULL;}
;

action: variableDefinition
| variableAssignment
| loop
| print
| scan
;

loop: TOKEN_WHILE { add('K'); } '(' comparation ')' '{' actions '}'
{
	$$.nd = mknode($4.nd, $7.nd, "loop");
}
;

print: TOKEN_PRINTF { add('K'); } '(' value ')' ';'
{
	$$.nd = mknode($4.nd, NULL, "print");
}
;

scan: TOKEN_SCANF { add('K'); } '(' TOKEN_VAR_ID ')' ';'
{
	$$.nd = mknode(NULL, NULL, "scan");
}
;

variableDefinition: valueType TOKEN_VAR_ID { add('V'); } '=' expression ';'
{
	$$.nd = mknode($5.nd, NULL, "variableDefinition");
}
;

variableAssignment: TOKEN_VAR_ID '=' expression ';' 
{
	$$.nd = mknode($3.nd, NULL, "variableAssignment");
}
| TOKEN_VAR_ID '=' functionCall ';'
{
	$$.nd = mknode($3.nd, NULL, "variableAssignment");
}
| TOKEN_VAR_ID '=' methodCall ';'
{
	$$.nd = mknode($3.nd, NULL, "variableAssignment");
}
;

expression: expression arithmetic expression
{
	$$.nd = mknode($1.nd, $3.nd, "expression");
}
| value
;

comparation: comparation comparator comparation
{
	$$.nd = mknode($1.nd, $3.nd, "comparation");
}
| comparation comparator value
{
	$$.nd = mknode($1.nd, NULL, "comparation");
}
| value comparator comparation
{
	$$.nd = mknode(NULL, $3.nd, "comparation");
}
| value comparator value
{
	$$.nd = mknode(NULL, NULL, "comparation");
}
;

comparator: TOKEN_MENOR_IGUAL { add('K'); } { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_MENOR { add('K'); } { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_MAIOR_IGUAL { add('K'); } { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_MAIOR { add('K'); } { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_IGUAL { add('K'); } { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_DIFERENTE { add('K'); } { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_AND { add('K'); } { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_OR { add('K'); } { $$.nd = mknode(NULL, NULL, "comparator"); }
;

arithmetic: TOKEN_ADD { add('K'); } { $$.nd = mknode(NULL, NULL, "arithmetic"); }
| TOKEN_SUB { add('K'); } { $$.nd = mknode(NULL, NULL, "arithmetic"); }
| TOKEN_MULT { add('K'); } { $$.nd = mknode(NULL, NULL, "arithmetic"); }
| TOKEN_DIV { add('K'); } { $$.nd = mknode(NULL, NULL, "arithmetic"); }
;

valueType:	TOKEN_INT { insert_type(); }
| TOKEN_FLOAT { add('K'); insert_type(); }
| TOKEN_CHAR { add('K'); insert_type(); }
| TOKEN_STR { add('K'); insert_type(); }
| TOKEN_VOID { add('K'); insert_type(); }
;

value: TOKEN_INT_NUM { add('C'); } { $$.nd = mknode(NULL, NULL, "value"); }
| TOKEN_FLOAT_NUM { add('C'); } { $$.nd = mknode(NULL, NULL, "value"); }
| TOKEN_CHAR_VAL { add('C'); } { $$.nd = mknode(NULL, NULL, "value"); }
| TOKEN_STR_VAL { add('C'); } { $$.nd = mknode(NULL, NULL, "value"); }
| TOKEN_VAR_ID { } { $$.nd = mknode(NULL, NULL, "variable"); }
| functionCall { $$.nd = mknode($1.nd, NULL, "functionCall"); }
| methodCall { $$.nd = mknode($1.nd, NULL, "methodCall"); }
;

return: TOKEN_RETURN { add('K'); } value ';'
{
	$$.nd = mknode($3.nd, NULL, "return");
}
| {$$.nd = NULL;}
;

%%

int main() {
    yyparse();
    printf("\n\n \t\t\t\t PHASE 1: LEXICAL ANALYSIS \n\n");
	printf("\nSYMBOL		DATATYPE	TYPE		LINE NUMBER \n");
	printf("_____________________________________________________________\n\n");
	int i=0;
	for(i=0; i<count; i++) {
		char *posicao = strstr(symbolTable[i].id_name, "incluir");
		if (posicao != NULL) {
			// Avança a posição para o caractere após a palavra "incluir"
			posicao += strlen("incluir");

			printf("%s\t%s\t\t%s\t%d\t\n", posicao, symbolTable[i].data_type, symbolTable[i].type, symbolTable[i].line_no);
		}else{
			printf("%s\t\t%s\t\t%s\t%d\t\n", symbolTable[i].id_name, symbolTable[i].data_type, symbolTable[i].type, symbolTable[i].line_no);
		}
	}
	for(i=0;i<count;i++){
		free(symbolTable[i].id_name);
		free(symbolTable[i].type);
	}
	printf("\n\n");
	printf("\t\t\t\t PHASE 2: SYNTAX ANALYSIS \n\n");
	printtree(head); 
	printf("\n\n");
	printf("\n----------------------- FIM DA COMPILACAO\n");
}

int search(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbolTable[i].id_name, type)==0) {
			return -1;
			break;
		}
	}
	return 0;
}

void add(char c) {
    q=search(yytext);
	if(q==0) {
		if(c=='H') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("FILE");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Header\t");
			count++;
		}
		else if(c=='K') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Keyword\t");
			count++;
		}
		else if(c=='V') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Variable");
			count++;
		}
		else if(c=='C') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("CONST");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Constant");
			count++;
		}
		else if(c=='F') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Function");
			count++;
		}
		else if(c=='G') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("CLASS");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Class\t");
			count++;
		}
		else if(c=='M') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Method\t");
			count++;
		}
    }
}

struct node* mknode(struct node *left, struct node *right, char *token) {	
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	char *newstr = (char *)malloc(strlen(token)+1);
	strcpy(newstr, token);
	newnode->left = left;
	newnode->right = right;
	newnode->token = newstr;
	return(newnode);
}

void printtree(struct node* tree) {
	printf("\n\n Inorder traversal of the Parse Tree: \n\n");
	printInorder(tree);
	printf("\n\n");
}

void printInorder(struct node *tree) {
	int i;
	if (tree->left) {
		printInorder(tree->left);
	}
	if (tree->right) {
		printInorder(tree->right);
	}
	printf("%s, ", tree->token);
}

void insert_type() {
	strcpy(type, yytext);
}

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}