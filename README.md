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

### View My Profile Feature

The View My Profile feature allows logged-in users to view their complete profile information. The feature displays:

- **Personal Information**: First name, last name, university, major, graduation year
- **About Me**: Optional personal description
- **Experience**: Up to 3 work experience entries (title, company, dates, description)
- **Education**: Up to 3 education entries (degree, university, years)

#### Key Features:

- **Unified Output**: Every line shown on console is written identically to the output file
- **Smart Display**: Shows "None" for empty experience/education sections
- **Missing Profile Handling**: Displays "You have not created a profile yet." for users without profiles
- **Consistent Formatting**: Uses standard headers and separators for readability

#### Profile Data Format:

Profiles are stored in `ProfileRecords.txt` using pipe-delimited format:

```
username|first_name|last_name|university|major|grad_year|about_me|exp1_title|exp1_company|exp1_dates|exp1_desc|exp2_title|...|edu3_years
```

#### Sample Output:

```
--- Your Profile ---
Name: John Doe
University: University of South Florida
Major: Computer Science
Graduation Year: 2025
About Me: Passionate about software development.
Experience:
  Title: Software Intern
  Company: Tech Solutions Inc
  Dates: Summer 2024
  Description: Developed web applications using modern frameworks.
Education:
  Degree: Bachelor of Science
  University: University of South Florida
  Years: 2021-2025
--------------------
Returning to Main Menu...
```

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
│   ├── ViewProfile.cob   # Profile viewing module
│   ├── ProfileStorage.cob # Profile storage module
│   ├── PROFILE-STORAGE-LOAD.cob # Profile loading module
│   └── copy/             # Copybook directory
│       └── AccountRecord.cpy
├── bin/                  # Generated executables
└── data/                 # Data files
    ├── InCollege-Input.txt
    ├── InCollege-Output.txt
    ├── AccountRecords.txt
    ├── ProfileRecords.txt
    ├── JobPostings.txt
    ├── applications.dat   # Persistent job applications
    └── Messages.txt       # Persistent private messages
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

## Job Board & Applications
## Messages

### Overview

- A new `Messages` option appears in the post-login main menu.
- `Send a New Message` lets you send a private message to a connected user only.
- All prompts and responses are mirrored to `data/InCollege-Output.txt` via the same dual-output helper.
 - Messages are limited to 200 characters; longer inputs are truncated to 200 with a note: `Note: Message truncated to 200 characters.`

### Typical Input Snippet

```
Log In
userA
Abcdef1!
Messages
Send a New Message
userB
Hello!
```

Expected confirmation:

```
Message sent to userB successfully!
```

Long message example (over 200 characters triggers truncation note):

```
Log In
userA
Abcdef1!
Messages
Send a New Message
userB
This is a very long message that exceeds two hundred characters to demonstrate truncation behavior in the messaging system. It should be shortened and a note displayed to the user indicating truncation has occurred.
```

Expected additional output before confirmation:

```
Note: Message truncated to 200 characters.
Message sent to userB successfully!
```

### Overview

- The `Job search/internship` menu now provides a complete workflow:
  - `Post a Job/Internship`
  - `Browse Jobs/Internships`
  - `View My Applications`
  - `Go Back` to the main menu
- Browse shows every posting with numbering, title, employer, and location.
- Selecting a job displays full details (title, description, employer, location, salary).
- Users can apply directly from the detail view; duplicate applications are prevented.
- All prompts and responses still flow through file-based input and mirrored output.

### Data Files

- Job postings persist in `data/JobPostings.txt` using pipe-delimited records:

  ```
  JobID|username|title|description|employer|location|salary
  ```

  Example:

  ```
  1|userA|Software Intern|API work|InCollege Inc|Remote|Salary: $25/hour
  ```

- Applications persist in `data/applications.dat`:

  ```
  ApplicationID|username|JobID
  ```

- Private messages persist in `data/Messages.txt`:

  ```
  sender|recipient|message|timestamp
  ```

  Example:

  ```
  userA|userB|Hello, congrats!|2025-10-30 14:05:33
  ```

### Typical Input Snippet

```
Log In
userA
Abcdef1!
Job
Post a Job/Internship
Software Intern
API work on core features
InCollege Inc
Remote
$25/hour
Job
Browse Jobs/Internships
1
Apply for this Job
View My Applications
```

### Reports (`View My Applications`)

- Generates a screen/file report formatted as:

  ```
  --- Your Job Applications ---
  Application Summary for userA
  ------------------------------
  Job Title: Software Intern
  Employer: InCollege Inc
  Location: Remote
  ---
  Total Applications: 1
  ------------------------------
  ```

- Uses the same dual-output helper to ensure console and `data/InCollege-Output.txt` stay identical.

### Validation & Test Coverage

- Required job fields (title, description, employer, location) are enforced; salary defaults to `Salary: NONE` when blank.
- `tests/InCollege-JobPosting-Tests.txt` covers posting validation and salary handling.
- `tests/InCollege-JobPersistence-Tests.txt` ensures JobID sequencing survives restarts.
- `tests/InCollege-Epic7-JobBrowsing-Comprehensive-Tests.txt` and `tests/InCollege-Epic7-JobBrowsing-EdgeCases-Tests.txt` validate browsing, detail view, and error handling.
- `tests/InCollege-JobApplication-Tests.txt` and `tests/InCollege-Epic7-JobApplication-Persistence-Tests.txt` cover applying, duplicate prevention, and persistence.
- `tests/InCollege-ApplicationReport-Tests.txt` verifies the report for zero, single, and multiple applications.

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
- **File Assertions:** Optionally asserts exact contents of data files (e.g., JobPostings.txt)

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

#### File Assertions (ExpectFile)

Add file checks inside the Expected: block to validate persistent files:

```
Expected:
... normal expected output lines ...
ExpectFile: ../data/JobPostings.txt
1|userA|First Title|First Description|FirstCo|Remote|Salary: NONE
2|userA|Second Title|Second Description|SecondCo|New York, NY|Salary: NONE
EndFile
End
```

Notes:
- When `ResetAccounts: yes` is set, the runner also truncates `../data/JobPostings.txt` to avoid leftover entries.

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
