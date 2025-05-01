# Script to configure Windows 11 with the WSL 2 Ubuntu environment
# Input the version of WSL to install
param (
  [Parameter(HelpMessage="Only Ubuntu (20.04, 22.04, 24.04) is supported as a WSL instances at this time.")]
  [ValidateSet("ubuntu", "ubuntu-20.04", "ubuntu-22.04", "ubuntu-24.04")]
  [string]$userdefined_distribution = "ubuntu",

  [string]$localusername = "localuser",
  [Parameter(HelpMessage="Please specify true or false")]
  [ValidateSet("true", "false")]
  [string]$SetDefaultInstall = "true"
)

# Requires -RunAsAdministrator

# Set default action to stop script on error
$ErrorActionPreference = "Stop"

# Install wsl and related features

function PREINSTALL {
  $VMP = Get-WindowsOptionalFeature -FeatureName "VirtualMachinePlatform" -Online
  $WSL = Get-WindowsOptionalFeature -FeatureName "Microsoft-Windows-Subsystem-Linux" -Online

  if ($VMP.State -eq "Enabled") {
    Write-Host "VirtualMachinePlatform is already installed"
  }
  else {
    Enable-WindowsOptionalFeature -FeatureName "VirtualMachinePlatform" -Online -All -NoRestart
  }

  if ($WSL.State -eq "Enabled") {
    Write-Host "WSL is already installed"
    Start-Process -FilePath C:\Windows\System32\wsl.exe -ArgumentList "--update --web-download"  -NoNewWindow -Wait -PassThru
  }
  else {
    Write-Host "Installing WSL"
    Enable-WindowsOptionalFeature -FeatureName "Microsoft-Windows-Subsystem-Linux" -Online -All -NoRestart
    Start-Process -FilePath C:\Windows\System32\wsl.exe -ArgumentList "--update --web-download"  -NoNewWindow -Wait -PassThru
  }

}

function DISTRIBUTION {
  param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$distribution
  )

  $installedDistributions = wsl --list --quiet

  if ($installedDistributions -notcontains $distribution) {

    $executable = switch ($distribution) {
      "ubuntu"       { 'ubuntu' }
      "ubuntu-20.04" { 'ubuntu2004' }
      "ubuntu-22.04" { 'ubuntu2204' }
      "ubuntu-24.04" { 'ubuntu2404' }
    }

    # Install the distribution
    Write-Host "`r`nInstalling $distribution..."
    Start-Process -wait -FilePath C:\Windows\System32\wsl.exe -ArgumentList "--install -d $distribution --web-download --no-launch"

    # Wait for the installation to complete
    do {
      Write-Host "`r`n$distribution is still installing, sleeping 15 seconds`r`n"
      Start-Sleep -Seconds 5
      $installedDistributions = wsl --list --quiet
      Start-Sleep -Seconds 10
    } while ($installedDistributions -notcontains $distribution)
  }

  Write-Host "`r`nUser setup starting..."

  $ScriptPath = wsl.exe -d $distribution --user root wslpath -a $PSScriptRoot.Replace('\', '\\')
  Start-Process -wait -FilePath C:\Windows\System32\wsl.exe -ArgumentList "-d $distribution --user root -- /bin/bash ${ScriptPath}/initial_user_setup.sh -u $localusername"
  wsl.exe --shutdown
  Start-Sleep -s 15

  if (-not $?) {
    Write-Host "Initial setup did not complete successfully, please try running the script again"
    exit
  }
}

function ENVIRONMENT_SETUP {
  param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$distribution
    )

  Write-Host "`r`nEnvironment setup starting..."

  $ScriptPath = wsl.exe -d $distribution --user root wslpath -a $PSScriptRoot.Replace('\', '\\')
  Start-Process -wait -FilePath C:\Windows\System32\wsl.exe -ArgumentList "-d $distribution --user anedomansky -- /bin/bash ${ScriptPath}/initial_setup.sh"
  wsl.exe --shutdown
  Start-Sleep -s 15

  if (-not $?) {
    Write-Host "Initial setup did not complete successfully, please try running the script again"
    exit
  }
}

function UTILS {
  param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$distribution
    )

  Write-Host "`r`nInstalling utils..."

  $ScriptPath = wsl.exe -d $distribution --user root wslpath -a $PSScriptRoot.Replace('\', '\\')
  Start-Process -wait -FilePath C:\Windows\System32\wsl.exe -ArgumentList "-d $distribution --user anedomansky -- /bin/bash ${ScriptPath}/install_utils.sh -u $localusername"
  wsl.exe --shutdown
  Start-Sleep -s 15

  if (-not $?) {
    Write-Host "Initial setup did not complete successfully, please try running the script again"
    exit
  }
}

# Complete the setup by setting the default wsl instance and setting localuser as the default user
function COMPLETION {
  param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$distribution
  )

  $executable = switch ($distribution){
    "ubuntu"       { 'ubuntu' }
    "ubuntu-20.04" { 'ubuntu2004' }
    "ubuntu-22.04" { 'ubuntu2204' }
    "ubuntu-24.04" { 'ubuntu2404' }
  }

  # Set default wsl instance to ${distribution}
  if ($SetDefaultInstall -eq "true") {
    Write-Host "Setting ${distribution} as default distribution`r`n"
    wsl.exe -s ${distribution}
  }
  else {
    Write-Host "Not setting default distribution`r`n"
  }
  Start-Process -FilePath C:\Windows\System32\wsl.exe -ArgumentList "config --default-user $localusername"  -NoNewWindow -Wait -PassThru
  wsl.exe --shutdown
  Start-Sleep -s 15

  Write-Host "${distribution} has been deployed"
  Write-Host "`r`nPlease restart your PC as a final completion step"
}

# Get the Windows version, 11 is currently supported
$isWin11 = (Get-WmiObject Win32_OperatingSystem).Caption -Match "Windows 11"

if ($isWin11) {
  Write-Host "Windows 11 is installed. Starting installation..."
  PREINSTALL
  DISTRIBUTION -distribution $userdefined_distribution
  ENVIRONMENT_SETUP -distribution $userdefined_distribution
  UTILS -distribution $userdefined_distribution
  COMPLETION -distribution $userdefined_distribution
}
else {
  Write-Host "Windows version not supported by this script"
  exit 1
}
