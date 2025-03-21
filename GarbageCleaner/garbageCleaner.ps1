# Function to check if the script is running as an administrator
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Restart the script as an administrator if not already running as one
if (-not (Test-Admin)) {
    Write-Host "Script is not running as an administrator. Restarting with elevated privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


### Define the path to the configuration file
$ConfigFilePath = ".\config.json"

# Check if the configuration file exists
if (-Not (Test-Path $ConfigFilePath)) {
    Write-Host "Configuration file not found at $ConfigFilePath. Exiting script."
    exit
}

# Read the configuration file
try {
    $jsonTemplate = Get-Content -Path $ConfigFilePath -Raw
    $jsonContent = $jsonTemplate -replace '{{localAPP}}', $env:LOCALAPPDATA `
                                    -replace '{{userProfile}}', $env:USERPROFILE `
                                    -replace '{{systemRoot}}', $env:SystemRoot

    $Config =  $jsonContent | ConvertFrom-Json
} catch {
    Write-Host "Failed to read or parse the configuration file. Please ensure it is valid JSON. Exiting script."
    exit
}
Write-Host "Script is running with administrator privileges."

# Clean custom directories
try {
    foreach ($dirObject in $Config.customDirectories) {
        try {
            $path = $dirObject.path
            Write-Host "Cleaning up: $path"
            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Invalid directory to clean: $dirObject"
        }
    }
} catch {
    Write-Host "No custom locations to clean!"
}

# Esvaziar lixeira
try{
    if($config.cleanUpRecycle){
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Host "Won't clean up recycle bin"
}
Write-Host "Clean-up completed!"