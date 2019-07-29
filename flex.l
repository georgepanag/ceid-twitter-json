%{
#include "y.tab.h"
#include <stdio.h>
int line_num = 1;
unsigned int stack_count= 0;
char * last_string = NULL;
unsigned short arr_block=0;
unsigned short start=0;
void indent(int);
%}

%option noyywrap

JSTRING \"{JCHAR}*\"
JCHAR [^\"]|(\\\")
DIGIT1to9 [1-9]
DIGIT [0-9]
JNUM -?{DIGIT1to9}{DIGIT}*(\.{DIGIT}*)?(e[+-]{DIGIT}+)?
WS [ \t]*
DAY_NAME MON|TUE|WED|THU|FRI|SAT|SUN
MONTH JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC
DAY [1-31]
YEAR {DIGIT}{DIGIT}{DIGIT}{DIGIT}
TIMESTAMP {HOUR}{COLON}{MIN_OR_SEC}{COLON}{MIN_OR_SEC}
COLON ":"
HOUR [0-23]
MIN_OR_SEC [0-60]
COMPLETE_TIMESTAMP {DAY_NAME}{WS}{MONTH}{WS}{DAY}{WS}{TIMESTAMP}{WS}{YEAR}
ID_STRING [^-]+?{DIGIT}+


%%

"{"		{if(start==0){printf("\{\n");start =1;}if(arr_block == 0 && last_string != NULL){indent(stack_count);printf("%s: \{\n",last_string);}if(arr_block == 1){indent(stack_count);printf("{\n");arr_block =0;}stack_count++;return '{';}
"}"		{if(arr_block == 0) arr_block == 1 ;stack_count--;return '}';}
":"            	return ':'; 
","		{printf(",\n");return ',';}
"["		{if(arr_block == 0 && last_string != NULL){indent(stack_count);printf("%s: [\n",last_string);};arr_block = 1;stack_count++;return '[';}
"]"		{arr_block = 0;stack_count--;return ']';}
"\n"		{line_num++;}
{WS}		/* ignore whitespace  */;
{JSTRING}	{yylval.val = strdup(yytext);last_string = strdup(yytext);return STRING;}
{JNUM}		{yylval.val = strdup(yytext);return NUM;}
{COMPLETE_TIMESTAMP} {yylval.val = strdup(yytext);return COMPLETE_TIMESTAMP;}
ID_STRING {yylval.val = strdup(yytext);return ID_STRING;}

%%
