# README for Sandbox Execution Tool

## Overview

The **Sandbox Execution Tool** is a PowerShell-based application designed to execute external executables in a controlled Windows Sandbox environment. This tool allows users to run potentially unsafe executables without risking their main system, while capturing the output for analysis and verification.

Windows Sandbox provides an isolated, temporary environment where software can be run safely and then discarded after use. This makes it ideal for testing untrusted executables, examining program behavior, or validating command-line outputs.

## Key Features

- **Execute External Programs**: Run any executable file in a Windows Sandbox
- **Command-line Parameter Support**: Pass custom parameters to your executable
- **Output Capture**: Redirect the output of the executable to a specified file
- **Network Control**: Option to disable network access for the sandboxed application
- **Read-Only Mode**: Restrict file access to the mapped folder
- **Timeout Setting**: Specify a timeout for the execution to prevent hanging processes
- **User-Friendly GUI**: Simple interface for selecting files and configuring options

## Contents of the Submission

The following files are included in this submission:

1. **Execute.ps1**:
   - The main PowerShell script that handles the execution of selected executables in the Windows Sandbox
   - Can be run with parameters for direct execution or without parameters to launch the GUI
   - Manages the configuration of the sandbox environment, including file paths, parameters, output redirection, and execution options

2. **gui.ps1**:
   - Creates the graphical user interface for the Sandbox Execution Tool
   - Allows users to select executables, specify parameters, configure output settings, and execute programs in a Windows Sandbox

3. **README.md**:
   - This README file providing an overview of the tool, installation instructions, usage guidelines, and details about the submission contents

4. **SandBox Manual.pdf**:
   - Comprehensive manual with step-by-step instructions on how to use the Sandbox Execution Tool

5. **SampleFile**:
   - Folder containing sample executables for testing the sandbox environment
   - Includes examples demonstrating different use cases for the tool

## Requirements

- **Windows 10/11**: The tool requires a Windows operating system with Windows Sandbox enabled
- **PowerShell**: The tool is built using PowerShell and requires PowerShell to be installed
- **Windows Sandbox**: Ensure that Windows Sandbox is enabled in your Windows Features

## Installation Instructions

1. **Download the Repository**:
   - Clone or download this repository to your local machine

2. **Enable Windows Sandbox**:
   - Ensure that Windows Sandbox is enabled in your Windows Features
   - You can do this by searching for "Turn Windows features on or off" in the Start menu and checking the box for Windows Sandbox
   - A system restart may be required after enabling this feature

## Running the Tool

1. **Open PowerShell**:
   - Press `Win + X` and select `Windows PowerShell`

2. **Navigate to the Tool Directory**:
   - Use the `cd` command to change to the directory where the scripts are located:
     ```powershell
     cd C:\path\to\your\tool
     ```

3. **Launch the tool with GUI**:
   - Run the script without parameters to open the Sandbox Execution Tool GUI:
     ```powershell
     .\Execute.ps1
     ```

4. **Launch the tool manually**:
   - Run the script with parameters to directly execute in sandbox mode:
     ```powershell
     .\Execute.ps1 -file "C:\path\to\your\executable.exe" -execParams "--param1 -param2" -output "output_file.txt" -hostFolder "C:\path\to\output\folder" -NoNetwork -timeout 20 
     ```

## Usage Instructions

1. **Select an Executable**:
   - Click the **Browse** button to select the executable file you want to run

2. **Specify Parameters** (if needed):
   - Enter any command-line parameters required by your executable
   - For example: `--verbose --output=json --no-cache`

3. **Specify Output Settings**:
   - Enter the desired output file name (e.g., `output.txt`) where program results will be saved
   - Select the host folder where the output file will be stored

4. **Configure Execution Options**:
   - Choose whether to disable network access for added security
   - Set read-only mode to prevent the executable from modifying files
   - Specify a timeout (in seconds) for the execution to prevent infinite loops or hanging processes

5. **Execute**:
   - Click the **Execute in Sandbox** button to run the selected executable in the Windows Sandbox
   - The sandbox will open briefly while executing the program
   - When complete, the sandbox will automatically close and a success message will appear

## Output

- The output of the executed program will be saved in the specified output file in the host folder
- This includes both standard output (stdout) and error output (stderr)
- A message box will confirm the completion of the execution

## Error Handling

- The tool includes validation checks to ensure that all required fields are filled and that the specified files and folders exist
- Error messages will be displayed if any issues are encountered
- Common errors include invalid file paths, non-existent folders, and timeout issues

## Conclusion

The **Sandbox Execution Tool** provides a safe and efficient way to run executables in a controlled environment, capturing their output for further analysis. This tool is designed to run standalone without the need for Visual Studio or other packages, making it easy to use for faculty and students in computer science education.

For any questions or issues, please refer to the included manual or contact the developer.