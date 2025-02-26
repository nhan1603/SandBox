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

Write-Host $execParams

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

# Validate parameters
if (-not (Test-Path $file)) {
    Write-Host "The specified file does not exist: $file"
    exit 1
}

if (-not (Test-Path $hostFolder)) {
    Write-Host "The specified host folder does not exist: $hostFolder"
    exit 1
}

# Network setting
$networkSetting = if ($NoNetwork) { 'Disable' } else { 'Enable' }

# Read policy setting
$readPolicy = if ($ReadOnly) { 'true' } else { 'false' }

$sandboxFile = Join-Path -Path $hostFolder -ChildPath "sandbox.wsb"
$executableName = Split-Path $file -Leaf

# Create a batch script to run the executable
$batchContent = @"
@echo off
cd C:\output
"$executableName" $execParams > "$output" 2>&1
timeout /t 2 /nobreak > nul
echo Done > execution_complete.txt
"@

$batchPath = Join-Path -Path $hostFolder -ChildPath "run.bat"
$batchContent | Set-Content -Path $batchPath -Force -Encoding ASCII

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
  <Security>
    <UserAccountControl>Enabled</UserAccountControl>
    <RestrictAccessToSystemResources>true</RestrictAccessToSystemResources>
  </Security>
</Configuration>
"@

# Write the configuration to the sandbox.wsb file
$sandboxConfig | Set-Content -Path $sandboxFile -Force

# Copy the executable to the host folder
Copy-Item -Path $file -Destination "$hostFolder\$executableName" -Force

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
    Start-Sleep -Seconds 5
    $fileContent = Get-Content -Path $resultFilePath -ErrorAction SilentlyContinue
    $isComplete = Test-Path $completionFlag
    
    if ($fileContent -and $isComplete) {
        Write-Host "Results saved to: $resultFilePath"
        # Get-Content -Path $resultFilePath

        # Force close the sandbox silently with no output
        # taskkill /F /IM WindowsSandboxClient.exe /T >$null 2>&1
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

# Cleanup
Remove-Item -Path $batchPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $sandboxFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $completionFlag -Force -ErrorAction SilentlyContinue
Remove-Item -Path $executionFile -Force -ErrorAction SilentlyContinue

Write-Host "Execution completed."