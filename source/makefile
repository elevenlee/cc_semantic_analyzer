# makefile
#
# use make command under current directory

# Variable Definition
BIN = SemanticAnalyzer
CC = gcc
CFLAGS = -Wall -O -g
SRCS = $(BIN).y $(BIN).l
OBJS = DieWithMessage.o Type.o Symbol.o Stack.o lex.yy.o $(BIN).tab.o 
LIBS = -lfl -lm

# Compile .c file to .exe file
$(BIN) : $(OBJS)
	$(CC) $(CFLAGS) $(BIN).tab.c DieWithMessage.c Type.c Symbol.c Stack.c $(LIBS) -o $(BIN)

# Compile .y file to .c file
$(BIN).tab.h $(BIN).tab.c : $(BIN).y
	bison -v -t -d $(BIN).y

# Compile .l file to .c file
lex.yy.c : $(BIN).l $(BIN).tab.h
	flex $(BIN).l # -d debug

# make all command
all:
	touch $(SRCS)
	make

# make clean command to delete all except source files
clean:
	rm -rf $(OBJS) $(BIN) lex.yy.c $(BIN).tab.h $(BIN).tab.c $(BIN).tar

# make tar command to compress all files
tar:
	tar -cvf $(BIN).tar $(SRCS) makefile

