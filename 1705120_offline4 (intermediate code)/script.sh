#!/bin/bash

yacc -d -y -v 1705120.y
#yacc -d -y 1705120.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
echo 'Generated the parser object file'
flex 1705120.l
echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ -o a.out y.o l.o -lfl
#g++ y.o l.o -lfl
echo 'All ready, running'
./a.out $1
