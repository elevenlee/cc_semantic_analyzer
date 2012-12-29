///////////////////////////////////////////////////////////
/*
 * File Name:       Stack.c
 * Instructor:      Prof. Mohamed Zahran
 * Grader:          Robert Soule
 * Author:          Shen Li
 * UID:             N14361265
 * Department:      Computer Science
 * Note:            This Stack.c file includes
 *                  Process Symbol Table Stack Functions.
*/
///////////////////////////////////////////////////////////

//////////Head File//////////
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SemanticAnalyzer.h"

//////////Function Definition//////////
/*  Initialize Symbol Table Stack Function
    Variable Definition:
    -- void
    Return Value: NLL
*/
void initStack(void){
    PSYMREC     formal;     //_symrec struct node

    //Allocate memory for symbol table stack
    stack = (SYMFNCT*)malloc(sizeof(SYMFNCT));
    //Initialize symbol table stack head node
    stack->name = (char*)malloc(strlen(CONST_SYMBOL) + 1);
    stack->name = strdup(CONST_SYMBOL);
    stack->parameter = 0;
    stack->rtn = NULL;
    stack->formal_list = NULL;
    stack->local_list = NULL;
    stack->next = NULL;
    //Initiliaze global formal parameter symbol table
    formal = initSymbolTable(CONST_FORMAL);
    //Put predefine variable 'true'
    putSymbolTable( formal,
                    CONST_TRUE,
                    ID_VARIABLE,
                    getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL),
                    NULL,
                    NULL);
    //Put predefine variable 'false'
    putSymbolTable( formal,
                    CONST_FALSE,
                    ID_VARIABLE,
                    getTypeTable(CONST_BOOLEAN, TYPE_SIMPLE, NULL, NULL),
                    NULL,
                    NULL);
    //Push Main Function (or Procedure) into stack
    push(   stack,
            CONST_GLOBAL,
            0,
            getTypeTable(CONST_VOID, TYPE_SIMPLE, NULL, NULL),
            formal,
            NULL);

    return;
}

/*  Clear Symbol Table Stack Function
    Variable Definition:
    -- s: symbol table stack
    Return Value: NULL
*/
void clearStack(PSYMFNCT s){
    //Free formal list symbol table
    if (s->formal_list != NULL){
        clearSymbolTable(s->formal_list);
    }
    //Free local variable symbol table
    if (s->local_list != NULL){
        clearSymbolTable(s->local_list);
    }
    //Free _symfnct struct node
    free(s);

    return;
}

/*  Detect Empty Stack Function
    Variable Definition:
    -- s: detected stack
    Return Value: if stack is empty, return true; else return false
*/
bool emptyStack(const PSYMFNCT s){
    return (NULL == s->next);
}

/*  Push Symbol Table into Stack Function
    Varialbe Definition:
    -- s: symbol table stack
    -- name: function name
    -- parameter: function parameter number
    -- rtn: function return type
    -- formal_list: function formal parameter list
    -- local_list: function local variable list
    Return Value: NULL
*/
void push(  PSYMFNCT    s,
            const char* name,
            size_t      parameter,
            PSYMTYP     rtn,
            PSYMREC     formal_list,
            PSYMREC     local_list){
    PSYMFNCT    node;       //_symfnct struct node

    //Allocate memory for symbol table node
    node = (SYMFNCT*)malloc(sizeof(SYMFNCT));
    //Set "name" field
    node->name = (char*)malloc(strlen(name) + 1);
    node->name = strdup(name);
    //Set "parameter" field
    node->parameter = parameter;
    //Set "rtn" field
    node->rtn = rtn;
    //Set "para_list" field
    node->formal_list = formal_list;
    //Set "local_list field
    node->local_list = local_list;
    //Push symbol table node into stack
    node->next = s->next;
    s->next = node;
    
    return;
}

/*  Pop Symbol Table Out Stack Function
    Variable Definition:
    -- s: symbol table stack
    Return Value: NULL
*/
void pop(PSYMFNCT s){
    PSYMFNCT    node;       //_symfnct struct node

    //Check whether stack is empty
    if (NULL == s->next){
        dieWithUserMessage("pop() failed", "Symbol table stack is empty!");
    }
    //Pop the top element out stack
    node = s->next;
    s->next = node->next;
    //Do not free the symbol table
    node->next = NULL;

    return;
}

/*  Get the Top Element in Stack Function
    Variable Definition:
    -- s: symbol table stack
    Return Value: the top element
*/
PSYMFNCT getTop(const PSYMFNCT s){
    //Check whether stack is empty
    if (NULL == s->next){
        dieWithUserMessage("getTop() failed", "The stack is empty!");
    }
    
    return s->next;
}

/*  Find Identifier in Stack Function
    Variable Definition:
    -- name: identifier name
    Return Value: return identifier node
*/
PSYMREC find(const char* name){
    PSYMFNCT    top;        //_symfnct struct node
    PSYMFNCT    node;       //_symfnct struct node
    PSYMREC     symbol;     //_symrec struct node

    //Get the stack top element
    top = getTop(stack);
    //Initialize symbol
    symbol = NULL;
    //Find identifier in symbol table
    for (node = top; node != NULL; node = node->next){
        //Find the identifier in local list
        symbol = getSymbolTable(node->local_list, name);
        //Not found
        if (NULL == symbol){
            //Find the identifier in formal list
            symbol = getSymbolTable(node->formal_list, name);
        }
        if (symbol != NULL){
            break;
        }
    }

    return symbol;
}

/*  Output Symbol Table Stack Function
    Variable Definition:
    -- s: symbol table stack
    Return Value: NULL
*/
void outputStack(const PSYMFNCT s){
    //Output stack top element name
    fputc('\n', stdout);
    fputs("**********", stdout);
    fputs(s->name, stdout);
    fputs("**********", stdout);
    fputc('\n', stdout);
    //Output stack top element parameter number
    fprintf(stdout, "Parameter Number: %u\n", s->parameter);
    //Output stack top element return type
    fprintf(stdout, "Return Type: ");
    outputType(s->rtn);
    //Output stack top element formal parameter list
    if (s->formal_list != NULL){
        outputSymbolTable(s->formal_list);
    }
    //Output stack top element local variable list
    if (s->local_list != NULL){
        outputSymbolTable(s->local_list);
    }
    //Output stack end
    fputs("**********", stdout);
    fputs(s->name, stdout);
    fputs(" end**********", stdout);
    fputc('\n', stdout);

    return;
}
