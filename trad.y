// Grupo: 2    Nicolas Arnedo Villanueva      Carlos Mozo Nieto
//             100386663@alumnos.uc3m.es    100405968@alumnos.uc3m.es
%{                          // SECCION 1 Declaraciones de C-Yacc

#include <stdio.h>
#include <ctype.h>            // declaraciones para tolower
#include <string.h>           // declaraciones para cadenas
#include <stdlib.h>           // declaraciones para exit ()

#define FF fflush(stdout);    // para forzar la impresion inmediata

char *mi_malloc (int) ;
char *genera_cadena (char *) ;
int yylex () ;
int yyerror () ;

char temp [2048] ;
char *nombreFuncion ;

char *int_to_string (int n)
{
    sprintf (temp, "%d", n) ;
    return genera_cadena (temp) ;
}

char *char_to_string (char c)
{
    sprintf (temp, "%c", c) ;
    return genera_cadena (temp) ;
}


%}

%union {                      // El tipo de la pila tiene caracter dual
    int valor ;             // - valor numerico de un NUMERO
    char *cadena ;          // - para pasar los nombres de IDENTIFES
}

%token <valor> NUMERO         // Todos los token tienen un tipo para la pila
%token <cadena> IDENTIF       // Identificador=variable
%token <cadena> INTEGER       // identifica la definicion de un entero
%token <cadena> PUTS
%token <cadena> STRING
%token <cadena> PRINTF
%token <cadena> MAIN          // identifica el comienzo del proc. main
%token <cadena> WHILE         // identifica el bucle main
%token <cadena> IF
%token <cadena> ELSE
%token <cadena> FOR
%token <cadena> RETURN

%type   <cadena>  axioma  imprimir imprimir2 expresion expresion_prec termino operando Globales Main VariablesG VariablesL cuerpo  cuerpo2 literal expresionLC expresionLC_prec expresionLC_prec2 expresionLC_prec4 expresionLC_prec5 termino2 operando2 While If For init sentencia vector asignarVector /*ternario*/ funciones declFunciones secuenciaParametros parametros llamadaFuncion parametrosLlamada secuenciaParametrosLlamada retorno secuenciaR secuenciaR2

%right '='                    // es la ultima operacion que se debe realizar
%left '+' '-'                 // menor orden de precedencia
%left '*' '/'                 // orden de precedencia intermedio
%left SIGNO_UNARIO            // mayor orden de precedencia

%%
                             // SECCION 3: Gramatica - Semantico

axioma: 	Globales funciones Main {printf("%s%s%s",$1,$2,$3);}
;

Globales: 	VariablesG  Globales 			{ sprintf(temp,"%s%s",$1,$2); $$=genera_cadena(temp);}
            |   /* lambda */ 				{$$="";}
   ;

VariablesG: 	INTEGER IDENTIF ';' 			{ sprintf (temp, "( setq %s  0 )\n", $2) ; $$=genera_cadena(temp);}
      	   |   	INTEGER sentencia ';' 			{ $$=$2; }
      	   |   	INTEGER IDENTIF '[' termino ']' ';' 	{ sprintf (temp, "( setq %s (make-array %s))\n", $2, $4) ;$$=genera_cadena(temp); }
	   |	INTEGER IDENTIF 			{nombreFuncion=genera_cadena($2);} 			'(' parametros ')'  '{' cuerpo '}' 	{sprintf(temp,"(defun %s (%s)\n%s)\n",$2,$5,$8);$$=genera_cadena(temp);}
   ;

VariablesL: 	INTEGER IDENTIF ';' 			{ sprintf (temp, "( setq %s  0 )\n", $2) ; $$=genera_cadena(temp);}
      	   |   	INTEGER sentencia ';' 			{ $$=$2; }
      	   |   	sentencia ';' 				{ $$=$1; }
 /*     	   |   	ternario ';' 				{ $$=$1; }*/
      	   |   	INTEGER IDENTIF '[' termino ']' ';' 	{ sprintf (temp, "( setq %s (make-array %s))\n", $2, $4) ;$$=genera_cadena(temp); }

   ;
 
/*ternario: 	IDENTIF '=' '(' expresionLC ')' '?' expresion ':' expresion
{sprintf(temp,"(if %s\n setq( %s %s)\n setq( %s %s)\n)",$4,$1,$7,$1,$9); $$=genera_cadena(temp);};*/


//FUNCIONES

funciones:      declFunciones funciones			{sprintf(temp,"%s%s",$1,$2); $$=genera_cadena(temp);}
            |   /*lambda*/ 				{$$="";}
            ;

