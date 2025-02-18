param (
    [string]$file,        # Path to the executable
    [string]$output,      # Result file name
    [switch]$NoNetwork,   # Disable network
    [switch]$ReadOnly     # Restrict file access
)

# Validate parameters
if (-not (Test-Path $file)) {
    Write-Host "The specified file does not exist: $file"
    exit 1
}

# Define the host folder for output
$hostFolder = "C:\path\to\your\output\folder"
$sandboxFile = "sandbox.wsb"

# Create the sandbox configuration content
$sandboxConfig = @"
<Configuration>
  <Networking>$($NoNetwork ? 'Disable' : 'Enable')</Networking>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>$hostFolder</HostFolder>
      <SandboxFolder>C:\output</SandboxFolder>
      <ReadOnly>$($ReadOnly ? 'true' : 'false')</ReadOnly>
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
Start-Sleep -Seconds 10  # Adjust this as necessary for your executable's runtime

# Display the results
$resultFilePath = Join-Path -Path $hostFolder -ChildPath $output
if (Test-Path $resultFilePath) {
    Write-Host "Results saved to: $resultFilePath"
    Get-Content -Path $resultFilePath
} else {
    Write-Host "Output file not found: $resultFilePath"
}