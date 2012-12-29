/*
    File Name:      SemanticAnalyzer.y
    Instructor:     Prof. Mohamed Zahran
    Grader:         Robert Soule
    Author:         Shen Li
    UID:            N14361265
    Department:     Computer Science
    Note:           This SyntaxAnalyzer.y file includes
                    Rule Definitions and User Definitions.
*/

/*Prologue*/
%{
    /*Head File*/
    #include <stdio.h>
    #include <stdlib.h>
    #include "SemanticAnalyzer.h"
    #include "lex.yy.c"

    /*Variable Definition*/
    PSYMTYP     pretype_table;      //predefine type table link chain
    PSYMTYP     type_table;         //type definition table link chain
    PSYMFNCT    stack;              //symbol table stack
    size_t      actual;             //actual parameter count
%}

/*Declarations*/
%union {
    int         ival;       //number type
    char        cval;       //symbol type
    char*       sval;       //identifer type
    PSYMREC     symptr;     //symbol table pointer
    PSYMTYP     typptr;     //type table pointer
}

%start  program

%token  <sval> AND PBEGIN FORWARD DIV DO ELSE END FOR FUNCTION IF ARRAY MOD NOT OF OR PROCEDURE PROGRAM RECORD THEN TO TYPE VAR WHILE
%token  <ival> NUMBER
%token  <sval> STRING
%token  <symptr> ID
%token  <cval> PLUS MINUS MULTI DIVIS
%token  <sval> ASSIGNOP
%token  <cval> LT EQ GT
%token  <sval> LE GE NE
%token  <cval> LPARENTHESIS RPARENTHESIS LBRACKET RBRACKET
%token  <cval> DOT COMMA COLON SEMICOLON
%token  <sval> DOTDOT

%type   <ival> constant
%type   <typptr> type result_type
%type   <typptr> expression simple_expression simple_expression_list
%type   <typptr> term factor
%type   <typptr> variable
%type   <typptr> function_reference
%type   <symptr> identifier_list
%type   <symptr> variable_declarations variable_declaration_list
%type   <symptr> formal_parameter_list formal_parameter_list_section
%type   <symptr> field_list field_list_section

%right  ASSIGNOP
%left   PLUS MINUS OR
%left   MULTI DIVIS DIV MOD AND
%right  POS NEG
%nonassoc   LT EQ GT LE GE NE

/*Grammer Rules*/
%%

program :   PROGRAM ID SEMICOLON type_definitions variable_declarations {PSYMFNCT top = getTop(stack); top->local_list = $5;}
            subprogram_declarations compound_statement DOT              {YYACCEPT;}
        ;
type_definitions    :   /*empty*/
                    |   TYPE type_definition_list
                    ;
type_definition_list    :   type_definition_list type_definition SEMICOLON
                        |   type_definition SEMICOLON
                        ;
variable_declarations   :   /*empty*/                       {$$ = initSymbolTable(CONST_VAR);}
                        |   VAR variable_declaration_list   {$$ = $2;}
                        ;
variable_declaration_list   :   variable_declaration_list identifier_list COLON type SEMICOLON
                                    {
                                        PSYMREC     node;
                                        PSYMFNCT    top = getTop(stack);

                                        $$ = $1;
                                        for (node = $2; node != NULL; node = node->next){
                                            if ((NULL == getSymbolTable($$, node->name))
                                                    && (NULL == getSymbolTable(top->formal_list, node->name))){
                                                putSymbolTable( $$,
                                                                node->name,
                                                                ID_VARIABLE,
                                                                $4,
                                                                NULL,
                                                                node->location);
                                            }
                                            else{
                                                fprintf(stderr, "Line %u:%u error: Multiple Declaration of Variable '%s'\n",    node->location->line,
                                                                                                                                node->location->column,
                                                                                                                                node->name);
                                            }
                                        }
                                    }
                            |   identifier_list COLON type SEMICOLON
                                    {
                                        PSYMREC     node;
                                        PSYMFNCT    top = getTop(stack);

                                        $$ = initSymbolTable(CONST_VAR);
                                        for (node = $1; node != NULL; node = node->next){
                                            if ((NULL == getSymbolTable($$, node->name))
                                                    && (NULL == getSymbolTable(top->formal_list, node->name))){
                                                putSymbolTable( $$,
                                                                node->name,
                                                                ID_VARIABLE,
                                                                $3,
                                                                NULL,
                                                                node->location);
                                            }
                                            else{
                                                fprintf(stderr, "Line %u:%u error: Multiple Declaration of Variable '%s'\n",    node->location->line,
                                                                                                                                node->location->column,
                                                                                                                                node->name);
                                            }
                                        }
                                    }
                            ;
