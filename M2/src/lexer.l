/* lexer.l - analisador lexico da linguagem Haxball */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

#define MAX_NIVEIS 100

int linha_token = 1;     /* linha do ultimo token, usada nas mensagens de erro */
int erros_lexicos = 0;

static int pilha[MAX_NIVEIS] = {0};  /* niveis de indentacao abertos */
static int topo = 0;
static int dedents_pendentes = 0;
static int nivel_parenteses = 0;     /* dentro de () ou [] o \n e ignorado */
static int linha_vazia = 1;          /* nenhum token na linha atual ainda */
static int inicio_arquivo = 1;

#define YY_USER_ACTION linha_token = yylineno;
#define TOKEN(t) do { linha_vazia = 0; return (t); } while (0)

struct reservada {
    const char *lexema;
    int token;
};

/* tabela de palavras reservadas, em ordem alfabetica (strcmp) por causa do bsearch */
static const struct reservada reservadas[] = {
    { "WO",       WO },
    { "apita",    APITA },
    { "cera",     CERA },
    { "e",        E },
    { "em",       EM },
    { "gol",      GOL },
    { "impedido", IMPEDIDO },
    { "jogada",   JOGADA },
    { "legal",    LEGAL },
    { "nao",      NAO },
    { "narra",    NARRA },
    { "ou",       OU },
    { "revisa",   REVISA },
    { "rodada",   RODADA },
    { "rola",     ROLA },
    { "segue",    SEGUE },
    { "torcida",  TORCIDA },
    { "vantagem", VANTAGEM },
    { "var",      VAR },
};

static int compara_reservada(const void *chave, const void *item) {
    return strcmp((const char *) chave, ((const struct reservada *) item)->lexema);
}

/* todo nome e lido como ID e depois procurado na tabela */
static int busca_reservada(const char *lexema) {
    const struct reservada *r = bsearch(lexema, reservadas,
        sizeof(reservadas) / sizeof(reservadas[0]), sizeof(reservadas[0]),
        compara_reservada);
    return r ? r->token : ID;
}

/* tab avanca ate o proximo multiplo de 8, como no Python */
static int calcula_coluna(const char *s) {
    int col = 0;
    for (; *s; s++) {
        if (*s == '\t') col = (col / 8 + 1) * 8;
        else col++;
    }
    return col;
}

static void erro_lexico(const char *msg, const char *lexema) {
    if (lexema) printf("erro lexico na linha %d: %s '%s'\n", yylineno, msg, lexema);
    else printf("erro lexico na linha %d: %s\n", yylineno, msg);
    erros_lexicos++;
}
%}

%option noyywrap
%option nounput
%option noinput
%option yylineno

%x INICIO

DIGITO  [0-9]
LETRA   [A-Za-z_]
EXP     [eE][+-]?{DIGITO}+

%%
    /* roda a cada chamada de yylex: a primeira linha tambem passa pela
       indentacao, e os DEDENTs que ficaram acumulados saem um por vez */
    if (inicio_arquivo) {
        inicio_arquivo = 0;
        BEGIN(INICIO);
    }
    if (dedents_pendentes > 0) {
        dedents_pendentes--;
        return DEDENT;
    }

    /* ---------- inicio de linha: controle de indentacao ---------- */

<INICIO>[ \t\r]*("#"[^\n]*)?\n  { /* linha em branco ou so com comentario */ }
<INICIO>[ \t\r]*("#"[^\n]*)?    { /* mesma coisa, na ultima linha sem \n */ }

<INICIO>[ \t]*/[^ \t\r\n#]  {
    int col = calcula_coluna(yytext);
    BEGIN(INITIAL);
    if (col > pilha[topo]) {
        if (topo + 1 >= MAX_NIVEIS) {
            erro_lexico("indentacao profunda demais", NULL);
        } else {
            pilha[++topo] = col;
            return INDENT;
        }
    }
    while (col < pilha[topo]) {
        topo--;
        dedents_pendentes++;
    }
    if (col != pilha[topo])
        erro_lexico("indentacao inconsistente", NULL);
    if (dedents_pendentes > 0) {
        dedents_pendentes--;
        return DEDENT;
    }
}

    /* ---------- espacos, comentarios e fim de linha ---------- */

[ \t\r]+        { }
"#"[^\n]*       { }
\\\r?\n         { /* \ no fim da linha junta com a proxima */ }

\n  {
    if (nivel_parenteses == 0) {
        linha_token = yylineno - 1;
        linha_vazia = 1;
        BEGIN(INICIO);
        return NEWLINE;
    }
}

    /* ---------- identificadores e palavras reservadas ---------- */

{LETRA}({LETRA}|{DIGITO})*  { TOKEN(busca_reservada(yytext)); }

    /* ---------- numeros ---------- */

{DIGITO}+"."{DIGITO}*{EXP}?     { TOKEN(FLOAT); }
"."{DIGITO}+{EXP}?              { TOKEN(FLOAT); }
{DIGITO}+{EXP}                  { TOKEN(FLOAT); }
{DIGITO}+                       { TOKEN(INT); }

    /* ---------- strings ---------- */

\"([^"\\\n]|\\.)*\"     { TOKEN(STRING); }
'([^'\\\n]|\\.)*'       { TOKEN(STRING); }
    /* string sem fechar: o \n seguinte encerra a linha mesmo dentro de () */
\"([^"\\\n]|\\.)*       { erro_lexico("string nao fechada", NULL); nivel_parenteses = 0; }
'([^'\\\n]|\\.)*        { erro_lexico("string nao fechada", NULL); nivel_parenteses = 0; }

    /* ---------- operadores e delimitadores ---------- */

    /* TODO: Membro 3 - operadores com mais de um caractere:
       ** // == != <= >= += -= *= /=  (os tokens ja estao no parser.y) */

"("|"["         { nivel_parenteses++; TOKEN(yytext[0]); }
")"|"]"         { if (nivel_parenteses > 0) nivel_parenteses--; TOKEN(yytext[0]); }
[-+*/%<>=,:.]   { TOKEN(yytext[0]); }

.       { erro_lexico("caractere invalido", yytext); }

    /* ---------- fim do arquivo ---------- */

<INITIAL,INICIO><<EOF>> {
    if (!linha_vazia) {
        linha_vazia = 1;
        return NEWLINE;
    }
    if (topo > 0) {
        topo--;
        return DEDENT;
    }
    yyterminate();
}

%%
