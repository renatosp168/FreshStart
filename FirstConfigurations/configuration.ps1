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

Write-Host "Script is running with administrator privileges."

### Define the path to the configuration file
$ConfigFilePath = ".\config.json"

# Check if the configuration file exists
if (-Not (Test-Path $ConfigFilePath)) {
    Write-Host "Configuration file not found at $ConfigFilePath. Exiting script."
    exit
}

# Read the configuration file
try {
    $Config = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
} catch {
    Write-Host "Failed to read or parse the configuration file. Please ensure it is valid JSON. Exiting script."
    exit
}

### Configure DNS
try {
    $PrimaryDNS = $Config.dns.primary
    $SecondaryDNS = $Config.dns.secondary

    Write-Host "DNS servers read from configuration file:"
    Write-Host "Primary DNS: $PrimaryDNS"
    Write-Host "Secondary DNS: $SecondaryDNS"

    # Get all network interfaces that are enabled and have IPv4 enabled
    $Interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and ($_.GetNetIPConfiguration().IPv4Address -ne $null) }

    # Loop through each interface and set the DNS servers
    foreach ($Interface in $Interfaces) {
        $InterfaceName = $Interface.Name
        Write-Host "Configuring DNS for interface: $InterfaceName"

        # Set the DNS servers
        Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses ($PrimaryDNS, $SecondaryDNS)

        Write-Host "DNS configured for $InterfaceName with $PrimaryDNS and $SecondaryDNS"
    }

    Write-Host "DNS configuration completed."
} catch {
    Write-Host "Skipping DNS configuration due to an error: $_"
}

### Configure Dark Mode
try {
    $lightmode = $Config.lightmode
    if ($lightmode -eq 0 -or $lightmode -eq 1) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value $lightmode
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value $lightmode
        Write-Host "Theme has been set to $(if ($lightmode -eq 0) { 'Dark Mode' } else { 'Light Mode' })."
    } else {
        throw "Invalid lightmode value in the configuration file. Expected 0 or 1, but found $lightmode."
    }
} catch {
    Write-Host "Skipping dark mode configuration due to an error: $_"
}

### Disable Task View, Search Bar, and Widgets
try {
    # Disable Task View
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
    # Hide Search Bar from Taskbar
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0
    # Turn Off Widgets
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0
    Write-Host "Task View, Search Bar, and Widgets have been disabled."
} catch {
    Write-Host "Skipping Task View, Search Bar, and Widgets configuration due to an error: $_"
}

### Disable Cortana
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaEnabled" -Value 0
    Write-Host "Cortana has been disabled."
} catch {
    Write-Host "Skipping Cortana disable due to an error: $_"
}

### Disable Bing Search in Start Menu
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
    Write-Host "Bing Search in Start Menu has been disabled."
} catch {
    Write-Host "Skipping Bing Search disable due to an error: $_"
}

### Disable Recent Files and Frequent Folders
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0
    Write-Host "Recent Files and Frequent Folders have been disabled."
} catch {
    Write-Host "Skipping Recent Files and Frequent Folders disable due to an error: $_"
}

### Disable Windows Tips and Suggestions
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Value 0
    Write-Host "Windows Tips and Suggestions have been disabled."
} catch {
    Write-Host "Skipping Windows Tips and Suggestions disable due to an error: $_"
}

### Disable OneDrive
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1
    Write-Host "OneDrive has been disabled."
} catch {
    Write-Host "Skipping OneDrive disable due to an error: $_"
}

### Disable Game Bar
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
    Write-Host "Game Bar has been disabled."
} catch {
    Write-Host "Skipping Game Bar disable due to an error: $_"
}

### Disable Aero Shake
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Value 1
    Write-Host "Aero Shake has been disabled."
} catch {
    Write-Host "Skipping Aero Shake disable due to an error: $_"
}

### Disable Fast Startup
try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0
    Write-Host "Fast Startup has been disabled."
} catch {
    Write-Host "Skipping Fast Startup disable due to an error: $_"
}

### Disable Hibernation
try {
    powercfg /hibernate off
    Write-Host "Hibernation has been disabled."
} catch {
    Write-Host "Skipping Hibernation disable due to an error: $_"
}

### Disable Remote Assistance
try {
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 0
    Write-Host "Remote Assistance has been disabled."
} catch {
    Write-Host "Skipping Remote Assistance disable due to an error: $_"
}

### Disable Shared Experiences
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "EnableCdp" -Value 0
    Write-Host "Shared Experiences have been disabled."
} catch {
    Write-Host "Skipping Shared Experiences disable due to an error: $_"
}

### Disable Location Tracking
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1
    Write-Host "Location Tracking has been disabled."
} catch {
    Write-Host "Skipping Location Tracking disable due to an error: $_"
}

### Disable Advertising ID
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
    Write-Host "Advertising ID has been disabled."
} catch {
    Write-Host "Skipping Advertising ID disable due to an error: $_"
}

