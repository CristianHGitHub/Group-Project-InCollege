# COBOL Free Format Makefile for InCollege Project
# Compiler: GnuCOBOL (cobc)
# Format: Free format COBOL

# Compiler and flags
COBC = cobc
COBCFLAGS = -free -x -Wall -Wextra -std=cobol2014 -static
COBCFLAGS_OBJ = -free -c -Wall -Wextra -std=cobol2014

# Directories
SRCDIR = src
BINDIR = bin
COPYDIR = src/copy

# Source files
MAIN_SRC = $(SRCDIR)/InCollege.cob
CREATE_SRC = $(SRCDIR)/CreateAccount.cob
LOGIN_SRC = $(SRCDIR)/Login.cob
NAV_SRC = $(SRCDIR)/Navigation.cob

# Object files
MAIN_OBJ = $(BINDIR)/InCollege.o
CREATE_OBJ = $(BINDIR)/CreateAccount.o
LOGIN_OBJ = $(BINDIR)/Login.o
NAV_OBJ = $(BINDIR)/Navigation.o

# Executable
TARGET = $(BINDIR)/InCollege

# Default target
all: $(TARGET)

# Main executable - compile all modules together
$(TARGET): $(MAIN_SRC) $(CREATE_SRC) $(LOGIN_SRC) $(NAV_SRC)
	@echo "Compiling and linking $(TARGET)..."
	@mkdir -p $(BINDIR)
	$(COBC) $(COBCFLAGS) -I$(COPYDIR) -o $(TARGET) $(MAIN_SRC) $(CREATE_SRC) $(LOGIN_SRC) $(NAV_SRC)
	@echo "Build completed successfully!"

# Run the program
run: $(TARGET)
	@echo "Running $(TARGET)..."
	cd $(BINDIR) && ./InCollege

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -f $(BINDIR)/*.o
	rm -f $(BINDIR)/InCollege
	rm -f $(BINDIR)/InCollege.exe
	@echo "Clearing output file content..."
	@touch data/InCollege-Output.txt
	@echo "" > data/InCollege-Output.txt
	@echo "Removing temporary files..."
	rm -f *.tmp *.bak core *.log
	@echo "Removing bin directory if empty..."
	rmdir $(BINDIR) 2>/dev/null || true
	@echo "Clean completed!"

# Test compilation
test: $(TARGET)
	@echo "Testing compilation..."
	@if [ -f $(TARGET) ]; then \
		echo "✓ Compilation successful!"; \
		echo "✓ Executable created: $(TARGET)"; \
	else \
		echo "✗ Compilation failed!"; \
		exit 1; \
	fi

# Run test (compile and run with output)
run-test: $(TARGET)
	@echo "Running program test..."
	@echo "======================"
	cd $(BINDIR) && ./InCollege
	@echo "======================"
	@echo "✓ Program executed successfully!"
	@echo "✓ Output written to data/InCollege-Output.txt"

# Help
help:
	@echo "Available targets:"
	@echo "  all       - Build the project (default)"
	@echo "  run       - Build and run the program"
	@echo "  test      - Test compilation only"
	@echo "  run-test  - Build, run, and show output"
	@echo "  clean     - Remove all generated files and clear output files"
	@echo "  help      - Show this help message"

.PHONY: all run clean test run-test help
