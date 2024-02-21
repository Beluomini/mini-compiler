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

	int check_types(char *, char *);
	char *get_type(char *);

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
	char *error_msg = "Erro de sintático não reconhecido";
	int countSinError = 0;
	char *sem_error[100];
	int countSemError = 0;

	char *scan_data;

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
		char type[100];
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
					TOKEN_INCLUDE TOKEN_LIB TOKEN_RETURN

%type	<nd_obj>	file program headers body header main
					structs struct classes class methods method methodCall
					functions function functionCall params param actions action
					variableDefinition variableAssignment loop print scan
					startIf if else comparation comparator
					vectorDefinition vectorValueAssignment vectorData
					valueType value arithmetic expression return

%%

file: program
{
	$$.nd = mknode($1.nd, NULL, "file");
	head = $$.nd; 
}
| headers classes
{
	$$.nd = mknode($1.nd, $2.nd, "file");
	head = $$.nd; 
}
;

program: headers body {
	$$.nd = mknode($1.nd, $2.nd, "program"); 
}

headers: header headers { $$.nd = mknode($1.nd, $2.nd, "headers"); }
| {$$.nd = NULL;}
;

header: TOKEN_INCLUDE { error_msg="Incluir vazio"; } TOKEN_LIB
{ 
	add('H'); 
	$$.nd = mknode(NULL, NULL, $3.name); 
}
;

body: structs { error_msg="Erro na função main"; } main '(' ')' { error_msg="Faltando '{'"; } '{'  actions return { error_msg="Faltando '}'"; }'}'
{ 
	$3.nd = mknode($8.nd, $9.nd, "main");
    $$.nd = mknode($1.nd, $3.nd, "body"); 
}
;

main: valueType TOKEN_MAIN 
{ 
	add('F'); 
}
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

class: TOKEN_CLASS { error_msg="Classes tem que ter um nome"; }  TOKEN_CLASS_ID { add('G'); } { error_msg="Faltando '{'"; } '{' actions methods { error_msg="Faltando '}'"; }'}'
{
	$$.nd = mknode($7.nd, $8.nd, "class");
}
;

methods: method methods
{
	$$.nd = mknode($1.nd, $2.nd, "methods");
}
| {$$.nd = NULL;}
;

method: TOKEN_START_METHOD { add('K'); error_msg="Tipo faltando"; } valueType {error_msg="Metodo deve ter um nome"; }TOKEN_VAR_ID { strcpy($5.name, yytext); error_msg="Faltando '('"; } '(' params {error_msg="Faltando ')'";} ')'  {error_msg="Faltando '{'";} '{' actions {error_msg="Metodo sem retorno";} return {error_msg="Faltando '}'";} '}'
{
	$$.nd = mknode($8.nd, $13.nd, "method");
	if(strcmp($3.type, $15.type) != 0) {
		char msg[100] = "";
		strcat(msg, "Retorno de método diferente do tipo de retorno: ");
		strcat(msg, $5.name);
		sem_error[countSemError] = (char *)malloc(strlen(msg) + 1);
		strcpy(sem_error[countSemError], msg);
		countSemError++;
	}
}
;

methodCall: TOKEN_CLASS_ID '.' TOKEN_VAR_ID { error_msg="Faltando '('"; } '(' params { error_msg="Faltando ')'"; } ')'
{
	$$.nd = mknode($6.nd, NULL, "methodCall");
	char *type = get_type($3.name);
	strcpy($$.type, type);
}
;

functions: function functions
{
	$$.nd = mknode($1.nd, $2.nd, "functions");
}
| {$$.nd = NULL;}
;

function: TOKEN_START_FUNC { add('K'); error_msg="Tipo faltando"; } valueType {error_msg="Função deve ter um nome"; } TOKEN_VAR_ID { strcpy($5.name,yytext); add('F'); error_msg="Faltando '('";} '(' params {error_msg="Faltando ')'";} ')' {error_msg="Faltando '{'";} '{' actions return {error_msg="Faltando '}'";} '}'
{
	$$.nd = mknode($8.nd, $13.nd, "function");
	if(strcmp($3.type, $14.type) != 0) {
		char msg[100] = "";
		strcat(msg, "Retorno de função diferente do tipo de retorno: ");
		strcat(msg, $5.name);
		sem_error[countSemError] = (char *)malloc(strlen(msg) + 1);
		strcpy(sem_error[countSemError], msg);
		countSemError++;
	}
}
;

functionCall: TOKEN_VAR_ID { error_msg="Faltando '('"; } '(' params { error_msg="Faltando ')'"; } ')'
{
	$$.nd = mknode($4.nd, NULL, "functionCall");
	char *type = get_type($1.name);
	strcpy($$.type, type);
}
;

