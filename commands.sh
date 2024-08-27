#!/bin/bash
set -e
TOOLSFILE="tools.yaml"
# Run prerequisites check

commands=(
    "list"
    "install"
)

prequisites() {
    # Check if yq is installed and ask to install
    if [ "$(uname)" != "Darwin" ]; then
        echo "This script is only supported on macOS!"
        exit 1
    fi

    if ! command -v brew &>/dev/null; then
        echo "Homebrew is not installed on macOS!"
        exit 1
    fi

    if ! command -v yq &>/dev/null; then
        echo "yq is required to run this script. Do you want to install it? (y/n)"
        read -r response
        if [ "$response" == "y" ]; then
            echo "[] Installing yq..."
            if ! brew install yq; then
                echo "Failed to install yq using brew."
                exit 1
            fi
        else
            echo "yq is required to run this script. Exiting..."
            exit 1
        fi
    fi
}

list() {
    if [ "$1" == "--description" ]; then
        echo "List all available tools"
        return
    fi
    # List all available tools
    if [ ! -f "$TOOLSFILE" ]; then
        echo "Tools file not found!"
        return 1
    fi
    # Extract, sort, and format the tools
    yq e '.[] | .name + " | " + .category' "$TOOLSFILE" | \
    sort -t '|' -k2,2 -k1,1 | \
    awk '
    BEGIN {
        FS="|";
        OFS="|";
        print "Category", "Tool";
        print "--------", "----";
    }
    {
        print $2, $1;
    }' | column -t -s '|'
}

# Function to install a specific tool
install() {
    # Command description
    case "$1" in
    --description)
        echo "Install a specific tool"
        return
        ;;
    --help)
        echo "Usage: install [tool_name]"
        echo "Install a specific tool by name."
        echo
        echo "Arguments:"
        echo "  --description   Show a brief description of this command."
        echo "  --help          Show this help message."
        echo "  --all           Install all tools."
        return
        ;;
    --all) ;;
    --* | '')
        echo "Invalid argument, use --help to see the usage."
        return 1
        ;;
    esac

    tool_name="$1"
    if [ ! -f "$TOOLSFILE" ]; then
        echo "$TOOLSFILE file not found!"
        return 1
    fi

    if [ "$tool_name" == "--all" ]; then
        tools=$(yq e '.[] | .name' "$TOOLSFILE")

        echo "The following tools will be installed:"
        for tool in $tools; do
            echo "[] $tool"
        done

        echo "Do you want to proceed with the installation? (y/n) "
        read -r response
        if [ "$response" != "y" ]; then
            echo "Installation aborted."
            exit 0
        fi

        for tool in $tools; do
            install_tool $tool
            if [ $? -ne 0 ]; then
                echo "Error installing $tool. Continuing with next tool..."
            fi
        done
    else
        install_tool "$tool_name"
    fi
}

install_tool() {
    set -e

    tool_name="$1"
    tool_info=$(yq e ".[] | select(.name == \"$tool_name\")" "$TOOLSFILE")

    if [ -z "$tool_info" ]; then
        echo "Tool not found!"
        return 1
    fi

    description=$(yq e ".[] | select(.name == \"$tool_name\") | .description" "$TOOLSFILE")
    pre_install_command=$(yq e ".[] | select(.name == \"$tool_name\") | .pre_install_command" "$TOOLSFILE")
    install_command=$(yq e ".[] | select(.name == \"$tool_name\") | .install_command" "$TOOLSFILE")
    post_install_command=$(yq e ".[] | select(.name == \"$tool_name\") | .post_install_command" "$TOOLSFILE")
    post_install_message=$(yq e ".[] | select(.name == \"$tool_name\") | .post_install_message" "$TOOLSFILE")


    # Run before installation commands to check installed packages
    echo "[*] Installing $tool"
    PRE_INSTALL=0
    eval "$pre_install_command"
    if [ "$PRE_INSTALL" -eq 1 ]; then
        echo "--> Skip install"
        return 0
    fi
    
    eval "$install_command"

    echo "- Post-installation ..."
    eval "$post_install_command"

    # echo -e "$post_install_message"
    return 0
}

# Function to uninstall a specific tool
uninstall() {
    echo "Uninstall a specific tool"
}

# Function to update a specific tool
update() {
    echo "Update a specific tool"
}

# Show help
help() {
    echo "Usage: $0 [command] [arguments]"
    echo
    echo "Commands:"
    for cmd in "${commands[@]}"; do
        description=$($cmd --description)
        printf "  %-10s %s\n" "$cmd" "$description"
    done
    echo
}
