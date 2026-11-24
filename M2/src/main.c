/* main.c - chama o analisador sintatico (ou so o lexico, com -t) */

#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

extern int yylex(void);
extern char *yytext;
extern FILE *yyin;
extern int linha_token;
extern int erros_lexicos;

static int verboso = 0;

void yyerror(const char *msg) {
    printf("erro sintatico na linha %d\n", linha_token);
    if (verboso)
        printf("  detalhe: %s\n", msg);
}

static const char *nome_token(int t) {
    switch (t) {
        case ID:          return "ID";
        case INT:         return "INT";
        case FLOAT:       return "FLOAT";
        case STRING:      return "STRING";
        case NEWLINE:     return "NEWLINE";
        case INDENT:      return "INDENT";
        case DEDENT:      return "DEDENT";
        case JOGADA:      return "JOGADA";
        case GOL:         return "GOL";
        case VAR:         return "VAR";
        case REVISA:      return "REVISA";
        case SEGUE:       return "SEGUE";
        case ROLA:        return "ROLA";
        case RODADA:      return "RODADA";
        case EM:          return "EM";
        case APITA:       return "APITA";
        case VANTAGEM:    return "VANTAGEM";
        case CERA:        return "CERA";
        case LEGAL:       return "LEGAL";
        case IMPEDIDO:    return "IMPEDIDO";
        case WO:          return "WO";
        case E:           return "E";
        case OU:          return "OU";
        case NAO:         return "NAO";
        case NARRA:       return "NARRA";
        case TORCIDA:     return "TORCIDA";
        case POT:         return "POT";
        case DIV_INT:     return "DIV_INT";
        case IGUAL:       return "IGUAL";
        case DIFERENTE:   return "DIFERENTE";
        case MENOR_IGUAL: return "MENOR_IGUAL";
        case MAIOR_IGUAL: return "MAIOR_IGUAL";
        case MAIS_IGUAL:  return "MAIS_IGUAL";
        case MENOS_IGUAL: return "MENOS_IGUAL";
        case VEZES_IGUAL: return "VEZES_IGUAL";
        case DIV_IGUAL:   return "DIV_IGUAL";
        default:          return NULL;
    }
}

/* modo -t: so imprime os tokens, um por linha */
static void lista_tokens(void) {
    int t;
    while ((t = yylex()) != 0) {
        const char *nome = nome_token(t);
        if (t == ID || t == INT || t == FLOAT || t == STRING)
            printf("<%s, %s>\n", nome, yytext);
        else if (nome)
            printf("<%s>\n", nome);
        else
            printf("<'%c'>\n", t);
    }
}

int main(int argc, char **argv) {
    int i, so_lexico = 0;
    const char *arquivo = NULL;

    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-t") == 0) so_lexico = 1;
        else if (strcmp(argv[i], "-v") == 0) verboso = 1;
        else if (!arquivo && argv[i][0] != '-') arquivo = argv[i];
        else {
            fprintf(stderr, "uso: %s [-t] [-v] [arquivo]\n", argv[0]);
            return 2;
        }
    }

    if (arquivo) {
        yyin = fopen(arquivo, "r");
        if (!yyin) {
            perror(arquivo);
            return 2;
        }
    }

    if (so_lexico) {
        lista_tokens();
        return erros_lexicos ? 1 : 0;
    }

    if (yyparse() != 0)
        return 1;
    if (erros_lexicos > 0) {
        printf("programa com erros lexicos\n");
        return 1;
    }
    printf("programa sintaticamente correto\n");
    return 0;
}
