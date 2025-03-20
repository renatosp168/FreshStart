# Define the path to the configuration file
$configFilePath = ".\config.json"

# Check if the configuration file exists
if (-Not (Test-Path $configFilePath)) {
    Write-Host "Configuration file not found at $configFilePath. Exiting script."
    exit
}

# Read the configuration file
try {
    $config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
} catch {
    Write-Host "Failed to read or parse the configuration file. Please ensure it is valid JSON. Exiting script."
    exit
}

# Define the repository URL and get the target directory from the configuration file
$repoUrl = "https://github.com/renatosp168/MIP.git"
$targetDir = $config.targetDir

# Check if the target directory exists, if not create it
if (-Not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir
}

# Clone the repository into the target directory
git clone $repoUrl $targetDir

# Check if the clone was successful
if ($?) {
    Write-Host "Repository cloned successfully to $targetDir"
} else {
    Write-Host "Failed to clone repository"
}