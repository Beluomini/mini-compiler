%{
    #include "y.tab.h"
    #include <string.h>
    int countn = 0;
%}

%option yylineno

upletter [A-Z]
lowletter [a-z]
digit [0-9]

%%

"main"                                          { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_MAIN; }
"acao"                                          { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_START_FUNC; }
"escreve"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_PRINTF; }
"escaneia"                                      { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_SCANF; }
"inteiro"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_INT; }
"decimal"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_FLOAT; }
"caracter"                                      { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_CHAR; }
"classe"                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_CLASS; }
"vazio"                                         { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_VOID; }
"palavra"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_STR; }
"retorna"                                       { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_RETURN; }
"para"	                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_FOR; }
"se"	                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_IF; }
"senao"	                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_ELSE; }
^"#incluir"[ ]*<.+\.h>                          { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_INCLUDE; }
[-]?{digit}+                                    { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_INT_NUM; }
[-]?{digit}+\.{digit}{1,6}                      { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_FLOAT_NUM; }
{lowletter}({upletter}|{lowletter}|{digit})*    { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_VAR_ID; }
{upletter}({upletter}|{lowletter}|{digit})*     { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_CLASS_ID; }
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
\/\/.*                                          { strcpy(yylval.nd_obj.name,(yytext)); }
\/\*(.*\n)*.*\*\/                               { strcpy(yylval.nd_obj.name,(yytext)); } 
[ \t]*                                          { strcpy(yylval.nd_obj.name,(yytext)); }
[\n]                                            { strcpy(yylval.nd_obj.name,(yytext)); countn++; }
.	                                            { strcpy(yylval.nd_obj.name,(yytext)); return *yytext; }
["].*["]                                        { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_STR_VAL; }
['].[']                                         { strcpy(yylval.nd_obj.name,(yytext)); return TOKEN_CHAR_VAL; }
%%

int yywrap() {
    return 1;
}