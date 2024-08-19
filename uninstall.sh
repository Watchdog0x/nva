#!/usr/bin/env bash
nva_version="1.2.0"

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31mError\033[0m: You don't have permission. Please run with sudo."
    exit 1
fi
clear

spinner() {
    local task_name="$1"
    local task_function="$2"
    local pid
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local temp_file=$(mktemp)
    
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local NC='\033[0m' 
    
    tput civis  

    $task_function > "$temp_file" 2>&1 &
    pid=$!
    

    local term_width=$(tput cols)
    local max_task_width=$((term_width - 10)) 
    
    if [ ${#task_name} -gt $max_task_width ]; then
        task_name="${task_name:0:$((max_task_width-3))}..."
    fi
    
    printf "%-*s" "$max_task_width" "$task_name"
    local i=0
    while kill -0 $pid 2>/dev/null; do
        printf "\r%-*s[%s]" "$max_task_width" "$task_name" "${spin[i]}"
        i=$(( (i+1) % ${#spin[@]} ))
        sleep 0.2
    done
    
    wait $pid
    local status=$?
    
    if [ $status -eq 0 ]; then
        printf "\r%-*s[${GREEN}✓${NC}]\n" "$max_task_width" "$task_name"
    else
        printf "\r%-*s[${RED}✗${NC}]\n" "$max_task_width" "$task_name"
        local error_message=$(cat "$temp_file")
        if [ -n "$error_message" ]; then
            echo -e "${RED}Error:${NC} $error_message"
        else
            echo -e "${RED}Error:${NC} An unknown error occurred."
        fi
    fi
    
    rm "$temp_file"

    return $status
}

trap 'tput cnorm' EXIT

uninstall(){

    if [ -d "/usr/share/bash-completion/completions" ]; then
        rm -f /usr/share/bash-completion/completions/nva
    else
       rm -f /etc/bash_completion.d/nva_completion
    fi

    rm -f /usr/local/bin/nva
    rm -rf ~/.config/nva
    rm -rf /opt/nva/

    source ~/.bashrc

}


farewell_message() {
    echo -e "\n\033[0;33mFarewell, fellow sysadmin.\033[0m"
    echo "We hope NVA served your Node.js management needs well."
    echo "Your server environment might feel a bit emptier without us."
    echo "If you encountered any issues or have suggestions for improvement,"
    echo "please don't hesitate to open an issue on our GitHub repository."
    echo -e "\033[0;36mMay your servers run smoothly and your deployments be ever successful.\033[0m"
}


main() { 

    printf "Uninstall nva \033[0;32mv%s\033[0m\n\n" "$nva_version"
    farewell_message
    
    spinner "Uninstall nva" uninstall

    printf "\nUninstalling completed successfully!\n"
}

main