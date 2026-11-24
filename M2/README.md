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

## Tokens

| Categoria | Tokens |
|---|---|
| Palavras reservadas | `jogada` `gol` `var` `revisa` `segue` `rola` `rodada` `em` `apita` `vantagem` `cera` `legal` `impedido` `WO` `e` `ou` `nao` `narra` `torcida` |
| Identificadores e literais | `ID`, `INT` (`10`), `FLOAT` (`2.5`, `.5`, `1e3`), `STRING` (`"..."` ou `'...'`) |
| Operadores de 2 caracteres | `**` `//` `==` `!=` `<=` `>=` `+=` `-=` `*=` `/=` |
| Operadores e delimitadores de 1 caractere | `+ - * / % < > = ( ) [ ] , : .` |
| Estrutura de blocos | `NEWLINE`, `INDENT`, `DEDENT` |

As palavras reservadas são reconhecidas como `ID` e depois procuradas numa tabela
(busca binária). Pela regra do maior casamento, `golaco` é um `ID` só, `**=` vira `**` e `=`,
e `1.2.3` vira `1.2` e `.3`. Comentários começam com `#` e vão até o fim da linha.

| Haxball | Python | | Haxball | Python |
|---|---|---|---|---|
| `jogada` | `def` | | `apita` | `break` |
| `gol` | `return` | | `vantagem` | `continue` |
| `var` | `if` | | `cera` | `pass` |
| `revisa` | `elif` | | `legal` / `impedido` | `True` / `False` |
| `segue` | `else` | | `WO` | `None` |
| `rola` | `while` | | `e` / `ou` / `nao` | `and` / `or` / `not` |
| `rodada` ... `em` | `for` ... `in` | | `narra` / `torcida` | `print` / `input` |

## Indentação

O lexer guarda uma pilha com as colunas dos blocos abertos (começa com `0`):

- no início de cada linha conta a coluna (tab avança até o próximo múltiplo de 8);
- coluna maior que o topo: empilha e gera `INDENT`;
- coluna menor: desempilha até achar a mesma coluna e gera um `DEDENT` para cada nível;
  se não achar, é erro léxico (`indentacao inconsistente`);
- linhas em branco ou só com comentário são ignoradas;
- dentro de `()` ou `[]` a quebra de linha é ignorada, e `\` no fim da linha junta com a próxima;
- no fim do arquivo gera o `NEWLINE` que faltar e fecha todos os blocos com `DEDENT`.

Com isso o parser vê os blocos como `NEWLINE INDENT comandos DEDENT`, sem ambiguidade de
`var`/`revisa`/`segue` (o famoso *dangling else* não acontece).

## Gramática (resumo)

```
programa        -> comandos | vazio
comando         -> comando_simples NEWLINE | comando_composto
bloco           -> comando_simples NEWLINE | NEWLINE INDENT comandos DEDENT
comando_simples -> expr | expr = expr | expr op= expr | gol [expr] | cera | apita | vantagem
condicional     -> var expr : bloco (revisa expr : bloco)* [segue : bloco]
laco_rola       -> rola expr : bloco
laco_rodada     -> rodada ID em expr : bloco
jogada          -> jogada ID ( [ID (, ID)*] ) : bloco
expr            -> ou > e > nao > comparacao (< > == != <= >= em, nao em)
                   > + - > * / // % > sinal > ** > chamada/indice/ponto > atomo
```

A precedência e a associatividade estão na própria hierarquia de não-terminais, sem `%left`.
O `parser.y` tem `%expect 0`, então qualquer conflito shift/reduce ou reduce/reduce faz
a compilação falhar. Para investigar um conflito: `bison -Wcounterexamples src/parser.y`.

Fora do subconjunto (ficam para versões futuras): dicionários, classes, `lambda`,
strings com três aspas e `segue` em laços.

## Cenários de teste

A lista completa, com o que cada teste verifica, está em [tests/cenarios.md](./tests/cenarios.md).
