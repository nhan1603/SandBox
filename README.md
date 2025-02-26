# README for Sandbox Execution Tool Submission

## Overview

This repository contains the **Sandbox Execution Tool**, a PowerShell-based application designed to execute external executables in a controlled Windows Sandbox environment. The tool provides a graphical user interface (GUI) for ease of use and allows users to capture the output of the executed programs.

## Contents of the Submission

The following files are included in this submission:

1. **gui.ps1**:

   - The main PowerShell script that creates the graphical user interface for the Sandbox Execution Tool. This script allows users to select executables, specify output settings, and execute the selected program in a Windows Sandbox.

2. **Execute.ps1**:

   - A PowerShell script that handles the execution of the selected executable in the Windows Sandbox. It manages the configuration of the sandbox environment, including file paths, output redirection, and execution options.

3. **README.md**:
   - This README file, which provides an overview of the tool, installation instructions, usage guidelines, and details about the contents of the submission.

## Requirements

- **Windows 10/11**: The tool requires a Windows operating system with Windows Sandbox enabled.
- **PowerShell**: The tool is built using PowerShell and requires PowerShell to be installed.
- **Windows Sandbox**: Ensure that Windows Sandbox is enabled in your Windows Features.

## Installation Instructions

1. **Download the Repository**:

   - Clone or download this repository to your local machine.

2. **Enable Windows Sandbox**:
   - Ensure that Windows Sandbox is enabled in your Windows Features. You can do this by searching for "Turn Windows features on or off" in the Start menu and checking the box for Windows Sandbox.

## Running the Tool

1. **Open PowerShell**:

   - Press `Win + X` and select `Windows PowerShell` or `Windows Terminal`.

2. **Navigate to the Tool Directory**:

   - Use the `cd` command to change to the directory where the scripts are located:
     ```powershell
     cd C:\path\to\your\tool
     ```

3. **Launch the GUI**:
   - Run the GUI script to open the Sandbox Execution Tool:
     ```powershell
     .\gui.ps1
     ```

## Usage Instructions

1. **Select an Executable**:

   - Click the **Browse** button to select the executable file you want to run.

2. **Specify Output Settings**:

   - Enter the desired output file name (e.g., `output.txt`) and the host folder where the output will be saved.

3. **Configure Execution Options**:

   - Choose whether to disable network access and whether to set the sandbox to read-only mode. You can also specify a timeout for the execution.

4. **Execute**:
   - Click the **Execute in Sandbox** button to run the selected executable in the Windows Sandbox.

## Output

- The output of the executed program will be saved in the specified output file in the host folder.
- A message box will confirm the completion of the execution.

## Error Handling

- The tool includes validation checks to ensure that all required fields are filled and that the specified files and folders exist. Error messages will be displayed if any issues are encountered.

## Conclusion

The **Sandbox Execution Tool** provides a safe and efficient way to run executables in a controlled environment, capturing their output for further analysis. This tool is designed to run standalone without the need for Visual Studio or other packages, making it easy to use for faculty and students in computer science education.

For any questions or issues, please refer to the documentation or contact the developer.
