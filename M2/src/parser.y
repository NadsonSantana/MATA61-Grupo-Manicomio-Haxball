/* parser.y - analisador sintatico da linguagem Haxball (sem acoes semanticas) */

%{
#include <stdio.h>

int yylex(void);
void yyerror(const char *msg);
%}

%define parse.error verbose
%expect 0

%token ID INT FLOAT STRING
%token NEWLINE INDENT DEDENT

/* palavras reservadas */
%token JOGADA GOL VAR REVISA SEGUE ROLA RODADA EM APITA VANTAGEM CERA
%token LEGAL IMPEDIDO WO E OU NAO NARRA TORCIDA

/* operadores com mais de um caractere (os de um caractere vem como 'x') */
%token POT DIV_INT IGUAL DIFERENTE MENOR_IGUAL MAIOR_IGUAL
%token MAIS_IGUAL MENOS_IGUAL VEZES_IGUAL DIV_IGUAL

%start programa

%%

/* ---------- programa e blocos ---------- */

programa
    : %empty
    | comandos
    ;

comandos
    : comando
    | comandos comando
    ;

comando
    : comando_simples NEWLINE
    | comando_composto
    ;

bloco
    : comando_simples NEWLINE
    | NEWLINE INDENT comandos DEDENT
    ;

/* ---------- comandos simples ---------- */

comando_simples
    : expr_stmt
    | GOL
    | GOL expr
    | CERA
    | APITA
    | VANTAGEM
    ;

expr_stmt
    : expr
    | expr '=' expr
    | expr op_atribuicao expr
    ;

op_atribuicao
    : MAIS_IGUAL
    | MENOS_IGUAL
    | VEZES_IGUAL
    | DIV_IGUAL
    ;

/* ---------- comandos compostos ---------- */

comando_composto
    : condicional
    | definicao_jogada
    | laco_rola
    | laco_rodada
    ;

/* var / revisa / segue  (if / elif / else) */
condicional
    : VAR expr ':' bloco lista_revisa senao
    ;

lista_revisa
    : %empty
    | lista_revisa REVISA expr ':' bloco
    ;

senao
    : %empty
    | SEGUE ':' bloco
    ;

/* rola (while) */
laco_rola
    : ROLA expr ':' bloco
    ;

/* rodada ... em (for ... in) */
laco_rodada
    : RODADA ID EM expr ':' bloco
    ;

/* jogada (def) */
definicao_jogada
    : JOGADA ID '(' parametros ')' ':' bloco
    ;

/* ---------- parametros da jogada ---------- */

parametros
    : %empty
    | lista_parametros
    ;

lista_parametros
    : ID
    | lista_parametros ',' ID
    ;

/* ---------- expressoes ---------- */

expr
    : expr OU expr_e
    | expr_e
    ;

expr_e
    : expr_e E expr_nao
    | expr_nao
    ;

expr_nao
    : NAO expr_nao
    | comparacao
    ;

comparacao
    : comparacao op_comparacao soma
    | soma
    ;

op_comparacao
    : '<'
    | '>'
    | IGUAL
    | DIFERENTE
    | MENOR_IGUAL
    | MAIOR_IGUAL
    | EM
    | NAO EM
    ;

soma
    : soma '+' termo
    | soma '-' termo
    | termo
    ;

termo
    : termo '*' fator
    | termo '/' fator
    | termo DIV_INT fator
    | termo '%' fator
    | fator
    ;

fator
    : '+' fator
    | '-' fator
    | potencia
    ;

potencia
    : primario
    | primario POT fator
    ;

primario
    : atomo
    | primario '(' argumentos ')'
    | primario '[' expr ']'
    | primario '.' ID
    ;

atomo
    : ID
    | INT
    | FLOAT
    | STRING
    | LEGAL
    | IMPEDIDO
    | WO
    | '(' expr ')'
    | '[' argumentos ']'
    | NARRA '(' argumentos ')'
    | TORCIDA '(' argumentos ')'
    ;

argumentos
    : %empty
    | lista_expr
    ;

lista_expr
    : expr
    | lista_expr ',' expr
    ;

%%
