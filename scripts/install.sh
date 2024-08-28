#!/bin/bash

install_tool() {
    tool_name="$1"
    install_command=$(yq e ".tools[] | select(.name == \"$tool_name\") | .install_command" "$CLIC_TOOLS_FILE")
    eval "$install_command"
}