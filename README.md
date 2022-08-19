# Translator from C into Lisp language

Project for Language Processors course at Universidad Carlos 3 de Madrid in May of 2022. Programmed in Yacc.

This final project for the course was about creating a program that could receive as an input code written in C and return as an output the equivalent code written in Lisp. This project put to test our abilitites to create a parser that could correctly read and translate C code. To be able to do this we had to create the appropriate LALR (1) grammar so it could be read correctly and then control the output through the Semantic section, that looks like this:

```
{ sprintf(temp,"%s%s",$1,$2); $$=genera_cadena(temp);}
```
