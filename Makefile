CC = gcc
CFLAGS = -Wall -Wextra -Werror

# Target executable
TARGET = myhtml

all: clean myhtml

myhtml: parser.tab.c lexer.c
	$(CC) -o $(TARGET) main.c parser.tab.c lexer.c -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lexer.c: lexer.l
	flex -o lexer.c lexer.l

clean:
	rm -f myhtml lexer.c parser.tab.c parser.tab.h
