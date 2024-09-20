#!/bin/bash

# Base directory where the emulator will start
base_dir="$HOME/linux2win"
current_dir="$base_dir"
declare -A variables
current_color="0A"  # Default to green
current_prompt="C:\Users\linux2win"  # Default prompt
current_title="Command Prompt"  # Default title

# Ensure the base directory exists
mkdir -p "$base_dir"

# Commands implementations

function cmd_help() {
    echo "Supported commands:"
    echo "help, whoami, systeminfo, prompt, title, color, echo, cls, dir, cd, cd.., tree"
    echo "md, rmdir, echo directories, del, ren, copy, move, xcopy, variables, start, exit"
}

function cmd_whoami() {
    echo "linux2win"
}

function cmd_systeminfo() {
    echo "Host Name: $(hostname)"
    echo "OS Name: Microsoft Windows 10"
    echo "OS Version: 10.0.19045"
    echo "System Type: x64-based PC"
    echo "User: linux2win"
}

function cmd_prompt() {
    current_prompt="$1"  # Change the prompt
    echo "$current_prompt"  # Output the new prompt
}

function cmd_title() {
    current_title="$1"  # Change the title
    echo -e "\033]0;$current_title\007"  # Set terminal title
}

function cmd_color() {
    case ${1^^} in
        0A) tput setaf 2 ;;  # Green
        0C) tput setaf 6 ;;  # Cyan
        *) echo "Invalid color code" ;;
    esac
    current_color="$1"  # Save the current color setting
}

function cmd_echo() {
    echo "$@"
}

function cmd_cls() {
    clear
}

function cmd_dir() {
    # List the current directory contents
    ls -la "$current_dir"
}

function cmd_cd() {
    local target="$1"
    
    if [[ "$target" == ".." ]]; then
        # Navigate to the parent directory
        current_dir=$(dirname "$current_dir")
    else
        # Navigate to the target directory if it exists
        if [[ -d "$current_dir/$target" ]]; then
            current_dir="$current_dir/$target"
        else
            echo "The system cannot find the path specified."
        fi
    fi
}

function cmd_tree() {
    # Display the tree structure
    tree "$current_dir"
    # Restore color
    cmd_color "$current_color"  # Reset to the original color
}

function cmd_md() {
    mkdir "$current_dir/$1" || echo "Error creating directory"
}

function cmd_rmdir() {
    rmdir "$current_dir/$1" || echo "Error removing directory"
}

function cmd_echo_directories() {
    ls -d "$current_dir"/*
}

function cmd_del() {
    rm "$current_dir/$1" || echo "Error deleting file"
}

function cmd_ren() {
    # Split the input into arguments
    IFS=' ' read -ra args <<< "$@"
    if [[ ${#args[@]} -ne 2 ]]; then
        echo "Usage: ren <current_filename> <new_filename>"
        return
    fi

    mv "$current_dir/${args[0]}" "$current_dir/${args[1]}" && echo "Renamed '${args[0]}' to '${args[1]}'" || echo "Error renaming file"
}

function cmd_copy() {
    cp "$current_dir/$1" "$current_dir/$2" || echo "Error copying file"
}

function cmd_move() {
    mv "$current_dir/$1" "$current_dir/$2" || echo "Error moving file"
}

function cmd_xcopy() {
    cp -r "$current_dir/$1" "$current_dir/$2" || echo "Error copying directories"
}

# Variable setting
function cmd_set() {
    local var_name="${1%%=*}"
    local var_value="${1#*=}"
    variables["$var_name"]="$var_value"
}

# Echoing variables
function cmd_echo_variable() {
    local var_name="${1//%/}"
    if [[ -n "${variables[$var_name]}" ]]; then
        echo "${variables[$var_name]}"
    else
        echo "Variable '$var_name' not found"
    fi
}

# Echoing to a file
function cmd_echo_to_file() {
    local text="${1%%>*}"
    local file="${1#*>}"
    text=$(echo "$text" | xargs)
    file=$(echo "$file" | xargs)
    echo "$text" > "$current_dir/$file"
}

function cmd_start() {
    echo "Virtual: 'start' command is not supported in linux2win emulator."
}

function cmd_exit() {
    echo "Exiting CMD Emulator..."
    exit 0
}

# Main command loop
function commandline() {
    clear
    echo "Microsoft Windows [Version 10.0.19045.4598]"
    echo "(c) Microsoft Corporation. All rights reserved."
    echo

    while true; do
        echo -n "$current_prompt> "  # Show prompt
        read -r input  # Read user input

        # Handling commands
        case $input in
            help) cmd_help ;;
            whoami) cmd_whoami ;;
            systeminfo) cmd_systeminfo ;;
            prompt*) cmd_prompt "${input#prompt }" ;;
            title*) cmd_title "${input#title }" ;;
            color*) cmd_color "${input#color }" ;;
            cls) cmd_cls ;;
            dir) cmd_dir ;;
            "cd.." ) cmd_cd ".." ;;
            cd*) cmd_cd "${input#cd }" ;;
            tree) cmd_tree ;;
            md*) cmd_md "${input#md }" ;;
            rmdir*) cmd_rmdir "${input#rmdir }" ;;
            del*) cmd_del "${input#del }" ;;
            ren*) cmd_ren "${input#ren }" ;;
            copy*) cmd_copy "${input#copy }" ;;
            move*) cmd_move "${input#move }" ;;
            xcopy*) cmd_xcopy "${input#xcopy }" ;;
            exit) cmd_exit ;;

            # Set variables
            set\ *=*) cmd_set "${input#set }" ;;

            # Echoing variables
            echo\ %*%) cmd_echo_variable "${input#echo }" ;;

            # Echoing to a file
            echo\ *\>*) cmd_echo_to_file "${input#echo }" ;;
            
            # Regular echo
            echo*) cmd_echo "${input#echo }" ;;
            
            *) echo "'$input' is not recognized as an internal or external command, operable program or batch file." ;;
        esac
    done
}

# Run the command line emulator
commandline
