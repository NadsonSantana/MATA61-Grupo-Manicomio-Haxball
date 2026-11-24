# Cenários de teste - M2

Cada `.in` tem um `.ora` com a saída esperada. Os testes de `lexico/` rodam com `./haxball -t`.

## Léxico (`tests/lexico`)

| Teste | O que verifica |
|---|---|
| `palavras_reservadas` | as 19 palavras reservadas e nomes parecidos que são `ID` (`golaco`, `Var`, `wo`, `gol2`) |
| `indentacao` | `INDENT`/`DEDENT` aninhados, dois `DEDENT` seguidos, linha em branco e comentário dentro do bloco, tab |
| `literais_comentarios` | `INT`, `FLOAT` (`2.5`, `.5`, `1e3`), strings com aspas simples/duplas e escape, comentários |
| `caractere_invalido` | erro léxico para `$` e `@`, e a análise continua |
| `operadores` | todos os operadores de dois caracteres |
| `maior_casamento` | maximal munch: `golaco`, `emnao`, `**=`, `====`, `<<=`, `1.2.3` |
| `string_nao_fechada` | erro léxico de string sem fechar e recuperação na linha seguinte |

## Programas válidos (`tests/validos`)

Saída esperada: `programa sintaticamente correto`.

| Teste | O que verifica |
|---|---|
| `condicional` | `var` / `revisa` / `segue` com bloco aninhado |
| `jogada_simples` | `jogada` sem parâmetros, `gol` com e sem valor, `cera` |
| `bloco_uma_linha` | blocos na mesma linha do `:` |
| `so_comentarios` | arquivo só com comentários e linhas em branco |
| `laco_rola` | `rola` com `apita` e `vantagem` |
| `laco_rodada` | `rodada ... em`, inclusive aninhado |
| `controle_fluxo` | laço dentro de jogada com `apita`, `vantagem` e `cera` |
| `expressoes_aritmeticas` | precedência de `+ - * / // % **`, sinal e atribuições compostas |
| `expressoes_logicas` | `e`, `ou`, `nao`, comparações encadeadas, `em` e `nao em` |
| `jogadas_e_chamadas` | parâmetros, chamadas, índice, acesso com ponto, listas, `narra` e `torcida` |
| `programa_completo` | fatorial recursivo usando quase tudo da linguagem |
| `tabs_e_quebra_de_linha` | indentação com tab, lista em várias linhas e `\` no fim da linha |

## Programas inválidos (`tests/invalidos`)

| Teste | Erro esperado |
|---|---|
| `falta_dois_pontos` | `var` sem `:` |
| `segue_sem_var` | `segue` solto |
| `revisa_sem_var` | `revisa` solto |
| `segue_duplicado` | dois `segue` no mesmo `var` |
| `indentacao_inesperada` | linha indentada sem abrir bloco |
| `bloco_sem_indentacao` | corpo do `var` sem indentar |
| `indentacao_inconsistente` | `DEDENT` para uma coluna que não existe na pilha (erro léxico) |
| `bloco_vazio_fim_arquivo` | `rola legal:` e o arquivo acaba |
| `rodada_sem_em` | `rodada x time:` |
| `rodada_sem_variavel` | `rodada 10 em time:` |
| `apita_com_valor` | `apita 3` |
| `rola_sem_condicao` | `rola:` |
| `parenteses_aberto` | `(` sem fechar |
| `operador_sobrando` | `placar = 3 +` |
| `parametro_invalido` | número na lista de parâmetros |
| `virgula_sobrando` | `narra("gol", , "x")` |
| `jogada_sem_parenteses` | `jogada escanteio:` |
| `palavra_reservada_como_nome` | `gol = 1` |
| `string_nao_fechada` | erro léxico e depois erro sintático |
