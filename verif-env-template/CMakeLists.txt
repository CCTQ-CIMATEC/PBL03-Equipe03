################################################################################
# Copyright 2026 Nelson Alves Ferreira Neto
# All Rights Reserved Worldwide
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation 
# and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
################################################################################
#
# File: CMakeLists.txt
#
# Description: This file is the main CMake configuration script for building and
# simulating the riscv-small project. It defines a dynamic build system that:
#   - Parses SystemVerilog header files (.svh) and packages in `.srclist` files.
#   - Uses Vivado Simulator (`xvlog`, `xelab`, `xsim`) for compilation and simulation.
#   - Establishes independent library dependencies to prevent elaboration errors.
#   - Dynamically creates standard `sim` and `gui` simulation targets as well as
#     targets for each individual test case specified in `tb/tests/*_test.sv`.
#
# Maintainer: Nelson Alves <nelsonafn@gmail.com>
#
################################################################################

cmake_minimum_required(VERSION 3.10)
project(AdderTemplate NONE)

# ==============================================================================
# 1. Options / Variables
# ==============================================================================
# Configuration parameters for specifying simulation parameters. 
# These variables can be overridden from the command line using -D<VAR>=<VALUE>.
# Example: cmake -DTOP_NAME=riscv_small_tb -DTEST_NAME=my_test ..
set(TOP_NAME "adder_tb_top" CACHE STRING "Specify the exact top module name to be simulated")
set(TEST_NAME "adder_basic_test" CACHE STRING "Specify the default UVM or SystemVerilog test name to run")
set(VIVADO_PARMS "--R" CACHE STRING "Pass extra Vivado parameters for xsim (e.g. --R for run all)")

# ==============================================================================
# 2. Environment Validation
# ==============================================================================
# Verify if the Vivado toolchain is properly loaded and initialized.
# This prevents obscure errors later in the compilation/simulation steps.
if(NOT DEFINED ENV{XILINX_VIVADO})
    message(FATAL_ERROR "XILINX_VIVADO environment variable is not set. Ensure you have sourced settings64.sh! Look at scripts/setup.sh for more info. Fix it, source it, and try again. $ source scripts/setup.sh")
endif()

# Convert VIVADO_PARMS into a list format.
# This ensures that multiple spaces or separate arguments aren't incorrectly grouped as a single string during execution.
separate_arguments(VIVADO_PARMS_LIST UNIX_COMMAND "${VIVADO_PARMS}")

# Log the active simulation configuration settings for user visibility.
message(STATUS "--------------------------------------------------")
message(STATUS "  Simulation Configuration:")
message(STATUS "  - Top Module     : ${TOP_NAME}")
message(STATUS "  - Test Name      : ${TEST_NAME}")
message(STATUS "  - Vivado Params  : ${VIVADO_PARMS}")
message(STATUS "--------------------------------------------------")

# ==============================================================================
# 3. Global Variables
# ==============================================================================
# Global properties and variables to track state across recursive CMake function calls.
# This tracks all processed target sources and compiled libraries.
set(PROCESSED_SRCLISTS "" CACHE INTERNAL "Tracks processed .srclist files to avoid infinite recursion")
set_property(GLOBAL PROPERTY ALL_COMPILE_TARGETS "")
set_property(GLOBAL PROPERTY ALL_SIM_LIBS "")

