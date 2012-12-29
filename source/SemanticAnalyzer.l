/*
    File Name:      SemanticAnalyzer.l
    Instructor:     Prof. Mohamed Zahran
    Grader:         Robert Soule
    Author:         Shen Li
    UID:            N14361265
    Department:     Computer Science
    Note:           This SyntaxAnalyzer.l file includes
                    Rule Definitions and User Functions.
*/

/*Declarations*/
%{
    /*Head File*/
    #include <stdio.h>
    #include <stdlib.h>
    #include "SemanticAnalyzer.h"
    #include "SemanticAnalyzer.tab.h"

    /*Variable Definition*/
    u_int32 line_number = 1;    //line number
    u_int16 column_number = 1;  //column number
%}

    /*Definition Section*/
DIGIT       [0-9]
NUMBER      {DIGIT}+(\.{DIGIT}+)?
LETTER      [a-zA-Z]
DELIM       [ \t\r]

%%
    /*Translation Rules*/
and                             {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);    return  (AND);  }
begin                           {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (PBEGIN);  }
forward                         {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (FORWARD);  }
div                             {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (DIV);  }
do                              {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (DO);   }
else                            {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (ELSE); }
end                             {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (END);  }
for                             {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (FOR);  }
function                        {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (FUNCTION); }
if                              {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (IF);   }
array                           {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (ARRAY);}
mod                             {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (MOD);  }
not                             {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (NOT);  }
of                              {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (OF);   }
or                              {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (OR);   }
procedure                       {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (PROCEDURE);}
program                         {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (PROGRAM);  }
record                          {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (RECORD);   }
then                            {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (THEN); }
to                              {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (TO);   }
type                            {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (TYPE); }
var                             {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (VAR);  }
while                           {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (WHILE);}
{NUMBER}(e[+-]?{NUMBER})?       {   yylval.ival = atoi(yytext);     column_number += strlen(yytext);	return  (NUMBER);   }
\"[^\"]*\"                      {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (STRING);   }
{LETTER}({LETTER}|{DIGIT}|_)*   {   yylval.symptr = installID();    column_number += strlen(yytext);    return  (ID);       }
"+"                             {   yylval.cval = '+';  column_number++;	return  (PLUS);   }
"-"                             {   yylval.cval = '-';  column_number++;	return  (MINUS);   }
"*"                             {   yylval.cval = '*';  column_number++;	return  (MULTI);   }
"/"                             {   yylval.cval = '/';  column_number++;	return  (DIVIS);   }
":="                            {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (ASSIGNOP); }
"<"                             {   yylval.cval = '<';  column_number++;	return  (LT);    }
"<="                            {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (LE);    }
"="                             {   yylval.cval = '=';  column_number++;	return  (EQ);    }
">="                            {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (GE);    }
">"                             {   yylval.cval = '>';  column_number++;	return  (GT);    }
"<>"                            {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (NE);    }
"."                             {   yylval.cval = '.';  column_number++;	return  (DOT);}
","                             {   yylval.cval = ',';  column_number++;	return  (COMMA);}
":"                             {   yylval.cval = ':';  column_number++;	return  (COLON);}
";"                             {   yylval.cval = ';';  column_number++;	return  (SEMICOLON);}
".."                            {   yylval.sval = strdup(yytext);   column_number += strlen(yytext);	return  (DOTDOT);}
"("                             {   yylval.cval = '(';  column_number++;	return  (LPARENTHESIS);  }
")"                             {   yylval.cval = ')';  column_number++;	return  (RPARENTHESIS);  }
"["                             {   yylval.cval = '[';  column_number++;	return  (LBRACKET);  }
"]"                             {   yylval.cval = ']';  column_number++;	return  (RBRACKET);  }
"{"                             {
                                    register int    c;      //register character

                                    //Find the '}' character
                                    while ((c = input())){
                                        if (c == '}'){
                                            //Comment end
											column_number++;
                                            break;
                                        }
                                        else if (c == '\n'){
                                            //Increase the line number
                                            line_number++;
											//Set column number
											column_number = 1;
                                        }
                                        else if (c == 0){
                                            //unexpected EOF inside comment
                                            fprintf(stderr, "Line %u:%u : Unexpected EOF inside comment\n", line_number, column_number);
                                            exit(1);
                                        }
                                    }
                                }
{DELIM}+                        {   column_number += strlen(yytext);	/*eat up whitespace*/   }
\n                              {   line_number++;	column_number = 1;	/*eat up whitespace*/	}
.                               {
                                    //Output the illegal character and it's line number
                                    fprintf(stderr, "Line %u:%u : '%c' (0%o) -- illegal character\n",   line_number,
                                                                                                        column_number,
                                                                                                        yytext[0],
                                                                                                        yytext[0]);
                                    exit(1);
                                }

%%
/*Auxiliary Functions*/
/*  Install Identifier Function
    Variable Definition:
    -- void
    Return Value: Identifier _symrec struct node
*/
PSYMREC installID(void){
    PSYMREC     node;       //_symrec struct node

    //Allocate space for identifier node
    node = (SYMREC*)malloc(sizeof(SYMREC));
    //Assign variable of _symrec struct node
    node->name = strdup(yytext);
    //Allocate space for identifier location
    node->location = (SYMLOC*)malloc(sizeof(SYMLOC));
    node->location->line = line_number;
    node->location->column = column_number;
    node->next = NULL;

    return node;
}
