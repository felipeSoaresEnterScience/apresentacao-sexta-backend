#!/bin/sh
# Runs CaptainHook inside the backend container.
# Git GUIs (Cursor Source Control) often start hooks with a minimal PATH.

set -e

export PATH="/usr/local/bin:/usr/bin:/bin:${PATH:-}"

CONTAINER="${CAPTAINHOOK_DOCKER_CONTAINER:-apresentacao-de-sexta-backend}"

resolve_docker() {
    if command -v docker >/dev/null 2>&1; then
        command -v docker
        return 0
    fi

    for candidate in /usr/local/bin/docker /usr/bin/docker; do
        if [ -x "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

if ! DOCKER_BIN=$(resolve_docker); then
    echo "CaptainHook: docker nao encontrado no PATH do git hook." >&2
    echo "PHP deste projeto so existe no container. Commite pelo terminal integrado" >&2
    echo "(nao pelo botao da Source Control) com o stack no ar." >&2
    echo "PATH=${PATH}" >&2
    exit 1
fi

if ! "$DOCKER_BIN" inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null | grep -q true; then
    echo "CaptainHook: container ${CONTAINER} nao esta rodando." >&2
    echo "No diretorio APRESENTACAO DE SEXTA, rode: docker compose up -d" >&2
    echo "Docker usado: ${DOCKER_BIN}" >&2
    exit 1
fi

exec "$DOCKER_BIN" exec -i -u "$(id -u):$(id -g)" "$CONTAINER" "$@"
