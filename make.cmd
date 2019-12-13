cls
bison -d project.y
flex project.l
g++ lex.yy.c project.tab.c -o app
app
type output.txt