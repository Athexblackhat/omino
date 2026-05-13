#!/bin/bash
# ╔═╗╔╦╗╦╔╗╔╔═╗  ╦ ╦╔╗╔╦╔╗╔╔═╗╔╦╗╔═╗╦  ╦  
# ║ ║║║║║║║║║ ║  ║ ║║║║║║║║╚═╗ ║ ╠═╣║  ║  
# ╚═╝╩ ╩╩╝╚╝╚═╝  ╚═╝╝╚╝╩╝╚╝╚═╝ ╩ ╩ ╩╩═╝╩═╝
# Uninstall script for OMINO Black Hat Edition
# Rebranded & Enhanced: The Eye That Sees All

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
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

hide_cursor() { printf "\e[?25l"; }
show_cursor() { printf "\e[?25h"; }

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

spinner_frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

spinner() {
    local message="$1"
    local pid=$2
    local frame=0
    local color=${3:-$OKCYAN}
    
    while kill -0 $pid 2>/dev/null; do
        local spin_char=${spinner_frames[$frame]}
        printf "\r\033[K  ${color}${spin_char}${RESET} ${message}"
        frame=$(( (frame + 1) % ${#spinner_frames[@]} ))
        sleep 0.1
    done
    printf "\r\033[K  ${OKGREEN}✓${RESET} ${message}\n"
}

pulse_warning() {
    local text="$1"
    local duration=${2:-3}
    local end_time=$(($(date +%s) + duration))
    
    while [[ $(date +%s) -lt $end_time ]]; do
        printf "\r  ${OKRED}${REVERSE}${BOLD} %s ${RESET}" "$text"
        sleep 0.3
        printf "\r  ${OKRED}${BOLD} %s ${RESET}" "$text"
        sleep 0.3
    done
    printf "\r  ${OKRED}${REVERSE}${BOLD} %s ${RESET}\n" "$text"
}

poof_effect() {
    local frames=(
        "     *     "
        "    ***    "
        "   *****   "
        "  *******  "
        " ********* "
        "***********"
        " ********* "
        "  *******  "
        "   *****   "
        "    ***    "
        "     *     "
        "           "
    )
    
    for frame in "${frames[@]}"; do
        printf "\r  ${OKORANGE}${frame}${RESET}"
        sleep 0.08
    done
    printf "\r\033[K"
}

progress_bar() {
    local current=$1
    local total=$2
    local message=${3:-"Removing"}
    local bar_width=30
    local filled=$(( current * bar_width / total ))
    local percentage=$(( current * 100 / total ))
    
    printf "\r  ${OKRED}[${RESET}"
    for ((i=0; i<filled; i++)); do
        printf "${OKRED}█${RESET}"
    done
    for ((i=filled; i<bar_width; i++)); do
        printf "${DIM}░${RESET}"
    done
    printf "${OKRED}]${RESET} ${percentage}%% ${message}"
}
clear
echo ""
echo ""
echo -e "${OKRED}${BOLD}"
echo -e "    ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ "
echo -e "   ██╔═══██╗████╗ ████║██║████╗  ██║██╔═══██╗"
echo -e "   ██║   ██║██╔████╔██║██║██╔██╗ ██║██║   ██║"
echo -e "   ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║"
echo -e "   ╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝"
echo -e "    ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ "
echo -e "${RESET}"
echo ""
echo -e "${OKCYAN}${RESET}${BOLD}${OKRED}⚠ UNINSTALL OMINO ⚠${RESET}${OKCYAN}${RESET}"
echo ""
echo -e "${OKMAGENTA}  ⚡ ${OKYELLOW}OMINO ${OKMAGENTA}⚡ ${OKCYAN}- The Eye That Sees All${RESET}"
echo -e "${OKMAGENTA}  ⚡ ${OKYELLOW}BLACK HAT EDITION - UNINSTALL${RESET} ${OKMAGENTA}⚡${RESET}"
echo ""
echo ""
INSTALL_DIR=/usr/share/omino
REMOVAL_ITEMS=(
    "/usr/share/omino/"
    "/usr/bin/omino"
    "/usr/local/bin/omino"
    "/root/.omino.conf"
    "/root/.omino.conf.bak"
    "/root/.omino_api_keys.conf"
    "/usr/share/applications/omino.desktop"
    "/usr/share/pixmaps/omino.png"
    "/root/workspace"
    "/workspace"
    "/root/omino"
    "/omino"
    "/usr/share/omino"
)

echo ""
echo -e "${OKCYAN}  ${RESET}                                                              ${OKCYAN}${RESET}"
echo -e "${OKCYAN}  ${RESET}  ${OKRED}${BOLD}⚠ WARNING: IRREVERSIBLE OPERATION ⚠${RESET}                      ${OKCYAN}║${RESET}"
echo -e "${OKCYAN}  ${RESET}                                                              ${OKCYAN}${RESET}"
echo -e "${OKCYAN}  ${RESET}  This will permanently remove:                               ${OKCYAN}${RESET}"
echo -e "${OKCYAN}  ${RESET}    • All OMINO files and directories                         ${OKCYAN}${RESET}"
echo -e "${OKCYAN}  ${RESET}    • All configuration files                                 ${OKCYAN}${RESET}"
echo -e "${OKCYAN}  ${RESET}    • All workspaces and loot data                            ${OKCYAN}${RESET}"
echo -e "${OKCYAN}  ${RESET}    • All plugins and tools                                    ${OKCYAN}${RESET}"
echo -e "${OKCYAN}  ${RESET}    • All symlinks and shortcuts                              ${OKCYAN}${RESET}"
echo -e "${OKCYAN}  ${RESET}                                                              ${OKCYAN}${RESET}"
echo ""

type_text "  The eye will close forever..." 0.04 "$OKMAGENTA"
echo ""

# Pulsing warning
pulse_warning "ARE YOU ABSOLUTELY SURE YOU WANT TO CONTINUE?" 3
echo ""

echo -e "${OKRED}[>]${RESET} ${OKWHITE}Type ${BOLD}${OKYELLOW}ERASE OMINO${RESET}${OKWHITE} to confirm uninstallation:${RESET}"
printf "  ${OKCYAN}➜${RESET} "
read answer

echo ""

if [[ "$answer" != "ERASE OMINO" ]]; then
    echo -e "${OKGREEN}  ✓${RESET} ${OKWHITE}Uninstallation cancelled.${RESET}"
    echo -e "${OKMAGENTA}  ⚡ ${OKYELLOW}The eye remains open...${RESET} ${OKMAGENTA}⚡${RESET}"
    echo ""
    show_cursor
    exit 0
fi

echo ""
echo -e "${OKCYAN}${RESET}${BOLD}${OKRED}INITIATING PURGE SEQUENCE...${RESET}${OKCYAN}${RESET}"
echo ""
sleep 1

hide_cursor

# Phase 1: Remove main installation directory
echo -e "${OKRED}  [PHASE 1/4]${RESET} ${OKWHITE}Removing OMINO core files...${RESET}"
echo ""

if [[ -d "$INSTALL_DIR" ]]; then
    # Get file count for progress
    file_count=$(find "$INSTALL_DIR" -type f 2>/dev/null | wc -l)
    current=0
    
    # Animated removal
    (
        rm -Rf "$INSTALL_DIR" 2>/dev/null
    ) &
    rm_pid=$!
    
    while kill -0 $rm_pid 2>/dev/null; do
        if [[ $file_count -gt 0 ]]; then
            current=$(( (current + 1) % file_count + 1 ))
            progress_bar $current $file_count "Purging OMINO..."
        fi
        sleep 0.1
    done
    wait $rm_pid
    
    printf "\r\033[K  ${OKGREEN}✓${RESET} ${OKWHITE}Core files removed${RESET}\n"
    poof_effect
else
    echo -e "  ${OKORANGE}⚠${RESET} ${DIM}Installation directory not found${RESET}"
fi

echo ""

# Phase 2: Remove binary symlinks
echo -e "${OKRED}  [PHASE 2/4]${RESET} ${OKWHITE}Removing OMINO binaries and symlinks...${RESET}"
echo ""

local binary_paths=(
    "/usr/bin/omino"
    "/usr/local/bin/omino"
    "/usr/bin/goohak"
    "/usr/local/bin/goohak"
    "/usr/bin/dirsearch"
    "/usr/local/bin/dirsearch"
)

for binary in "${binary_paths[@]}"; do
    if [[ -f "$binary" ]] || [[ -L "$binary" ]]; then
        rm -f "$binary" 2>/dev/null &
        rm_pid=$!
        spinner "Removing: $binary" $rm_pid "$OKRED"
        wait $rm_pid
    fi
done

echo ""

echo -e "${OKRED}  [PHASE 3/4]${RESET} ${OKWHITE}Removing OMINO configuration files...${RESET}"
echo ""

local config_files=(
    "/root/.omino.conf"
    "/root/.omino.conf.bak"
    "/root/.omino_api_keys.conf"
    "/usr/share/applications/omino.desktop"
    "/usr/share/applications/omino.desktop"
    "/usr/share/pixmaps/omino.png"
    "/usr/share/pixmaps/omino.png"
    "/usr/share/kali-menu/applications/omino.desktop"
    "/usr/share/kali-menu/applications/omino.desktop"
)

for config in "${config_files[@]}"; do
    if [[ -f "$config" ]]; then
        rm -f "$config" 2>/dev/null &
        rm_pid=$!
        spinner "Removing: $config" $rm_pid "$OKRED"
        wait $rm_pid
    fi
done

echo ""

echo -e "${OKRED} [PHASE 4/4]${RESET} ${OKWHITE}Removing OMINO symlinks and shortcuts...${RESET}"
echo ""

local symlinks=(
    "/root/workspace"
    "/workspace"
    "/root/omino"
    "/omino"
    "/usr/share/omino"
    "/root/Desktop/workspaces"
    "/home/kali/Desktop/workspaces"
)

for symlink in "${symlinks[@]}"; do
    if [[ -L "$symlink" ]]; then
        rm -f "$symlink" 2>/dev/null &
        rm_pid=$!
        spinner "Removing symlink: $symlink" $rm_pid "$OKRED"
        wait $rm_pid
    elif [[ -d "$symlink" ]]; then
        # Also remove if it's a leftover directory
        rm -Rf "$symlink" 2>/dev/null &
        rm_pid=$!
        spinner "Removing directory: $symlink" $rm_pid "$OKRED"
        wait $rm_pid
    fi
done

echo ""
show_cursor

echo -e "${OKCYAN} ${RESET}${BOLD}${OKGREEN}VERIFICATION CHECK${RESET} ${OKCYAN}${RESET}"

echo ""

# Verify main directory is gone
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo -e "  ${OKGREEN}✓${RESET} OMINO installation directory: ${OKGREEN}REMOVED${RESET}"
else
    echo -e "  ${OKRED}✗${RESET} OMINO installation directory: ${OKRED}STILL EXISTS${RESET}"
fi

# Verify binary is gone
if ! command -v omino &>/dev/null; then
    echo -e "  ${OKGREEN}✓${RESET} OMINO command: ${OKGREEN}REMOVED${RESET}"
else
    echo -e "  ${OKRED}✗${RESET} OMINO command: ${OKRED}STILL AVAILABLE${RESET}"
fi

if [[ ! -f "/root/.omino.conf" ]]; then
    echo -e "  ${OKGREEN}✓${RESET} OMINO configuration: ${OKGREEN}REMOVED${RESET}"
else
    echo -e "  ${OKRED}✗${RESET} OMINO configuration: ${OKRED}STILL EXISTS${RESET}"
fi

echo ""

echo ""
echo -e "${OKMAGENTA} ${RESET}                                                       ${OKMAGENTA}${RESET}"
echo -e "${OKMAGENTA} ${RESET}   ${BOLD}${OKRED}OMINO HAS BEEN PURGED${RESET}         {OKMAGENTA}${RESET}"
echo -e "${OKMAGENTA} ${RESET}                                                       ${OKMAGENTA}${RESET}"

echo ""

# Dramatic exit sequence
type_text "  The eye has closed..." 0.06 "$DIM"
sleep 0.5
type_text "  The shadows reclaim what was theirs..." 0.05 "$DIM"
sleep 0.5
type_text "  But memories remain in the void..." 0.04 "$DIM"
sleep 0.5
echo ""

echo -e "${OKORANGE} + -- --=[ ${BOLD}Uninstallation Complete${RESET} ${OKORANGE}]${RESET}"
echo -e "${OKORANGE} + -- --=[ ${DIM}OMINO Black Hat Edition - Purged from existence${RESET} ${OKORANGE}]${RESET}"
echo ""
echo ""
echo -e "${OKYELLOW}  ℹ${RESET} ${DIM}Note: Third-party tools installed with OMINO (nmap, go, etc.)${RESET}"
echo -e "     ${DIM}were not removed as they may be used by other applications.${RESET}"
echo ""
sleep 1
echo -e "${DIM}  Goodbye...${RESET}"
echo ""

exit 0