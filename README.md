## InCollege Program Outline

This is a tentative outline for the InCollege program. The structure may change as the project progresses.

```
data/   # I/O files
│
├── InCollege-Input.txt             # Sample input file
├── InCollege-Test.txt              # Test input file
├── InCollege-Output-Sample.txt     # Sample output file showing expected output
└── InCollege-Output.txt            # Temporary file containing actual program output, produced during runtime

src/    # Modularized source code
│
├── InCollege.cob                   # Main program that contains core logic
└── ...                             # Various other subprograms called during main loop
```

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

### Preparation of Input File `InCollege-Input.txt`

The input file should contain commands for the program to execute. Each command should be on a new line. Below are some examples of valid input sequences:
```
Create New Account
nick
PASWRD123!
```
```
Log In
nick
PASWRD123!
```

Note: The Log In and Create New Account commands should be followed by a username and password on separate lines. The Log In sequence will fail if the account does not have a corresponding record in `AccountRecords.txt`.