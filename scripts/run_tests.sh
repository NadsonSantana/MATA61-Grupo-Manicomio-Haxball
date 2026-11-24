#!/usr/bin/env bash

set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_CMD="${RUN_CMD:-./haxball}"
TIMEOUT="${TIMEOUT:-10}"

cd "$ROOT" || exit 2

if [ "$#" -gt 0 ]; then
    parts=("$@")
else
    mapfile -t parts < <(find . -maxdepth 1 -type d -name 'M[0-9]*' -printf '%f\n' | sort)
fi

total=0; failed=0

for part in "${parts[@]}"; do
    echo "=== $part ==="

    if [ ! -f "$part/makefile" ] && [ ! -f "$part/Makefile" ]; then
        echo "SKIP  sem makefile em $part"
        continue
    fi

    if ! make -C "$part" compile >"$part/.compile.log" 2>&1; then
        echo "FAIL  'make compile' falhou:"
        sed 's/^/      /' "$part/.compile.log"
        rm -f "$part/.compile.log"
        failed=$((failed + 1)); total=$((total + 1))
        continue
    fi
    rm -f "$part/.compile.log"

    mapfile -t inputs < <(find "$part/tests" -type f -name '*.in' 2>/dev/null | sort)

    for in_file in "${inputs[@]}"; do
        total=$((total + 1))
        ora_file="${in_file%.in}.ora"

        if [ ! -f "$ora_file" ]; then
            echo "FAIL  $in_file (oráculo $ora_file não existe)"
            failed=$((failed + 1)); continue
        fi

        # testes da pasta lexico so listam os tokens
        flag=""
        case "$in_file" in */tests/lexico/*) flag="-t" ;; esac

        actual="$(cd "$part" && timeout "$TIMEOUT" $RUN_CMD $flag < "$ROOT/$in_file" 2>&1)"
        status=$?

        # 0 = aceito, 1 = erro lexico/sintatico; qualquer outro codigo e falha
        if [ "$status" -gt 1 ]; then
            echo "FAIL  $in_file (código de saída $status)"
            failed=$((failed + 1)); continue
        fi

        if diff_out="$(diff -u --strip-trailing-cr -Z "$ora_file" <(printf '%s\n' "$actual"))"; then
            echo "PASS  $in_file"
        else
            echo "FAIL  $in_file"
            echo "$diff_out" | sed 's/^/      /'
            failed=$((failed + 1))
        fi
    done
done

echo
echo "Resumo: $((total - failed))/$total passaram"
[ "$failed" -eq 0 ]
