///////////////////////////////////////////////////////////
/*
 * File Name:       SemanticAnalyzer.h
 * Instructor:      Prof. Mohamed Zahran
 * Grader:          Robert Soule
 * Author:          Shen Li
 * UID:             N14361265
 * Department:      Computer Science
 * Note:            This SyntaxAnalyzer.h file includes
 *                  variable, macro, structure, function
 *                  declaration and precompile.
*/
///////////////////////////////////////////////////////////

//////////Precompile//////////
#ifndef SEMANTICANALYZER_H
#define SEMANTICANALYZER_H

//////////Head File//////////
#include <stdbool.h>

//////////Macro Declaration//////////
/*type definition*/
#define CONST_VOID      "void"
#define CONST_INTEGER   "integer"
#define CONST_BOOLEAN   "boolean"
#define CONST_STRING    "string"
#define CONST_RECORD    "record"
/*variable definition*/
#define CONST_GLOBAL    "global"
#define CONST_TRUE      "true"
#define CONST_FALSE     "false"
/*table head name definition*/
#define CONST_SYMBOL    "SYMBOL TABLE"
#define CONST_PREDEF    "PREDEFINE"
#define CONST_TYPE      "TYPE"
#define CONST_VAR       "VARIABLE"
#define CONST_FORMAL    "FORMAL"
#define CONST_FIELD     "FIELD"

//////////Type Declaration//////////
typedef unsigned short  u_int16;
typedef unsigned int    u_int32;

//////////Enum Declaration//////////
enum    identifier_type{
    ID_VARIABLE = 1,
    ID_PROCEDURE,
    ID_FUNCTION,
};

enum    type_property{
    TYPE_SIMPLE = 1,
    TYPE_ARRAY,
    TYPE_RECORD,
};

//////////Struct Declaration//////////
/*Array Bound Structure*/
typedef struct _arrbound{
    u_int16 start;              //array bound start
    u_int16 end;                //array bound end
}ARRBOUND, *PARRBOUND;

/*Symbol Location Structure*/
typedef struct _symloc{
    u_int32 line;
    u_int16 column;
}SYMLOC, *PSYMLOC;

/*Type Definition Structure*/
typedef struct _symtyp{
    char*   name;               //type name
    u_int16 property;           //type property: simple, array or record
    union{
        struct _symtyp  *equal; //type equivalence
        PARRBOUND       array;  //type bound for array
        struct _symrec  *field; //type name field list for record
    }value;                     //type value
    struct _symtyp  *next;      //link field
}SYMTYP, *PSYMTYP;

/*Symbol Table Structure*/
typedef struct _symrec{
    char*   name;               //identifier name
    u_int16 property;           //identifier property: variable, function or procedure
    union{
        PSYMTYP         type;   //variable type
        struct _symfnct *fnct;  //function or procedure struct
    }value;
    PSYMLOC location;           //identifier location
    struct _symrec  *next;      //link field
}SYMREC, *PSYMREC;

/*Symbol Table Function (or Procedure) Structure*/
typedef struct _symfnct{
    char*   name;               //function name 
    size_t  parameter;          //function parameter number
    PSYMTYP rtn;                //function return type
    PSYMREC formal_list;        //function formal parameter list
    PSYMREC local_list;         //function local variable list
    struct _symfnct *next;      //link chain
}SYMFNCT, *PSYMFNCT;

//////////Variable Declaration//////////
extern u_int32  line_number;
extern u_int16  column_number;
extern PSYMTYP  pretype_table;
extern PSYMTYP  type_table;
extern PSYMFNCT stack;
extern size_t   actual;

/////////Function Declaration//////////
/*DieWithMessage.c*/
void    dieWithUserMessage(const char* message, const char* detail);
void    dieWithSystemMessage(const char* message);
/*SemanticAnalyzer.l*/
PSYMREC installID(void);
/*SemanticAnalyzer.y*/
void    yyerror(const char* detail);
void    init(void);
void    clear(void);
/*Type.c*/
void    initTypeTable(void);
void    clearTypeTable(PSYMTYP table);
void    putTypeTable(   PSYMTYP     table,
                        const char* name,
                        u_int16     property,
                        PSYMTYP     equal,
                        PARRBOUND   array,
                        PSYMREC     field);
PSYMTYP getTypeTable(   const char*     name,
                        u_int16         property,
                        const PARRBOUND array,
                        const PSYMREC   field);
void    outputType(const PSYMTYP node);
void    outputTypeTable(const PSYMTYP table);
/*Symbol.c*/
PSYMREC initSymbolTable(const char* name);
void    clearSymbolTable(PSYMREC table);
void    putSymbolTable( PSYMREC     table,
                        const char* name,
                        u_int16     property,
                        PSYMTYP     type,
                        PSYMFNCT    fnct,
                        PSYMLOC     location);
PSYMREC getSymbolTable( const PSYMREC   table,
                        const char*     name);
bool    compareSymbolTable( const PSYMREC   table_1,
                            const PSYMREC   table_2);
size_t  getLengthSymbolTable(const PSYMREC  table);
void    outputSymbolTable(const PSYMREC table);
/*Stack.c*/
void    initStack(void);
void    clearStack(PSYMFNCT s);
bool    emptyStack(const PSYMFNCT s);
void    push(   PSYMFNCT    s,
                const char* name,
                size_t      parameter,
                PSYMTYP     rtn,
                PSYMREC     formal_list,
                PSYMREC     local_list);
void    pop(PSYMFNCT s);
PSYMFNCT    getTop(const PSYMFNCT s);
PSYMREC find(const char* name);
void    outputStack(const PSYMFNCT s);

#endif  //SEMANTICANALYZER_H
