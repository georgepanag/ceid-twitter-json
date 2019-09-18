
%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern FILE *yyout;
void yyerror(char *);
void indent(int i);
void text_checker(const char*,const char*, int*);
void id_str_checker(const char*, int*);
void created_at_checker(const char*, int*);
void user_checker(const char*,int*, int*);
void user_fields_checker(const char*, int*);
void ret_screen_name_checker(const char*, int*);
void ret_useratext_checker(const char*, int*);
void ret_status_checker(const char*, int*,int*);
#define MAX_TEXT 141
extern int line_num;
int check[4] = {0,0,0,0};
int user_check[4]= {0,0,0,0};
int retweet[2] = {0,0};
int ret_status_check[3]= {0,0,0};

extern unsigned int start;
extern unsigned int stack_count;
%}

%union { char* val;}
%token <val> STRING 
%token <val> NUM
%%




file: object			{printf("\n");}
	
;

object: '{' '}'			{indent(stack_count);printf("}");}
	|'{' fields '}'		{printf("\n");indent(stack_count);printf("}");}
;

fields: pair			
	| fields ',' pair	
;

pair:   STRING ':' STRING	{indent(stack_count);printf("%s: %s",$1,$3);text_checker($1,$3,check);user_fields_checker($1,user_check);id_str_checker($1,check);created_at_checker($1,check);ret_screen_name_checker($1,ret_status_check);}
	| STRING ':' NUM	{indent(stack_count);printf("%s: %s",$1,$3);user_fields_checker($1,user_check);}
	| STRING ':' array	{printf("\n");indent(stack_count);printf("]");}
	| STRING ':' empty_array {indent(stack_count);printf("]");}
	| STRING ':' object	{user_checker($1,user_check,check);ret_useratext_checker($1,ret_status_check);ret_status_checker($1,ret_status_check,retweet);}	
;

array: '[' arr_fields ']'		
;

empty_array: '[' ']'		
;

arr_fields: arr_memb 
	| arr_fields ',' arr_memb
;

arr_memb: NUM			{indent(stack_count);printf("%s",$1);}
	| STRING		{indent(stack_count);printf("%s",$1);}
	| array			
	| object
;
%%

void yyerror(char *s) {
	fprintf(stderr, "Syntax error at line : %d\n", line_num);
	exit(1);
}									

void indent(int i){
	int j=0;
	for(j; j<i;j++){
		printf("\t");
	}
}


void text_checker(const char *string,const char* text, int* checker){
	if(!strcmp(string,"\"text\"")){
		if(strlen(text) < 140 && stack_count <= 1){	
			if(*checker==0){
				checker[0]=1;

			}
			else if (*checker == 1){
				fprintf(stderr, "Element text must appear only once(line : %d)",line_num);
				exit(1);
			}
		}
	}
}

void id_str_checker(const char *string, int* checker){
	if(!strcmp(string,"\"id_str\"")&& stack_count <=1){
		if(*(checker+1)==0){
			checker[1]=1;
		}
		else if( *(checker +1) ==1){
			fprintf(stderr,"Element id_str must only appear one time (line : %d)",line_num);	
			exit(1);
			
		}
	}
}

void created_at_checker(const char *string, int* checker){
	if(!strcmp(string,"\"created_at\"")&& stack_count <=1){
		if(*(checker+3)==0){
			checker[3]=1;
		}
		else if( *(checker +3) ==1){
			fprintf(stderr,"Element created_at must only appear one time (line : %d)",line_num);	
			exit(1);
			
		}
	}
}

void user_fields_checker(const char *string, int* checker){

	if(!strcmp(string, "\"id\"")){
		*checker = 1;
	}
	if(!strcmp(string, "\"name\""))
		*(checker + 1) = 1;
	if(!strcmp(string, "\"screen_name\""))
		*(checker + 2) = 1;
	if(!strcmp(string, "\"location\""))
		*(checker + 3) = 1;

}

void user_checker(const char* string , int* checker, int* Checker){
	if(!strcmp(string,"\"user\"")){
		if(*(checker) == 1 && *(checker + 1) == 1 && *(checker+2) ==1 && *(checker+3) ==1)
			*(Checker+2) = 1;
	}
	else 
		for(int i=0;i<4;i++){
			*(checker + i) = 0;
		}
}

void ret_screen_name_checker(const char*string,int *checker){
	if(!strcmp(string,"\"screen_name\"")){
		checker[0] = 1;
}	if(!strcmp(string,"\"text\""))
		checker[2] = 1;
}

void ret_useratext_checker(const char * string,int* checker){
	if(!strcmp(string,"\"user\"")){
		if(checker[0] == 1)
			checker[1] = 1;
	}
	else{ 
		checker[0] = 0;
}

}

void ret_status_checker(const char * string,int *checker,int *Checker){
	if(!strcmp(string,"\"retweeted_status\"")){
		if(check[1] && check[2])
			Checker[0] = 1;
	}
		

}



int main ( int argc, char **argv  ) 
 {
	++argv; --argc;
	if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
	else
        yyin = stdin;
	printf("user : %d\n", check[1]);
	for(int i = 0;i<3;i++)
		printf("%d%d\n",*retweet,*(ret_status_check + i));
	yyparse ();
	for(int i = 0;i<3;i++)
		printf("%d   %d\n",*retweet,*(ret_status_check + i));
	printf("\n\n\n");
	if(!check[0]){
		printf("JSON file missing text filed\n");
		return 0;
}
	if(!check[1]){
		printf("JSON file missing id_srt filed\n");
		return 0;
}
	if(!check[2]){
		printf("JSON file missing correct user filed\n");
		return 0;
}
	if(!check[3]){
		printf("JSON file missing created_at filed\n");
		return 0;
}
	printf("JSON parsed succefuly\n");
	return 0;

}   
	
