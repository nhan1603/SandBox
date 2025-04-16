param (
    [string]$file,        # Path to the executable
    [string]$output,      # Result file name
    [string]$hostFolder = "C:\Users", # Default host folder for the output
    [string]$execParams = "", # Parameters for the executable
    [switch]$NoNetwork,   # Disable network
    [switch]$ReadOnly,    # Restrict file access
    [int]$timeout = 120   # Default timeout in seconds
)

#  THIS SOMEHOW DOES NOT WORK, need to double check
# Function to check if the program has no argument provided
# function Test-HasNoArguments {
#     return ($PSBoundParameters.Count -eq 0)
# }

# Parameter count: https://stackoverflow.com/questions/59657293/how-to-check-number-of-arguments-in-powershell
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.5#psboundparameters
# If no parameters provided, launch GUI
if ($PSBoundParameters.Count -eq 0) {
    # Load GUI script from the same directory as this script
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $guiPath = Join-Path $scriptPath "gui.ps1"
    
    if (Test-Path $guiPath) {
        & $guiPath
        exit
    } else {
        Write-Host "No parameter found. Exitting the program."
        exit 1
    }
}

# Check if the file is valid: 
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-5.1
# Validate parameters
if (-not (Test-Path $file)) {
    Write-Host "The specified file does not exist: $file"
    exit 1
}

if (-not (Test-Path $hostFolder)) {
    # Write into console
    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-host?view=powershell-5.1
    Write-Host "The specified host folder does not exist: $hostFolder"
    exit 1
}

# If condition: https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-if?view=powershell-7.5
# Network setting
$networkSetting = if ($NoNetwork) { 'Disable' } else { 'Enable' }

# Read policy setting
$readPolicy = if ($ReadOnly) { 'true' } else { 'false' }

# File path processing: https://stackoverflow.com/questions/35813186/extract-the-filename-from-a-path
$sandboxFile = Join-Path -Path $hostFolder -ChildPath "sandbox.wsb"
$executableName = Split-Path $file -Leaf

# Create a batch script to run the executable
# Syntax to run the executable and out put into the file
# Ref: https://ss64.com/nt/syntax-redirection.html
$batchContent = @"
@echo off
cd C:\output
"$executableName" $execParams > "$output" 2>&1
timeout /t 2 /nobreak > nul
echo Done > execution_complete.txt
"@

$batchPath = Join-Path -Path $hostFolder -ChildPath "run.bat"
$batchContent | Set-Content -Path $batchPath -Force -Encoding ASCII

# Sample config: https://techcommunity.microsoft.com/blog/windowsosplatform/windows-sandbox---config-files/354902
# Create the sandbox configuration content
$sandboxConfig = @"
<Configuration>
  <Networking>$networkSetting</Networking>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>$hostFolder</HostFolder>
      <SandboxFolder>C:\output</SandboxFolder>
      <ReadOnly>$readPolicy</ReadOnly>
    </MappedFolder>
  </MappedFolders>
  <LogonCommand>
    <Command>cmd.exe /c C:\output\run.bat</Command>
  </LogonCommand>
</Configuration>
"@

# Write the configuration to the sandbox.wsb file
$sandboxConfig | Set-Content -Path $sandboxFile -Force

# Check if the executable is already in the host folder
$targetExecutablePath = Join-Path -Path $hostFolder -ChildPath $executableName
$executableAlreadyExists = Test-Path $targetExecutablePath

# Copy the executable to the host folder only if it doesn't already exist
if (-not $executableAlreadyExists) {
    Write-Host "Copying executable to host folder..."
    Copy-Item -Path $file -Destination "$hostFolder\$executableName" -Force
}

# Create the output file
$resultFilePath = Join-Path -Path $hostFolder -ChildPath $output
$executionFile = Join-Path -Path $hostFolder -ChildPath $executableName
$completionFlag = Join-Path -Path $hostFolder -ChildPath "execution_complete.txt"

if (-not (Test-Path $resultFilePath)) {
    New-Item -Path $resultFilePath -ItemType File -Force | Out-Null
}

# Remove completion flag if it exists from previous run
if (Test-Path $completionFlag) {
    Remove-Item -Path $completionFlag -Force
}

# Launch the Windows Sandbox
Write-Host "Launching Windows Sandbox..."
$process = Start-Process -FilePath "C:\Windows\System32\WindowsSandbox.exe" -ArgumentList $sandboxFile -PassThru

# Wait and check for output
$startTime = Get-Date
Write-Host "Waiting for output (timeout: $timeout seconds)..."

do {
    # Wait 5 second to check for status
    Start-Sleep -Seconds 5
    # Check if file content is available
    $fileContent = Get-Content -Path $resultFilePath -ErrorAction SilentlyContinue
    $isComplete = Test-Path $completionFlag
    
    if ($fileContent -and $isComplete) {
        Write-Host "Results saved to: $resultFilePath"
        # Get-Content -Path $resultFilePath

        # Force close the sandbox silently with no output
        # taskkill /F /IM WindowsSandboxClient.exe /T >$null 2>&1
        # https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/taskkill
        # Prevent the taskkill result from the console: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/out-null
        cmd /c taskkill /F /IM WindowsSandboxClient.exe /T | Out-Null
        break
    }

    $elapsedTime = (Get-Date) - $startTime
    if ($elapsedTime.TotalSeconds -gt $timeout) {
        Write-Host "Timeout reached. No output detected."
        # Force close the sandbox on timeout
         cmd /c taskkill /F /IM WindowsSandboxClient.exe /T | Out-Null
        break
    }
} while ($true)

# Cleanup the preparation after finishing
Remove-Item -Path $batchPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $sandboxFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $completionFlag -Force -ErrorAction SilentlyContinue
# Only remove the executable if it is a copy for execution
if (-not $executableAlreadyExists) {
    Remove-Item -Path $executionFile -Force -ErrorAction SilentlyContinue
}


Write-Host "Execution completed."