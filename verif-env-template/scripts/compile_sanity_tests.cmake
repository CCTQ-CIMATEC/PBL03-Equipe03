# ==============================================================================
# RISC-V Sanity Tests Compilation Target
# ==============================================================================
# Description: This CMake script defines a dynamic target capable of initializing
# the riscv-tests submodule, configuring the build space, making the suite, and 
# outputting the specific `.hex` memory maps needed for structural simulation.
# ==============================================================================

set(HEX_TEST_NAME "rv32ui-p-addi" CACHE STRING "Specify the exact test name from riscv-tests/isa to convert")
set(RISCV_TESTS_DIR "${CMAKE_SOURCE_DIR}/src/riscv-tests")
set(RISCV_PREFIX "riscv64-unknown-elf-")
set(DEFAULT_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/sanity_tests")
file(MAKE_DIRECTORY "${DEFAULT_WORKING_DIRECTORY}")
set(OUTPUT_HEX "${DEFAULT_WORKING_DIRECTORY}/${HEX_TEST_NAME}.hex")

# First, check if the required objcopy tool is present
find_program(RISCV_OBJCOPY riscv64-unknown-elf-objcopy)
if(NOT RISCV_OBJCOPY)
    message(FATAL_ERROR "riscv64-unknown-elf-objcopy not found! Please install the required binutils using: sudo apt install binutils-riscv64-unknown-elf")
endif()

# Check for autoconf
find_program(AUTOCONF autoconf)
if(NOT AUTOCONF)
    message(FATAL_ERROR "autoconf not found! Please install it using: sudo apt install autoconf")
endif()

# Check for GCC RISC-V Cross Compiler
find_program(RISCV_GCC riscv64-unknown-elf-gcc)
if(NOT RISCV_GCC)
    message(FATAL_ERROR "riscv64-unknown-elf-gcc not found! Please install it using: sudo apt install gcc-riscv64-unknown-elf")
endif()

add_custom_target(compile_sanity_tests
    # 1. Update the riscv-tests submodule
    COMMAND git submodule update --init --recursive "${RISCV_TESTS_DIR}"

    # 2. Configure the test suite specifically for your local embedded RISC-V toolchain.
    # We execute this inside build/sanity_tests (DEFAULT_WORKING_DIRECTORY) out-of-tree 
    # so we do not pollute the submodule natively!
    COMMENT "Configuring riscv-tests out-of-tree..."
    COMMAND "${RISCV_TESTS_DIR}/configure" --srcdir="${RISCV_TESTS_DIR}" 
    
    # 3. Compile the target natively inside the isolated build directory!
    # By passing RISCV_PREFIX_VAR="${HEX_TEST_NAME}", we cleverly trick the Makefile 
    # to compile our exact instruction test file natively without compiling the giant
    # benchmarks suite which depends on complete bare-metal libraries.
    COMMAND make -C "${DEFAULT_WORKING_DIRECTORY}" XLEN=32 RISCV_PREFIX="${RISCV_PREFIX}" RISCV_PREFIX_VAR="${HEX_TEST_NAME}" isa

    # 4. Generate the HEX format from the compiled ELF using the standard objcopy
    COMMAND riscv64-unknown-elf-objcopy -O verilog -j .text -j .text.startup -j .text.init -j .data 
        --gap-fill 00000000 --set-start=0 --reverse-bytes=4 
        "${DEFAULT_WORKING_DIRECTORY}/isa/${HEX_TEST_NAME}" 
        -v --verilog-data-width 4 
        "${OUTPUT_HEX}"
        
    # 5. Fix the first line to be the precise address marker for the Vivado simulator
    COMMAND sed -i.bak "1 s/.*/@00000000/" "${OUTPUT_HEX}"
    
    WORKING_DIRECTORY "${DEFAULT_WORKING_DIRECTORY}"
    COMMENT "Building test suite and generating memory map for: ${HEX_TEST_NAME}..."
    USES_TERMINAL
)