declFunciones:  IDENTIF 				{nombreFuncion=genera_cadena($1);} 			'(' parametros ')'  '{' cuerpo '}' 	{sprintf(temp,"(defun %s (%s)\n%s)\n",$1,$4,$7);$$=genera_cadena(temp);}
	    /*|	INTEGER IDENTIF 			{nombreFuncion=genera_cadena($2);} 			'(' parametros ')'  '{' cuerpo '}' 	{sprintf(temp,"(defun %s (%s)\n%s)\n",$2,$5,$8);$$=genera_cadena(temp);}*/

;

parametros:     INTEGER IDENTIF secuenciaParametros 	{sprintf(temp,"%s%s",$2,$3); $$=genera_cadena(temp);}
            |    /*lambda*/				{$$="";}
            ;

secuenciaParametros:   	/*lambda*/			{$$="";}  
	    |   	',' parametros 			{sprintf(temp," %s",$2); $$=genera_cadena(temp);}
	    ;

llamadaFuncion:     IDENTIF '(' parametrosLlamada ')' 	{sprintf(temp,"(%s%s)",$1,$3); $$=genera_cadena(temp);}
;

parametrosLlamada:  expresion secuenciaParametrosLlamada {sprintf(temp," %s%s",$1,$2); $$=genera_cadena(temp);}
                    |  /* lambda */ 			 {$$="";}
                    ;

secuenciaParametrosLlamada:  /* lambda */		 {$$="";}  
		    |   ',' parametrosLlamada 		 {sprintf(temp,"%s",$2); $$=genera_cadena(temp);}
;

Main: 		MAIN '(' ')' '{' cuerpo2 '}' 		{ sprintf(temp,"( defun main ()\n%s) \n(main);",$5); $$=genera_cadena(temp);}
   ;

cuerpo2: 	cuerpo 					{$$=$1;}
      	   |   /* lambda */ 				{$$="";}
   ;

cuerpo:     	VariablesL cuerpo2 			{sprintf(temp,"%s%s",$1,$2); $$=genera_cadena(temp);}

      	   | 	PRINTF '(' imprimir ')' ';' cuerpo2   	{sprintf(temp,"%s\n%s",$3,$6); $$=genera_cadena(temp);}

      	   | 	literal ';' cuerpo2   			{sprintf(temp,"%s\n%s",$1,$3); $$=genera_cadena(temp);}

      	   |   	While cuerpo2 				{sprintf(temp,"%s%s",$1,$2); $$=genera_cadena(temp);}

      	   |   	If cuerpo2 			{sprintf(temp,"%s%s",$1,$2); $$=genera_cadena(temp);}

      	   |   	For cuerpo2 			{sprintf(temp,"%s%s",$1,$2); $$=genera_cadena(temp);}

      	   |   	asignarVector ';'cuerpo2 	{sprintf(temp,"%s%s",$1,$3); $$=genera_cadena(temp);}

      	   |   llamadaFuncion ';' cuerpo2 	{sprintf(temp,"%s\n%s",$1,$3); $$=genera_cadena(temp);}

	   |   retorno ';' cuerpo2 		{sprintf(temp,"%s%s",$1,$3); $$=genera_cadena(temp);}

/*	   |  	IDENTIF '=' '(' expresionLC ')' '?' expresion ':' expresion ';' cuerpo2
{sprintf(temp,"(if %s\n setq( %s %s)\n setq( %s %s)\n)",$4,$1,$7,$1,$9,$11); $$=genera_cadena(temp);}
*/
/*
	   |   ternario ';' cuerpo2 		{sprintf(temp,"%s%s",$1,$3); $$=genera_cadena(temp);}*/
   ;

retorno:    RETURN expresion 			{sprintf(temp,"(return-from %s %s)\n",nombreFuncion,$2); $$=genera_cadena(temp);}
        |   RETURN expresion ',' secuenciaR 	{sprintf(temp,"(return-from %s (values %s %s))\n",nombreFuncion,$2,$4); $$=genera_cadena(temp);}
        ;

secuenciaR:     expresion secuenciaR2 {sprintf(temp,"%s%s",$1,$2); $$=genera_cadena(temp);}
;

secuenciaR2:    ',' secuenciaR 					{sprintf(temp," %s",$2); $$=genera_cadena(temp);} 
		| /* lambda */ 					{$$="";}
;


While:     	WHILE '(' expresionLC ')' '{' cuerpo '}' 	{sprintf(temp,"(loop while %s do\n%s)\n",$3,$6); $$=genera_cadena(temp);}
   ;

