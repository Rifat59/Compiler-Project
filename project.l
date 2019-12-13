
%{
	#include <iostream>
	#include <stdlib.h>
	#include <stdio.h>
	#include <fstream>
	#include <cstring>
	#include <map>

	using namespace std;

	#include "structs.h"
	#include "project.tab.h"

	extern YYSTYPE yylval;
	int yyerror (char const *s);

	map<string,int> indexMap;
	int nextIndex = 1;
%}

NUM [0-9]+
DONUM {NUM}[.]{NUM}
CHNUM ['].[']
STRING ["][^"\n]*["]
ID [_a-zA-Z][_a-zA-Z0-9]*
HEADER [_a-zA-Z][_a-zA-Z0-9]*[.]"h"
LINE .*[\n]
SINGLE_LINE_COMMENT [/][/]{LINE}
MULTI_LINE_COMMENT [/][*](([*]+[^/*])|[^*])*[*]+[/]


%%

either		{return(EITHER);}
eitheror	{return(EITHEROR);}
nor			{return(NOR);}
eitherclose		{return(EITHERCLOSE);}
while		{return(WHILE);}
whileclose	{return(WHILECLOSE);}
for 		{return(FOR);}
forclose	{return(FORCLOSE);}
switch		{return(SWITCH);}
switchclose	{return(SWITCHCLOSE);}
default     {return(DEFAULT);}
defaultclose     {return(DEFAULTCLOSE);}
is			{return(IS);}
isclose		{return(ISCLOSE);}
to			{return TO;}
print 		{return(PRINT);}
integer			{return(INT);}
double		{return(DOUBLE);}
char		{return(CHAR);}
bool 		{return(BOOL);}	
void		{return(VOID);}
include 	{return(INCLUDE);}
main 		{return(MAIN);}
mainclose 	{return(MAINCLOSE);}
input 		{return(INPUT);}
true 		{yylval.value = 1; return(BOOL); }
false 		{yylval.value = 0; return(BOOL); }

{STRING} 	{ 
				char* str = new char[yyleng+1];
				strcpy(str,yytext);
				str[yyleng-1] = '\0';

				yylval.stringData.start = str+1;
				yylval.stringData.size = yyleng;
				return(STRING); 
			}

{HEADER} 	{
					yylval.stringData.start = yytext;
					yylval.stringData.size = yyleng;
					return(HEADER);
			}

{NUM}	{
			
			yylval.value = atoi(yytext);
			return(NUM);
		}
		
{DONUM}	{
			
			yylval.value = atof(yytext);
			return(DONUM);
		}		

{CHNUM}	{
			
			yylval.value = yytext[1];
			return(CHNUM);
		}

{ID}	{
			
			int index = indexMap[yytext];
			//cout<<"id "<<yytext<<" has index "<<index<<endl;

			if(index == 0)
			{
				index = nextIndex;
				indexMap[yytext]=index;
				nextIndex++;
			}

			yylval.value = index;
			return(ID);
		}

"<="	{return(LE);}
">="	{return(GE);}
"=="	{return(EQ);}

[-+=/*()\n<>{}.#:|,]	{return *yytext;}
{SINGLE_LINE_COMMENT}	{}
{MULTI_LINE_COMMENT}	{}

[ \t]	

.	{cout<<"Unrecognized character : "<<yytext<<endl;}


%%

int yywrap()
{
	return 1;
}