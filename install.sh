#!/bin/bash
# ╔═╗╔╦╗╦╔╗╔╔═╗  ╔═╗╔═╗
# ║ ║║║║║║║║║ ║  ║  ║╣  
# ╚═╝╩ ╩╩╝╚╝╚═╝  ╚═╝╚═╝
# Advanced Multi-distro Installer with Real-time Animations
# Created by ATHEX BLACK HAT × DIR CYBER
# Rebranded & Animated Edition

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
MATRIX_CHARS=('0' '1' '7' 'A' 'F' '3' '9' 'C')
MATRIX_COLORS=('\033[32m' '\033[92m' '\033[36m' '\033[91m')

# Terminal dimensions
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
TERM_HEIGHT=$(tput lines 2>/dev/null || echo 24)

# Animation state
ANIMATION_PID=""
CLEANUP_DONE=false
OS=""
PKG_MANAGER=""

# ═══════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════
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

# ═══════════════════════════════════════════════════════════════
# ADVANCED ANIMATIONS
# ═══════════════════════════════════════════════════════════════

# Matrix rain effect
matrix_rain() {
    local duration=${1:-2}
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
            local char=${MATRIX_CHARS[$((RANDOM % ${#MATRIX_CHARS[@]}))]}
            local color=${MATRIX_COLORS[$((RANDOM % ${#MATRIX_COLORS[@]}))]}
            
            if [[ $line -lt $TERM_HEIGHT ]] && [[ $col -lt $TERM_WIDTH ]]; then
                move_cursor $((line + 1)) $((col + 1))
                printf "${color}${char}${RESET}"
            fi
            
            # Move line down
            lines[$idx]=$((line + 1))
            
            # Reset if reached bottom
            if [[ ${lines[$idx]} -gt $TERM_HEIGHT ]]; then
                lines[$idx]=0
            fi
        done
        sleep 0.03
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
    
    # Avoid division by zero
    if [[ $total -eq 0 ]]; then
        total=1
    fi
    
    local filled=$(( current * bar_width / total ))
    local empty=$(( bar_width - filled ))
    local percentage=$(( current * 100 / total ))
    
    printf "\r  ${OKCYAN}[${RESET}"
    
    for ((i=0; i<filled; i++)); do
        if [[ $i -lt $((bar_width / 3)) ]]; then
            printf "${OKGREEN}▓${RESET}"
        elif [[ $i -lt $((bar_width * 2 / 3)) ]]; then
            printf "${OKCYAN}▓${RESET}"
        else
            printf "${OKBLUE}▓${RESET}"
        fi
    done
    
    for ((i=0; i<empty; i++)); do
        printf "${DIM}░${RESET}"
    done
    
    printf "${OKCYAN}]${RESET} %3d%% %s" "$percentage" "$message"
}

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

type_text() {
    local text="$1"
    local delay=${2:-0.02}
    local color=${3:-$OKWHITE}
    
    printf "${color}"
    for ((i=0; i<${#text}; i++)); do
        printf "${text:$i:1}"
        sleep $delay
    done
    printf "${RESET}\n"
}

display_banner() {
    clear_screen
    hide_cursor
    
    # Simple matrix effect
    matrix_rain 2 &
    local matrix_pid=$!
    wait $matrix_pid 2>/dev/null
    clear_screen
    
    echo ""
    echo ""
    echo -e "${BOLD}${OKRED}    ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ ${RESET}"
    echo -e "${BOLD}${OKRED}   ██╔═══██╗████╗ ████║██║████╗  ██║██╔═══██╗${RESET}"
    echo -e "${BOLD}${OKRED}   ██║   ██║██╔████╔██║██║██╔██╗ ██║██║   ██║${RESET}"
    echo -e "${BOLD}${OKRED}   ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║${RESET}"
    echo -e "${BOLD}${OKRED}   ╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝${RESET}"
    echo -e "${BOLD}${OKRED}    ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ${RESET}"
    echo ""
    echo -e "${OKCYAN}  ${RESET}   ${BOLD}${OKORANGE}ADVANCED SECURITY RECONNAISSANCE SUITE${RESET}     ${OKCYAN}${RESET}"
    echo -e "${OKCYAN}  ${RESET}   ${BOLD}${OKRED}CREATED BY ATHEX BLACK HAT × DIR CYBER${RESET}      ${OKCYAN}${RESET}"
    echo ""
    echo -e "${DIM}  Powered by AI | Multi-Distro Support | Auto-Dependency Resolution${RESET}"
    echo ""
    echo -e "${OKMAGENTA}  ⚡ ${OKYELLOW}OMINO ${OKMAGENTA}⚡ ${OKCYAN}- The Eye That Sees All${RESET}"
    echo -e "${OKMAGENTA}  ⚡ ${OKYELLOW}BLACK HAT EDITION ${OKMAGENTA}⚡ ${OKRED}- For Authorized Use Only${RESET}"
    echo ""
    echo ""
}

section_header() {
    local title="$1"
    local icon="$2"
    local color="$3"
    local width=50
    
    echo ""
    printf "${color}${BOLD}  ╔"
    for ((i=0; i<width; i++)); do printf "═"; done
    printf "╗${RESET}\n"
    
    printf "${color}${BOLD}  ║${RESET} ${icon} ${BOLD}${title}${RESET}\n"
    
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
    
    echo ""

    echo -e "${OKCYAN}    ${OKORANGE}${BOLD}SYSTEM INFORMATION${RESET}                            ${OKCYAN}${RESET}"
    printf "${OKCYAN}  ${RESET}  ${OKWHITE}OS      :${RESET} ${OKGREEN}%-36s${OKCYAN}${RESET}\n" "$os_name"
    printf "${OKCYAN}  ${RESET}  ${OKWHITE}Kernel  :${RESET} ${OKGREEN}%-36s${OKCYAN}${RESET}\n" "$kernel"
    printf "${OKCYAN}  ${RESET}  ${OKWHITE}Arch    :${RESET} ${OKGREEN}%-36s${OKCYAN}${RESET}\n" "$arch"
    printf "${OKCYAN}  ${RESET}  ${OKWHITE}CPU     :${RESET} ${OKGREEN}%-36s${OKCYAN}${RESET}\n" "$cpu"
    printf "${OKCYAN}  ${RESET}  ${OKWHITE}RAM     :${RESET} ${OKGREEN}%-36s${OKCYAN}${RESET}\n" "$ram"
    printf "${OKCYAN}  ${RESET}  ${OKWHITE}Shell   :${RESET} ${OKGREEN}%-36s${OKCYAN}${RESET}\n" "$SHELL"
    echo -e "${OKCYAN}  ${RESET}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# ANIMATED CONFIRMATION
# ═══════════════════════════════════════════════════════════════
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
        
        # Install package based on OS
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
            opensuse)
                zypper install -y "$pkg" &>/dev/null &
                ;;
            macos)
                brew install "$pkg" &>/dev/null &
                ;;
            *)
                # Fallback - try apt
                apt install -y "$pkg" &>/dev/null &
                ;;
        esac
        local pid=$!
        
        # Animated dots while installing
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

display_completion() {
    clear_screen
    
    # Quick celebration
    echo ""
    echo ""
    echo ""
    echo -e "${OKGREEN}${BOLD}"
    echo "         ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗        "
    echo "        ██╔═══██╗████╗ ████║██║████╗  ██║██╔═══██╗       "
    echo "        ██║   ██║██╔████╔██║██║██╔██╗ ██║██║   ██║       "
    echo "        ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║       "
    echo "        ╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝       "
    echo "         ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝        "
    echo ""
    echo "              ✅ INSTALLATION COMPLETE!"
    echo ""
    echo -e "${RESET}"
    echo ""
    
    # Summary
    echo -e "${OKCYAN}    ${OKORANGE}${BOLD}INSTALLATION SUMMARY${RESET}                         ${OKCYAN}║${RESET}"
    echo -e "${OKCYAN}  ${RESET}"
    printf "${OKCYAN}  ${RESET}  Install Directory : ${OKGREEN}%-26s${OKCYAN}${RESET}\n" "$INSTALL_DIR"
    printf "${OKCYAN}  ${RESET}  Loot Directory    : ${OKGREEN}%-26s${OKCYAN}${RESET}\n" "$LOOT_DIR"
    printf "${OKCYAN}  ${RESET}  OS Detected       : ${OKGREEN}%-26s${OKCYAN}${RESET}\n" "$OS"
    printf "${OKCYAN}  ${RESET}  Package Manager   : ${OKGREEN}%-26s${OKCYAN}${RESET}\n" "$PKG_MANAGER"
    echo -e "${OKCYAN}  ${RESET}"
    echo ""
    
    echo -e "${OKYELLOW}${BOLD}  To launch OMINO, type: sudo omino${RESET}"
    echo ""
    echo -e "  ${OKMAGENTA}🜛 The Eye Sees All...${RESET}"
    echo ""
    echo -e "  ${DIM}Developed by ATHEX BLACK HAT × DIR CYBER${RESET}"
    echo ""
    sleep 1
}

# ═══════════════════════════════════════════════════════════════
# OS DETECTION
# ═══════════════════════════════════════════════════════════════
detect_os() {
    section_header "System Detection" "🔍" "$OKCYAN"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
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
                echo -e "  ${OKYELLOW}Attempting to continue with apt...${RESET}"
                OS="debian"
                PKG_MANAGER="apt"
                ;;
        esac
    else
        echo -e "  ${OKORANGE}⚠${RESET} Unable to detect OS. Trying to continue..."
        OS="debian"
        PKG_MANAGER="apt"
    fi
    
    display_system_info
    sleep 1
}

# ═══════════════════════════════════════════════════════════════
# MAIN INSTALLATION
# ═══════════════════════════════════════════════════════════════
main() {
    # Setup cleanup trap
    trap 'show_cursor' EXIT INT TERM
    
    # Installation directories
    INSTALL_DIR=/usr/share/omino
    LOOT_DIR=/usr/share/omino/loot
    PLUGINS_DIR=/usr/share/omino/plugins
    GO_DIR=~/go/bin
    
    # Display banner
    display_banner
    
    # Check root
    if [[ "$OS" != "macos" ]] && [[ $EUID -ne 0 ]]; then
        echo -e "${OKRED}[!] This script must be run as root on Linux systems${RESET}"
        echo -e "${OKRED}[!] Please run: sudo bash install.sh${RESET}"
        show_cursor
        exit 1
    fi
    
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
    
    # Phase 2: Package Updates
    section_header "Phase 2: System Updates" "🔄" "$OKCYAN"
    animated_step "Updating package repositories..." "$OKCYAN" \
        $PKG_MANAGER update -y 2>/dev/null || $PKG_MANAGER update 2>/dev/null || true
    
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
        pip3 install --upgrade pip dnspython colorama tldextract urllib3 ipaddress requests 2>/dev/null --break-system-packages 2>/dev/null || pip3 install --upgrade pip dnspython colorama tldextract urllib3 ipaddress requests 2>/dev/null || true
    
    animated_step "Configuring Ruby environment..." "$OKRED" \
        gem install rake ruby-nmap net-http-persistent mechanize text-table public_suffix 2>/dev/null || true
    
    animated_step "Configuring Go environment..." "$OKCYAN" \
        mkdir -p "$GO_DIR"
    
    # Phase 6: OMINO Core Files
    section_header "Phase 6: OMINO Core" "⚡" "$OKORANGE"
    animated_step "Installing OMINO files..." "$OKORANGE" \
        cp -Rf ./* "$INSTALL_DIR/" 2>/dev/null || true
    
    animated_step "Setting permissions..." "$OKORANGE" \
        chmod +x "$INSTALL_DIR/omino.sh" 2>/dev/null || chmod +x "$INSTALL_DIR/omino" 2>/dev/null || true
    
    # Phase 7: Metasploit Integration (optional)
    section_header "Phase 7: Metasploit Framework" "💣" "$OKRED"
    animated_step "Checking Metasploit..." "$OKRED" \
        command -v msfconsole &>/dev/null || true
    
    # Phase 8: Go Tools (optional - may fail, that's ok)
    section_header "Phase 8: Advanced Go Tools" "🔬" "$OKCYAN"
    
    if command -v go &>/dev/null; then
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
                GO111MODULE=on go install -v "$tool_path" 2>/dev/null || true
        done
        
        # Update nuclei templates
        if command -v nuclei &>/dev/null; then
            animated_step "Updating Nuclei templates..." "$OKCYAN" \
                nuclei -update-templates 2>/dev/null || nuclei --update 2>/dev/null || true
        fi
    else
        echo -e "  ${OKORANGE}⚠${RESET} Go not found. Skipping Go tools installation."
    fi
    
    # Phase 9: Python Arsenal
    section_header "Phase 9: Python Arsenal" "🐍" "$OKGREEN"
    
    local python_tools=(
        "Sublist3r:https://github.com/aboul3la/Sublist3r.git"
        "DirSearch:https://github.com/maurosoria/dirsearch.git"
        "GitGraber:https://github.com/hisxo/gitGraber.git"
        "LinkFinder:https://github.com/1N3/LinkFinder.git"
        "MassDNS:https://github.com/blechschmidt/massdns.git"
        "CMSMap:https://github.com/Dionach/CMSmap.git"
    )
    
    cd "$PLUGINS_DIR" 2>/dev/null || mkdir -p "$PLUGINS_DIR" && cd "$PLUGINS_DIR"
    for tool_info in "${python_tools[@]}"; do
        IFS=':' read -r tool_name tool_url <<< "$tool_info"
        local tool_dir=$(echo "$tool_name" | tr '[:upper:]' '[:lower:]')
        if [[ ! -d "$tool_dir" ]]; then
            animated_step "Cloning $tool_name..." "$OKGREEN" \
                git clone "$tool_url" "$tool_dir" 2>/dev/null || true
        fi
    done
    
    # Phase 10: System Integration
    section_header "Phase 10: System Integration" "🔗" "$OKMAGENTA"
    
    # Find the main executable
    local omino_exec=""
    if [[ -f "$INSTALL_DIR/omino.sh" ]]; then
        omino_exec="$INSTALL_DIR/omino.sh"
    elif [[ -f "$INSTALL_DIR/omino" ]]; then
        omino_exec="$INSTALL_DIR/omino"
    fi
    
    if [[ -n "$omino_exec" ]]; then
        animated_step "Creating OMINO symlink..." "$OKMAGENTA" \
            ln -fs "$omino_exec" /usr/local/bin/omino 2>/dev/null || ln -fs "$omino_exec" /usr/bin/omino 2>/dev/null || true
        
        # Also link from install directory to common locations
        ln -fs "$omino_exec" /usr/bin/omino 2>/dev/null || true
        chmod +x "$omino_exec" 2>/dev/null || true
        chmod +x /usr/local/bin/omino 2>/dev/null || true
        chmod +x /usr/bin/omino 2>/dev/null || true
    fi
    
    animated_step "Creating workspace links..." "$OKMAGENTA" \
        ln -fs "$LOOT_DIR/workspaces" /workspace 2>/dev/null || true
    
    # Phase 11: Configuration
    section_header "Phase 11: Configuration" "⚙️" "$OKBLUE"
    
    if [[ "$OS" != "macos" ]]; then
        if [[ -f "$INSTALL_DIR/omino.conf" ]]; then
            animated_step "Setting up configuration files..." "$OKBLUE" \
                cp -f "$INSTALL_DIR/omino.conf" /root/.omino.conf 2>/dev/null || true
        fi
    fi
    
    # Add to PATH if needed
    echo ""
    if ! grep -q "omino" ~/.bashrc 2>/dev/null; then
        echo "alias omino='sudo /usr/local/bin/omino'" >> ~/.bashrc 2>/dev/null || true
        echo -e "  ${OKGREEN}✓${RESET} Added OMINO alias to ~/.bashrc"
    fi
    
    # Cleanup
    section_header "Finalizing" "🧹" "$DIM"
    animated_step "Cleaning temporary files..." "$DIM" \
        rm -rf /tmp/msfinstall /tmp/arachni* /tmp/gobuster* 2>/dev/null || true
    
    CLEANUP_DONE=true
    
    # Show completion
    display_completion
    
    show_cursor
    echo ""
    echo -e "  ${OKGREEN}Run: source ~/.bashrc${RESET}"
    echo -e "  ${OKGREEN}Then: sudo omino -t example.com${RESET}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# EXECUTION
# ═══════════════════════════════════════════════════════════════
if [[ "$1" == "force" ]] || [[ "$1" == "-y" ]] || [[ "$1" == "--yes" ]]; then
    FORCE_MODE=true
fi

main "$@"