subprogram_declarations :   /*empty*/
                        |   procedure_declaration SEMICOLON subprogram_declarations
                        |   function_declaration SEMICOLON subprogram_declarations
                        ;
type_definition :   ID EQ type
                        {
                            if (NULL == getTypeTable(   $1->name,
                                                        TYPE_SIMPLE,
                                                        NULL,
                                                        NULL)){
                                putTypeTable(   type_table,
                                                $1->name,
                                                TYPE_SIMPLE,
                                                $3,
                                                NULL,
                                                NULL);
                            }
                            else{
                                fprintf(stderr, "Line %u:%u : Multiple Definition of Type Identifier '%s'\n",   $1->location->line,
                                                                                                                $1->location->column,
                                                                                                                $1->name);
                            }
                        }
                ;
procedure_declaration   :   PROCEDURE ID
                                {
                                    PSYMFNCT    old_top;
                                    PSYMFNCT    new_top;

                                    old_top = getTop(stack);
                                    if (NULL == getSymbolTable(old_top->local_list, $2->name)){
                                        push(   stack,
                                                $2->name,
                                                0,
                                                getTypeTable(CONST_VOID, TYPE_SIMPLE, NULL, NULL),
                                                NULL,
                                                NULL);
                                        new_top = getTop(stack);
                                        putSymbolTable( old_top->local_list,
                                                        $2->name,
                                                        ID_PROCEDURE,
                                                        NULL,
                                                        new_top,
                                                        $2->location);
                                    }
                                    else{
                                        fprintf(stderr, "Line %u:%u error: Multiple Declaration of Procedure '%s'\n",   $2->location->line,
                                                                                                                        $2->location->column,
                                                                                                                        $2->name);
                                        push(   stack,
                                                $2->name,
                                                0,
                                                getTypeTable(CONST_VOID, TYPE_SIMPLE, NULL, NULL),
                                                NULL,
                                                NULL);
                                    }
                                }
                            LPARENTHESIS formal_parameter_list RPARENTHESIS SEMICOLON
                                {
                                    PSYMFNCT top = getTop(stack);
                                    top->parameter = getLengthSymbolTable($5);
                                    top->formal_list = $5;
                                }
                            declaration_body    {pop(stack);}
                        ;
function_declaration    :   FUNCTION ID
                                {
                                    PSYMFNCT    old_top;
                                    PSYMFNCT    new_top;

                                    old_top = getTop(stack);
                                    if (NULL == getSymbolTable(old_top->local_list, $2->name)){
                                        push(stack, $2->name, 0, NULL, NULL, NULL);
                                        new_top = getTop(stack);
                                        putSymbolTable( old_top->local_list,
                                                        $2->name,
                                                        ID_FUNCTION,
                                                        NULL,
                                                        new_top,
                                                        $2->location);
                                    }
                                    else{
                                        fprintf(stderr, "Line %u:%u error: Multiple Declaration of Function '%s'\n",    $2->location->line,
                                                                                                                        $2->location->column,
                                                                                                                        $2->name);
                                        push(stack, $2->name, 0, NULL, NULL, NULL);
                                    }
                                }
                            LPARENTHESIS formal_parameter_list RPARENTHESIS COLON result_type SEMICOLON
                                {
                                    PSYMFNCT top = getTop(stack);
                                    top->parameter = getLengthSymbolTable($5);
                                    top->rtn = $8;
                                    top->formal_list = $5;
                                }
                            declaration_body    {pop(stack);}
                        ;
