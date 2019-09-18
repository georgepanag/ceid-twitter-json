%{
#include "y.tab.h"
#include <stdio.h>
int line_num = 1;
unsigned int stack_count= 0;
char * last_string = NULL;
unsigned short arr_block=0;
unsigned short start=0;
void indent(int);
void inv_tokens();
%}

%option noyywrap

JSTRING \"{JCHAR}*\"
JCHAR [^\"]|(\\\")
DIGIT1to9 [1-9]
DIGIT [0-9]
JNUM -?{DIGIT1to9}{DIGIT}*(\.{DIGIT}*)?(e[+-]{DIGIT}+)?
WS [ \t]*

DAY Mon|Tue|Wed|Thu|Fri|Sat|Sun
MMM Jan|Feb|ar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec
DD [0]{DIGIT1to9}|[1-2]{DIGIT}|[3][0-1]
HOURS [0-1]{DIGIT}|[2][0-3]
MINUTS [0-5]{DIGIT}
YYYY {DIGIT1to9}{DIGIT}{DIGIT}{DIGIT}
DBQ ["]
DATE \"{DAY}{WS}{MMM}{WS}{DD}{WS}{HOURS}:{MINUTS}:{MINUTS}{WS}{YYYY}\"$
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
{DATE}		{yylval.val = strdup(yytext);return DAYN;}
.		{inv_tokens();}

%%

void inv_tokens(){
	fprintf(stderr,"Invalid token : %s \n at line : %d \n", yytext, line_num);
	exit(0);
}
