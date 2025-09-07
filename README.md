Below is a tentative outline for the InCollege program. For now, it will only consist of two directories, though this will be subject to change as the project progresses:

data/   # I/O files
    InCollege-Input.txt             # Sample input file
    InCollege-Test.txt              # Test input file
    InCollege-Output-Sample.txt     # Sample output file showing expected output
    InCollege-Output.txt            # Temporary file containing actual program output, produced during runtime

src/    # Modularized source code
    InCollege.cob                   # Main program that contains core logic
    ...                             # Various other subprograms called during main loop

Prerequisites:
- Docker Desktop
- Visual Studio Code with Dev Containers extension

Compilation:
Using a Dev Container in VS Code, open `src/InCollege.cob` and build the program by pressing `Ctrl+Shift+B`. This will create a binary executable in the `/bin` directory. Then, using the terminal, navigate to the `/bin` directory and run the program with `./InCollege`.

Preparation of Input File `InCollege-Input.txt`:
[TBD]