# ==============================================================================
# 4. Helper Function: compile_xvlog_library
# ==============================================================================
# Consolidates the common logic for creating an xvlog compilation target 
# with the appropriate stamp file and dependencies. This allows generalizing 
# compilation for both standard sourcelists and isolated packages.
# ==============================================================================
function(compile_xvlog_library TARGET_LIB SV_FILES LOCAL_XVLOG_LIBS TARGET_DEPENDENCIES LOCAL_XVLOG_INCDIRS)
    set(TARGET_NAME "compile_${TARGET_LIB}")
    
    # Handle cases where there are no standalone .sv modules, only dependencies.
    if(NOT SV_FILES)
        if(TARGET_DEPENDENCIES)
            add_custom_target(${TARGET_NAME})
            add_dependencies(${TARGET_NAME} ${TARGET_DEPENDENCIES})
            set_property(GLOBAL APPEND PROPERTY ALL_COMPILE_TARGETS "${TARGET_NAME}")
        endif()
        return()
    endif()

    set(STAMP_FILE "${CMAKE_BINARY_DIR}/${TARGET_LIB}.stamp")
    
    # Broaden dependencies to include all .sv and .svh files in the same directories.
    # This implicitly catches all `include files that aren't explicitly listed.
    set(ALL_DEPENDS ${SV_FILES})
    foreach(SV_FILE IN LISTS SV_FILES)
        get_filename_component(SV_DIR "${SV_FILE}" DIRECTORY)
        file(GLOB DIR_SVS "${SV_DIR}/*.sv" "${SV_DIR}/*.svh")
        list(APPEND ALL_DEPENDS ${DIR_SVS})
    endforeach()
    if(ALL_DEPENDS)
        list(REMOVE_DUPLICATES ALL_DEPENDS)
    endif()
    
    # Prepare xvlog parameters mapping the exact required libraries using the -L flag
    set(LOCAL_XVLOG_ARGS "-L" "uvm")
    if(LOCAL_XVLOG_INCDIRS)
        list(APPEND LOCAL_XVLOG_ARGS ${LOCAL_XVLOG_INCDIRS})
    endif()
    if(LOCAL_XVLOG_LIBS)
        list(REMOVE_DUPLICATES LOCAL_XVLOG_LIBS)
        foreach(LIB_NAME IN LISTS LOCAL_XVLOG_LIBS)
            list(APPEND LOCAL_XVLOG_ARGS "-L" "${LIB_NAME}")
        endforeach()
    endif()

    # In EDA flows, using a stamp file with an add_custom_command ensures that the
    # compilation only runs when the `.sv` dependencies are newer than the stamp file.
    # This gives `make` a discrete file (`.stamp`) to check timestamps against.
    add_custom_command(
        OUTPUT "${STAMP_FILE}"
        COMMAND xvlog -work ${TARGET_LIB} ${LOCAL_XVLOG_ARGS} -sv ${SV_FILES}
        COMMAND touch "${STAMP_FILE}"
        DEPENDS ${ALL_DEPENDS}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Compiling ${TARGET_LIB}..."
        VERBATIM
    )
    
    # The custom target just drives the creation of the stamp file
    add_custom_target(${TARGET_NAME} DEPENDS "${STAMP_FILE}")
    
    # Apply sub-dependencies (either packages or nested srclists)
    if(TARGET_DEPENDENCIES)
        add_dependencies(${TARGET_NAME} ${TARGET_DEPENDENCIES})
    endif()
    
    # Register this compilation target globally
    set_property(GLOBAL APPEND PROPERTY ALL_COMPILE_TARGETS "${TARGET_NAME}")
endfunction()

