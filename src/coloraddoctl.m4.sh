#!/usr/bin/env bash

# ARG_HELP([Utility to control the coloraddod daemon.])

# ARG_POSITIONAL_SINGLE([action], [Operation to perform])
# ARG_POSITIONAL_SINGLE([key], [The name of the key or variable])
# ARG_POSITIONAL_SINGLE([value], [The value to be set], [null])

# ARGBASH_GO

readonly FIFO_DIR_PATH="$XDG_RUNTIME_DIR/coloraddod"
readonly CMD_FIFO_FILE_PATH="$FIFO_DIR_PATH/cmd.fifo"
readonly EVT_FIFO_FILE_PATH="$FIFO_DIR_PATH/evt.fifo"


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
        echo "$line" >&2
    else
        echo "$line"
    fi
done

exec 4>&-

exit $exit_code
