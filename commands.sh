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
    os_type=$(uname)
    package_manager=""
    if [ "$os_type" == "Linux" ]; then
        if command -v apt &>/dev/null; then
            package_manager="apt"
        elif command -v yum &>/dev/null; then
            package_manager="yum"
        else
            echo "Unsupported Linux package manager!"
            exit 1
        fi
    elif [ "$os_type" == "Darwin" ]; then
        if command -v brew &>/dev/null; then
            package_manager="brew"
        else
            echo "Homebrew is not installed on macOS!"
            exit 1
        fi
    else
        echo "Unsupported operating system!"
        exit 1
    fi

    if ! command -v yq &>/dev/null; then
        echo "yq is required to run this script. Do you want to install it? (y/n)"
        read -r response
        if [ "$response" == "y" ]; then
            echo "[*] Installing yq..."
            case "$package_manager" in
            apt)
                if ! sudo apt update && sudo apt install -y yq; then
                    echo "Failed to install yq using apt."
                    exit 1
                fi
                ;;
            yum)
                if ! sudo yum install -y yq; then
                    echo "Failed to install yq using yum."
                    exit 1
                fi
                ;;
            brew)
                if ! brew install yq; then
                    echo "Failed to install yq using brew."
                    exit 1
                fi
                ;;
            esac
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
    # List all available tools in the tools file
    yq e ".[].name" "$TOOLSFILE"

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
            echo "- $tool"
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
    (
        eval "$pre_install_command"
    )
    test=$?
    if [ $test -eq 1 ]; then
        echo "[-] $tool_name is already installed."
        return 0
    else
        echo "[*] Installing $tool"
    fi

    # echo "[*] Installing $tool_name..."
    # eval "$install_command"

    # echo "Running post-installation commands ..."
    # eval "$post_install_command"

    # echo -e "$post_install_message"
    # return 0
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
