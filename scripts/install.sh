#!/bin/bash
source "$CLIC_ROOT_DIR/scripts/utils.sh"

tool_name="$1"

# Check if the tool name exists in the tools file
exists=$(check_exits "$tool_name")
if [ "$exists" == "1" ]; then
    echo "-> Tool not found"
    exit 1
fi

pre_install=$(check_preqs "$tool_name")
installed=$(check_installed "$tool_name")

if [ "$pre_install" == "1" ] || [ "$installed" == "1" ]; then
    echo "-> $tool_name is already installed"
    exit 1
fi


install_command=$(yq e ".tools[] | select(.name == \"$tool_name\") | .cmd_install" "$CLIC_TOOLS_FILE")
eval "$install_command"
if [ $? == 0 ]; then
    echo "-> $tool_name installed successfully"
    exit 0
else
    echo "-> Failed to install $tool_name"
    exit 1
fi
