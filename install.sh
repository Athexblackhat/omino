#!/bin/bash
# ╔═╗╔╦╗╦╔╗╔╔═╗  ╔═╗╔═╗
# ║ ║║║║║║║║║ ║  ║  ║╣
# ╚═╝╩ ╩╩╝╚╝╚═╝  ╚═╝╚═╝
# Advanced Multi-distro Installer with Real-time Animations
# Created by ATHEX BLACK HAT 
# Rebranded & Animated Edition

set -e

# ═══════════════════════════════════════════════════════════════
# COLOR PALETTE & VISUAL EFFECTS
# ═══════════════════════════════════════════════════════════════
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
OKCYAN='\033[96m'
OKMAGENTA='\033[95m'
OKWHITE='\033[97m'
OKYELLOW='\033[33m'
RESET='\e[0m'
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'
REVERSE='\033[7m'
UNDERLINE='\033[4m'

# ═══════════════════════════════════════════════════════════════
# ANIMATION ENGINE
# ═══════════════════════════════════════════════════════════════
SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
SPINNER_FRAMES_ADV=('▁' '▂' '▃' '▄' '▅' '▆' '▇' '█' '▇' '▆' '▅' '▄' '▃' '▂' '▁')
PROGRESS_CHARS=('█' '▓' '▒' '░')
MATRIX_CHARS=('0' '1')
MATRIX_COLORS=('\033[32m' '\033[92m' '\033[36m')

# Terminal dimensions
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
TERM_HEIGHT=$(tput lines 2>/dev/null || echo 24)

# Animation state
ANIMATION_PID=""
CLEANUP_DONE=false