declaration_body    :   block
                    |   FORWARD 
                            {
                                PSYMREC local = initSymbolTable(CONST_VAR);
                                PSYMFNCT top = getTop(stack);
                                top->local_list = local;
                            }
                    ;
formal_parameter_list   :   /*empty*/                       {$$ = initSymbolTable(CONST_FORMAL);}
                        |   formal_parameter_list_section   {$$ = $1;}
                        ;
formal_parameter_list_section   :   formal_parameter_list_section SEMICOLON identifier_list COLON type
                                        {
                                            PSYMREC     node;

                                            $$ = $1;
                                            for (node = $3; node != NULL; node = node->next){
                                                if (NULL == getSymbolTable($$, node->name)){
                                                    putSymbolTable( $$,
                                                                    node->name,
                                                                    ID_VARIABLE,
                                                                    $5,
                                                                    NULL,
                                                                    node->location);
                                                }
                                                else{
                                                    fprintf(stderr, "Line %u:%u error: Multiple Declaration of Variable '%s'\n",    node->location->line,
                                                                                                                                    node->location->column,
                                                                                                                                    node->name);
                                                }
                                            }
                                        }
                                |   identifier_list COLON type
                                        {
                                            PSYMREC     node;

                                            $$ = initSymbolTable(CONST_FORMAL);
                                            for (node = $1; node != NULL; node = node->next){
                                                if (NULL == getSymbolTable($$, node->name)){
                                                    putSymbolTable( $$,
                                                                    node->name,
                                                                    ID_VARIABLE,
                                                                    $3,
                                                                    NULL,
                                                                    node->location);
                                                }
                                                else{
                                                    fprintf(stderr, "Line %u:%u error: Multiple Declaration of Variable '%s'\n",    node->location->line,
                                                                                                                                    node->location->column,
                                                                                                                                    node->name);
                                                }
                                            }
                                        }
                                ;
block   :   variable_declarations   {PSYMFNCT top = getTop(stack); top->local_list = $1;}
            compound_statement
        ;
compound_statement  :   PBEGIN statement_sequence END
                    ;
statement_sequence  :   statement_sequence SEMICOLON statement
                    |   statement
                    ;
statement   :   open_statement
            |   closed_statement
            ;
open_statement  :   open_if_statement
                |   open_while_statement
                |   open_for_statement
                ;
closed_statement    :   /*empty*/
                    |   assignment_statement
                    |   procedure_statement
                    |   compound_statement
                    |   closed_if_statement
                    |   closed_while_statement
                    |   closed_for_statement
                    ;
open_if_statement   :   IF expression THEN statement
							{
                                if ($2 != getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL)){
                                    fprintf(stdout, "Line %u:%u warning: Condition would be '%s' instead of '%s'\n",    line_number,
                                                                                                                        column_number,
                                                                                                                        CONST_BOOLEAN,
                                                                                                                        $2->name);
                                }
                            }
                    |   IF expression THEN closed_statement ELSE open_statement
							{
                                if ($2 != getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL)){
                                    fprintf(stdout, "Line %u:%u warning: Condition would be '%s' instead of '%s'\n",    line_number,
                                                                                                                        column_number,
                                                                                                                        CONST_BOOLEAN,
                                                                                                                        $2->name);
                                }
                            }
                    ;
closed_if_statement :   IF expression THEN closed_statement ELSE closed_statement
							{
                                if ($2 != getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL)){
                                    fprintf(stdout, "Line %u:%u warning: Condition would be '%s' instead of '%s'\n",    line_number,
                                                                                                                        column_number,
                                                                                                                        CONST_BOOLEAN,
                                                                                                                        $2->name);
                                }
                            }
                    ;