params: { error_msg="Params are incorrect"; } param ',' params
{
	$$.nd = mknode($2.nd, $4.nd, "params");
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
| vectorDefinition
| vectorValueAssignment
| loop
| print
| scan
| startIf
;

startIf: TOKEN_IF { add('K'); } if else
{
	$$.nd = mknode($3.nd, $4.nd, "if else");
}
;

if: { error_msg="Faltando '('"; } '(' comparation { error_msg="Faltando ')'"; } ')' { error_msg="Faltando '{'"; } '{' actions { error_msg="Faltando '}'"; } '}'
{
	$$.nd = mknode($3.nd, $8.nd, "if");
}
;

else: TOKEN_ELSE { add('K');  error_msg="Faltando '{'";} '{' actions { error_msg="Faltando '}'";} '}'
{
	$$.nd = mknode($4.nd, NULL, "else");
}
| {$$.nd = NULL;}
;

loop: TOKEN_WHILE { add('K'); error_msg="Faltando '('";} '(' comparation { error_msg="Faltando ')'";} ')' { error_msg="Faltando '{'";} '{' actions { error_msg="Faltando '}'";} '}'
{
	$$.nd = mknode($4.nd, $9.nd, "loop");
}
;

print: TOKEN_PRINTF { add('K');  error_msg="Faltando '('";} '(' value {error_msg="Faltando ')'";} ')' {error_msg="Faltando ';'";} ';'
{
	$$.nd = mknode($4.nd, NULL, "print");
}
;

scan: TOKEN_SCANF { add('K'); error_msg="Faltando '('";} '(' TOKEN_VAR_ID {error_msg=("Faltando ')'");} ')' {error_msg=("Faltando ';'");} ';'
{
	$$.nd = mknode(NULL, NULL, "scan");
}
;

vectorDefinition: valueType '[' TOKEN_INT_NUM {error_msg=("Vetor definido incorretamente");} ']' TOKEN_VAR_ID { add('V'); } '=' '{' vectorData '}' { error_msg="Missing ';'"; } ';'
{
	$$.nd = mknode($10.nd, NULL, "vectorDefinition");
}
;

vectorValueAssignment: TOKEN_VAR_ID '[' TOKEN_INT_NUM ']' '=' value { error_msg="Missing ';'"; } ';'
{
	$$.nd = mknode($6.nd, NULL, "vectorValueAssignment");
}
| TOKEN_VAR_ID '[' TOKEN_INT_NUM ']' '=' functionCall { error_msg="Missing ';'"; } ';'
{
	$$.nd = mknode(NULL, NULL, "vectorValueAssignment");
}
| TOKEN_VAR_ID '[' TOKEN_INT_NUM ']' '=' methodCall { error_msg="Missing ';'"; } ';'
{
	$$.nd = mknode(NULL, NULL, "vectorValueAssignment");
}
| TOKEN_VAR_ID '['']' '=' vectorData { error_msg="Missing ';'"; } ';'
{
	$$.nd = mknode($5.nd, NULL, "vectorValueAssignment");
}
;

vectorData: value ',' vectorData
{
	$$.nd = mknode($1.nd, $3.nd, "vectorData");
}
| value
{
	$$.nd = mknode($1.nd, NULL, "vectorData");
}
;

variableDefinition: valueType TOKEN_VAR_ID { strcpy($2.name, yytext); add('V'); } '=' expression { error_msg="Missing ';'"; } ';'
{
	$$.nd = mknode($5.nd, NULL, "variableDefinition");
	int check = check_types($1.type, $5.type);
	if(check == 1) {
		char msg[100] = "";
		strcat(msg, "Atribuição de tipos diferentes com a variável: ");
		strcat(msg, $2.name);
		sem_error[countSemError] = (char *)malloc(strlen(msg) + 1);
		strcpy(sem_error[countSemError], msg);
		countSemError++;
	}
}
;

variableAssignment: TOKEN_VAR_ID '=' expression { error_msg="Missing ';'"; } ';' 
{
	$$.nd = mknode($3.nd, NULL, "variableAssignment");
}
| TOKEN_VAR_ID '=' functionCall { error_msg="Missing ';'"; } ';'
{
	$$.nd = mknode($3.nd, NULL, "variableAssignment");
}
| TOKEN_VAR_ID '=' methodCall { error_msg="Missing ';'"; } ';'
{
	$$.nd = mknode($3.nd, NULL, "variableAssignment");
}
;

expression: expression arithmetic expression
{
	$$.nd = mknode($1.nd, $3.nd, "expression");
}
| value
{
	$$.nd = mknode($1.nd, NULL, "value");
	strcpy($$.type, $1.type);
}
| '(' expression ')'
{
	$$.nd = mknode($2.nd, NULL, "expression");
}
;

arithmetic: TOKEN_ADD { $$.nd = mknode(NULL, NULL, "arithmetic"); }
| TOKEN_SUB { $$.nd = mknode(NULL, NULL, "arithmetic"); }
| TOKEN_MULT { $$.nd = mknode(NULL, NULL, "arithmetic"); }
| TOKEN_DIV { $$.nd = mknode(NULL, NULL, "arithmetic"); }
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
| '(' comparation ')'
{
	$$.nd = mknode($2.nd, NULL, "comparation");
}
;

comparator: TOKEN_MENOR_IGUAL { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_MENOR { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_MAIOR_IGUAL { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_MAIOR { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_IGUAL { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_DIFERENTE { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_AND { $$.nd = mknode(NULL, NULL, "comparator"); }
| TOKEN_OR { $$.nd = mknode(NULL, NULL, "comparator"); }
;

valueType:	TOKEN_INT { add('K'); insert_type(); strcpy($$.type, "int");}
| TOKEN_FLOAT { add('K'); insert_type(); strcpy($$.type, "float");}
| TOKEN_CHAR { add('K'); insert_type(); strcpy($$.type, "char");}
| TOKEN_STR { add('K'); insert_type(); strcpy($$.type, "str");}
| TOKEN_VOID { add('K'); insert_type(); strcpy($$.type, "void"); }
;

value: TOKEN_INT_NUM { add('C'); } { $$.nd = mknode(NULL, NULL, "value"); strcpy($$.type, "int");}
| TOKEN_FLOAT_NUM { add('C'); } { $$.nd = mknode(NULL, NULL, "value"); strcpy($$.type, "float");}
| TOKEN_CHAR_VAL { add('C'); } { $$.nd = mknode(NULL, NULL, "value"); strcpy($$.type, "char");}
| TOKEN_STR_VAL { add('C'); } { $$.nd = mknode(NULL, NULL, "value"); strcpy($$.type, "str");}
| TOKEN_VAR_ID { } { $$.nd = mknode(NULL, NULL, "variable"); }
| functionCall { $$.nd = mknode($1.nd, NULL, "functionCall"); }
| methodCall { $$.nd = mknode($1.nd, NULL, "methodCall"); }
;

return: TOKEN_RETURN { add('K'); error_msg="Sem valor pra retorno";} value { error_msg="Missing ';'"; } ';'
{
	$$.nd = mknode($3.nd, NULL, "return");
	strcpy($$.type, $3.type);
}
| {$$.nd = NULL;}
;

%%

int main(int argc, char **argv) {

	struct node *trees[argc];
	char *fileNames[argc];

	for(int i=1;i<argc;i++){
		FILE *f = fopen(argv[i], "r");
		if (!f) {
			printf("\nErro ao abrir o arquivo: %s\n", argv[i]);
			return 1;
		}

		yyin = f;


		yyparse();

		trees[i] = head;
		fileNames[i] = argv[i];
		head = NULL;
		
		fclose(f);
	}


		printf("\n\n \t\t\t\t PHASE 1: LEXICAL ANALYSIS \n\n");
		printf("\nSYMBOL		DATATYPE	TYPE		LINE NUMBER \n");
		printf("_____________________________________________________________\n\n");
		int i=0;
		for(i=0; i<count; i++) {
			printf("%s\t\t%s\t\t%s\t%d\t\n", symbolTable[i].id_name, symbolTable[i].data_type, symbolTable[i].type, symbolTable[i].line_no);	
		}
		for(i=0;i<count;i++){
			free(symbolTable[i].id_name);
			free(symbolTable[i].type);
		}
		printf("\n\n");
		printf("\t\t\t\t PHASE 2: SYNTAX ANALYSIS \n\n");
		for (int i = 1; i < argc; i++) {
			printf("\t\t\t\t FILE %s SYNTAX ANALYSIS \n\n", fileNames[i]);
			printtree(trees[i]); 
			printf("\n\n");
		}
		printf("\n\n");
		printf("\t\t\t\t PHASE 3: SEMANTIC ANALYSIS \n\n");
		if(countSemError == 0){
			printf("Sem erros semânticos\n");
		}
		else{
			for(int j = 0; j < countSemError; j++){
				printf("\n%d Erro semântico: %s", j+1, sem_error[j]);
			}
		}
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
			symbolTable[count].id_name=strdup(yytext), "\t";
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

char *get_type(char *var){
	for(int i=0; i<count; i++) {
		if(!strcmp(symbolTable[i].id_name, var)) {
			return symbolTable[i].data_type;
		}
	}
}

int check_types(char *type1, char *type2){
	// declaration with no init
	if(!strcmp(type2, "null"))
		return -1;
	// both datatypes are same
	if(!strcmp(type1, type2))
		return 0;
	// both datatypes are different
	return 1;
}

void yyerror(const char* msg) {
	if(countSinError == 0){
    	fprintf(stderr, "Erro de sintaxe na linha %d: (%s)\n", countn, error_msg);
		countSinError++;
	}
}