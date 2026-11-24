# M2 - Análise Léxica e Sintática (sem ações semânticas)

Equipe: Manicômio

Membros:
- Jaedson Barbosa Macedo, Jaedsonn
- Igor Reis Santos, igor377
- Nadson de Santana Sousa, NadsonSantana
- Beatriz Santos Oliveira, Bizo-0910

## Arquivos

- `Makefile`: alvos `compile`, `run`, `test` e `clean`.
- `src/lexer.l`: especificação Flex do analisador léxico. Gera os tokens, consulta a tabela de
  palavras reservadas e controla a indentação (`INDENT`, `DEDENT` e `NEWLINE`).
- `src/parser.y`: gramática Bison da linguagem, **sem ações semânticas**.
- `src/main.c`: chama `yyparse()` (ou só o `yylex()`, com `-t`) e define o `yyerror()`.
- `tests/`: testes de entrada/saída. Cada `.in` tem um oráculo `.ora` com a saída esperada.
  - `lexico/`: rodam com `-t` e comparam a lista de tokens.
  - `validos/`: programas corretos, a saída esperada é `programa sintaticamente correto`.
  - `invalidos/`: programas com erro léxico ou sintático.

## Como compilar

Requer `flex`, `bison` e `gcc`. Dentro de `M2`:

```bash
make compile
```

O Bison gera `build/parser.tab.c` e `build/parser.tab.h`, o Flex gera `build/lex.yy.c`, e tudo é
compilado junto com `src/main.c` no executável `haxball`.

## Como executar

```bash
./haxball programa.hax        # ou: ./haxball < programa.hax
```

Saídas possíveis:

```
programa sintaticamente correto
erro sintatico na linha N
erro lexico na linha N: caractere invalido '$'
```

Opções:
- `-t`: só roda o analisador léxico e imprime um token por linha (ex.: `<VAR>`, `<ID, golaco>`).
- `-v`: junto com o erro sintático, mostra a mensagem detalhada do Bison.

## Como testar

Dentro de `M2`:

```bash
make test
```

Ou como o CI faz, a partir da raiz do repositório:

```bash
bash scripts/run_tests.sh M2
```

<!-- TODO: Membro 4 - documentar a tabela de tokens, o resumo da gramatica,
     o tratamento da indentacao e a lista de cenarios de teste -->