If:		IF '(' expresionLC ')' '{' cuerpo '}' 		{sprintf(temp,"(if %s\n%s)\n",$3,$6); $$=genera_cadena(temp);}

            |   IF '(' expresionLC ')' '{' cuerpo '}' ELSE '{' cuerpo '}'
{sprintf(temp,"(if %s\n%s%s)\n",$3,$6,$10); $$=genera_cadena(temp);}
   ;

For:   		FOR '(' init ';' expresionLC ';' sentencia ')' '{' cuerpo '}'
  {sprintf(temp,"%s(loop while %s do\n%s%s)\n",$3,$5,$10,$7); $$=genera_cadena(temp);}
   ;

init:     	INTEGER sentencia 		{$$=$2;}
      	   |   	sentencia 			{$$=$1;}
        ;

sentencia:   	IDENTIF '=' expresion 		{sprintf(temp,"(setq %s %s)\n",$1,$3); $$=genera_cadena(temp);}
;

literal:   	PUTS '(' STRING ')' 		{sprintf(temp,"(print \"%s\")",$3); $$=genera_cadena(temp);}
    ;

imprimir2: 	imprimir 			{$$=$1;}
      	   |   	/* lambda */ 			{$$="";}
    ;

imprimir: 	expresion ','  imprimir2        { sprintf(temp, "( print %s ) %s ", $1, $3);$$ = genera_cadena (temp) ; }
      	   | 	STRING ',' imprimir2           	{ sprintf(temp, " %s ", $3);$$ = genera_cadena (temp) ; }
      	   | 	expresion         		{ sprintf(temp, "( print %s )", $1);$$ = genera_cadena (temp) ; }
      	   | 	STRING           		{ sprintf(temp, "", $1);$$ = genera_cadena (temp) ; }       
     ;

vector: 	IDENTIF '[' expresion ']' {sprintf(temp, "(aref %s %s)",$1,$3); $$=genera_cadena(temp);}
     ;

asignarVector: 	IDENTIF '[' expresion ']' '=' expresion {sprintf(temp,"(setf (aref %s %s) %s)\n",$1,$3,$6); $$=genera_cadena(temp);};
;

expresion:          expresion_prec
                |   expresion_prec '+' expresion   		{ sprintf(temp, "(+ %s %s)", $1, $3); 
                                                    $$ = genera_cadena(temp); }
                |   expresion_prec '-' expresion 		{ sprintf(temp, "(- %s %s)", $1, $3); 
                                                    $$ = genera_cadena(temp); }
                ;

expresion_prec:         termino			    { ; }
                    |   termino '*' expresion_prec  { sprintf(temp, "(* %s %s)", $1, $3); 
                                                    $$ = genera_cadena(temp); }
                    |   termino '/' expresion_prec  { sprintf(temp, "(/ %s %s)", $1, $3); 
                                                    $$ = genera_cadena(temp); }
                    |   termino '%' expresion_prec  { sprintf(temp, "(mod %s %s)", $1, $3); 
                                                    $$ = genera_cadena(temp); }
;

expresionLC:  	expresionLC_prec
      	   |   	expresionLC_prec '|' '|' expresionLC  { sprintf(temp, "(or %s %s)", $1, $4);
                                                    $$ = genera_cadena(temp); }
       ;  

expresionLC_prec:   expresionLC_prec2
      	   |   expresionLC_prec2 '&' '&' expresionLC_prec    { sprintf(temp, "(and %s %s)", $1, $4);
                                                   $$ = genera_cadena(temp); }
      ;

expresionLC_prec2:  expresionLC_prec4

                |   expresionLC_prec4 '=' '=' expresionLC_prec4    { sprintf(temp, "(= %s %s)", $1, $4);
                                                    $$ = genera_cadena(temp); }
                |   expresionLC_prec4 '!' '=' expresionLC_prec4   { sprintf(temp, "(/= %s %s)", $1, $4);
                                                    $$ = genera_cadena(temp); }
                |   expresionLC_prec4 '<' expresionLC_prec4    { sprintf(temp, "(< %s %s)", $1, $3);
                                                    $$ = genera_cadena(temp); }
                |   expresionLC_prec4 '<' '=' expresionLC_prec4   { sprintf(temp, "(<= %s %s)", $1, $4);
                                                    $$ = genera_cadena(temp); }
                |   expresionLC_prec4 '>' expresionLC_prec4    { sprintf(temp, "(> %s %s)", $1, $3);
                                                    $$ = genera_cadena(temp); }
                |   expresionLC_prec4 '>' '=' expresionLC_prec4   { sprintf(temp, "(>= %s %s)", $1, $4);
                                                    $$ = genera_cadena(temp); }  
      ;

