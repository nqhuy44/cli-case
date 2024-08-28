#!/bin/bash

uninstall_tool() {
    tool_name="$1"
    uninstall_command=$(yq e ".tools[] | select(.name == \"$tool_name\") | .uninstall_command" "$TOOLSFILE")
    eval "$uninstall_command"
}