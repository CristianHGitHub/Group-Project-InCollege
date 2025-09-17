## InCollege Application

### Prerequisites

- Docker Desktop
- Visual Studio Code with Dev Containers extension

### Compilation

1. Using a Dev Container in VS Code, open `src/InCollege.cob`.
2. Build the program by pressing `Ctrl+Shift+B`.
    This will create a binary executable in the `/bin` directory.
3. In the terminal, navigate to the `/bin` directory and run the program:
    ```sh
    ./InCollege
    ```

### Contribution Guidelines
- Create a new branch for each Jira story, following the naming convention `SCRUM-<story-number>`. Commit all relevant changes to this branch. When the story is complete, open a pull request to merge the changes into the `develop` branch. After the merge into `develop`, conduct additional testing to ensure that the merge did not introduce any issues. Then, open a pull request to merge `develop` into `main`.
- Please conduct at least minimal testing of your changes before submitting a pull request.

### Preparation of Input File `InCollege-Input.txt` for Testing

The input file should contain commands for the program to execute. Each command should be on a new line. Initially, the input file would require that arguments are passed along with the command on the same line (e.g. LOGIN|nick,PASWRD123!). Although this was easier to parse and handle errors for, it doesn't allow for the type of natural language output that we need in order to match the sample provided in the assignment guidelines. In its current form, it mimics CLI input by users in an interactive session, where input is collected sequentially in response to certain prompts (e.g. Enter your choice: ). We can revise it as necessary if we decide that it isn't efficient enough for testing. To improve testing, there's a hidden Log Out command that can be used at any point in the input to act as a reset, allowing multiple input sequences to be tested from one input file during the same execution of the program. Below are some examples of valid input sequences with the current format:
```
Create New Account
nick
PASWRD123!
```
```
Log In
nick
PASWRD123!
Job
```

Note: The Log In and Create New Account commands should be followed by a username and password on separate lines. The Log In sequence will fail if the account does not have a corresponding record in `AccountRecords.txt`.

## 🚀 Quick Start & Build Instructions

### Prerequisites
- **GnuCOBOL (cobc)** - COBOL compiler for free format support
- **Make** (Linux/Unix/macOS) or **Command Prompt** (Windows)

### Build Commands

#### 🐧 Linux/Unix/macOS
```bash
# Build and compile the project
make

# Build and run with console output
make run

# Test compilation only
make test

# Run test with output display
make run-test

# Clean all generated files
make clean

# Show available commands
make help
```

#### 🪟 Windows
```cmd
# Build, compile, and run with output
build.bat

# Clean generated files
clean.bat
```

### 📁 Project Structure
```
workspace/
├── Makefile              # Linux/Unix build configuration
├── build.bat             # Windows build script
├── clean.bat             # Windows clean script
├── src/                  # Source code directory
│   ├── InCollege.cob     # Main program
│   ├── CreateAccount.cob # Account creation module
│   ├── Login.cob         # Login module
│   ├── Navigation.cob    # Navigation module
│   └── copy/             # Copybook directory
│       └── AccountRecord.cpy
├── bin/                  # Generated executables
└── data/                 # Data files
    ├── InCollege-Input.txt
    ├── InCollege-Output.txt
    └── AccountRecords.txt
```

### ⚡ Single Line Commands
```bash
# Quick build and test
make && make run-test

# Clean and rebuild
make clean && make

# Windows equivalent
build.bat
```

## Testing Framework

### Test Case Development

The project includes a comprehensive testing framework using structured test files and a Python-based test runner. Test cases are designed to validate specific functionality and edge cases in the InCollege application.

#### Test File Structure

Test files follow a specific format that the test runner can parse:

```
Test: Description of what this test validates
ResetAccounts: yes/no
Input:
Create New Account
testuser
TestPass1!
Log In
testuser
TestPass1!
Profile
[... additional input lines ...]
Expected:
Welcome to InCollege!
Log In
Create New Account
[... expected output lines ...]
End
```

#### Key Components:
- **Test:** Brief description of the test case
- **ResetAccounts:** Whether to clear `AccountRecords.txt` before running this test
- **Input:** Sequential commands that simulate user interaction
- **Expected:** Line-by-line expected program output
- **End:** Marks the end of the test case

#### Test Files Location
```
tests/
├── InCollege-Test.txt                    # Basic functionality tests
├── InCollege-ProfileCreation-Test.txt    # Profile creation and validation tests
└── [other test files...]
```

### Test Runner (`test_runner.py`)

The `tools/test_runner.py` script automates test execution and validation:

#### Features:
- **Automated Execution:** Runs the InCollege binary with test input files
- **Output Comparison:** Compares actual program output with expected results line-by-line
- **Account Reset:** Optionally clears account data between tests
- **Detailed Reporting:** Shows pass/fail status and highlights mismatches

#### Usage:
```bash
# Run all profile creation tests
python3 tools/test_runner.py tests/InCollege-ProfileCreation-Test.txt

# Run basic functionality tests
python3 tools/test_runner.py tests/InCollege-Test.txt

# Run with default test file
python3 tools/test_runner.py

# Export per-test inputs/outputs for a suite
python3 tools/test_runner.py --export tests/InCollege-ViewProfile-Tests.txt

# Run ALL test files and export inputs/outputs (quote the asterisk)
python3 tools/test_runner.py --export "*"
```

#### Example Output:
```
[1/3] Create complete profile with all fields
  PASS (86 lines)
[2/3] Missing required field validation
  FAIL at line 54
    expected: Error: First name is required and cannot be empty.
    actual  : Please enter your last name:
  (Tip: check ../data/InCollege-Output.txt)
[3/3] Optional fields can be left empty
  PASS (86 lines)

Summary: 2 passed, 1 failed, 3 total
```

#### Writing New Tests:
1. Create test cases in the appropriate test file using the standard format
2. Ensure input sequences provide all required data (profile creation needs 27+ input lines)
3. Match expected output exactly to program prompts and messages
4. Test both success scenarios and validation/error cases
5. Run tests frequently during development to catch regressions

### Exporting Test Inputs/Outputs

- Use the `--export` flag to write each test case's raw input and actual output to the project root under `export/`.
- File layout:
  - `export/input/<testfile-stem>-<case-number>.txt`
  - `export/output/<testfile-stem>-<case-number>.txt`
- The `<testfile-stem>` is the test file name without the `.txt` extension, and `<case-number>` is the 1-based index within that file.
- To export for all test files in `tests/`, run (note the quotes to avoid shell glob expansion):
  - `python3 tools/test_runner.py --export "*"`
- Running export multiple times overwrites existing files of the same name.
