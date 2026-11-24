# Linguagem Haxball - Compiladores (MATA61 - UFBA)

Equipe: Manicômio

A Haxball é um subconjunto de Python com temática de futebol, definida pela equipe na M1.
Os comandos do Python foram trocados por termos do futebol (`def` → `jogada`, `if` → `var`,
`while` → `rola`, `print` → `narra`...), e a estrutura de blocos usa `:` e indentação,
igual ao Python.

## M2 - Análise Léxica e Sintática (sem ações semânticas)

Analisador léxico em **Flex** e analisador sintático em **Bison** para a linguagem Haxball.
A gramática do Bison não tem nenhuma ação semântica: o programa só diz se a entrada
é sintaticamente correta ou mostra a linha do erro.

Código, instruções de compilação e testes: [M2/README.md](./M2/README.md)

## Estrutura

```
.github/workflows/ci.yaml   CI: instala flex e bison e roda os testes
scripts/run_tests.sh        roda os testes de todas as pastas M*
M2/                         analisador léxico e sintático
```

## Testes

Da raiz do repositório:

```bash
bash scripts/run_tests.sh
```

## Entrega

Cada etapa é desenvolvida numa branch própria (ex.: `m2`) e entregue por um Pull Request
que fica aberto para a correção.

- **M2:** [PR #5](https://github.com/NadsonSantana/MATA61-Grupo-Manicomio-Haxball/pull/5)
  (`m2` → `base-m2`). A branch `base-m2` tem só o primeiro commit, então o PR mostra a M2
  inteira, com os commits de todos os membros.
