cc_semantic_analyzer
====================

In this part of the project we will build a more realistic symbol table, and use it for semantic analysis and type checking.
You will just need to continue on the parser fil you have built in the previous part of this project.


1. The code was written under the Ubuntu Linux System (Version 11.10)
2. The Compiler version is GCC 4.6.1
3. I have written a "makefile" document
   So just type "make" command under current directory to compile source code.
   Also, type "make clean" under current directory to remove all files except source files. 
4. The format of running source code is as below:

    ./SemanticAnalyzer <input file name>

   (1) The <input file name> argument is necessary;

5. Some additional information about Semantic Analyzer
   *The Semantic Analyzer program could detect lexeme error, syntax error, and several semantic error.
        For lexeme error, output illegal character and it's location, then terminate program.
        For syntax error, output syntax error message and it's location, then continue to parse program until EOF.
        For semantic error, output semantic error message  and it's location, then continue to parse program until EOF.
            * Multiple Declaration error
            * Undeclaration error
            * Few of many arguments for function of procedure error
            * Type inequivalence warning
   *Moreover, I add the "/" as division operation. Its token name is "DIVIS".
