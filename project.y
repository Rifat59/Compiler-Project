%{
	#include <iostream>
	#include <stdlib.h>
	#include <stdio.h>
	#include <cstring>
	#include "structs.h"

	using namespace std; 

	#define MAX_SYM 20
	#define MAX_SWITCH 10

	int yylex();
	int yyerror (char const *s);
	void init(char* file);


    double sym[MAX_SYM];
    char type[MAX_SYM];
    bool declared[MAX_SYM];

%}

%union {
	double value;
	char type;
	Exp_type expType;	
	CString stringData;
	ArrayDouble arrayDouble;
};

%token <value> ID NUM DONUM CHNUM
%token <stringData> HEADER STRING
%token EITHER EITHEROR NOR EITHERCLOSE WHILE WHILECLOSE INT PRINT FOR FORCLOSE LE GE EQ NQ TO DOUBLE CHAR VOID INCLUDE MAIN MAINCLOSE BOOL SWITCH SWITCHCLOSE INPUT DEFAULT DEFAULTCLOSE IS ISCLOSE

%right '='
%left '<' '>' LE GE EQ
%left '+' '-'
%left '*' '/'

%type <expType> expr is
%type <type> type
%type <value> loop_condition
%type <arrayDouble> case default

%start start

%%

start: header_start main
	;

header_start: header 
	| header '\n' header_start
	;

header: '#' INCLUDE '"' HEADER '"'
	| /* empty */
	;

main: MAIN '\n' body '\n' MAINCLOSE '\n'
	;

body: stmnt '\n' body
	| stmnt '\n'
	;

stmnt: declared
	| condition
	| loop
	| assign
	| switch
	| printf
	| input
	|     /*empty line*/
	;

condition:
	EITHER '(' expr ')' '\n' body EITHERCLOSE	{
		if($3.value){
			printf("If is executed.\n");
		}
		else {
			printf("Wrong condition of If.\n");
		}
	}
	| EITHER '(' expr ')' '\n' body NOR '\n' body EITHERCLOSE {
		if($3.value){
			printf("If is executed.\n");
		}
		else {
			printf("Else is executed.\n");
			 }
	}
	| EITHER '(' expr ')' '\n' body EITHEROR '(' expr ')' '\n' body '\n' NOR '\n' body EITHERCLOSE {
		if($3.value){
			printf("If is executed.\n");
		}
		else if($9.value){printf("Else If is executed.\n");}
		else {
			printf("Else is executed.\n");
			 }
	}
	;

loop:
	WHILE '(' loop_condition ')' '\n' body WHILECLOSE {
		printf("While loop is executed.\n");
	}
	| FOR '(' loop_condition ')' '\n' body FORCLOSE {
		printf("For loop is executed.\n");
	}
	;

loop_condition:
	NUM TO NUM 	{$$ = $3 - $1;}
	;

declared:	type ID	'|' {
							if(declared[(int)$2])
							{
								yyerror("Error : Cannot redeclare variable!\n");
							}
							else
							{
								sym[(int)$2]=0;
								type[(int)$2]=$1;
								declared[(int)$2]=true; 
							}
						}
		;

assign:
	ID '=' expr '|'		{
							if(!declared[(int)$1])
							{
								yyerror("Error : undeclared variable is used!!\n");
							} 
							else if(type[(int)$1] != $3.type)
							{
								yyerror("Error : type does not match!!\n");
							}
							else
							{
								sym[(int)$1]=$3.value;
							}	
						}
	;

switch:
	SWITCH '(' NUM ')' ':' '\n' case SWITCHCLOSE {

										bool isExecuted = false;

										for(int  i = $7.size - 1; i > 0; i--)
										{
											if($7.start[i] == $3)
											{
												cout<<"Is block number "<<$7.size - i<<" is executed."<<endl;
												isExecuted = true;
												break;
											}
										}

										if(!isExecuted)
										{
											cout<<"Default block is executed."<<endl;
										}

										delete($7.start);
									}
	;

case:
	is '\n' case    {
						if($1.type == $3.type || $3.type == 'u')
										{
											if($3.size >= MAX_SWITCH)
											{
												yyerror("Error : Switch cannot be that long!");
											}

											$$.start = $3.start;
											$$.size = $3.size;
											$$.type = $1.type;
											$$.start[$$.size] = $1.value;
											$$.size++;
										}
										else
										{
											yyerror("Error : Type mismatch in switch statement!");
										}
					}
	| default '\n'		{ $$ = $1; }
	;

is: IS expr ':' '\n' body ISCLOSE 	{
									$$ = $2;
								}
	;

default: DEFAULT ':' '\n' body DEFAULTCLOSE	{
									double * array = new double[MAX_SWITCH];
									array[0] = 0;

									$$.type = 'u';
									$$.start = array; 
									$$.size = 1;
								}
	;

printf:
	PRINT '{' expr '}' '|'	{
								printf("%f\n", $3.value);
							}
	| PRINT '{' STRING '}' '|'  {
								printf("%s\n",$3.start );

								delete($3.start);
							}
	| PRINT '{' STRING ':' expr '}' '|' {
											printf("%s : %f\n",$3,$5.value );
										}
	;

input: INPUT '{' ID '}' '|'	{
						if(!declared[(int)$3])
						{
							yyerror("Error : undeclared variable used!");
						}
						else {
							//printf("input is called.\n" );
							cin>>sym[(int)$3];
							getchar();
						}
					}
	;

expr:
	NUM 				{$$.value = $1;$$.type = 'i'}
	| DONUM 			{$$.value = $1;$$.type = 'd'}
	| CHNUM 			{$$.value = $1;$$.type = 'c'}
	| ID 				{$$.value = sym[(int)$1];$$.type = type[(int)$1];}
	| expr '+' expr 	{$$.value = $1.value + $3.value;if($1.type == $3.type){$$.type = $1.type;}else{$$.type = 'd';}}
	| expr '-' expr 	{$$.value = $1.value - $3.value;if($1.type == $3.type){$$.type = $1.type;}else{$$.type = 'd';}}
	| expr '*' expr 	{$$.value = $1.value * $3.value;if($1.type == $3.type){$$.type = $1.type;}else{$$.type = 'd';}}
	| expr '/' expr 	{
							if($3.value > 0){
								$$.value = $1.value / $3.value;
							}
							else {
								printf("Devision is not possible!!");
							}
						}
	| expr '<' expr 	{$$.value = $1.value < $3.value;}
	| expr '>' expr 	{$$.value = $1.value > $3.value;}
	| expr GE expr 	{$$.value = $1.value <= $3.value;}
	| expr LE expr 	{$$.value = $1.value >= $3.value;}
	| expr EQ expr 	{$$.value = $1.value == $3.value;}

	| '(' expr ')'	{ $$.value = $2.value; }
	;

type:
	INT 		{$$ = 'i';}
	| DOUBLE 	{$$ = 'd';}
	| CHAR 		{$$ = 'c';}
	| BOOL 		{$$ = 'b';}
	;

%%


int yyerror(char const *s)
{
	printf("%s\n",s);
	return (0);
}

int main()
{

	freopen("input.txt","r",stdin);
	freopen("output.txt","w",stdout);

	for(int i = 0; i < MAX_SYM; i++){
		declared[i] = false;
	}

	yyparse();
	exit (0);
}