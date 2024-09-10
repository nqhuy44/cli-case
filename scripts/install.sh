#!/bin/bash
# Function to handle errors
error_handler() {
  echo "Error occurred in script at line: $1"
  exit 1
}

# Trap errors and call error_handler
trap 'error_handler $LINENO' ERR

source "$CLIC_ROOT_DIR/scripts/utils.sh"

tool_name="$1"
version="$2"

# Check if the tool name exists in the tools file
exists=$(check_exits "$tool_name")
if [ "$exists" == "1" ]; then
    echo "-> Tool not found"
    exit 1
fi

# Get method to install the tool
method='default'
# if version is provided method is set to version
if [ -n "$version" ]; then
    method='version'
fi
pre_install=$(check_preqs "$tool_name")
installed=$(check_installed "$tool_name")

if [ "$pre_install" == "1" ]; then
    echo "-> Prerequisites tools are not installed"
    #list prereqs
    prereqs=$(yq e ".tools[] | select(.name == \"$tool_name\") | .preqs" "$CLIC_TOOLS_FILE")
    echo "Prerequisites: $prereqs"
    #ask to install prereqs
    echo "Do you want to install the prerequisites? (y/n)"
    read answer
    if [ "$answer" == "y" ]; then
        for tool in $prereqs; do
            "$CLIC_ROOT_DIR/scripts/install.sh" "$tool"
        done
    else
        exit 1
    fi
fi

if [ "$installed" == "1" ]; then
    echo "-> $tool_name is already installed"
    exit 1
fi


install_command=$(yq e ".tools[] | select(.name == \"$tool_name\") | .cmd_install.$method" "$CLIC_TOOLS_FILE")
export VERSION="$version"
# echo $install_command
eval "$install_command"
if [ $? == 0 ]; then
    echo "-> $tool_name installed successfully"
    exit 0
else
    echo "-> Failed to install $tool_name"
    exit 1
fi
