yacc -d 2005083.y
flex 2005083.l
g++ lex.yy.c y.tab.c -std=c++11
