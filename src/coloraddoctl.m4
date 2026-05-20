#!/usr/bin/env bash

# ARG_HELP([Utility to control the coloraddod daemon.])

# ARG_POSITIONAL_INF([rest],[Any arguments],[0])

# ARGBASH_GO

readonly FIFO_DIR_PATH="$XDG_RUNTIME_DIR/coloraddod"
readonly CMD_FIFO_FILE_PATH="$FIFO_DIR_PATH/cmd.fifo"
readonly EVT_FIFO_FILE_PATH="$FIFO_DIR_PATH/evt.fifo"


if ! pgrep -f coloraddod > /dev/null; then
    echo "Error: 'coloraddod' instance not found"
    exit 1

elif ! [[[ -p "$CMD_FIFO_FILE_PATH" && -p "$EVT_FIFO_FILE_PATH" ]]]; then
    printf "Error: '%s' or '%s' pipes not found\n" \
        "$CMD_FIFO_FILE_PATH" "$EVT_FIFO_FILE_PATH"

    exit 1
fi

exec 3> "$CMD_FIFO_FILE_PATH"
printf 'control %s\n' "$*" >&3
exec 3>&-

exec 4< "$EVT_FIFO_FILE_PATH"

while read -u 4 -r line; do
    if [[[ -z "$exit_code" ]]]; then
        [[[ "$line" != "Error:"* ]]]
        exit_code=$?
    fi

    if (( exit_code )); then
        printf '%s\n' "$line" >&2
    else
        printf '%s\n' "$line"
    fi
done

exec 4>&-

exit $exit_code
