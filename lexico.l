%{
    #include "y.tab.h"
    #include<string.h>
    int countn = 0;
%}

%option yylineno

upletter [A-Z]
lowletter [a-z]
digit [0-9]
unary "++"|"--"
boolean "sim"|"nao"
id [a-zA-Z][a-zA-Z0-9]*
whitespace [ ]
quebra [\n]
tab [\t]

%%

"escreve"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_PRINTF; }
"escaneia"                                      { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_SCANF; }
"inteiro"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_INT; }
"decimal"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_FLOAT; }
"caracter"                                      { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_CHAR; }
"booleano"                                      { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_BOOL; }
"vazio"                                         { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_VOID; }
"palavra"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_STR; }
"retorna"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_RETURN; }
"para"	                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_FOR; }
"se"	                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_IF; }
"senao"	                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_ELSE; }
^"#incluir"[ ]*<.+\.h>                          { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_INCLUDE; }
"sim"                                           { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_TRUE; }
"nao"                                           { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_FALSE; }
[-]?{digit}+                                    { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_INT_NUM; }
[-]?{digit}+\.{digit}{1,6}                      { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_FLOAT_NUM; }
{lowletter}({upletter}|{lowletter}|{digit})*    { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_VAR_ID; }
{upletter}({upletter}|{lowletter}|{digit})*     { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_STRUCT_ID; }
{unary}                                         { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_UNARY; }
"<="                                            { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_MENOR_IGUAL; }
">="                                            { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_MAIOR_IGUAL; }
"=="                                            { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_IGUAL; }
"!="                                            { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_DIFERENTE; }
">"	                                            { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_MAIOR; }
"<"	                                            { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_MENOR; }
"&&"	                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_AND; }
"||"	                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_OR; }
"+"                                             { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_ADD; }
"-"                                             { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_SUB; }
"/"                                             { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_DIV; }
"*"                                             { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_MULT; }
\/\/.*                                          { strcpy(yylval.nd_obj.name,(yytext)); ; }
\/\*(.*\n)*.*\*\/                               { strcpy(yylval.nd_obj.name,(yytext)); ; } 
[ \t]*                                          { strcpy(yylval.nd_obj.name,(yytext)); ; }
[\n]                                            { strcpy(yylval.nd_obj.name,(yytext)); countn++; }
.	                                            { strcpy(yylval.nd_obj.name,(yytext)); return *yytext; }
["].*["]                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_STR_VAL; }
['].[']                                         { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_CHAR_VAL; }
[~~].*[~~]                                      { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_COMMENT; }
%%

int yywrap() {
    return 1;
}