open_while_statement    :   WHILE expression DO open_statement
								{
                                    if ($2 != getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL)){
                                        fprintf(stdout, "Line %u:%u warning: Condition would be '%s' instead of '%s'\n",    line_number,
                                                                                                                            column_number,
                                                                                                                            CONST_BOOLEAN,
                                                                                                                            $2->name);
                                    }
                                }
                        ;
closed_while_statement  :   WHILE expression DO closed_statement
								{
                                    if ($2 != getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL)){
                                        fprintf(stdout, "Line %u:%u warning: Condition would be '%s' instead of '%s'\n",    line_number,
                                                                                                                            column_number,
                                                                                                                            CONST_BOOLEAN,
                                                                                                                            $2->name);
                                    }
                                }
                        ;
open_for_statement  :   FOR ID ASSIGNOP expression TO expression DO open_statement
                            {
                                PSYMREC node;

                                if ($4 != $6){
                                    fprintf(stdout, "Line %u:%u warning: Initialization '%s' and Termination '%s' without a cast\n",	$2->location->line,
                                                                                                                                        $2->location->column,
                                                                                                                                        $4->name,
                                                                                                                                        $6->name);
                                }
                                else{
                                    node = find($2->name);
                                    if (NULL == node){
										fprintf(stderr, "Line %u:%u error: Undeclaration of Variable '%s'\n", 	$2->location->line,
                                                                                                                $2->location->column,
                                                                                                                $2->name);
                                    }
                                    else if (node->property != ID_VARIABLE){
                                    	fprintf(stderr, "Line %u:%u error: Function or Procedure could not be a left-operand\n",	$2->location->line,
                                                                                                                                    $2->location->column);
                                    }
                                    else if ($4 != node->value.type){
                                    	fprintf(stdout, "Line %u:%u warning: Assignment '%s' with '%s' without a cast\n",	$2->location->line,
                                                                                                                            $2->location->column,
                                                                                                                            node->value.type->name,
                                                                                                                            $4->name);
                                    }
                                }
                            }
                    ;
closed_for_statement    :   FOR ID ASSIGNOP expression TO expression DO closed_statement
                                {
                                	PSYMREC node;

                                    if ($4 != $6){
                                        fprintf(stdout, "Line %u:%u warning: Initialization '%s' and Termination '%s' without a cast\n",    $2->location->line,
                                                                                                                                            $2->location->column,
                                                                                                                                            $4->name,
                                                                                                                                            $6->name);
                                    }
                                    else{
                                        node = find($2->name);
                                        if (NULL == node){
										    fprintf(stderr, "Line %u:%u error: Undeclaration of Variable '%s'\n", 	$2->location->line,
                                                                                                                    $2->location->column,
                                                                                                                    $2->name);
                                        }
                                        else if (node->property != ID_VARIABLE){
                                        	fprintf(stderr, "Line %u:%u error: Function or Procedure could not be a left-operand\n",    $2->location->line,
                                                                                                                                        $2->location->column);
                                        }
                                        else if ($4 != node->value.type){
                                        	fprintf(stdout, "Line %u:%u warning: Assignment '%s' with '%s' without a cast\n",   $2->location->line,
                                                                                                                                $2->location->column,
                                                                                                                                node->value.type->name,
                                                                                                                                $4->name);
                                        }
                                    }
                                }
                        ;
assignment_statement    :   variable ASSIGNOP expression
                                {
                                    if ($1 != $3){
                                        fprintf(stderr, "Line %u:%u warning: Assignment '%s' with '%s' without a cast\n",   line_number,
                                                                                                                            column_number,
                                                                                                                            $1->name,
                                                                                                                            $3->name);
                                    } 
                                }
                        ;
