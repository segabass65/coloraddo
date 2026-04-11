#!/usr/bin/env bash

# ARG_HELP([Changing border colors depending on bspwm node flags])

# ARG_OPTIONAL_BOOLEAN([names], [n], [Log names instead of IDs], [off])
# ARG_OPTIONAL_SINGLE([log-level], [l], [Minimum logging level], [20])

# ARGBASH_GO

FIFO_DIR_PATH="$XDG_RUNTIME_DIR/coloraddod"
CMD_FIFO_FILE_PATH="$FIFO_DIR_PATH/cmd.fifo"
EVT_FIFO_FILE_PATH="$FIFO_DIR_PATH/evt.fifo"

declare -Ar LOG_LEVELS=(
    [[10]]="DEBUG"
    [[20]]="INFO"
    [[30]]="WARNING"
    [[40]]="ERROR"
    [[50]]="CRITICAL"
)

array_contains() {
    local needle="$1"
    shift
    local item

    for item; do
        [[[ "$item" == "$needle" ]]] && return 0
    done

    return 1
}

logging() {
    local level_id="$1"

    if (( level_id < _arg_log_level && _arg_log_level <= 50 )); then
        return 1
    fi

    shift
    local message="$*"
    local level_name="${LOG_LEVELS[[$level_id]]}"

    printf '[[%(%T)T]] [[%s]]: %s\n' -1 "$level_name" "$message"
}

logging_node() {
    local level_id="$1"

    if (( $level_id < $_arg_log_level )); then
        return 1
    fi

    local node_id="$2"
    shift 2
    local message="$*"

    local thread
    local level_name="${LOG_LEVELS[[$level_id]]}"
    
    if [[[ "$_arg_names" == "off" ]]]; then
        thread="$node_id"
    else
        thread="$(xtitle "$node_id" 2> /dev/null)"
        [[[ -z "$thread" ]]] && thread="$node_id"
    fi

    printf '[[%(%T)T]] [[%s/%s]]: %s\n' -1 "$thread" "$level_name" "$message"
}

get_top_flag() {
    local node_id="$1"

    local flag
    local node_ids

    for flag in "${flags[[@]]}"; do
        declare -n node_ids="$flag"_node_ids

        if array_contains "$node_id" "${node_ids[[@]]}"; then
            printf "$flag"
            
            return 0
        fi
    done

    printf "normal"
}

recolor_border() {
    local border_color="$1"
    local node_id="$2"

    if chwb -c "${border_colors[[$border_color]]}" "$node_id"; then
        logging_node 20 "$node_id" \
            "border recolored ($border_color)"
            
    else
        logging_node 40 "$node_id" \
            "border recolor failed ($border_color)"
    fi
}

recolor_borders() {
    local node_ids
    local node_id
    local node_top_flag

    border_colors[["active"]]="$(bspc config active_border_color | tr -d "#")"
    border_colors[["focused"]]="$(bspc config focused_border_color | tr -d "#")"
    border_colors[["normal"]]="$(bspc config normal_border_color| tr -d "#")"

    mapfile -t locked_node_ids < <(bspc query -N -n .locked)
    mapfile -t marked_node_ids < <(bspc query -N -n .marked)
    mapfile -t node_ids < <(bspc query -N -n .window)
    mapfile -t private_node_ids < <(bspc query -N -n .private)
    mapfile -t sticky_node_ids < <(bspc query -N -n .sticky)
    mapfile -t urgent_node_ids < <(bspc query -N -n .urgent)

    focused_node_id="$(bspc query -N -n .focused)"

    for node_id in "${node_ids[[@]]}"; do
        node_top_flag="$(get_top_flag "$node_id")"

        if [[[ "$node_id" != "$focused_node_id" ]]]; then
            if [[[ "$node_top_flag" != "normal" ]]]; then
                recolor_border "$node_top_flag" "$node_id"
            fi

        else
            focused_node_top_flag="$node_top_flag"
        fi
    done
}

