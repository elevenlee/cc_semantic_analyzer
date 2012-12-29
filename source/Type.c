///////////////////////////////////////////////////////////
/*
 * File Name:       Type.c
 * Instructor:      Prof. Mohamed Zahran
 * Grader:          Robert Soule
 * Author:          Shen Li
 * UID:             N14361265
 * Department:      Computer Science
 * Note:            This Type.c file includes
 *                  Process Type Table Functions.
*/
///////////////////////////////////////////////////////////

//////////Head File//////////
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SemanticAnalyzer.h"

//////////Function Definition//////////
/*  Initialize Predefine Table and Type Table Function
    Variable Definition:
    -- void
    Return Value: NULL
*/
void initTypeTable(void){
    //Allocate memory for predefine type table
    pretype_table = (SYMTYP*)malloc(sizeof(SYMTYP));
    //Initilize predefine type table head node
    pretype_table->name = (char*)malloc(strlen(CONST_PREDEF) + 1);
    pretype_table->name = strdup(CONST_PREDEF);
    pretype_table->property = 0;
    pretype_table->value.equal = NULL;
    pretype_table->next = NULL;
    //Put void into predefine type table
    putTypeTable(   pretype_table,
                    CONST_VOID,
                    TYPE_SIMPLE,
                    NULL,
                    NULL,
                    NULL);
    //Put integer into predefine type table
    putTypeTable(   pretype_table,
                    CONST_INTEGER,
                    TYPE_SIMPLE,
                    NULL,
                    NULL,
                    NULL);
    //Put string into predefine table
    putTypeTable(   pretype_table,
                    CONST_STRING,
                    TYPE_SIMPLE,
                    NULL,
                    NULL,
                    NULL);
    //Put boolean into predefine table
    putTypeTable(   pretype_table,
                    CONST_BOOLEAN,
                    TYPE_SIMPLE,
                    NULL,
                    NULL,
                    NULL);

    //Allocate memory for type table
    type_table = (SYMTYP*)malloc(sizeof(SYMTYP));
    //Initialize type table head node
    type_table->name = (char*)malloc(strlen(CONST_TYPE) + 1);
    type_table->name = strdup(CONST_TYPE);
    type_table->property = 0;
    type_table->value.equal = NULL;
    type_table->next = NULL;

    return;
}

/*  Clear Type Table Function
    Variable Definition:
    -- table: type table
    Return Value: NULL
*/
void clearTypeTable(PSYMTYP table){
    PSYMTYP     node;       //_symtyp struct node

    //Initialize node
    node = table->next;
    //Free all node in type table link chain
    while (node != NULL){
        //According to the property
        switch (node->property){
            case TYPE_SIMPLE:
                //Nothing to do
                break;
            case TYPE_ARRAY:
                //Free _arrbound struct node
                if (node->value.array != NULL){
                    free(node->value.array);
                }
                break;
            case TYPE_RECORD:
                //Free field symbol table
                if (node->value.field != NULL){
                    clearSymbolTable(node->value.field);
                }
                break;
            default:
                break;
        }
        //Remove node from type table
        table->next = node->next;
        //Free _symtyp struct node
        free(node);
        //Update node pointer
        node = table->next;
    }
    //Free type table head node
    free(table);

    return;
}

/*  Put Type Identifier into Type Table Function
    Variable Definition:
    -- table: type table
    -- name: type name
    -- property: type property
    -- equal: type equivalence
    -- array: array bound
    -- field: record field list
    Return Value: NULL
*/
void putTypeTable(  PSYMTYP     table,
                    const char* name,
                    u_int16     property,
                    PSYMTYP     equal,
                    PARRBOUND   array,
                    PSYMREC     field){
    PSYMTYP     node;       //_symtyp struct node

    //Allocate memory for type node
    node = (SYMTYP*)malloc(sizeof(SYMTYP));
    //Set "name" field
    node->name = (char*)malloc(strlen(name) + 1);
    node->name = strdup(name);
    //Set "property" field
    node->property = property;
    //Set "value" field
    switch (property){
        case TYPE_SIMPLE:
            //Set equivalence type
            node->value.equal = equal;
            break;
        case TYPE_ARRAY:
            //Set array boundary
            node->value.array = array;
            break;
        case TYPE_RECORD:
            //Set record field
            node->value.field = field;
            break;
        default:
            dieWithUserMessage("putTypeTable() failed", "property incorrect!");
            break;
    }
    //Put type node into table
    node->next = table->next;
    table->next = node;

    return;
}

/*  Get Type Identifier from Type Table
    Variable Definition:
    -- name: type name
    -- property: type property
    -- array: array bound
    -- field: record field list
    Return Value:   if exists, return type identifier _symtyp struct node;
                    else return NULL
*/
PSYMTYP getTypeTable(   const char*     name,
                        u_int16         property,
                        const PARRBOUND array,
                        const PSYMREC   field){
    PSYMTYP     node;       //_symtyp struct node

    //Find the type in pretype table
    for (node = pretype_table->next; node != NULL; node = node->next){
        //Compare the name and property field
        if ((0 == strcmp(node->name, name))
                && (property == node->property)){
            //According to the property
            if (TYPE_SIMPLE == property){
                return node;
            }
            else if (TYPE_ARRAY == property){
                //Compare the array boundary
                if ((array->start == node->value.array->start)
                        && (array->end == node->value.array->end)){
                    return node;
                }
            }
            else if (TYPE_RECORD == property){
                //Compare the field list
                if (compareSymbolTable(field, node->value.field)){
                    return node;
                }
            }
            else{
                dieWithUserMessage("getTypeTable() failed", "property incorrect!");
            }
        }
    }
    //Find the type in type table
    for (node = type_table->next; node != NULL; node = node->next){
        //Compare the name field
        if (0 == strcmp(node->name, name)){
            return node;
        }
    }

    return NULL;
}

/*  Output Type Identifier in the Type table
    Variable Definition:
    -- node: type node
    Return Value: NULL
*/
void outputType(const PSYMTYP node){
    //Output type name
    fprintf(stdout, "%8s ", node->name);
    //Output type value
    switch (node->property){
        case TYPE_SIMPLE:
            //Output equivalence
            if (node->value.equal != NULL){
                outputType(node->value.equal);
            }
            break;
        case TYPE_ARRAY:
            //Output array bound
            if (node->value.array != NULL){
                fprintf(stdout, "(bound: %u to %u)",    node->value.array->start,
                                                        node->value.array->end);
            }
            break;
        case TYPE_RECORD:
            //Output field list
            if (node->value.field != NULL){
                outputSymbolTable(node->value.field);
            }
            break;
        default:
            //Nothing to output
            break;
    }
    fputc('\n', stdout);
    
    return;
}

/*  Output Type Identifier in the Type Table
    Variable Definition:
    -- table: type table
    Return Value: NULL
*/
void outputTypeTable(const PSYMTYP table){
    PSYMTYP     node;       //_symtyp struct node

    //Output the type table name
    fputc('\n', stdout);
    fputs("**********", stdout);
    fputs(table->name, stdout);
    fputs("**********", stdout);
    fputc('\n', stdout);
    //Output type table node
    for (node = table->next; node != NULL; node = node->next){
        outputType(node);
    }

    return;
}
