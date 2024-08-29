#!/bin/bash

export CLIC_ROOT_DIR="$(dirname "$0")"
export CLIC_TOOLS_FILE="$CLIC_ROOT_DIR/resources/tools.yaml"
export CLIC_HELP_FILE="$CLIC_ROOT_DIR/resources/help.yaml"

# source "$CLIC_ROOT_DIR/scripts/utils.sh"
# source "$CLIC_ROOT_DIR/scripts/list.sh"
# source "$CLIC_ROOT_DIR/scripts/install.sh"
# source "$CLIC_ROOT_DIR/scripts/uninstall.sh"

help() {
    usage=$(yq e '.usage' "$HELP_FILE")
    echo "$usage"
    echo

    commands=$(yq e '.commands' "$HELP_FILE")
    echo "$commands" | yq e -o=json '.' | yq e -N '.[]' | while IFS= read -r command; do
        name=$(echo "$command" | yq e '.name' -)
        description=$(echo "$command" | yq e '.description' -)
        printf "  %-20s %s\n" "$name" "$description"
    done
}

chmod +x $CLIC_ROOT_DIR/scripts/*.sh

case "$1" in
list)
    "$CLIC_ROOT_DIR/scripts/list.sh"
    ;;
install)
    "$CLIC_ROOT_DIR/scripts/install.sh" "$2"
    ;;
uninstall)
    "$CLIC_ROOT_DIR/scripts/uninstall.sh" "$2"
    ;;
help | *)
    help
    ;;
esac