expresionLC_prec4:  expresionLC_prec5
                |   expresionLC_prec5 '+' expresionLC_prec4   { sprintf(temp, "(+ %s %s)", $1, $3);
                                                    $$ = genera_cadena(temp); }
                |   expresionLC_prec5 '-' expresionLC_prec4 { sprintf(temp, "(- %s %s)", $1, $3);
                                                    $$ = genera_cadena(temp); }
       ;

expresionLC_prec5:      termino2
                    |   termino2 '*' expresionLC_prec5 { sprintf(temp, "(* %s %s)", $1, $3);
                                                    $$ = genera_cadena(temp); }
                    |   termino2 '/' expresionLC_prec5  { sprintf(temp, "(/ %s %s)", $1, $3);
                                                    $$ = genera_cadena(temp); }
                    |   termino2 '%' expresionLC_prec5  { sprintf(temp, "(mod %s %s)", $1, $3);
                                                    $$ = genera_cadena(temp); }
        ;

termino2:        operando2 				{ sprintf(temp,"%s",$1);
                                        $$ = genera_cadena(temp); }                        
            |   '+' operando2 %prec SIGNO_UNARIO 	{ sprintf(temp,"+%s",$2);
                                                    $$ = genera_cadena(temp); }
            |   '-' operando2 %prec SIGNO_UNARIO 	{ sprintf(temp,"-%s",$2);
                                                    $$ = genera_cadena(temp); }                                      
         ;

operando2:      IDENTIF 				{ sprintf(temp,"%s",$1);$$ = genera_cadena(temp); }
            |   NUMERO 				{ $$ = int_to_string($1); }
            |   vector
            |   llamadaFuncion
            |   '(' expresionLC ')' 	{ sprintf(temp,"%s",$2);$$ = genera_cadena(temp);}
            ;
termino:        operando { $$ = $1; }                          
            |   '+' operando %prec SIGNO_UNARIO { sprintf (temp, " + %s", $2) ;  
$$ = genera_cadena (temp) ; }
            |   '-' operando %prec SIGNO_UNARIO { sprintf (temp, " - %s ", $2) ;  
$$ = genera_cadena (temp) ; }
                                                 
            ;

operando:       IDENTIF 		{ $$ = genera_cadena($1) ;}
            |   NUMERO 			{ $$ = int_to_string ($1) ; }
	    |   vector   		{$$=genera_cadena($1) ;}
	    |   llamadaFuncion  	{$$=genera_cadena($1);}
            |   '(' expresion ')' 	{$$=genera_cadena($2) ;}
            ;

%%

                            // SECCION 4    Codigo en C
int n_linea = 1 ;

int yyerror (mensaje)
char *mensaje ;
{
    fprintf (stderr, "%s en la linea %d\n", mensaje, n_linea) ;
    printf ( "\n") ; // bye
}

char *mi_malloc (int nbytes)       // reserva n bytes de memoria dinamica
{
    char *p ;
    static long int nb = 0;        // sirven para contabilizar la memoria
    static int nv = 0 ;            // solicitada en total

    p = malloc (nbytes) ;
    if (p == NULL) {
        fprintf (stderr, "No queda memoria para %d bytes mas\n", nbytes) ;
        fprintf (stderr, "Reservados %ld bytes en %d llamadas\n", nb, nv) ;
        exit (0) ;
    }
    nb += (long) nbytes ;
    nv++ ;

    return p ;
}


/***************************************************************************/
/********************** Seccion de Palabras Reservadas *********************/
/***************************************************************************/

typedef struct s_pal_reservadas { // para las palabras reservadas de C
    char *nombre ;
    int token ;
} t_reservada ;

t_reservada pal_reservadas [] = { // define las palabras reservadas y los
    "main",        MAIN,           // y los token asociados
    "int",         INTEGER,
    "puts",        PUTS,
    "printf",      PRINTF,
    "while",       WHILE,
    "if",   	   IF,
    "else",        ELSE,
    "for",         FOR,
    "return",      RETURN,
    NULL,          0               // para marcar el fin de la tabla
} ;

