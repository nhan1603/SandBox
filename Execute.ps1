param (
    [string]$file,        # Path to the executable
    [string]$output,      # Result file name
    [string]$hostFolder = "C:\Users\920322\Workspace\SandBox", #default host folder for the output
    [switch]$NoNetwork,   # Disable network
    [switch]$ReadOnly     # Restrict file access
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

$sandboxFile = "sandbox.wsb"

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
    <Command>cmd.exe /c start /wait C:\output\$(Split-Path $file -Leaf) > C:\output\$output</Command>
  </LogonCommand>
  <Security>
    <UserAccountControl>Enabled</UserAccountControl>
    <RestrictAccessToSystemResources>true</RestrictAccessToSystemResources>
  </Security>
</Configuration>
"@

# Write the configuration to the sandbox.wsb file
$sandboxConfig | Set-Content -Path $sandboxFile

# Copy the executable to the host folder
Copy-Item -Path $file -Destination "$hostFolder\$(Split-Path $file -Leaf)" -Force

# Launch the Windows Sandbox
Start-Process -FilePath "C:\Windows\System32\WindowsSandbox.exe" -ArgumentList $sandboxFile

# Wait for the sandbox to finish execution
Start-Sleep -Seconds 30

# Create the output file in the host folder before running the executable
$resultFilePath = Join-Path -Path $hostFolder -ChildPath $output
 
# Create an empty output file if it doesn't exist
if (-not (Test-Path $resultFilePath)) {
    New-Item -Path $resultFilePath -ItemType File -Force | Out-Null
    Write-Host "Created empty output file at: $resultFilePath"
}

# Output the result
Write-Host "Looking for output file at: $resultFilePath"
if (Test-Path $resultFilePath) {
    Write-Host "Results saved to: $resultFilePath"
    Get-Content -Path $resultFilePath
} else {
    Write-Host "Output file not found: $resultFilePath"
}