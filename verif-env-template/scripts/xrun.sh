#!/bin/bash

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear='\033[0m'  # Clear the color after that

# Check if clean is requested
check_clean() {
    echo -e "${yellow}Cleaning build directory natively with GNU Make...${clear}"
    cd "$(dirname "$0")/.."
    if [ -d "build" ] && [ -f "build/Makefile" ]; then
        make -C build clean
    else
        echo "Build directory already clean or not configured."
    fi
    exit 0
}

# Check if help is requested
check_help() {
    echo "Usage: xrun.sh [options]"
    echo ""
    echo "Options:"
    echo "  --t|-top <top_name>              Specify the top module name (default: ${TOP_NAME})"
    echo "  --N|-name_of_test <test_name>    Specify the test name (default: ${TEST_NAME})"
    echo "  --h|help                         Display this help message"
    echo "  --c|-clean                       Clean build"
    echo "  --v|-vivado <\"--vivado_params\">  Pass Vivado parameters"
    echo ""
    echo "Use -v \"--R\" to run all, --v \"--g\" to gui, and --v \"--g -view top_sim.wcfg\" to load waveforms"
    exit 0
}

# Display error message and exit
error_exit() {
    echo -e "${red}ERROR: $1${clear}"
    exit 1
}

# Native project root variables
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${ROOT_DIR}/configure"

# Default Settings (Extracted directly from ./configure)
TOP_NAME=$(grep -oP '^TOP_NAME="\K[^"]+' "$CONFIG_FILE" || echo "adder_tb_top")
TEST_NAME=$(grep -oP '^TEST_NAME="\K[^"]+' "$CONFIG_FILE" || echo "adder_basic_test")
VIVADO_PARMS=$(grep -oP '^VIVADO_PARMS="\K[^"]+' "$CONFIG_FILE" || echo "--R")
DO_CLEAN=0
RUN_TARGET="sim"

# Parse parameters using getopts
parse_params() {
    options=$(getopt -a --longoptions help,clean,top:,name_of_test:,vivado: -n "xrun" -- ${0} "${@}")
    eval set -- "$options"
    while true; do
        case "$1" in
            --top) shift; TOP_NAME="$1" ;;
            --name_of_test) shift; TEST_NAME="$1" ;;
            --clean) DO_CLEAN=1 ;;
            --help) check_help ;;
            --vivado) 
                shift; 
                VIVADO_PARMS="$1" 
                # Smartly adjust the build target if they explicitly request GUI mode 
                if [[ "$VIVADO_PARMS" == *"--g"* ]]; then
                    RUN_TARGET="gui"
                fi
                ;;
            --) shift; break ;;
            *) error_exit "Option '${1}' requires an argument" ;;
        esac
        shift
    done
}

# Main script execution
main() {
    parse_params "$@"

    if [ $DO_CLEAN -eq 1 ]; then
        check_clean
    fi

    # Go to root directory natively so configure works from wherever script is run
    cd "$ROOT_DIR" || exit 1

    echo -e "${green}Translating xrun.sh arguments to CMake...${clear}"
    echo "------------------------------------------------"
    echo "  Module    : $TOP_NAME"
    echo "  Test      : $TEST_NAME"
    echo "  Vivado    : $VIVADO_PARMS"
    echo "------------------------------------------------"

    # Forward arguments to our CMake configure wrapper
    ./configure --top "${TOP_NAME}" --test "${TEST_NAME}" --vivado "${VIVADO_PARMS}" || error_exit "CMake Configuration Failed"

    echo -e "${green}Executing natively via GNU Make...${clear}"
    # The build script defaults the TEST_NAME inside CMake, so `make sim` runs that specific test correctly natively.
    make -C build "${RUN_TARGET}" || error_exit "Simulation Failed"
}

main "$@"
