CC = gcc
FLEX = flex
BISON = bison
CFLAGS = -Wall -Isrc -I$(BUILD)
BUILD = build

.PHONY: compile run test clean

compile: haxball

haxball: $(BUILD)/parser.tab.c $(BUILD)/lex.yy.c src/main.c
	$(CC) $(CFLAGS) $(BUILD)/parser.tab.c $(BUILD)/lex.yy.c src/main.c -o $@

$(BUILD)/parser.tab.c $(BUILD)/parser.tab.h: src/parser.y
	mkdir -p $(BUILD)
	$(BISON) -d -Wall -o $(BUILD)/parser.tab.c $<

$(BUILD)/lex.yy.c: src/lexer.l $(BUILD)/parser.tab.h
	$(FLEX) -o $@ $<

run: haxball
	@./haxball $(ARGS)

# testes em tests/lexico rodam com -t (so tokens); o resto roda o parser
test: haxball
	@fail=0; total=0; \
	for in in tests/*/*.in; do \
		ora="$${in%.in}.ora"; flag=""; \
		case "$$in" in tests/lexico/*) flag="-t";; esac; \
		total=$$((total + 1)); \
		if ./haxball $$flag < "$$in" 2>&1 | diff -u "$$ora" -; then \
			echo "PASS  $$in"; \
		else \
			echo "FAIL  $$in"; fail=$$((fail + 1)); \
		fi; \
	done; \
	echo; echo "Resumo: $$((total - fail))/$$total passaram"; \
	[ $$fail -eq 0 ]

clean:
	rm -rf haxball $(BUILD)
