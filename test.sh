function prompt_with_timeout {
    local duration=${1:-10}
    local prompt=${2:-"Please enter a value"}
    local default_value=${3:-"default_value"}
    local user_input

    echo -ne "$prompt... ($duration) "
    for ((i=$duration; i>=1; i--)); do
        read -s -t 1 -n 1 user_input
        if [[ -n $user_input ]]; then
            echo "\r"
            read -s -r user_input # continue reading user input until they hit enter
            echo "$user_input"
            return
        fi
        echo -ne "\r$prompt... ($(($i-1)))   "
    done
    echo "$default_value"
}

function prompt_with_timeout {
    read -t 5 -p "Enter text (default: DEFAULT_VALUE): " input
    if [ -z "$input" ]; then
        echo "Timeout reached, returning default value."
        input="DEFAULT_VALUE"
    fi
    echo "Input was: $input"
}

function prompt_yes_no {
    local TIMEOUT=${2:-5}
    local ADDITIONAL_ARGS=${3}
    local MESSAGE="${1} (yes/$(tput setaf 2)$(tput bold)no$(tput sgr 0)): "
    read -t $TIMEOUT $ADDITIONAL_ARGS -p "${MESSAGE}" input
    if [ -z "$input" ]; then
        echo '0'
    elif [ "$input" = "y" ] || [ "$input" = "Y" ] || [ "$input" = "yes" ] || [ "$input" = "YES" ]; then
        echo '1'
    else
        echo '2'
    fi
}

function prompt_input {
    local MESSAGE="${1}: "
    local TIMEOUT=${2:-5}
    local ADDITIONAL_ARGS=${3}
    read -t $TIMEOUT $ADDITIONAL_ARGS -p "${MESSAGE}" input
    echo $input
}

function prompt_yes_no_message {
    local result=$(prompt_yes_no "$@")

    case $result in
        0)
            echo -e "timed out. proceed with default value. \r"
            return 1;;
        2)
            return 1;;
        *)
            return 0;;
    esac
}


PAS=$(prompt_input "enter your user name" 5 "-s")
if [ -z "$PAS" ]; then
    echo ""
    PAS="asdf"
fi

echo "psd is: ${PAS}";

# if prompt_yes_no_message "Are you sure?" 3; then
#     echo 'ok, yes';
# else
#     echo 'ok, no';
# fi

# if prompt_yes_no_message "Are you sure?"; then
#     echo "yes";
# else
#     echo "no";
# fi
