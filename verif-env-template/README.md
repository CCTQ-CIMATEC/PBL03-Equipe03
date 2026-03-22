# Adder Template
Simple adder module for demonstration purposes.

## Implementation Status

- [x] Conception
- [x] Microarchitecture
- [x] RTL Design
- [x] TB environment
- [ ] Testcases
- [ ] Functional Verification
- [ ] RTL signoff 

## Verification Template Overview

The verification template in this repository is designed to provide a modular and reusable environment for verifying RTL designs using the Universal Verification Methodology (UVM). It includes the following components:

### Key Components
1. **Testbench Environment**:
   - The testbench is structured around UVM principles and includes agents, monitors, drivers, and sequencers.
   - The environment is defined in `tb/env/top/adder_env.sv` and instantiated in the top-level testbench `tb/adder_tb_top.sv`.

2. **Agents**:
   - The agent encapsulates the driver, monitor, and sequencer for the adder DUT.
   - Defined in `tb/env/agents/adder_agent/adder_agent.sv`.

3. **Reference Model**:
   - A behavioral model of the adder is implemented in `tb/env/ref_model/adder_ref_model.sv` to generate expected outputs for comparison.

4. **Scoreboard**:
   - The scoreboard compares the DUT's output with the reference model's output to verify correctness.
   - Implemented in `tb/env/top/adder_scoreboard.sv`.

5. **Coverage**:
   - Functional coverage is collected using `tb/env/top/adder_coverage.sv` to ensure all scenarios are tested.

6. **Sequences and Tests**:
   - Sequences generate randomized transactions for the DUT, defined in `tb/tests/sequence_lib/adder_basic_seq.sv`.
   - Tests are defined in `tb/tests/adder_basic_test.sv` and aggregated in `tb/tests/adder_test_list.sv`.

7. **Top-Level Testbench**:
   - The top-level testbench `tb/adder_tb_top.sv` instantiates the DUT, connects it to the UVM environment, and starts the simulation.

8. **Automation Scripts**:
   - A native `CMakeLists.txt` is provided to automate out-of-source builds, Xilinx Vivado compilation, elaboration, and simulation processes.

### Source Organization
- **RTL Design**: Located in the `rtl/` directory.
- **Testbench Components**: Organized under `tb/` with subdirectories for agents, reference models, and top-level environment.
- **Source Lists**: Defined in `srclist/` for easy inclusion in simulation scripts. Supports standard file paths, nested `.srclist` files (which create separate compilation libraries), and `+incdir+path/to/dir` directives for global UVM macro includes.
- **Submodules**: Located in `src/` for easy integration with git submodules and dependencies.

This template is designed to streamline the verification process, promote reusability, and ensure thorough testing of the adder design.

## How to run

### Step 1: Set up the environment
Before running the simulation, you must source the required Xilinx tools (Vivado or Vitis). This injects the EDA toolpaths into your current terminal instance.

```bash
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
# or
$ source /opt/Xilinx/2025.2/Vivado/settings64.sh 
# or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
# or
$ source /opt/Xilinx/2025.2/Vivado/.settings64-Vivado.sh 
```

### Step 2: Configure the Build
This project uses CMake to automate the Vivado simulation flow (`xvlog`, `xelab`, `xsim`). You generate an isolated `build/` directory using the provided wrapper script.

```bash
# Sets up the default simulation environment
$ ./configure
```
Under the hood, this parses your SV files, generates dependency trees via stamp files (so they only recompile when modified), and creates dynamically bound Make targets.

#### Custom Defaults Configuration
If you want to bake a different default test sequence into the generated Makefiles:
```bash
$ ./configure --top <top_name> --test <test_name>
```

### Step 3: Run the simulation
Because of the smart wrapper generated in the project root, you have several ways to trigger the simulations cleanly!

#### Option A: Running from the Project Root (Smart Proxy)
You do not need to `cd build/`. You can immediately execute targets from the root, and it will intentionally forward your requests into CMake. It allows you to inject individual test names via spaces.

- **`make compile`**: Explicitly compiles the SV source code (`xvlog`) without running simulation.
- **`make elaborate`**: Elaborates the compiled design into a simulation snapshot (`xelab`) without running simulation.
- **`make sim`**: Runs the default test configuration (e.g. `adder_basic_test`) silently in terminal.
- **`make gui`**: Opens Vivado XSim GUI using your defined waveform layout.
- **`make sim_<test_name>`**: Injects the test dynamically (e.g. `make sim_adder_corner_test`) replacing defaults.
- **`make gui_<test_name>`**: Injects the test dynamically into the GUI directly (e.g. `make gui_adder_corner_test`).

#### Option B: Running from inside the `build/` directory
When inside the strictly generated CMake target directory, you can utilize the auto-generated target configurations. (Note: spaces denote multiple targets inside native Make!)

```bash
$ cd build/
```
- **`make sim`**: Runs the default test configured.
- **`make <test_name>`**: Runs a specific test dynamically discovered natively (e.g. `make adder_corner_test`).
- **`make sim_<test_name>`**: Explicitly runs the auto-generated test strictly in SIM terminal mode.
- **`make gui_<test_name>`**: Explicitly runs the auto-generated test natively triggering the Vivado GUI.

#### Option C: Legacy Workflow Wrapper
If you are strictly used to Xilinx environments parsing raw arguments, we provide a reverse-compatible wrapper that automatically triggers CMake and GNU Make behind the scenes.

```bash
$ bin/xrun.sh --name_of_test adder_corner_test
```
*(Runs completely self-contained from anywhere in the project tree.)*

### Step 4: Clean Build
To clean the entire build cache (safe compilation reset):
```bash
$ make clean
```

### Summary of Configure Arguments
| Variable | Default Value | Description |
|---|---|---|
| `--top` | `adder_tb_top` | Specifies the top-level testbench module to load in elaboration. |
| `--test` | `adder_basic_test` | The UVM test name passed directly to `+UVM_TESTNAME` in `xsim`. |
| `--vivado` | `--R` | Passes arbitrary flags natively to the simulation engine. (Setting `--g` turns on GUI mode) |


## Important Information

1. **Tool Versions**:
   - Ensure you are using Vivado or Vitis version 2024.1 or later for compatibility with the scripts and UVM libraries.

2. **Directory Structure**:
   - Maintain the directory structure as provided in the repository to ensure the scripts and source lists function correctly.

3. **Debugging Tips**:
   - Use the `--vivado "--g"` option to open the GUI for debugging.
   - Check the `build/` directory for logs and intermediate files if issues arise during simulation.

4. **Extending the Template**:
   - To add new tests, create sequences in `tb/tests/sequence_lib/` and include them in `tb/tests/adder_seq_list_pkg.sv` and `tb/tests/adder_test_list_pkg.sv`.
   - To add standalone shared components (like interfaces), map them to an `.srclist` module to build them as an independent library.
   - For additional coverage, extend the coverage model in `tb/env/top/adder_coverage.sv`.

5. **Support**:
   - For questions or issues, contact the maintainer at `nelsonafn@gmail.com`.

6. **License**:
   - This project is distributed under the BSD license. Refer to the `LICENSE` file for details.

This section provides essential details to ensure smooth usage and extension of the verification template.

## Install cmake
sudo apt install cmake
sudo apt install autoconf
