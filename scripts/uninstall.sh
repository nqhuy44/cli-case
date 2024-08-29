#!/bin/bash
source "$CLIC_ROOT_DIR/scripts/utils.sh"

tool_name="$1"

# Check if the tool name exists in the tools file
exists=$(check_exits "$tool_name")
if [ "$exists" == "1" ]; then
    echo "-> Tool not found"
    exit 1
fi

# Check if the tool is installed
installed=$(check_installed "$tool_name")
if [ "$installed" == "0" ]; then
    echo "-> $tool_name is not installed"
    exit 1
fi

uninstall_command=$(yq e ".tools[] | select(.name == \"$tool_name\") | .cmd_uninstall" "$CLIC_TOOLS_FILE")
eval "$uninstall_command"
if [ $? == 0 ]; then
    installed=$(check_installed "$tool_name")
    if [ "$installed" == "0" ]; then
        echo "-> $tool_name uninstalled"
        exit 0
    fi
    echo "-> Failed to uninstall $tool_name"
    exit 1
else
    installed=$(check_installed "$tool_name")
    if [ "$installed" == "0" ]; then
        echo "-> $tool_name uninstalled"
        exit 1
    fi
    echo "-> Failed to uninstall $tool_name"
    exit 1
fi