procedure_statement :   ID LPARENTHESIS actual_parameter_list RPARENTHESIS
                            {
                                PSYMREC node = find($1->name);

                                if (NULL == node){
                                    fprintf(stderr, "Line %u:%u error: Undeclaration of Procedure '%s'\n",  $1->location->line,
                                                                                                            $1->location->column,
                                                                                                            $1->name);
                                }
                                else if (ID_PROCEDURE != node->property){
                                   fprintf(stderr, "Line %u:%u error: Undeclaration of Procedure '%s'\n",   $1->location->line,
                                                                                                            $1->location->column,
                                                                                                            $1->name);
                                }
                                else if (actual < node->value.fnct->parameter){
                                    fprintf(stderr, "Line %u:%u error: Too few arguments to Procedure '%s'\n",  $1->location->line,
                                                                                                                $1->location->column,
                                                                                                                $1->name);
                                }
                                else if (actual > node->value.fnct->parameter){
                                    fprintf(stderr, "Line %u:%u error: Too many arguments to Procedure '%s'\n", $1->location->line,
                                                                                                                $1->location->column,
                                                                                                                $1->name);
                                }
                                actual = 0;
                            }
                    ;
type    :   ID
                {
                    $$ = getTypeTable($1->name, TYPE_SIMPLE, NULL, NULL);
                    if (NULL == $$){
                        fprintf(stderr, "Line %u:%u error: Undefine Type Identifier '%s'\n",    $1->location->line,
                                                                                                $1->location->column,
                                                                                                $1->name);
                        putTypeTable(   pretype_table,
                                        $1->name,
                                        TYPE_SIMPLE,
                                        NULL,
                                        NULL,
                                        NULL);
                        $$ = pretype_table->next;
                    }
                    else if ($$->value.equal != NULL){
                        $$ = $$->value.equal;
                    }
                }
        |   ARRAY LBRACKET constant DOTDOT constant RBRACKET OF type
                {
                    PARRBOUND   p_array = (ARRBOUND*)malloc(sizeof(ARRBOUND));
                    p_array->start = $3;
                    p_array->end = $5;
                    $$ = getTypeTable($8->name, TYPE_ARRAY, p_array, NULL);
                    if (NULL == $$){
                        putTypeTable(   pretype_table,
                                        $8->name,
                                        TYPE_ARRAY,
                                        NULL,
                                        p_array,
                                        NULL);
                        $$ = pretype_table->next;
                    }
                }
        |   RECORD field_list END
                {
                    $$ = getTypeTable($1, TYPE_RECORD, NULL, $2);
                    if (NULL == $$){
                        putTypeTable(   pretype_table,
                                        $1,
                                        TYPE_RECORD,
                                        NULL,
                                        NULL,
                                        $2);
                        $$ = pretype_table->next;
                    }
                }
        ;
result_type :   ID
                    {
                        $$ = getTypeTable($1->name, TYPE_SIMPLE, NULL, NULL);
                        if (NULL == $$){
                            fprintf(stderr, "Line %u:%u error: Undefine Type Identifier '%s'\n",    $1->location->line,
                                                                                                    $1->location->column,
                                                                                                    $1->name);
                            putTypeTable(   pretype_table,
                                            $1->name,
                                            TYPE_SIMPLE,
                                            NULL,
                                            NULL,
                                            NULL);
                            $$ = pretype_table->next;
                        }
                        else if ($$->value.equal != NULL){
                            $$ = $$->value.equal;
                        }
                    }
            ;
field_list  :   /*empty*/			{$$ = initSymbolTable(CONST_FIELD);}
            |   field_list_section	{$$ = $1;}
            ;
