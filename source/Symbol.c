///////////////////////////////////////////////////////////
/*
 * File Name:       Symbol.c
 * Instructor:      Prof. Mohamed Zahran
 * Grader:          Robert Soule
 * Author:          Shen Li
 * UID:             N14361265
 * Department:      Computer Science
 * Note:            This Symbol.c file includes
 *                  Process Symbol Table Functions.
*/
///////////////////////////////////////////////////////////

//////////Head File//////////
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SemanticAnalyzer.h"

//////////Function Definition//////////
/*  Initialize Symbol Table Function
    Variable Definition:
    -- name: symbol table name
    Return Value: symbol table head node
*/
PSYMREC initSymbolTable(const char* name){
    PSYMREC     node;       //_symrec struct node

    //Allocate memory for symbol table
    node = (SYMREC*)malloc(sizeof(SYMREC));
    //Initialize symbol table head node
    node->name = (char*)malloc(strlen(name) + 1);
    node->name = strdup(name);
    node->property = 0;
    node->value.type = NULL;
    node->location = NULL;
    node->next = NULL;

    return node;
}

/*  Clear Symbol Table Function
    Variable Definition:
    -- table: symbol table head node
    Return Value: NULL
*/
void clearSymbolTable(PSYMREC table){
    PSYMREC     node;       //_symrec struct node

    //Initialize node
    node = table->next;
    //Free all node in symbol table link chain
    while (node != NULL){
        //According to the property
        switch (node->property){
            case ID_VARIABLE:
                //Nothing to do
                break;
            case ID_PROCEDURE:
                //Free _symfnct struct node
                if (node->value.fnct != NULL){
                    clearStack(node->value.fnct);
                }
                break;
            case ID_FUNCTION:
                //Free _symfnct struct node
                if (node->value.fnct != NULL){
                    clearStack(node->value.fnct);
                }
                break;
            default:
                break;
        }
        //Remove node from symbol table
        table->next = node->next;
        //Free _symloc struct node
        if (node->location != NULL){
            free(node->location);
        }
        //Free _symrec struct node
        free(node);
        //Update node pointer
        node = table->next;
    }
    //Free symbol table head node
    free(table);

    return;
}

/*  Put Identifier into Symbol Table Function
    Variable Definition:
    -- table: symbol table
    -- name: identifier name
    -- property: identifier property
    -- type: identifier type
    -- fnct: identifier function (or procedure) pointer
    -- location: identifier location
    Return Value: NULL
*/
void putSymbolTable(    PSYMREC     table,
                        const char* name,
                        u_int16     property,
                        PSYMTYP     type,
                        PSYMFNCT    fnct,
                        PSYMLOC     location){
    PSYMREC     node;       //_symrec struct node

    //Allocate memory for identifier node
    node = (SYMREC*)malloc(sizeof(SYMREC));
    //Set "name" field
    node->name = (char*)malloc(strlen(name) + 1);
    node->name = strdup(name);
    //Set "property" field
    node->property = property;
    //Set "value" field
    switch (property){
        case ID_VARIABLE:
            //Set identifier type
            node->value.type = type;
            break;
        case ID_PROCEDURE:
            //Set identifier procedure entry
            node->value.fnct = fnct;
            break;
        case ID_FUNCTION:
            //Set identifier function entry
            node->value.fnct = fnct;
            break;
        default:
            dieWithUserMessage("putSymbolTable() failed", "property incorrect!");
            break;
    }
    //Set "location" field (dangling reference)
    node->location = location;
    //Put identifier node into symbol table
    node->next = table->next;
    table->next = node;

    return;
}

/*  Get Identifier from Symbol Table Function
    Variable Definition:
    -- table: symbol table
    -- name: identifier name
    Return Value:   if exists, return identifier _symrec struct node;
                    else return NULL
*/
PSYMREC getSymbolTable( const PSYMREC   table,
                        const char*     name){
    SYMREC  *node;      //identifier _symrec struct node

    //Find the identifier in symbol table
    for (node = table->next; node != NULL; node = node->next){
        //Compare the name field
        if (0 == strcmp(node->name, name)){
            return node;
        }
    }

    return NULL;
}

/*  Compare Two Symbol Table Function
    Variable Definition:
    -- table_1: the first symbol table
    -- table_2: the second symbol table
    Return Value: if two symbol table are same, return true; else return false
*/
bool compareSymbolTable(const PSYMREC   table_1,
                        const PSYMREC   table_2){
    PSYMREC     node_1;     //_symrec struct node
    PSYMREC     node_2;     //_symrec struct node

    //Initialize two nodes
    node_1 = table_1->next;
    node_2 = table_2->next;
    //Compare each identifier's type
    while ((node_1 != NULL) && (node_2 != NULL)){
        //Compare the identifier property
        if ((node_1->property != ID_VARIABLE)
                || (node_2->property != ID_VARIABLE)){
            return false;
        }
        //Compare the identifier type
        else if (node_1->value.type != node_2->value.type){
            return false;
        }
        node_1 = node_1->next;
        node_2 = node_2->next;
    }
    //Compare the identifier list length
    if ((node_1 != NULL)
            || (node_2 != NULL)){
        return false;
    }
    
    return true;
}

/*  Get Symbol Table Length Function
    Variable Definition:
    -- table: symbol table
    Return Value: symbol table length
*/
size_t getLengthSymbolTable(const PSYMREC table){
    PSYMREC     node;       //_symrec struct node
    size_t      count;      //count

    //Compute the length of table
    for (node = table->next, count = 0; node != NULL; node = node->next){
        count++;
    }

    return count;
}

/*  Output Symbol Table Function
    Variable Definition:
    -- table: symbol table
    Return Value: NULL
*/
void outputSymbolTable(const PSYMREC table){
    PSYMREC     node;       //_symrec struct node

    //Output the symbol table name
    fputc('\n', stdout);
    fputs("**********", stdout);
    fputs(table->name, stdout);
    fputs("**********", stdout);    
    fputc('\n', stdout);
    //Output symbol table node
    for (node = table->next; node != NULL; node = node->next){
        //Output identifier name and property
        fprintf(stdout, "%8s ", node->name);
        switch (node->property){
            case ID_VARIABLE:
                //Output identifier type
                if (node->value.type != NULL){
                    outputType(node->value.type);
                }
                break;
            case ID_PROCEDURE:
                //Output procedure symbol table
                if (node->value.fnct != NULL){
                    outputStack(node->value.fnct);
                }
                break;
            case ID_FUNCTION:
                //Output function symbol table
                if (node->value.fnct != NULL){
                    outputStack(node->value.fnct);
                }
                break;
            default:
                //Nothing to output
                break;
        }
    }
    //Output table end
    fputs("**********", stdout);
    fputs(table->name, stdout);
    fputs(" end**********", stdout);
    fputc('\n', stdout);

    return;
}
