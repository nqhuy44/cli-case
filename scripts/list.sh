#!/bin/bash
source "$CLIC_ROOT_DIR/scripts/utils.sh"

# Read the tools file and extract the tools
tools=$(yq e '.tools[] | [.category, .name] | @csv' "$CLIC_TOOLS_FILE")

# Collect the tools in an array
tool_list=()
while IFS=, read -r category name; do
    # Skip tools with the category "lib"
    if [ "$category" == "lib" ]; then
        continue
    fi
    
    installed=$(check_installed "$name")
    if [ "$installed" == "1" ]; then
        installed="Installed"
    else
        installed="-"
    fi
    tool_list+=("$category,$name,$installed")
done <<<"$tools"

# Sort the tools by category and name
sorted_tools=$(printf "%s\n" "${tool_list[@]}" | sort -t, -k1,1 -k2,2)

# Print the header
header="Category,Tool,Installed"
separator="--------,----,---------"

# Combine header, separator, and sorted tools
output=$(printf "%s\n%s\n%s\n" "$header" "$separator" "$sorted_tools")

# Print the combined output in a formatted manner
printf "%s\n" "$output" | while IFS=, read -r category name installed; do
    printf "%-10s | %-20s | %-10s\n" "$category" "$name" "$installed"
done | column -t -s '|'