### Disable Windows Timeline
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0
    Write-Host "Windows Timeline has been disabled."
} catch {
    Write-Host "Skipping Windows Timeline disable due to an error: $_"
}

### Disable Windows Tips on Lock Screen
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Value 0
    Write-Host "Windows Tips on Lock Screen have been disabled."
} catch {
    Write-Host "Skipping Windows Tips on Lock Screen disable due to an error: $_"
}

### Disable Windows Narrator
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -Value 0
    Write-Host "Windows Narrator has been disabled."
} catch {
    Write-Host "Skipping Windows Narrator disable due to an error: $_"
}

### Disable Windows Game Mode
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0
    Write-Host "Windows Game Mode has been disabled."
} catch {
    Write-Host "Skipping Windows Game Mode disable due to an error: $_"
}

### Disable Touch Keyboard
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\TabletTip\1.7" -Name "TipbandDesiredVisibility" -Value 0
    Write-Host "Touch Keyboard has been disabled."
} catch {
    Write-Host "Skipping Touch Keyboard disable due to an error: $_"
}

### Disable Windows Feedback
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0
    Write-Host "Windows Feedback has been disabled."
} catch {
    Write-Host "Skipping Windows Feedback disable due to an error: $_"
}

### Disable Windows Insider Program
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PreviewBuilds" -Name "AllowBuildPreview" -Value 0
    Write-Host "Windows Insider Program has been disabled."
} catch {
    Write-Host "Skipping Windows Insider Program disable due to an error: $_"
}

### Disable Windows Mixed Reality
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Mixed Reality" -Name "EnableWindowsMixedReality" -Value 0
    Write-Host "Windows Mixed Reality has been disabled."
} catch {
    Write-Host "Skipping Windows Mixed Reality disable due to an error: $_"
}

### Disable Windows Update Sharing
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0
    Write-Host "Windows Update Sharing has been disabled."
} catch {
    Write-Host "Skipping Windows Update Sharing disable due to an error: $_"
}

### Disable Windows Media Player
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventCDDVDMetadataRetrieval" -Value 1
    Write-Host "Windows Media Player has been disabled."
} catch {
    Write-Host "Skipping Windows Media Player disable due to an error: $_"
}

### Disable Windows Fax and Scan
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printing\Fax" -Name "DisableFax" -Value 1
    Write-Host "Windows Fax and Scan has been disabled."
} catch {
    Write-Host "Skipping Windows Fax and Scan disable due to an error: $_"
}

### Disable Windows DVD Maker
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DVD Maker" -Name "DisableDVDMaker" -Value 1
    Write-Host "Windows DVD Maker has been disabled."
} catch {
    Write-Host "Skipping Windows DVD Maker disable due to an error: $_"
}

### Disable Windows Movie Maker
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Movie Maker" -Name "DisableMovieMaker" -Value 1
    Write-Host "Windows Movie Maker has been disabled."
} catch {
    Write-Host "Skipping Windows Movie Maker disable due to an error: $_"
}

### Disable Windows Sound Recorder
try {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\SoundRecorder" -Name "DisableSoundRecorder" -Value 1
    Write-Host "Windows Sound Recorder has been disabled."
} catch {
    Write-Host "Skipping Windows Sound Recorder disable due to an error: $_"
}

### Restart Explorer to apply changes
try {
    Stop-Process -Name explorer -Force
    Write-Host "Explorer has been restarted to apply changes."
} catch {
    Write-Host "Skipping Explorer restart due to an error: $_"
}

### Remove Bloatware Apps
try {
    $bloatwareApps = @(
        "Microsoft.3DBuilder",
        "Microsoft.BingFinance",
        "Microsoft.BingNews",
        "Microsoft.BingSports",
        "Microsoft.BingWeather",
        "Microsoft.Getstarted",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.Office.OneNote",
        "Microsoft.People",
        "Microsoft.SkypeApp",
        "Microsoft.Windows.Photos",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCalculator",
        "Microsoft.WindowsCamera",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsPhone",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.WindowsStore",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.MinecraftUWP",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.OneConnect",
        "Microsoft.Messaging",
        "Microsoft.ConnectivityStore",
        "Microsoft.CommsPhone",
        "Microsoft.ScreenSketch",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.GetHelp"
    )

    foreach ($app in $bloatwareApps) {
        Write-Host "Removing $app..."
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }

    Write-Host "Bloatware apps have been removed."
} catch {
    Write-Host "Skipping bloatware removal due to an error: $_"
}

### Remove Third-Party Bloatware Apps
try {
    $thirdPartyBloatware = @(
        "DellInc.DellCommandUpdate",
        "DellInc.PartnerPromo",
        "DellInc.DellMobileConnect"
    )

    foreach ($app in $thirdPartyBloatware) {
        Write-Host "Removing $app..."
        # Remove the app for the current user
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        # Remove the app for all users and prevent reinstallation
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }

    Write-Host "Third-party bloatware apps have been removed."
} catch {
    Write-Host "Skipping third-party bloatware removal due to an error: $_"
}