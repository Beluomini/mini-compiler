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

%token TOKEN_VOID 
%token <nd_obj> 	TOKEN_INT_NUM TOKEN_FLOAT_NUM TOKEN_CHAR_VAL TOKEN_STR_VAL TOKEN_VAR_ID TOKEN_STRUCT_ID
					TOKEN_INT TOKEN_FLOAT TOKEN_CHAR TOKEN_STR
					TOKEN_BOOL TOKEN_TRUE TOKEN_FALSE
					TOKEN_ADD TOKEN_MULT TOKEN_DIV TOKEN_SUB TOKEN_UNARY
					TOKEN_PRINTF TOKEN_SCANF 
					TOKEN_FOR TOKEN_WHILE TOKEN_IF TOKEN_ELSE  
					TOKEN_MENOR_IGUAL TOKEN_MAIOR_IGUAL TOKEN_IGUAL TOKEN_DIFERENTE TOKEN_MAIOR TOKEN_MENOR
					TOKEN_AND TOKEN_OR 
					TOKEN_INCLUDE TOKEN_RETURN TOKEN_COMMENT 

%type <nd_obj> 		value arithmetic expression

%%

expression: expression arithmetic expression { }
| value { }
;

arithmetic: TOKEN_ADD 
| TOKEN_SUB 
| TOKEN_MULT
| TOKEN_DIV
;

value: TOKEN_INT_NUM { }
| TOKEN_FLOAT_NUM { }
| TOKEN_CHAR_VAL { }
| TOKEN_STR_VAL { }
| TOKEN_TRUE { }
| TOKEN_FALSE { }
| TOKEN_VAR_ID { }
;

%%

int main() {
    yyparse();
    printf("\n\n \t\t\t\t\t\t PHASE 1: LEXICAL ANALYSIS \n\n");
	printf("\nSYMBOL   DATATYPE   TYPE   LINE NUMBER \n");
	printf("_______________________________________\n\n");
	int i=0;
	for(i=0; i<count; i++) {
		printf("%s\t%s\t%s\t%d\t\n", symbolTable[i].id_name, symbolTable[i].data_type, symbolTable[i].type, symbolTable[i].line_no);
	}
	for(i=0;i<count;i++){
		free(symbolTable[i].id_name);
		free(symbolTable[i].type);
	}
	printf("\n\n");
	printf("\t\t\t\t\t\t PHASE 2: SYNTAX ANALYSIS \n\n");
	printtree(head); 
	printf("\n\n");
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
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Header");
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
	printf("%s, ", tree->token);
	if (tree->right) {
		printInorder(tree->right);
	}
}

void insert_type() {
	strcpy(type, yytext);
}

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}