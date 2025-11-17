# smallsh

A simple shell written in C that implements a subset of features from shells like `bash`.

## Features

*   Provides a prompt for running commands.
*   Handles blank lines and comments (lines beginning with `#`).
*   Includes three built-in commands: `exit`, `cd`, and `status`.
*   Executes other commands by creating new processes using the `exec()` family of functions.
*   Supports input and output redirection (`<` and `>`).
*   Supports running commands in both the foreground and background (`&`).
*   Implements custom handlers for `SIGINT` (Ctrl+C) and `SIGTSTP` (Ctrl+Z) signals.

## Usage

The general syntax for a command is:

```
command [arg1 arg2 ...] [< input_file] [> output_file] [&]
```

*   **Command Prompt:** The shell uses the colon `:` symbol as the prompt.
*   **Comments & Blank Lines:** Lines starting with `#` and blank lines are ignored.
*   **Built-in Commands:**
    *   `exit`: Exits the shell, terminating any running jobs.
    *   `cd [directory]`: Changes the current working directory. With no arguments, it changes to the `HOME` directory.
    *   `status`: Prints the exit status or terminating signal of the last foreground process.
*   **Executing Other Commands:**
    *   Any command that is not built-in is executed in a new process.
    *   The shell uses the `PATH` environment variable to find executables.
*   **I/O Redirection:**
    *   `< input_file`: Redirects standard input from `input_file`.
    *   `> output_file`: Redirects standard output to `output_file`.
*   **Background Processes:**
    *   Appending `&` to a command runs it in the background.
    *   The shell will print the process ID of the background job.
    *   Input/output for background commands is redirected to `/dev/null` if not otherwise specified.
*   **Signal Handling:**
    *   `SIGINT` (Ctrl+C): Ignored by the shell and background processes. Terminates a foreground process.
    *   `SIGTSTP` (Ctrl+Z): Toggles a foreground-only mode where the `&` operator is ignored.

## Example

```
$ smallsh
: ls
junk   smallsh    smallsh.c
: ls > junk
: status
exit value 0
: cat junk
junk
smallsh
smallsh.c
: sleep 5
^Cterminated by signal 2
: sleep 15 &
background pid is 4923
: 
background pid 4923 is done: exit value 0
: ^Z
Entering foreground-only mode (& is now ignored)
: sleep 5 &
: ^Z
Exiting foreground-only mode
: exit
$
```
