# 0 - GetSelf (Git repository cloaning script)

This PowerShell script automates the process of cloning this Git repository into a specified target directory. The target directory is read from a configuration file (`config.json`), making the script flexible and reusable.

Note: this script is only to get he freshstart content from git

---

## Features

- **Dynamic Target Directory**: The target directory for cloning the repository is read from a configuration file.
- **Error Handling**: The script checks for the existence of the configuration file and validates its content.
- **Directory Creation**: If the target directory does not exist, the script creates it automatically.
- **Success/Failure Feedback**: The script provides clear feedback on whether the repository was cloned successfully or if an error occurred.

---

## Prerequisites

- **PowerShell**: The script requires PowerShell 5.1 or later.
- **Git**: Git must be installed and accessible from the command line.
- **Configuration File**: A `config.json` file is required to specify the target directory.

---

## Configuration File (`config.json`)

The script reads the target directory from a `config.json` file in the same directory. Here's an example configuration:

```json
{
    "targetDir": "C:\\path\\to\\your\\folder"
}
```

## Run the Script
- Open PowerShell.
- Navigate to the directory containing the script.
- Run the script:
```
.\clone_repo.ps1
```

# 1 - FirstConfigurations (Windows Configuration Script)

This PowerShell script is designed to automate the configuration of various Windows settings, including DNS configuration, dark mode, disabling unnecessary features, and removing bloatware apps. It requires administrative privileges to run and uses a JSON configuration file (`conf.json`) for some customizable settings.

---

## Features

- **DNS Configuration**: Sets primary and secondary DNS servers for all active network interfaces.
- **Dark Mode/Light Mode**: Configures the system theme based on the `lightmode` setting in the configuration file.
- **Disable Unnecessary Features**: Disables features like Task View, Search Bar, Widgets, Cortana, Bing Search, Recent Files, Windows Tips, OneDrive, Game Bar, Aero Shake, Fast Startup, Hibernation, Remote Assistance, Shared Experiences, Location Tracking, Advertising ID, Windows Timeline, Windows Narrator, Game Mode, Touch Keyboard, Windows Feedback, Windows Insider Program, Windows Mixed Reality, Windows Update Sharing, Windows Media Player, Windows Fax and Scan, Windows DVD Maker, Windows Movie Maker, and Windows Sound Recorder.
- **Remove Bloatware Apps**: Removes pre-installed Microsoft and third-party bloatware apps.
- **Restart Explorer**: Restarts Windows Explorer to apply changes.

---

## Prerequisites

- **PowerShell**: The script requires PowerShell 5.1 or later.
- **Administrator Privileges**: The script must be run with administrative privileges.
- **Configuration File**: A `conf.json` file is required to specify DNS servers and theme settings.

---

## Configuration File (`conf.json`)

The script reads settings from a `conf.json` file in the same directory. Here's an example configuration:

```json
{
    "dns": {
        "primary": "192.168.1.69",
        "secondary": "1.1.1.1"
    },
    "lightmode": 1
}
```

## Run the Script
- Open PowerShell as an administrator.
- Navigate to the directory containing the script.
- Run the script:
```
.\configure_windows.ps1
```

# 2 - App Installer
Not implemented yet - DO NOT use 

# License
These scripts are provided under the MIT License. Feel free to modify and distribute it as needed.

# Contributing
If you have suggestions or improvements, please open an issue or submit a pull request.

# Disclaimer
This script modifies system settings and removes applications. Use it at your own risk. Always test in a safe environment before deploying to production systems.