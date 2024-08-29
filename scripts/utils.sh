#!/bin/bash

check_exits() {
    tool_name="$1"
    # Check if the tool name exists in the tools file
    tool=$(yq e ".tools[] | select(.name == \"$tool_name\")" "$CLIC_TOOLS_FILE")
    if [ -z "$tool" ]; then
        echo 1
    else
        echo 0
    fi
}

check_installed() {
    tool_name="$1"
    # get command to check from tools file
    command=$(yq e ".tools[] | select(.name == \"$tool_name\") | .cmd_check" "$CLIC_TOOLS_FILE")
    # check if the tool is installed
    # echo $command
    installed=$(eval "$command")
    echo "$installed"
}

check_preqs() {
    tool_name="$1"
    # get command to check from tools file
    requires=$(yq e ".tools[] | select(.name == \"$tool_name\") | .preqs" "$CLIC_TOOLS_FILE")
    # requires are a list of tools that need to be installed first
    for tool in $requires; do
        installed=$(check_installed "$tool")
        if [ "$installed" == "0" ]; then
            echo "$tool is not installed"
            return 1
        fi
    done
}