#!/usr/bin/env bash

# ARG_HELP([help])

# ARG_POSITIONAL_SINGLE([key], [desc])
# ARG_POSITIONAL_SINGLE([value], [desc], [null])

# ARGBASH_GO

FIFO_DIR_PATH="$XDG_RUNTIME_DIR/coloraddod"
CMD_FIFO_FILE_PATH="$FIFO_DIR_PATH/cmd.fifo"
EVT_FIFO_FILE_PATH="$FIFO_DIR_PATH/evt.fifo"

printf '%s\n' "$*" > "$CMD_FIFO_FILE_PATH"

while read -r line; do
    echo "event: $line"
done < "$EVT_FIFO_FILE_PATH"
