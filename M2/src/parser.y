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
    /* TODO: Membro 2 - comandos apita (break) e vantagem (continue) */
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
    /* TODO: Membro 2 - incluir os lacos rola e rodada aqui */
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

/* TODO: Membro 2 - regras dos lacos:
     laco_rola   -> rola (while)
     laco_rodada -> rodada ... em (for ... in) */

/* jogada (def) */
definicao_jogada
    : JOGADA ID '(' parametros ')' ':' bloco
    ;

/* ---------- parametros da jogada ---------- */

/* TODO: Membro 3 - aceitar lista de parametros separados por virgula */
parametros
    : %empty
    ;

/* ---------- expressoes ---------- */

/* TODO: Membro 3 - hierarquia completa de expressoes, da menor para a maior
   precedencia: ou, e, nao, comparacoes (< > == != <= >= em, nao em),
   + -, * / // %, sinal (+x, -x), ** e primario (chamada f(x), indice a[i],
   acesso a.b), alem de listas [..], narra(...) e torcida(...) com varios
   argumentos. O trecho abaixo e so um esqueleto provisorio. */
expr
    : expr '+' atomo
    | atomo
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
    | NARRA '(' expr ')'
    ;

%%
