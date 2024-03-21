# mini-compiler

A OOP compiler for a mini language. Designed by Lucas Beluomini the compiler is written in C and uses the Flex and Bison tools to generate the lexical and syntax analyzers. The compiler is able to generate the assembly code for the mini language.

This project was design to a subject at UEM by Lucas Beluomini RA 120111


## ▶️ How to use 

To use the compiler you need to have the Flex and Bison tools installed in your machine. After that, you can use the following commands to compile the compiler:

```bash
flex -i -o lex.yy.c scanner.l

bison -d -v -o parser.tab.c parser.y

gcc -o compiler lex.yy.c parser.tab.c -lfl
```

You can use the makefile to compile the compiler. The makefile will use the archive teste.mini to try the compilation. After that, you can use the following command to compile a mini language code:

```bash
make
```

## ✅ To-Do List 

(X) Lexical Analysis

(X) Syntax Analysis

(-) Semantic Analysis

( ) Intermediate Code Generation

( ) Optimization

( ) Code Generation

## 📖 Bibliography 

- [Bison](https://iq.opengenus.org/yacc-and-bison/#gsc.tab=0)
- [Basic of Bison](https://www.gnu.org/software/bison/manual/html_node/Actions.html)
- [Example 1](https://medium.com/codex/building-a-c-compiler-using-lex-and-yacc-446262056aaa)
- [Example 2](https://medium.com/@mirasma/creating-a-mini-c-compiler-using-lex-and-yacc-part-1-963b0860f5b1)
- [Example 3](https://eqdrs.github.io/compilers/2019/09/08/implementando-um-analisador-lexico-usando-o-flex.html)
