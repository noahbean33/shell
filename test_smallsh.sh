#!/bin/bash

# A script to test the functionality of the smallsh program.

# Compile the program
gcc -o smallsh smallsh.c

if [ $? -ne 0 ]; then
    echo "Compilation failed. Exiting."
    exit 1
fi

echo "Compilation successful. Starting tests..."

# Create temporary files for testing
TEST_INPUT="test_input.txt"
TEST_OUTPUT="test_output.txt"
EXPECTED_OUTPUT="expected_output.txt"

# Cleanup function to remove temporary files
cleanup() {
    rm -f smallsh "$TEST_INPUT" "$TEST_OUTPUT" "$EXPECTED_OUTPUT" test_dir_file.txt
}

# Test 1: Basic command and output redirection
echo "--- Test 1: Basic command & output redirection ---"
(echo "ls > $TEST_OUTPUT"; echo "exit") | ./smallsh > /dev/null
if [ -f "$TEST_OUTPUT" ]; then
    echo "SUCCESS: Output file created."
else
    echo "FAILURE: Output file not created."
fi

# Test 2: Status command
echo "--- Test 2: 'status' command ---"
(echo "ls > /dev/null"; echo "status"; echo "exit") | ./smallsh > "$TEST_OUTPUT"
grep -q "exit value 0" "$TEST_OUTPUT"
if [ $? -eq 0 ]; then
    echo "SUCCESS: 'status' reported exit value 0 for successful command."
else
    echo "FAILURE: 'status' did not report exit value 0."
fi

(echo "badcommand"; echo "status"; echo "exit") | ./smallsh > "$TEST_OUTPUT" 2>/dev/null
grep -q "exit value 1" "$TEST_OUTPUT"
if [ $? -eq 0 ]; then
    echo "SUCCESS: 'status' reported exit value 1 for failed command."
else
    echo "FAILURE: 'status' did not report exit value 1."
fi

# Test 3: Input redirection
echo "--- Test 3: Input redirection ---"
echo "Hello World" > "$TEST_INPUT"
(echo "wc < $TEST_INPUT"; echo "exit") | ./smallsh > "$TEST_OUTPUT"
grep -q "1       2      12" "$TEST_OUTPUT"
if [ $? -eq 0 ]; then
    echo "SUCCESS: Input redirection with 'wc' worked as expected."
else
    echo "FAILURE: Input redirection failed."
fi

# Test 4: Comments and blank lines
echo "--- Test 4: Comments and blank lines ---"
(echo "# This is a comment"; echo ""; echo "echo 'Success'"; echo "exit") | ./smallsh > "$TEST_OUTPUT"
grep -q "Success" "$TEST_OUTPUT"
if [ $? -eq 0 ]; then
    echo "SUCCESS: Comments and blank lines are ignored."
else
    echo "FAILURE: Comments and blank lines were not handled correctly."
fi

# Test 5: Background command
echo "--- Test 5: Background command '&' ---"
(echo "sleep 1 &"; echo "exit") | ./smallsh > "$TEST_OUTPUT"
grep -q "background pid" "$TEST_OUTPUT"
if [ $? -eq 0 ]; then
    echo "SUCCESS: Background process started and PID was printed."
else
    echo "FAILURE: Background process did not start as expected."
fi

# Test 6: 'cd' command
echo "--- Test 6: 'cd' command ---"
ORIGINAL_DIR=$(pwd)
(echo "mkdir test_dir"; echo "cd test_dir"; echo "pwd > ../test_dir_file.txt"; echo "exit") | ./smallsh > /dev/null
if [ -f "test_dir_file.txt" ] && grep -q "test_dir" "test_dir_file.txt"; then
    echo "SUCCESS: 'cd' to a specific directory works."
else
    echo "FAILURE: 'cd' to a specific directory failed."
fi
rm -rf test_dir

# Final cleanup
cleanup
echo "--- Tests complete --- "