# ==============================================================================
# 5. Parsing Function: create_library_from_srclist
# ==============================================================================
# This function dynamically parses a source list (.srclist) line by line.
# 
#  Logic Flow:
#  1. Reads `.srclist` to retrieve SystemVerilog files, packages, and sub-lists.
#  2. If a sub-list (.srclist) is found, it evaluates it recursively, creating a dependent library.
#  3. If a package (.svh/.sv) is found, it compiles the package into an independent, shared library 
#     ensuring it can be used efficiently across other modules without duplication/elaboration loops.
#  4. If a standard `.sv` module is found, it bundles it with other SV files into the main target library.
#  5. Finally, uses the helper compile_xvlog_library to abstract away custom commands.
#
# Parameters:
#  - SRCLIST_PATH: The absolute path to the `.srclist` file to parse.
#  - TARGET_LIB: The logical name of the library (e.g., 'work', 'my_module_lib') being created.
# ==============================================================================
function(create_library_from_srclist SRCLIST_PATH TARGET_LIB)
    # Stop recursion if the list was already parsed.
    if("${SRCLIST_PATH}" IN_LIST PROCESSED_SRCLISTS)
        return()
    endif()
    set(PROCESSED_SRCLISTS "${PROCESSED_SRCLISTS};${SRCLIST_PATH}" CACHE INTERNAL "")

    # Tell CMake to re-run configuration automatically if this srclist is modified.
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${SRCLIST_PATH}")

    if(NOT EXISTS "${SRCLIST_PATH}")
        message(FATAL_ERROR "Source list not found: ${SRCLIST_PATH}")
    endif()

    file(STRINGS "${SRCLIST_PATH}" LINES)
    
    # Local variables for current library compilation
    set(SV_FILES "")
    set(TARGET_DEPENDENCIES "")
    set(LOCAL_XVLOG_LIBS "")
    set(LOCAL_XVLOG_INCDIRS "")

    foreach(LINE IN LISTS LINES)
        # Remove trailing comments and strip whitespaces
        string(REGEX REPLACE "#.*$" "" LINE "${LINE}")
        string(STRIP "${LINE}" LINE)
        if(LINE STREQUAL "")
            continue() # Skip empty lines
        endif()

        if(LINE MATCHES "^\\+incdir\\+(.*)$")
            list(APPEND LOCAL_XVLOG_INCDIRS "-i" "${CMAKE_SOURCE_DIR}/${CMAKE_MATCH_1}")
            
        elseif(LINE MATCHES "\\.srclist$" OR LINE MATCHES "pkg\\.svh?$")
            # For both sub-lists and packages, we create an independent library target
            # and inherit it as a dependency for the current parent module list.
            get_filename_component(CHILD_BASE_NAME "${LINE}" NAME_WE)
            set(CHILD_LIB "${CHILD_BASE_NAME}_lib")
            
            if(LINE MATCHES "\\.srclist$")
                # Recursively parse the target directory based on srclist structure
                create_library_from_srclist("${CMAKE_SOURCE_DIR}/${LINE}" "${CHILD_LIB}")
            else()
                # Packages shouldn't be parsed, simply compile them structurally using the helper.
                # We pass the accumulated LOCAL_XVLOG_LIBS and TARGET_DEPENDENCIES so it can resolve prior packages.
                get_property(COMPILED_PKGS GLOBAL PROPERTY PROCESSED_PKGS)
                if(NOT "${CHILD_LIB}" IN_LIST COMPILED_PKGS)
                    set_property(GLOBAL APPEND PROPERTY PROCESSED_PKGS "${CHILD_LIB}")
                    compile_xvlog_library("${CHILD_LIB}" "${CMAKE_SOURCE_DIR}/${LINE}" "${LOCAL_XVLOG_LIBS}" "${TARGET_DEPENDENCIES}" "${LOCAL_XVLOG_INCDIRS}")
                endif()
            endif()
            
            # Sub-library now acts as a dependency/linked object towards main compilation tree
            list(APPEND TARGET_DEPENDENCIES "compile_${CHILD_LIB}")
            set_property(GLOBAL APPEND PROPERTY ALL_SIM_LIBS "${CHILD_LIB}")
            list(APPEND LOCAL_XVLOG_LIBS "${CHILD_LIB}")

        else()
            # Standard SystemVerilog file (.sv)
            list(APPEND SV_FILES "${CMAKE_SOURCE_DIR}/${LINE}")
        endif()
    endforeach()

    # Compile the aggregated files for this srclist using the common helper function
    compile_xvlog_library("${TARGET_LIB}" "${SV_FILES}" "${LOCAL_XVLOG_LIBS}" "${TARGET_DEPENDENCIES}" "${LOCAL_XVLOG_INCDIRS}")
    
endfunction()

# ==============================================================================
# 6. Build Flow Implementation
# ==============================================================================

# Start parsing the design hierarchy starting from the top module's srclist.
# The resultant library is assigned the default 'work' name.
set(PROCESSED_SRCLISTS "" CACHE INTERNAL "")
create_library_from_srclist("${CMAKE_SOURCE_DIR}/srclist/${TOP_NAME}.srclist" "work")

# Gather all identified compilation targets and used libraries generated recursively above.
get_property(COMPILE_TARGETS GLOBAL PROPERTY ALL_COMPILE_TARGETS)
get_property(SIM_LIBS GLOBAL PROPERTY ALL_SIM_LIBS)

# Format library flags for Xelab linker/elaborator (-L lib1 -L lib2 ...)
set(XELAB_LIBS "")
if(SIM_LIBS)
    list(REMOVE_DUPLICATES SIM_LIBS)
    foreach(LIB_NAME IN LISTS SIM_LIBS)
        list(APPEND XELAB_LIBS "-L" "${LIB_NAME}")
    endforeach()
endif()