field_list_section  :   field_list_section SEMICOLON identifier_list COLON type
                            {
                                PSYMREC     node;

                                $$ = $1;
                                for (node = $3; node != NULL; node = node->next){
                                    if (NULL == getSymbolTable($$, node->name)){
                                        putSymbolTable( $$,
                                                        node->name,
                                                        ID_VARIABLE,
                                                        $5,
                                                        NULL,
                                                        node->location);
                                    }
                                    else{
                                        fprintf(stderr, "Line %u:%u error: Multiple Declaration of Variable '%s'\n",    node->location->line,
                                                                                                                        node->location->column,
                                                                                                                        node->name);
                                    }
                                }
                            }
                    |   identifier_list COLON type
                            {
                                PSYMREC     node;

                                $$ = initSymbolTable(CONST_FIELD);
                                for (node = $1; node != NULL; node = node->next){
                                    if (NULL == getSymbolTable($$, node->name)){
                                        putSymbolTable( $$,
                                                        node->name,
                                                        ID_VARIABLE,
                                                        $3,
                                                        NULL,
                                                        node->location);
                                    }
                                    else{
                                        fprintf(stderr, "Line %u:%u error: Multiple Delcaration of Variable '%s'\n",    node->location->line,
                                                                                                                        node->location->column,
                                                                                                                        node->name);
                                    }
                                }
                            }
                    ;
constant    :   NUMBER                      {$$ = $1;}
            |   PLUS NUMBER     %prec POS   {$$ = +$1;}
            |   MINUS NUMBER    %prec NEG   {$$ = -$1;}
            ;
expression  :   simple_expression   {$$ = $1;}
            |   simple_expression LT simple_expression
                    {
                        if ($1 != $3){
                            fprintf(stdout, "Line %u:%u warning: Compare with '%s' and '%s' without a cast\n",  line_number,
                                                                                                                column_number,
                                                                                                                $1->name,
                                                                                                                $3->name);
                        }
                        $$ = getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL);
                    }
            |   simple_expression LE simple_expression
					{
                        if ($1 != $3){
                            fprintf(stdout, "Line %u:%u warning: Compare with '%s' and '%s' without a cast\n",  line_number,
                                                                                                                column_number,
                                                                                                                $1->name,
                                                                                                                $3->name);
                        }
                        $$ = getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL);
                    }
            |   simple_expression EQ simple_expression
					{
                        if ($1 != $3){
                            fprintf(stdout, "Line %u:%u warning: Compare with '%s' and '%s' without a cast\n",  line_number,
                                                                                                                column_number,
                                                                                                                $1->name,
                                                                                                                $3->name);
                        }
                        $$ = getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL);
                    }
            |   simple_expression GE simple_expression
					{
                        if ($1 != $3){
                            fprintf(stdout, "Line %u:%u warning: Compare with '%s' and '%s' without a cast\n",  line_number,
                                                                                                                column_number,
                                                                                                                $1->name,
                                                                                                                $3->name);
                        }
                        $$ = getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL);
                    }
            |   simple_expression GT simple_expression
					{
                        if ($1 != $3){
                            fprintf(stdout, "Line %u:%u warning: Compare with '%s' and '%s' without a cast\n",  line_number,
                                                                                                                column_number,
                                                                                                                $1->name,
                                                                                                                $3->name);
                        }
                        $$ = getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL);
                    }
            |   simple_expression NE simple_expression
					{
                        if ($1 != $3){
                            fprintf(stdout, "Line %u:%u warning: Compare with '%s' and '%s' without a cast\n",  line_number,
                                                                                                                column_number,
                                                                                                                $1->name,
                                                                                                                $3->name);
                        }
                        $$ = getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL);
                    }
            ;
simple_expression   :   simple_expression_list                      {$$ = $1;}
                    |   PLUS simple_expression_list     %prec POS   {$$ = $2;}
                    |   MINUS simple_expression_list    %prec NEG   {$$ = $2;}
                    ;
