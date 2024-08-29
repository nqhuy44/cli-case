#!/bin/bash

check_exits() {
    local tool_name="$1"
    # Check if the tool name exists in the tools file
    local tool=$(yq e ".tools[] | select(.name == \"$tool_name\")" "$CLIC_TOOLS_FILE")
    if [ -z "$tool" ]; then
        echo 1
    else
        echo 0
    fi
}

check_category() {
    local tool_name="$1"
    local category=$(yq e ".tools[] | select(.name == \"$tool_name\") | .category" "$CLIC_TOOLS_FILE")
    echo "$category"
}

# Func to get install method by OS,
get_install_method() {
    local tool_name="$1"
    local package="custom"
    if $(uname -a | grep -q "Darwin"); then
        package="brew"
    elif $(uname -a | grep -q "Linux"); then
        package="apt"
    fi
    local method_install=$(yq e ".tools[] | select(.name == \"$tool_name\") | .cmd_install.$package" "$CLIC_TOOLS_FILE")
    if  [ -z "$method_install" ]; then
        echo "custom"
    else
        echo "$package"
    fi
}

# Func to check if a tool is installed
check_installed() {
    local tool_name="$1"
    local command=$(yq e ".tools[] | select(.name == \"$tool_name\") | .cmd_check" "$CLIC_TOOLS_FILE")
    
    # Check if the tool is installed
    local installed=$(eval "$command")
    if [ "$installed" == "0" ]; then
        echo 0
    else
        echo 1
    fi
}



# Func to check if a tool has prerequisites
check_preqs() {
    local tool_name="$1"
    # get command to check from tools file
    local requires=$(yq e ".tools[] | select(.name == \"$tool_name\") | .preqs" "$CLIC_TOOLS_FILE")
    # requires are a list of tools that need to be installed first
    for tool in $requires; do
        local installed=$(check_installed "$tool")
        if [ "$installed" == "0" ]; then
            echo "$tool is not installed"
            return 1
        fi
    done
}
