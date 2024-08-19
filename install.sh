#!/usr/bin/env bash
nva_version="1.2.0"

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31mError\033[0m: You don't have permission. Please run with sudo."
    exit 1
fi

clear
to_install=()

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

check_dependencies() {
    command_exists() {
        command -v "$1" &>/dev/null
    }

    local temp_to_install=()
    for cmd in awk grep uniq tar curl; do
        if ! command_exists "$cmd"; then
            temp_to_install+=("$cmd")
        fi
    done

    if ! dpkg -s bash-completion &>/dev/null; then
        temp_to_install+=("bash-completion")
    fi


    if [ ${#temp_to_install[@]} -ne 0 ]; then
        printf "%s\n" "${temp_to_install[@]}" > /tmp/to_install_list
    fi

    return 0
}

installing_dependencies(){
    local to_install=()

    mapfile -t to_install < /tmp/to_install_list
    apt-get update

    for pkg in "${to_install[@]}"; do
    if ! apt-get install -y "$pkg" >/dev/null 2>&1; then
        echo "Failed to install $pkg" >&2
        rm -f /tmp/to_install_list
        return 1
        fi
    done

    rm -f /tmp/to_install_list
    return 0
}

check_node() {
    if dpkg -s nodejs &> /dev/null; then
         echo "normal" >> /tmp/to_remove_list
        apt-get purge --auto-remove -y nodejs
    elif command -v node &>/dev/null; then
        echo "notnormal" >> /tmp/to_remove_list
    fi

    return 0
}

remove_node() {
    if [ -f /tmp/to_remove_list ]; then
        if grep -q "normal" /tmp/to_remove_list; then
            apt-get purge --auto-remove -y nodejs
        elif grep -q "notnormal" /tmp/to_remove_list; then
            if [ -d "$NVM_DIR" ]; then
                rm -rf "$NVM_DIR"
                for file in ~/.bash_profile ~/.profile ~/.bashrc; do
                    if [ -f "$file" ]; then
                        sed -i '/NVM_DIR/d' "$file"
                        sed -i '/nvm.sh/d' "$file"
                        sed -i '/bash_completion/d' "$file"
                    fi
                done
            elif [ -d "$HOME/.fnm" ]; then
                rm -rf "$HOME/.fnm"
                rm -rf "$HOME/.local/share/fnm"
                rm -rf "$HOME/Library/Application Support/fnm"

                for file in ~/.bash_profile ~/.profile ~/.bashrc; do
                    if [ -f "$file" ]; then
                        sed -i '/# fnm/d; /FNM_PATH/d; /fnm env/d' "$file"
                    fi
                done
            else
                for command_to_remove in node npm npx corepack; do
                    command_path=$(which "$command_to_remove" 2>/dev/null)
                    if [ -n "$command_path" ]; then
                        rm -f "$command_path"
                    fi
                done
            fi
          
        fi
        rm -f /tmp/to_remove_list
    fi

    return 0
}

installing_nva() {
    cd /opt/ && git clone https://github.com/Watchdog0x/nva.git

    if [ -d "/usr/share/bash-completion/completions" ]; then
        ln -rfs /opt/nva/nva_completion /usr/share/bash-completion/completions/nva
    else
        ln -rfs /opt/nva/nva_completion /etc/bash_completion.d/
    fi

    ln -rfs /opt/nva/nva /usr/local/bin/

    mkdir -p /opt/nva/nodejs
    
    rm -rf /opt/nva/.git
    rm -rf /opt/nva/docs
    rm -f /opt/nva/.gitignore
    rm -f /opt/nva/README.md
    rm -f /opt/nva/install.sh

    source ~/.bashrc

    return 0
}

main() { 
    if command -v nva &> /dev/null; then
        local installed_version=$(nva -v | grep Version | awk '{print $NF}' | tr -d '()' )
        if [[ $installed_version == "$nva_version" ]]; then
            printf "nva version \033[0;32mv%s\033[0m is already installed\n" "$nva_version"
            return 0
        fi
    fi
    printf "Installering nva \033[0;32mv%s\033[0m\n\n" "$nva_version"

    spinner "Checking dependencies" check_dependencies
    
    if [ -s /tmp/to_install_list ]; then
        mapfile -t to_install < /tmp/to_install_list
        spinner "Installing dependencies: ${to_install[*]}" installing_dependencies
    fi

    spinner "Checking node installed" check_node
    if [ -s /tmp/to_remove_list ]; then
         spinner "Removeing node" remove_node
    fi 


    spinner "Installing nva" installing_nva

    printf "\nInstallation completed successfully!\n"
}

main