simple_expression_list  :   term	{$$ = $1;}
                        |   simple_expression_list PLUS term
								{
                        			if ($1 != $3){
                            			fprintf(stdout, "Line %u:%u warning: Operate '%s' and '%s' without a cast\n",	line_number,
                                                                                                                  		column_number,
                                                                                                                		$1->name,
                                                                                                                		$3->name);
                        			}
                        			$$ = $1;
                    			}
                        |   simple_expression_list MINUS term
								{
                        			if ($1 != $3){
                            			fprintf(stdout, "Line %u:%u warning: Operate '%s' and '%s' without a cast\n",	line_number,
                                                                                                            		    column_number,
                                                                                                            		    $1->name,
                                                                                                            		    $3->name);
                        			}
                        			$$ = $1;
                    			}
                        |   simple_expression_list OR term
								{
                        			if ($1 != $3){
                            			fprintf(stdout, "Line %u:%u warning: Operate '%s' and '%s' without a cast\n",	line_number,
                                                                                                            		    column_number,
                                                                                                            		    $1->name,
                                                                                                            		    $3->name);
                        			}
                        			$$ = getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL);
                    			}
                        ;
term    :   factor	{$$ = $1;}
        |   term MULTI factor
				{
					if ($1 != $3){
						fprintf(stdout, "Line %u:%u warning: Operate '%s' and '%s' without a cast\n",	line_number,
                                                                                                        column_number,
                                                                                                        $1->name,
                                                                                                        $3->name);
					}
					$$ = $1;
				}
        |   term DIV factor
				{
					if ($1 != $3){
						fprintf(stdout, "Line %u:%u warning: Operate '%s' and '%s' without a cast\n",	line_number,
                                                                                                        column_number,
                                                                                                        $1->name,
                                                                                                        $3->name);
					}
					$$ = $1;
				}
        |   term DIVIS factor
				{
					if ($1 != $3){
						fprintf(stdout, "Line %u:%u warning: Operate '%s' and '%s' without a cast\n",	line_number,
                                                                                                        column_number,
                                                                                                        $1->name,
                                                                                                        $3->name);
					}
					$$ = $1;
				}
        |   term MOD factor
				{
					if ($1 != $3){
						fprintf(stdout, "Line %u:%u warning: Operate '%s' and '%s' without a cast\n",	line_number,
                                                                                                        column_number,
                                                                                                        $1->name,
                                                                                                        $3->name);
					}
					$$ = $1;
				}
        |   term AND factor
				{
					if ($1 != $3){
						fprintf(stdout, "Line %u:%u warning: Operate '%s' and '%s' without a cast\n",	line_number,
                                                                                                        column_number,
                                                                                                        $1->name,
                                                                                                        $3->name);
					}
					$$ = getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL);
				}
        ;
factor  :   NUMBER                                  {$$ = getTypeTable(CONST_INTEGER, TYPE_SIMPLE, NULL, NULL);}
        |   STRING                                  {$$ = getTypeTable(CONST_STRING, TYPE_SIMPLE, NULL, NULL);}
        |   variable                                {$$ = $1;}
        |   function_reference                      {$$ = $1;}
        |   NOT factor                              {$$ = $2;}
        |   LPARENTHESIS expression RPARENTHESIS    {$$ = $2;}
        ;
function_reference  :   ID LPARENTHESIS actual_parameter_list RPARENTHESIS
                            {
                                PSYMREC node = find($1->name);

                                if (NULL == node){
                                    fprintf(stderr, "Line %u:%u error: Undeclaration of Function '%s'\n",	$1->location->line,
                                                                                                            $1->location->column,
                                                                                                            $1->name);
									$$ = getTypeTable(CONST_VOID, TYPE_SIMPLE, NULL, NULL);
                                }
                                else if (ID_FUNCTION != node->property){
                                    fprintf(stderr, "Line %u:%u error: Undeclaration of Function '%s'\n",   $1->location->line,
                                                                                                            $1->location->column,
                                                                                                            $1->name);
                                    $$ = getTypeTable(CONST_VOID, TYPE_SIMPLE, NULL, NULL);
                                }
								else{
                                    if (actual < node->value.fnct->parameter){
                                        fprintf(stderr, "Line %u:%u error: Too few arguments to Function '%s'\n",   $1->location->line,
                                                                                                                    $1->location->column,
                                                                                                                    $1->name);
                                    }
                                    else if (actual > node->value.fnct->parameter){
                                        fprintf(stderr, "Line %u:%u error: Too many arguments to Function '%s'\n",  $1->location->line,
                                                                                                                    $1->location->column,
                                                                                                                    $1->name);
                                    }
									$$ = node->value.fnct->rtn;
								}
                                actual = 0;
                            }
                    ;