handle_event() {
    local event="$1"

    case "$event" in
        "node_focus")
            local node_id="$4"

            if [[[ "$node_id" != "$focused_node_id" ]]]; then 
                if [[[ "$focused_node_top_flag" != "normal" ]]]; then
                    recolor_border \
                        "$focused_node_top_flag" \
                        "$focused_node_id" &
                fi

                focused_node_id="$node_id"
                focused_node_top_flag="$(get_top_flag "$focused_node_id")"
            fi

            logging_node 10 "$focused_node_id" "focused" &
        ;;

        "node_flag")
            local node_id="$4"
            local flag="$5"
            local flag_value="$6"

            local node_ids
            local node_top_flag

            declare -n node_ids="$flag"_node_ids

            if [[[ "$flag_value" == "on" ]]]; then
                logging_node 10 "$node_id" "$flag" &

                node_ids+=("$node_id")

            else
                logging_node 10 "$node_id" "un$flag" &

                node_ids=("${node_ids[[@]]/$node_id}")
            fi

            node_top_flag="$(get_top_flag "$node_id")"

            if [[[ "$node_id" == "$focused_node_id" ]]]; then
                focused_node_top_flag="$node_top_flag"
            else
                recolor_border "$node_top_flag" "$node_id" &
            fi
        ;;

        "node_remove")
            local node_id="$4"

            local flag
            local node_ids

            logging_node 10 "$node_id" "removed"

            for flag in "${flags[[@]]}"; do
                declare -n node_ids="$flag"_node_ids

                if array_contains "$node_id" "${node_ids[[@]]}"; then
                    node_ids=("${node_ids[[@]]/$node_id}")
                fi
            done
        ;;

        "node_swap")
            local src_node_id="$4"
            local dst_node_id="$7"

            local node_id

            for node_id in "$src_node_id" "$dst_node_id"; do
                logging_node 10 "$node_id" "swapped" &

                if [[[ "$node_id" != "$focused_node_id" ]]]; then
                    recolor_border \
                        "$(get_top_flag "$node_id")" \
                        "$node_id" &
                fi
            done
        ;;

        "node_transfer")
            local src_node_id="$4"
            local dst_node_id="$7"

            local node_id

            for node_id in "$src_node_id" "$dst_node_id"; do
                logging_node 10 "$node_id" "transferred" &

                if [[[ "$node_id" != "$focused_node_id" ]]]; then
                    recolor_border \
                        "$(get_top_flag "$node_id")" \
                        "$node_id" &
                else
                    recolor_border \
                        "focused" \
                        "$node_id" &
                fi
            done
        ;;
    esac
}

is_hex_color() {
    local color="$1"

    [[[ "$color" =~ ^#?([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6})$ ]]]
}

handle_command() {
    local command="$1"

    case "$command" in
        "locked_border_color")
            echo 1
            local color="$2"

            if is_hex_color "$color"; then
                echo 1
                border_colors[["locked"]]="${color#\#}"

                echo ${border_colors[["locked"]]}
            fi
        ;;
    esac
}

fifo_loop() {
    mkdir -p "$FIFO_DIR_PATH"
    [[ -p "$CMD_FIFO_FILE_PATH" ]] || mkfifo "$CMD_FIFO_FILE_PATH"
    [[ -p "$EVT_FIFO_FILE_PATH" ]] || mkfifo "$EVT_FIFO_FILE_PATH"

    while read -r cmd arg; do
        echo $cmd $arg
        handle_command "$cmd" "$arg"
    done < "$CMD_FIFO_FILE_PATH"
}

cleanup() {
    rm -f "$CMD_FIFO_FILE_PATH" "$EVT_FIFO_FILE_PATH"
    rmdir "$FIFO_DIR_PATH" 2> /dev/null

    pkill -P $$
    exit
}

init() {
    if ! pgrep -x bspwm > /dev/null; then
        logging 50 "'bspwm' instance not found"

        return 1

    elif ! command -v chwb > /dev/null; then
        logging 50 "'chwb' not found (part of 'wmutils')"

        return 1

    elif ((
        _arg_log_level < 10 || _arg_log_level > 50 || _arg_log_level % 10 != 0
    )); then

        logging 50 "Incorrect log level, allowed values: 10-50 (step 10)"

        return 1
    fi

    subscriptions=(
        "node_flag"
        "node_focus"
        "node_remove"
        "node_swap"
        "node_transfer"
    )   

    flags=("marked" "urgent" "sticky" "private" "locked")

    declare -A border_colors=(
        [["locked"]]="f38ba8"
        [["private"]]="fab387"
        [["urgent"]]="74c7ec"
        [["marked"]]="a6e3a1"
        [["sticky"]]="fab387"
    )

    trap cleanup EXIT SIGINT SIGTERM
    
    recolor_borders

    fifo_loop &
    
    logging 20 "Event handling started"

    bspc subscribe "${subscriptions[[@]]}" | while read line; do
        handle_event $line
    done

    logging 20 "Event handling stopped"
}

init
