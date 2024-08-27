# Import command functions from commands.sh
set -e

source ./commands.sh

# Array to store command names
prequisites

# Command line arguments
case "$1" in
    list)
        list
        ;;
    install)
        install "$2"
        ;;
    help)
        help
        ;;
    # other cases no in the list
    *)
        echo "Invalid command!"
        help
        ;;
esac
