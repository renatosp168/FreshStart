function Read-Configurations{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string] $configFilePath
    )

    $config = @{}

    Get-Content -Path $configFilePath | ForEach-Object {
        # Skip empty lines and comments (lines starting with #)
        if ($_ -match "^\s*#" -or $_ -match "^\s*$") {
            return
        }

        # Split each line into key and value based on the first '=' character
        $key, $value = $_ -split '=', 2

        # Trim any leading/trailing whitespace from the key and value
        $key = $key.Trim()
        $value = $value.Trim()

        # Add the key-value pair to the hashtable
        $config[$key] = $value
    }
    return $config
}