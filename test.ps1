param (
    [string]$file,        # Path to the executable
    [string]$output,      # Result file name
    [string]$hostFolder = "C:\Users\920322\Workspace\SandBox", # Default host folder for the output
    [switch]$NoNetwork,   # Disable network
    [switch]$ReadOnly,    # Restrict file access
    [int]$timeout = 120   # Default timeout in seconds
)

# Function to check if parameters were explicitly provided
function Test-HasNoArguments {
    return ($PSBoundParameters.Count -eq 0 -and $args.Count -eq 0)
}

# Check if any arguments were passed
if ($PSBoundParameters.Count -eq 0) {
    Write-Host $PSBoundParameters.Count
    Write-Host "No parameters were provided."
    exit
} else {
    Write-Host "Number of provided parameters: $($PSBoundParameters.Count)"
    Write-Host "Parameters were provided."
}