# Define the overarching `compile` target that triggers the compilation of all .sv files.
if(COMPILE_TARGETS)
    add_custom_target(compile DEPENDS ${COMPILE_TARGETS})
else()
    add_custom_target(compile COMMENT "No sources to compile.")
endif()

# ==============================================================================
# 7. Elaboration and Simulation Targets
# ==============================================================================

# Elaborate target: links the compiled units into a simulated snapshot ('top_sim') using xelab.
add_custom_target(elaborate
    COMMAND xelab ${TOP_NAME} -L uvm ${XELAB_LIBS} --timescale 1ns/1ps -s top_sim --debug typical --mt 16 --incr
    DEPENDS compile
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Elaborating design snapshot (top_sim)..."
    VERBATIM
)

set(DOLLAR "$")

# Primary 'sim' target: executes the simulation engine headlessly in CLI (xsim)
add_custom_target(sim
  COMMAND xsim top_sim ${VIVADO_PARMS_LIST} --testplusarg UVM_TESTNAME=${TEST_NAME}
  DEPENDS elaborate
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  COMMENT "Running standard simulation in CLI..."
  USES_TERMINAL
  VERBATIM
)

# 'gui' target: executes the simulation engine visually in Vivado's GUI
add_custom_target(gui
  COMMAND xsim top_sim --gui --view ../scripts/${TOP_NAME}_sim.wcfg ${VIVADO_PARMS_LIST} --testplusarg UVM_TESTNAME=${TEST_NAME}
  DEPENDS elaborate
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  COMMENT "Opening simulation in Vivado GUI..."
  USES_TERMINAL
  VERBATIM
)

# Define simulation artifacts natively to automatically get wiped out upon running `make clean`.
set_directory_properties(PROPERTIES ADDITIONAL_CLEAN_FILES 
    "xsim.dir;xvlog.log;xvlog.pb;xelab.log;xelab.pb;xsim.log;xsim.jou;webtalk_pn.xml;webtalk.jou;xsim_webtalk.tcl;xsim.covdb;top_sim.wdb;tr_db.log;*.stamp;*.hex"
)

# ==============================================================================
# 8. Dynamic Native Targets For Individually Assigned Tests
# ==============================================================================
# Finds all default UVM or plain systemverilog structural tests locally configured.
# Gives the user the capacity to call `make sim_<test_name>` without specifying standard CMAKE flags.
file(GLOB TEST_FILES "${CMAKE_SOURCE_DIR}/tb/tests/*_test.sv")
foreach(TEST_FILE IN LISTS TEST_FILES)
    get_filename_component(INDIVIDUAL_TEST_NAME "${TEST_FILE}" NAME_WE)
    
    # Explicit CLI explicit simulator target specific to test structure
    add_custom_target(sim_${INDIVIDUAL_TEST_NAME}
        COMMAND xsim top_sim ${VIVADO_PARMS_LIST} --testplusarg UVM_TESTNAME=${INDIVIDUAL_TEST_NAME}
        DEPENDS elaborate
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running explicit simulation in CLI view: ${INDIVIDUAL_TEST_NAME}..."
        USES_TERMINAL
        VERBATIM
    )
    
    # Create a wrapper target for exactly this test name (Standard Mode)
    # This acts as an alias so users can invoke either `make sim_my_test` or `make my_test`
    add_custom_target(${INDIVIDUAL_TEST_NAME} DEPENDS sim_${INDIVIDUAL_TEST_NAME})
    
    # Explicit GUI explicit simulator target specific to test structure
    add_custom_target(gui_${INDIVIDUAL_TEST_NAME}
        COMMAND xsim top_sim --gui --view ../scripts/${TOP_NAME}_sim.wcfg ${VIVADO_PARMS_LIST} --testplusarg UVM_TESTNAME=${INDIVIDUAL_TEST_NAME}
        DEPENDS elaborate
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Opening explicitly designed GUI simulation: ${INDIVIDUAL_TEST_NAME}..."
        USES_TERMINAL
        VERBATIM
    )
endforeach()

# ==============================================================================
# 9. External Targets (Tests compilation)
# ==============================================================================
# Injects the separate logic to sync and compile external RISC-V tests
# include(${CMAKE_SOURCE_DIR}/scripts/compile_sanity_tests.cmake)
