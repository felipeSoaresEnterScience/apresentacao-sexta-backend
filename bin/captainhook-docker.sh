#!/bin/sh
# Runs CaptainHook inside the backend container.
# Supports: terminal, dev container (php local), GitHub Desktop/Cursor Flatpak (flatpak-spawn).

set -e

export PATH="/usr/local/bin:/usr/bin:/bin:${PATH:-}"

CONTAINER="${CAPTAINHOOK_DOCKER_CONTAINER:-apresentacao-de-sexta-backend}"
DOCKER_MODE=""
DOCKER_BIN=""

resolve_php() {
    for candidate in /usr/local/bin/php /usr/bin/php; do
        if [ -x "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

resolve_docker() {
    for candidate in /usr/bin/docker /usr/local/bin/docker /bin/docker; do
        if [ -x "$candidate" ]; then
            DOCKER_BIN="$candidate"
            DOCKER_MODE="direct"
            return 0
        fi
    done

    if command -v docker >/dev/null 2>&1; then
        DOCKER_BIN="$(command -v docker)"
        DOCKER_MODE="direct"
        return 0
    fi

    if command -v flatpak-spawn >/dev/null 2>&1; then
        for candidate in /usr/bin/docker /usr/local/bin/docker docker; do
            if flatpak-spawn --host "$candidate" version >/dev/null 2>&1; then
                DOCKER_BIN="$candidate"
                DOCKER_MODE="flatpak"
                return 0
            fi
        done
    fi

    return 1
}

container_running() {
    if [ "$DOCKER_MODE" = "flatpak" ]; then
        flatpak-spawn --host "$DOCKER_BIN" inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null | grep -q true
        return
    fi

    "$DOCKER_BIN" inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null | grep -q true
}

run_in_container() {
    if [ "$DOCKER_MODE" = "flatpak" ]; then
        exec flatpak-spawn --host "$DOCKER_BIN" exec -i -u "$(id -u):$(id -g)" "$CONTAINER" "$@"
    fi

    exec "$DOCKER_BIN" exec -i -u "$(id -u):$(id -g)" "$CONTAINER" "$@"
}

if resolve_docker && container_running; then
    run_in_container "$@"
fi

if PHP_BIN="$(resolve_php)"; then
    exec "$PHP_BIN" "$@"
fi

echo "CaptainHook: nao foi possivel rodar os hooks." >&2
echo "- Container ${CONTAINER} parado ou docker inacessivel" >&2
echo "- PHP local tambem nao encontrado" >&2
echo "Suba o stack: docker compose up -d (no diretorio APRESENTACAO DE SEXTA)" >&2
echo "PATH=${PATH}" >&2
exit 1
