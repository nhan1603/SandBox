param (
    [string]$file,        # Path to the executable
    [string]$output,      # Result file name
    [string]$hostFolder = "C:\Users\920322\Workspace\SandBox", #default host folder for the output
    [switch]$NoNetwork,   # Disable network
    [switch]$ReadOnly,    # Restrict file access
    [int]$timeout = 120   # Default timeout in seconds
)

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
# Exit the sandbox after execution
# Remain a timeout for ensuring output is done
$batchContent = @"
@echo off
cd C:\output
"$executableName" > "$output" 2>&1
timeout /t 2 /nobreak 
shutdown /s /t 0
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
if (-not (Test-Path $resultFilePath)) {
    New-Item -Path $resultFilePath -ItemType File -Force | Out-Null
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
    
    if ($fileContent) {
        Write-Host "Output detected!"
        Write-Host "Results saved to: $resultFilePath"
        Get-Content -Path $resultFilePath
        break
    }

    $elapsedTime = (Get-Date) - $startTime
    if ($elapsedTime.TotalSeconds -gt $timeout) {
        Write-Host "Timeout reached. No output detected."
        break
    }

    Write-Host "Waiting for output... ($([math]::Round($elapsedTime.TotalSeconds))/$timeout seconds elapsed)"
} while ($true)

# Cleanup
Remove-Item -Path $batchPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $sandboxFile -Force -ErrorAction SilentlyContinue

Write-Host "Execution completed."