center_text() {
    local text="$1"
    local width=${2:-$TERM_WIDTH}
    local text_length=${#text}
    local padding=$(( (width - text_length) / 2 ))
    [[ $padding -lt 0 ]] && padding=0
    printf "%${padding}s" ""
}

hide_cursor() {
    printf "\e[?25l"
}

show_cursor() {
    printf "\e[?25h"
}

save_cursor() {
    printf "\e[s"
}

restore_cursor() {
    printf "\e[u"
}

move_cursor() {
    local row=$1
    local col=$2
    printf "\e[${row};${col}H"
}

clear_line() {
    printf "\e[2K"
}

clear_screen() {
    printf "\e[2J\e[H"
}


matrix_rain() {
    local duration=${1:-3}
    local cols=()
    local lines=()
    
    # Initialize columns
    for ((i=0; i<TERM_WIDTH; i+=2)); do
        cols+=($i)
        lines+=(0)
    done
    
    local end_time=$(($(date +%s) + duration))
    
    while [[ $(date +%s) -lt $end_time ]]; do
        for idx in "${!cols[@]}"; do
            local col=${cols[$idx]}
            local line=${lines[$idx]}
            
            # Random character
            local char=${MATRIX_CHARS[$((RANDOM % 2))]}
            local color=${MATRIX_COLORS[$((RANDOM % 3))]}
            
            move_cursor $((line + 1)) $((col + 1))
            printf "${color}${char}${RESET}"
            
            # Move line down
            lines[$idx]=$((line + 1))
            
            # Reset if reached bottom
            if [[ ${lines[$idx]} -gt $TERM_HEIGHT ]]; then
                lines[$idx]=0
            fi
        done
        sleep 0.05
    done
}

# Spinning loader animation
spinner() {
    local message="$1"
    local pid=$2
    local frame=0
    local color=${3:-$OKCYAN}
    
    while kill -0 $pid 2>/dev/null; do
        local spin_char=${SPINNER_FRAMES[$frame]}
        printf "\r\033[K  ${color}${spin_char}${RESET} ${message}"
        frame=$(( (frame + 1) % ${#SPINNER_FRAMES[@]} ))
        sleep 0.1
    done
    printf "\r\033[K  ${OKGREEN}✓${RESET} ${message}\n"
}

# Progress bar with percentage
progress_bar() {
    local current=$1
    local total=$2
    local message=${3:-"Progress"}
    local bar_width=40
    local filled=$(( current * bar_width / total ))
    local empty=$(( bar_width - filled ))
    local percentage=$(( current * 100 / total ))
    
    printf "\r  ${OKCYAN}[${RESET}"
    
    # Filled portion with gradient
    for ((i=0; i<filled; i++)); do
        if [[ $i -lt $((bar_width / 3)) ]]; then
            printf "${OKGREEN}▓${RESET}"
        elif [[ $i -lt $((bar_width * 2 / 3)) ]]; then
            printf "${OKCYAN}▓${RESET}"
        else
            printf "${OKBLUE}▓${RESET}"
        fi
    done
    
    # Empty portion
    for ((i=0; i<empty; i++)); do
        printf "${DIM}░${RESET}"
    done
    
    printf "${OKCYAN}]${RESET} ${percentage}%% ${message}"
}

# Pulse effect
pulse_effect() {
    local text="$1"
    local color="$2"
    local duration=${3:-2}
    local end_time=$(($(date +%s) + duration))
    
    while [[ $(date +%s) -lt $end_time ]]; do
        printf "\r${color}${BOLD}${text}${RESET}"
        sleep 0.2
        printf "\r${color}${DIM}${text}${RESET}"
        sleep 0.2
    done
    printf "\r${color}${BOLD}${text}${RESET}\n"
}

# Typing effect
type_text() {
    local text="$1"
    local delay=${2:-0.03}
    local color=${3:-$OKWHITE}
    
    printf "${color}"
    for ((i=0; i<${#text}; i++)); do
        printf "${text:$i:1}"
        sleep $delay
    done
    printf "${RESET}\n"
}

# Explosion effect
explosion_effect() {
    local frames=(
        "     .     "
        "    . .    "
        "   .   .   "
        "  .     .  "
        " .       . "
        "***********"
        " ********* "
        "  *******  "
        "   *****   "
        "    ***    "
        "     *     "
    )
    
    save_cursor
    for frame in "${frames[@]}"; do
        restore_cursor
        printf "${OKORANGE}${frame}${RESET}"
        sleep 0.1
    done
}

display_banner() {
    clear_screen
    hide_cursor
    
    local logo_lines=(
        ""
        ""
        "${BOLD}${OKRED}    ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ ${RESET}"
        "${BOLD}${OKRED}   ██╔═══██╗████╗ ████║██║████╗  ██║██╔═══██╗${RESET}"
        "${BOLD}${OKRED}   ██║   ██║██╔████╔██║██║██╔██╗ ██║██║   ██║${RESET}"
        "${BOLD}${OKRED}   ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║${RESET}"
        "${BOLD}${OKRED}   ╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝${RESET}"
        "${BOLD}${OKRED}    ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ${RESET}"
        "${BOLD}${OKRED}   CREATED BY ATHEX BLACK HAT & DIR CYBER    ${RESET}"
        ""
        "${OKCYAN}${RESET}${BOLD}${OKORANGE}ADVANCED SECURITY RECONNAISSANCE SUITE${RESET}     ${OKCYAN}${RESET}"
        ""
        "${DIM} Powered by AI | Multi-Distro Support | Auto-Dependency Resolution${RESET}"
        ""
        "${OKMAGENTA} ⚡ ${OKYELLOW}OMINO ${OKMAGENTA}⚡${OKCYAN}- The Eye That Sees All${RESET}"
        "${OKMAGENTA} ⚡ ${OKYELLOW}BLACK HAT EDITION ${OKMAGENTA}⚡ ${OKRED}- For Authorized Use Only${RESET}"
        ""
    )
    
    # Animate the banner
    for i in "${!logo_lines[@]}"; do
        if [[ $i -eq 0 ]]; then
  
            matrix_rain 2 &
            local matrix_pid=$!
            wait $matrix_pid 2>/dev/null
            clear_screen
        fi
        printf "%s\n" "${logo_lines[$i]}"
        sleep 0.1
    done
    
    for ((i=0; i<3; i++)); do
        printf "\r\033[3A"
        printf "${BOLD}${OKRED}    ██╗  ██╗ █████╗  ██████╗██╗  ██╗██╗███╗   ██╗ ██████╗ ${RESET}\n"
        sleep 0.05
        printf "\r\033[2A"
        printf "${BOLD}${OKRED}    ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ ${RESET}\n"
        sleep 0.05
    done
    
    echo ""
    echo ""
}


section_header() {
    local title="$1"
    local icon="$2"
    local color="$3"
    local width=$((TERM_WIDTH - 4))
    
    echo ""
    printf "${color}${BOLD}  ╔"
    for ((i=0; i<width; i++)); do printf "═"; done
    printf "╗${RESET}\n"
    
    printf "${color}${BOLD}  ║${RESET} ${icon} ${BOLD}${title}${RESET}"
    # Fill rest of line
    local title_len=$(( ${#title} + ${#icon} + 2 ))
    local spaces=$((width - title_len))
    for ((i=0; i<spaces; i++)); do printf " "; done
    printf "${color}${BOLD}║${RESET}\n"
    
    printf "${color}${BOLD}  ╚"
    for ((i=0; i<width; i++)); do printf "═"; done
    printf "╝${RESET}\n"
    echo ""
}

display_system_info() {
    local os_name=""
    local kernel=""
    local arch=""
    local cpu=""
    local ram=""
    
    case "$(uname -s)" in
        Linux*)   os_name="🐧 Linux" ;;
        Darwin*)  os_name="🍎 macOS" ;;
        *)        os_name="💻 Unknown" ;;
    esac
    
    kernel=$(uname -r)
    arch=$(uname -m)
    
    if command -v nproc &>/dev/null; then
        cpu="$(nproc) cores"
    else
        cpu="Unknown"
    fi
    
    if command -v free &>/dev/null; then
        ram=$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}')
    else
        ram="Unknown"
    fi
    
    printf "${OKCYAN} ${RESET}\n"
    printf "${OKCYAN} ${OKORANGE}SYSTEM INFORMATION${RESET}                                       ${OKCYAN}${RESET}\n"
    printf "${OKCYAN} ${RESET}\n"
    printf "${OKCYAN} ${OKWHITE}OS${RESET}      : ${OKGREEN}%-47s${OKCYAN}${RESET}\n" "$os_name"
    printf "${OKCYAN} ${OKWHITE}Kernel${RESET}  : ${OKGREEN}%-47s${OKCYAN}${RESET}\n" "$kernel"
    printf "${OKCYAN} ${OKWHITE}Arch${RESET}    : ${OKGREEN}%-47s${OKCYAN}${RESET}\n" "$arch"
    printf "${OKCYAN} ${OKWHITE}CPU${RESET}     : ${OKGREEN}%-47s${OKCYAN}${RESET}\n" "$cpu"
    printf "${OKCYAN} ${OKWHITE}RAM${RESET}     : ${OKGREEN}%-47s${OKCYAN}${RESET}\n" "$ram"
    printf "${OKCYAN} ${OKWHITE}Shell${RESET}   : ${OKGREEN}%-47s${OKCYAN}${RESET}\n" "$SHELL"
    printf "${OKCYAN} ${RESET}\n"
    echo ""
}


# Animated confirmation
confirm_installation() {
    echo ""
    type_text "  🎯 Ready to transform your system into a powerful security platform?" 0.02 "$OKCYAN"
    echo ""
    printf "${OKRED}${BOLD}"
    pulse_effect "  ⚠️  This will install OMINO under $INSTALL_DIR. Continue?" "$OKRED" 2
    printf "${RESET}"
    echo ""
    printf "  ${OKWHITE}[${OKGREEN}Y${OKWHITE}/${OKRED}N${OKWHITE}] ${OKCYAN}➜${RESET} "
    read -r answer
    if [[ "$answer" != "y" ]] && [[ "$answer" != "Y" ]]; then
        echo ""
        type_text "  ❌ Installation cancelled. Goodbye!" 0.03 "$OKRED"
        show_cursor
        exit 0
    fi
}

# Animated step execution
animated_step() {
    local step_name="$1"
    local step_color="$2"
    shift 2
    local cmd=("$@")
    
    printf "  ${step_color}▶${RESET} ${OKWHITE}${step_name}${RESET} "
    
    # Run command in background
    ("${cmd[@]}" 2>/dev/null || true) &
    local cmd_pid=$!
    
    # Show spinner
    local frame=0
    while kill -0 $cmd_pid 2>/dev/null; do
        local spin_char=${SPINNER_FRAMES[$frame]}
        printf "\r  ${step_color}${spin_char}${RESET} ${OKWHITE}${step_name}${RESET}"
        frame=$(( (frame + 1) % ${#SPINNER_FRAMES[@]} ))
        sleep 0.1
    done
    
    wait $cmd_pid
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        printf "\r  ${OKGREEN}✓${RESET} ${OKWHITE}${step_name}${RESET} ${OKGREEN}Complete${RESET}\n"
    else
        printf "\r  ${OKRED}✗${RESET} ${OKWHITE}${step_name}${RESET} ${OKORANGE}(may need attention)${RESET}\n"
    fi
}

# Multi-step installation with progress
multi_step_install() {
    local title="$1"
    shift
    local steps=("$@")
    local total=${#steps[@]}
    local current=0
    
    section_header "$title" "🔧" "$OKMAGENTA"
    
    for step in "${steps[@]}"; do
        current=$((current + 1))
        progress_bar $current $total "$step"
        echo ""
        sleep 0.2
    done
    echo ""
}


pkg_install_animated() {
    local packages=("$@")
    local total=${#packages[@]}
    
    if [[ $total -eq 0 ]]; then
        return
    fi
    
    printf "  ${OKCYAN}📦${RESET} Installing ${OKYELLOW}%d${RESET} packages...\n" "$total"
    echo ""
    
    local count=0
    for pkg in "${packages[@]}"; do
        count=$((count + 1))
        
        # Show package name with progress
        printf "  ${OKBLUE}[%3d/%3d]${RESET} ${OKWHITE}%-40s${RESET}" "$count" "$total" "$pkg"
        
        # Install package
        case "$OS" in
            debian)
                apt install -y "$pkg" &>/dev/null &
                ;;
            rhel)
                $PKG_MANAGER install -y "$pkg" &>/dev/null &
                ;;
            arch)
                pacman -S --noconfirm --needed "$pkg" &>/dev/null &
                ;;
            macos)
                brew install "$pkg" &>/dev/null &
                ;;
        esac
        local pid=$!
        
        local dots=0
        while kill -0 $pid 2>/dev/null; do
            case $dots in
                0) printf "\r  ${OKBLUE}[%3d/%3d]${RESET} ${OKWHITE}%-40s${RESET} ${OKCYAN}.  ${RESET}" "$count" "$total" "$pkg" ;;
                1) printf "\r  ${OKBLUE}[%3d/%3d]${RESET} ${OKWHITE}%-40s${RESET} ${OKCYAN}.. ${RESET}" "$count" "$total" "$pkg" ;;
                2) printf "\r  ${OKBLUE}[%3d/%3d]${RESET} ${OKWHITE}%-40s${RESET} ${OKCYAN}...${RESET}" "$count" "$total" "$pkg" ;;
            esac
            dots=$(( (dots + 1) % 3 ))
            sleep 0.3
        done
        
        wait $pid
        if [[ $? -eq 0 ]]; then
            printf "\r  ${OKBLUE}[%3d/%3d]${RESET} ${OKWHITE}%-40s${RESET} ${OKGREEN}✓${RESET}\n" "$count" "$total" "$pkg"
        else
            printf "\r  ${OKBLUE}[%3d/%3d]${RESET} ${OKWHITE}%-40s${RESET} ${OKORANGE}⚠${RESET}\n" "$count" "$total" "$pkg"
        fi
    done
    echo ""
}


display_file_tree() {
    local dir="$1"
    local prefix="$2"
    
    printf "${DIM}"
    printf "${prefix}├── ${OKGREEN}%s${RESET}\n" "$(basename "$dir")"
    
    local items=("$dir"/*)
    local count=${#items[@]}
    local i=0
    
    for item in "${items[@]}"; do
        i=$((i + 1))
        local new_prefix="${prefix}│   "
        
        if [[ $i -eq $count ]]; then
            new_prefix="${prefix}└── "
        fi
        
        if [[ -d "$item" ]]; then
            printf "${new_prefix}${OKBLUE}%s/${RESET}\n" "$(basename "$item")"
        else
            printf "${new_prefix}${OKWHITE}%s${RESET}\n" "$(basename "$item")"
        fi
    done
    printf "${RESET}"
}


display_completion() {
    clear_screen
    
    local colors=("$OKRED" "$OKORANGE" "$OKYELLOW" "$OKGREEN" "$OKCYAN" "$OKBLUE" "$OKMAGENTA")
    
    for ((i=0; i<5; i++)); do
        clear_screen
        local color=${colors[$((RANDOM % 7))]}
        
        echo ""
        echo ""
        echo ""
        echo -e "${color}${BOLD}"
        echo "                                                          "
        echo "         ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗        "
        echo "        ██╔═══██╗████╗ ████║██║████╗  ██║██╔═══██╗       "
        echo "        ██║   ██║██╔████╔██║██║██╔██╗ ██║██║   ██║       "
        echo "        ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║       "
        echo "        ╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝       "
        echo "         ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝        "
        echo "                                                          "
        echo "                INSTALLATION COMPLETE!                   "
        echo "    "
        echo -e "${RESET}"
        
        sleep 0.15
    done
    
    clear_screen
    
    # Final display
    echo ""
    echo -e "${OKGREEN}${BOLD}"
    echo "                                                         "
    echo "         ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗        "
    echo "        ██╔═══██╗████╗ ████║██║████╗  ██║██╔═══██╗       "
    echo "        ██║   ██║██╔████╔██║██║██╔██╗ ██║██║   ██║       "
    echo "        ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║       "
    echo "        ╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝       "
    echo "         ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝        "
    echo "                                                         "
    echo "                 INSTALLATION COMPLETE!                  "
    echo "    "
    echo -e "${RESET}"
    echo ""
    
    # Stats display
    printf "${OKCYAN}  ${RESET}\n"
    printf "${OKCYAN}  ${OKORANGE}INSTALLATION SUMMARY${RESET}                                   ${OKCYAN}${RESET}\n"
    printf "${OKCYAN}  ${RESET}\n"
    printf "${OKCYAN}  ${OKWHITE}Install Directory  :${RESET} ${OKGREEN}%-40s${OKCYAN}${RESET}\n" "$INSTALL_DIR"
    printf "${OKCYAN}  ${OKWHITE}Loot Directory     :${RESET} ${OKGREEN}%-40s${OKCYAN}${RESET}\n" "$LOOT_DIR"
    printf "${OKCYAN}  ${OKWHITE}OS Detected        :${RESET} ${OKGREEN}%-40s${OKCYAN}${RESET}\n" "$OS"
    printf "${OKCYAN}  ${OKWHITE}Package Manager    :${RESET} ${OKGREEN}%-40s${OKCYAN}${RESET}\n" "$PKG_MANAGER"
    printf "${OKCYAN}  ${RESET}\n"
    echo ""
    
    type_text "   To launch OMINO, type: ${BOLD}${OKYELLOW}omino${RESET}" 0.03 "$OKWHITE"
    echo ""
    
    # Easter egg - matrix effect on exit
    echo ""
    printf "  ${OKMAGENTA}The Eye Sees All...${RESET}\n"
    sleep 1
}


detect_os() {
    section_header "System Detection" "🔍" "$OKCYAN"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        echo -e "  ${OKGREEN}✓${RESET} Detected: ${BOLD}macOS${RESET}"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|kali|parrot)
                OS="debian"
                PKG_MANAGER="apt"
                echo -e "  ${OKGREEN}✓${RESET} Detected: ${BOLD}${PRETTY_NAME}${RESET} ${DIM}(Debian-based)${RESET}"
                ;;
            rhel|centos|fedora|rocky|alma|amzn)
                OS="rhel"
                PKG_MANAGER=$(command -v dnf &>/dev/null && echo "dnf" || echo "yum")
                echo -e "  ${OKGREEN}✓${RESET} Detected: ${BOLD}${PRETTY_NAME}${RESET} ${DIM}(RHEL-based)${RESET}"
                ;;
            arch|manjaro|endeavouros)
                OS="arch"
                PKG_MANAGER="pacman"
                echo -e "  ${OKGREEN}✓${RESET} Detected: ${BOLD}${PRETTY_NAME}${RESET} ${DIM}(Arch-based)${RESET}"
                ;;
            opensuse*|sles)
                OS="opensuse"
                PKG_MANAGER="zypper"
                echo -e "  ${OKGREEN}✓${RESET} Detected: ${BOLD}${PRETTY_NAME}${RESET} ${DIM}(openSUSE-based)${RESET}"
                ;;
            *)
                echo -e "  ${OKRED}✗${RESET} Unsupported distribution: $ID"
                exit 1
                ;;
        esac
    fi
    
    display_system_info
    sleep 1
}


main() {
    # Setup cleanup trap
    trap 'show_cursor; [[ $CLEANUP_DONE == false ]] && cleanup' EXIT INT TERM
    
    # Display banner
    display_banner
    
    # Installation directories
    INSTALL_DIR=/usr/share/omino
    LOOT_DIR=/usr/share/omino/loot
    PLUGINS_DIR=/usr/share/omino/plugins
    GO_DIR=~/go/bin
    
    # Show confirmation
    confirm_installation
    
    # OS Detection with animation
    detect_os
    
    # Phase 1: Directory Structure
    section_header "Phase 1: Directory Structure" "📁" "$OKBLUE"
    animated_step "Creating OMINO directories..." "$OKBLUE" \
        mkdir -p "$INSTALL_DIR" "$LOOT_DIR" "$PLUGINS_DIR" "$GO_DIR" \
        "$LOOT_DIR/domains" "$LOOT_DIR/screenshots" "$LOOT_DIR/nmap" \
        "$LOOT_DIR/reports" "$LOOT_DIR/output" "$LOOT_DIR/osint" \
        "$LOOT_DIR/workspaces"
    
    echo -e "  ${DIM}Directory tree:${RESET}"
    display_file_tree "$INSTALL_DIR" "  "
    sleep 1
    
    # Phase 2: Package Updates
    section_header "Phase 2: System Updates" "🔄" "$OKCYAN"
    animated_step "Updating package repositories..." "$OKCYAN" \
        $PKG_MANAGER update -y 2>/dev/null || $PKG_MANAGER update 2>/dev/null
    
    # Phase 3: Core Dependencies
    section_header "Phase 3: Core Dependencies" "📦" "$OKMAGENTA"
    
    local core_packages=(
        git curl wget sudo gpg
        nmap whois dnsutils
        python3 python3-pip
        ruby golang nodejs npm
        php jq aha xmlstarlet
        dos2unix net-tools
        p7zip-full openssl
    )
    
    pkg_install_animated "${core_packages[@]}"
    
    # Phase 4: Security Tools
    section_header "Phase 4: Security Arsenal" "🛡️" "$OKRED"
    
    local security_packages=(
        nikto sqlmap hydra
        dnsrecon whatweb wafw00f
        sslscan nbtscan
        enum4linux
    )
    
    pkg_install_animated "${security_packages[@]}" 2>/dev/null || true
    
    # Phase 5: Language Environments
    section_header "Phase 5: Language Environments" "🐍" "$OKGREEN"
    
    animated_step "Configuring Python environment..." "$OKGREEN" \
        pip3 install --upgrade pip dnspython colorama tldextract urllib3 \
        ipaddress requests --break-system-packages 2>/dev/null || pip3 install --upgrade pip dnspython colorama tldextract urllib3 ipaddress requests 2>/dev/null
    
    animated_step "Configuring Ruby environment..." "$OKRED" \
        gem install rake ruby-nmap net-http-persistent mechanize text-table public_suffix 2>/dev/null
    
    animated_step "Configuring Go environment..." "$OKCYAN" \
        mkdir -p "$GO_DIR"
    
    # Phase 6: OMINO Core Files
    section_header "Phase 6: OMINO Core" "⚡" "$OKORANGE"
    animated_step "Installing OMINO files..." "$OKORANGE" \
        cp -Rf ./* "$INSTALL_DIR/" 2>/dev/null
    
    animated_step "Setting permissions..." "$OKORANGE" \
        chmod +x "$INSTALL_DIR/omino" 2>/dev/null
    
    # Phase 7: Metasploit Integration
    section_header "Phase 7: Metasploit Framework" "💣" "$OKRED"
    animated_step "Checking Metasploit..." "$OKRED" \
        command -v msfconsole &>/dev/null || curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall 2>/dev/null && chmod 755 /tmp/msfinstall && /tmp/msfinstall 2>/dev/null
    
    # Phase 8: Go Tools Installation
    section_header "Phase 8: Advanced Go Tools" "🔬" "$OKCYAN"
    
    local go_tools=(
        "nuclei:github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
        "subfinder:github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        "httpx:github.com/projectdiscovery/httpx@latest"
        "amass:github.com/OWASP/Amass/v3/...@master"
        "ffuf:github.com/ffuf/ffuf@latest"
        "gau:github.com/lc/gau@latest"
    )
    
    for tool_info in "${go_tools[@]}"; do
        IFS=':' read -r tool_name tool_path <<< "$tool_info"
        animated_step "Installing $tool_name..." "$OKCYAN" \
            GO111MODULE=on go install -v "$tool_path" 2>/dev/null
    done
    
    # Update nuclei templates
    animated_step "Updating Nuclei templates..." "$OKCYAN" \
        nuclei -update-templates 2>/dev/null || nuclei --update 2>/dev/null
    
    # Phase 9: Python Arsenal
    section_header "Phase 9: Python Arsenal" "🐍" "$OKGREEN"
    
    local python_tools=(
        "Sublist3r:https://github.com/Athexblackhat/Sublist3r.git"
        "DirSearch:https://github.com/maurosoria/dirsearch.git"
        "GitGraber:https://github.com/hisxo/gitGraber.git"
        "LinkFinder:https://github.com/Athexblackhat/LinkFinder.git"
        "MassDNS:https://github.com/blechschmidt/massdns.git"
        "CMSMap:https://github.com/Dionach/CMSmap.git"
    )
    
    cd "$PLUGINS_DIR" || return
    for tool_info in "${python_tools[@]}"; do
        IFS=':' read -r tool_name tool_url <<< "$tool_info"
        local tool_dir=$(echo "$tool_name" | tr '[:upper:]' '[:lower:]')
        if [[ ! -d "$tool_dir" ]]; then
            animated_step "Cloning $tool_name..." "$OKGREEN" \
                git clone "$tool_url" "$tool_dir" 2>/dev/null
        fi
    done

    section_header "Phase 10: System Integration" "🔗" "$OKMAGENTA"
    
    animated_step "Creating OMINO symlink..." "$OKMAGENTA" \
        ln -fs "$INSTALL_DIR/omino" /usr/local/bin/omino 2>/dev/null || ln -fs "$INSTALL_DIR/omino" /usr/bin/omino 2>/dev/null
    
    animated_step "Creating workspace links..." "$OKMAGENTA" \
        ln -fs "$LOOT_DIR/workspaces" /workspace 2>/dev/null
    
    section_header "Phase 11: Configuration" "⚙️" "$OKBLUE"
    
    if [[ "$OS" != "macos" ]]; then
        animated_step "Setting up configuration files..." "$OKBLUE" \
            cp -f "$INSTALL_DIR/omino.conf" /root/.omino.conf 2>/dev/null
    fi
    
    # Cleanup
    section_header "Finalizing" "🧹" "$DIM"
    animated_step "Cleaning temporary files..." "$DIM" \
        rm -rf /tmp/msfinstall /tmp/arachni* /tmp/gobuster* 2>/dev/null
    
    CLEANUP_DONE=true
    
    display_completion
    
    show_cursor
}


if [[ "$1" == "force" ]] || [[ "$1" == "-y" ]] || [[ "$1" == "--yes" ]]; then
    FORCE_MODE=true
fi

main "$@"