#!/bin/sh
set -e

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if [ "$BRANCH" = "main" ]; then
    cat >&2 <<EOF

Push bloqueado: branch protegida.

  Branch atual: main

  Trabalhe na develop e abra um Pull Request para integrar na main.

EOF
    exit 1
fi

exit 0
