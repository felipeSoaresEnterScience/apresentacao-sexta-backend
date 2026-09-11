#!/bin/sh
set -e

COMMIT_MSG_FILE="$1"

if [ -z "$COMMIT_MSG_FILE" ] || [ ! -f "$COMMIT_MSG_FILE" ]; then
    echo "" >&2
    echo "Erro no hook commit-msg: arquivo de mensagem nao encontrado." >&2
    exit 1
fi

if git rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; then
    exit 0
fi

SUBJECT="$(head -n 1 "$COMMIT_MSG_FILE")"

PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9\-\. ]+\))?!?: .+$'

if echo "$SUBJECT" | grep -Eq "$PATTERN"; then
    exit 0
fi

cat >&2 <<EOF

Commit bloqueado: mensagem invalida.

  Voce escreveu: "$SUBJECT"

  Formato obrigatorio (Conventional Commits):
    tipo(escopo): descricao

  Tipos aceitos:
    feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

  Exemplos validos:
    feat: adiciona endpoint de login
    fix(auth): corrige validacao de token
    fix(git hook): ajusta validacao de commit
    chore(deps): atualiza dependencias

EOF

exit 1
