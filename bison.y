
%{
#include <string.h>
#include <stdio.h>
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern FILE *yyout;
void yyerror(char *);
void indent(int i);
#define MAX_TEXT 141
extern int line_num;
extern unsigned int start;
extern unsigned int stack_count;
int check[4] = {0,0,0,0};
%}

%union { char* val;}
%token <val> STRING 
%token <val> NUM

%token <val> DAYN

%%




file: object			{printf("\n");}
;

object: '{' '}'			{indent(stack_count);printf("}");}
	|'{' fields '}'		{printf("\n");indent(stack_count);printf("}");}
;

fields: pair			
	| fields ',' pair	
;

pair:   STRING ':' STRING   	{if(!strcmp("\"text\"",$1)){if(strlen($3)>140){}}indent(stack_count);printf("%s: %s",$1,$3);}
    	| STRING ':' NUM 	{indent(stack_count);printf("%s: %s",$1,$3);}
	| STRING ':' array	{printf("\n");indent(stack_count);printf("]");}
	| STRING ':' empty_array {indent(stack_count);printf("]");}
	| STRING ':' object
	| STRING ':' DAYN	{printf("%s: %s",$1,$3);}	
;

array: '[' arr_fields ']'	
;

empty_array: '[' ']'
;

arr_fields: arr_memb 
	| arr_fields ',' arr_memb
;

arr_memb: NUM 			{indent(stack_count);printf("%s",$1);}
	| STRING		{indent(stack_count);printf("%s",$1);}
	| array
	| object
;



%%

void yyerror(char *s) {
    fprintf(stderr, "Syntax error at line : %d\n", line_num);
}									

void indent(int i){
	int j=0;
	for(j; j<i;j++){
		printf("\t");
	}
}


/*
void checker(char *string, char *text, int* checker){
	if(strcmp(string,"text") && strlen(string) <= 141)
		*checker = 1;
	if(strcmp(string, "created_at")
		*(checker + 1) = 1;
	if(str
	
}
*/
int main ( int argc, char **argv  ) 
 {
	++argv; --argc;
	if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
	else
        yyin = stdin;
	yyparse ();
	return 0;
}   
	