variable    :   ID component_selection
                    {
                        PSYMFNCT top = getTop(stack);
                        PSYMREC node;

                        if ($1->name == top->name){
                            $$ = top->rtn;
                        }
                        else{
                            node = find($1->name);
                            if (NULL == node){
                                fprintf(stderr, "Line %u:%u error: Undeclaration of Variable '%s'\n",   $1->location->line,
                                                                                                        $1->location->column,
                                                                                                        $1->name);
                                $$ = getTypeTable(CONST_VOID, TYPE_SIMPLE, NULL, NULL);
                            }
                            else if (ID_VARIABLE == node->property){
                                $$ = node->value.type;
                            }
                            else{
                                $$ = node->value.fnct->rtn;
                            }
                        }
                    }
            ;
component_selection :   /*empty*/
                    |   DOT ID component_selection
                    |   LBRACKET expression RBRACKET
                            {
                                if ($2 != getTypeTable(CONST_INTEGER, TYPE_SIMPLE, NULL, NULL)){
                                    fprintf(stderr, "Line %u:%u error: Array subscript is not an '%s'\n",   line_number,
                                                                                                            column_number,
                                                                                                            CONST_INTEGER);
                                }
                            }
                        component_selection
                    ;
actual_parameter_list   :   /*empty*/   {actual = 0;}
                        |   actual_parameter_list_section
                        ;
actual_parameter_list_section   :   actual_parameter_list_section COMMA expression  {actual++;}
                                |   expression                                      {actual++;}
                                ;
identifier_list :   identifier_list COMMA ID	{$$ = $3;$3->next = $1;}
                |   ID					        {$$ = $1;}
                ;

%%
/*Epilogue*/
/*  Main Function
    Variable Definition:
    -- argc: number of command arguments
    -- argv: each variable of command arguments(argv[0] is the path of execution file forever)
    Return Value: exit number
*/
int main(int argc, char *argv[]){
    //Test for correct number of arguments
    if (argc != 2){
        dieWithUserMessage("Parameter(s)", "<input file name>");
    }

    //Open file for reading input stream
    if ((yyin = fopen(argv[1], "r")) == NULL){
        dieWithUserMessage("fopen() failed", "Cannot open file to read input stream!");
    }

    //Initialize
    init();

    //Start syntax analysis
    do {
        yyparse();
    } while (!feof(yyin));

    //Clear
    clear();
    //Close file stream
    fclose(yyin);

    return 0;
}

/*  Parser Error Function
    Variable Definition:
    -- detail: detail error message
    Return Value: NULL
*/
void yyerror(const char* detail){
    fprintf(stderr, "Line %u:%u : %s\n",    line_number,
                                            column_number,
                                            detail);

    return;
}

/*  Initialize Analyzer Function
    Variable Definition:
    -- void
    Return Value: NULL
*/
void init(void){
    //Initialize predefine and type table
    initTypeTable();
    //Initialize symbol table stack
    initStack();
    //Initialize actual parameter count
    actual = 0;

    return;
}

/*	Clear Analyzer Function
	Variable Definition:
	-- void
	Return Value: NULL
*/
void clear(void){
    PSYMFNCT    top;        //_symfnct struct node

    //Get the top element of stack
    top = getTop(stack);
    //Free top element
    clearStack(top);
    //Free stack head node
    free(stack);
    //Free pretype table
    clearTypeTable(pretype_table);
    //Free type table
    clearTypeTable(type_table);

    return;
}