t_reservada *busca_pal_reservada (char *nombre_simbolo)
{                                  // Busca n_s en la tabla de pal. res.
                                   // y devuelve puntero a registro (simbolo)
    int i ;
    t_reservada *sim ;

    i = 0 ;
    sim = pal_reservadas ;
    while (sim [i].nombre != NULL) {
   if (strcmp (sim [i].nombre, nombre_simbolo) == 0) {
                            // strcmp(a, b) devuelve == 0 si a==b
            return &(sim [i]) ;
        }
        i++ ;
    }

    return NULL ;
}

 
/***************************************************************************/
/******************* Seccion del Analizador Lexicografico ******************/
/***************************************************************************/

char *genera_cadena (char *nombre)     // copia el argumento a un
{                                      // string en memoria dinamica
    char *p ;
    int l ;

    l = strlen (nombre)+1 ;
    p = (char *) mi_malloc (l) ;
    strcpy (p, nombre) ;

    return p ;
}


int yylex ()
{
    int i ;
    unsigned char c ;
    unsigned char cc ;
    char ops_expandibles [] = "!<=>|&%+-/*" ;
    char cadena [256] ;
    t_reservada *simbolo ;

    do {
        c = getchar () ;

        if (c == '#') { // Ignora las lineas que empiezan por #  (#define, #include)
            do { // OJO que puede funcionar mal si una linea contiene #
                c = getchar () ;
            } while (c != '\n') ;
        }

        if (c == '/') { // Si la linea contiene un / puede ser inicio de comentario
            cc = getchar () ;
            if (cc != '/') {   // Si el siguiente char es /  es un comentario, pero...
                ungetc (cc, stdin) ;
            } else {
                c = getchar () ; // ...
                if (c == '@') { // Si es la secuencia //@  ==> transcribimos la linea
                    do { // Se trata de codigo inline (Codigo embebido en C)
                        c = getchar () ;
                        putchar (c) ;
                    } while (c != '\n') ;
                } else { // ==> comentario, ignorar la linea
                    while (c != '\n') {
                        c = getchar () ;
                    }
                }
            }
        } else if (c == '\\') c = getchar () ;

        if (c == '\n')
            n_linea++ ;

    } while (c == ' ' || c == '\n' || c == 10 || c == 13 || c == '\t') ;

    if (c == '\"') {
        i = 0 ;
        do {
            c = getchar () ;
            cadena [i++] = c ;
        } while (c != '\"' && i < 255) ;
        if (i == 256) {
            printf ("AVISO: string con mas de 255 caracteres en linea %d\n", n_linea) ;
        } // habria que leer hasta el siguiente " , pero, y si falta?
        cadena [--i] = '\0' ;
        yylval.cadena = genera_cadena (cadena) ;
        return (STRING) ;
    }

    if (c == '.' || (c >= '0' && c <= '9')) {
        ungetc (c, stdin) ;
        scanf ("%d", &yylval.valor) ;
//         printf ("\nDEV: NUMERO %d\n", yylval.valor) ;        // PARA DEPURAR
        return NUMERO ;
    }

    if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) {
        i = 0 ;
        while (((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
            (c >= '0' && c <= '9') || c == '_') && i < 255) {
            cadena [i++] = tolower (c) ;
            c = getchar () ;
        }
        cadena [i] = '\0' ;
        ungetc (c, stdin) ;

        yylval.cadena = genera_cadena (cadena) ;
        simbolo = busca_pal_reservada (yylval.cadena) ;
        if (simbolo == NULL) {    // no es palabra reservada -> identificador
//               printf ("\nDEV: IDENTIF %s\n", yylval.cadena) ;    // PARA DEPURAR
            return (IDENTIF) ;
        } else {
//               printf ("\nDEV: OTRO %s\n", yylval.cadena) ;       // PARA DEPURAR
            return (simbolo->token) ;
        }
    }

    if (strchr (ops_expandibles, c) != NULL) { // busca c en ops_expandibles
        cc = getchar () ;
        sprintf (cadena, "%c%c", (char) c, (char) cc) ;
        simbolo = busca_pal_reservada (cadena) ;
        if (simbolo == NULL) {
            ungetc (cc, stdin) ;
            yylval.cadena = NULL ;
            return (c) ;
        } else {
            yylval.cadena = genera_cadena (cadena) ; // aunque no se use
            return (simbolo->token) ;
        }
    }

//    printf ("\nDEV: LITERAL %d #%c#\n", (int) c, c) ;      // PARA DEPURAR
    if (c == EOF || c == 255 || c == 26) {
//         printf ("tEOF ") ;                                // PARA DEPURAR
        return (0) ;
    }

    return c ;
}


int main ()
{
    yyparse () ;
}
