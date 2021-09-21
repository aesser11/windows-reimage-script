###################################
# Windows10PostDeploy-NoChoco.ps1 #
###################################
try {
# Relaunch the script with administrator privileges and bypass execution-policy if it isn't already
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    exit
}
################################
# Windows 10 Apps to Blacklist #
################################
$win10AppBlacklist = @(
    # microsoft apps as of 2004 (so far only blacklisting ui-removable ones)
    "*Microsoft.3DBuilder*",
    "*Microsoft.Advertising.Xaml*",
    "*Microsoft.BingNews*",
    "*Microsoft.BingWeather*",
    "*Microsoft.MicrosoftOfficeHub*",
    "*Microsoft.MicrosoftSolitaireCollection*",
    "*Microsoft.Office.OneNote*",
    "*Microsoft.Office.Sway*",

    # non-microsoft as of 2004
    "*ActiproSoftwareLLC*",
    "*Adobe*",
    "*Asphalt8Airborne*",
    "*AutodeskSketchBook*",
    "*BubbleWitch3Saga*",
    "*CandyCrush*",
    "*CookingFever*",
    "*CyberLink*",
    "*DisneyMagicKingdoms*",
    "*DolbyAccess*",
    "*Drawboard*",
    "*Duolingo*",
    "*EclipseManager*",
    "*Facebook*",
    "*FarmHeroesSaga*",
    "*FarmVille*",
    "*Fitbit*",
    "*Flipboard*",
    "*FreeCasino*",
    "*HotSpotShield*",
    "*iHeartRadio*",
    "*Keeper*",
    "*king.com.*",
    "*LinkedIn*",
    "*MarchofEmpires*",
    "*Minecraft*",
    "*Netflix*",
    "*NYTCrossword*",
    "*Pandora*",
    "*PetRescueSaga*",
    "*PhototasticCollage*",
    "*PicsArt-PhotoStudio*",
    "*Plex*",
    "*PolarrPhotoEditorAcademicEdition*",
    "*RoyalRevolt2*",
    "*Shazam*",
    "*Sketchable*",
    "*SlingTV*",
    "*Spotify*",
    "*TuneInRadio*",
    "*Twitter*",
    "*WhatsApp*",
    "*WinZipUniversal*",
    "*Wunderlist*",
    "*Xing*"
)

#############################
# 3rd Party Apps to Install #
#############################
$applicationsToInstall = @(
    ## ninite
    "https://ninite.com/7zip-chrome-discord-spotify-steam-teamviewer15-vlc-windirstat/ninite.exe",

    ## filename exception cases
    #battle.net
    "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP",
    #github-desktop
    "https://central.github.com/deployments/desktop/desktop/latest/win32",

    ## version exception cases
    #goggalaxy
    #"https://www.gog.com/galaxy",
    #rufus
    "https://rufus.ie/en/"
)

#################
# Reimage Steps #
#################
$firstRunFunctions1 = @(
    # user input required
    "renameComputer",#change-prompt-logic
    "installSoftware",#append-software

    # automated and universal
    "removeWin10Apps"
)

$finalFirstRunFunctions3 = @(
    # tailored to my desired settings
    "remainingStepsToText"
)

$everyRunFunctions2 = @(
    # universal functions
    "disableTelemetry",
    "setWindowsTimeZone",
    "disableStickyKeys",
    "soundCommsAttenuation",
    "disableMouseAcceleration",

    # tailored to my desired settings
    "modifyWindowsFeatures",
    "setPowerProfile",
    "taskbarHideSearch",

    # functions exclusively for myself
    "enableGuestSMBShares",
    "uninstallOneDrive",
    "disableSharedExperiences",
    "disableWifiSense",
    "disableLocalIntranetFileWarnings",
    "advancedExplorerSettings",
    "enableClipboardHistory"
)

$finalEveryRunFunctions4 = @(
    "promptForRestart"
)

#############
# Functions #
#############
Function installSoftware {
    # problematic software to download
    $global:appendOutputSoftware += "
https://www.hwinfo.com/download/
https://www.sublimetext.com/download
https://electrum.org/#download
https://www.fosshub.com/MKVToolNix.html
https://www.privateinternetaccess.com/download
https://www.minecraft.net/en-us/download
"
    #Disable File Security Checks for this PowerShell instance
    $env:SEE_MASK_NOZONECHECKS = 1

    ##########################
    # Download software here #
    ##########################
    Write-Host "Downloading software installers..." -ForegroundColor Yellow
    foreach ($downloadURL in $applicationsToInstall) {
        switch -wildcard ($downloadURL) {
            "*battle.net*" {
                $filename = "Battle.net-Setup.exe"
                $output = "C:\Users\$env:username\Downloads\$filename"
                write-host "filename: $filename"
                write-host "output: $output"
                Write-Host "Downloading file $downloadURL" -ForegroundColor Green
                (New-Object System.Net.WebClient).DownloadFileAsync($downloadURL, $output)
            }
            "*github*" {
                $filename = "GitHubDesktopSetup-x64.exe"
                $output = "C:\Users\$env:username\Downloads\$filename"
                write-host "filename: $filename"
                write-host "output: $output"
                Write-Host "Downloading file $downloadURL" -ForegroundColor Green
                (New-Object System.Net.WebClient).DownloadFileAsync($downloadURL, $output)
            }
            "*gog*" {
                $versionURL = (Invoke-WebRequest -Uri $downloadURL -UseBasicParsing).Links.Href -like "https://webinstallers.gog-statics.com/download/GOG_Galaxy*.exe*"
                $downloadURL = $versionURL[0]
                $filename = "GOG_Galaxy.exe"
                $output = "C:\Users\$env:username\Downloads\$filename"
                write-host "filename: $filename"
                write-host "output: $output"
                Write-Host "Downloading file $downloadURL" -ForegroundColor Green
                (New-Object System.Net.WebClient).DownloadFileAsync($downloadURL, $output)
            }
            "*rufus*" {
                $versionURL = (Invoke-WebRequest -Uri $downloadURL -UseBasicParsing).Links.Href -like "https://github.com/pbatard/rufus/releases/download/*/rufus*.exe"
                $downloadURL = $versionURL[0]
                $filename = $downloadURL.Substring($downloadURL.LastIndexOf("/") + 1)
                $output = "C:\Users\$env:username\Downloads\$filename"
                write-host "filename: $filename"
                write-host "output: $output"
                Write-Host "Downloading file $downloadURL" -ForegroundColor Green
                (New-Object System.Net.WebClient).DownloadFileAsync($downloadURL, $output)
            }
            # default behavior for all other apps
            default {
                $filename = $downloadURL.Substring($downloadURL.LastIndexOf("/") + 1)
                $output = "C:\Users\$env:username\Downloads\$filename"
                write-host "filename: $filename"
                write-host "output: $output"
                Write-Host "Downloading file $downloadURL" -ForegroundColor Green
                (New-Object System.Net.WebClient).DownloadFileAsync($downloadURL, $output)
            }
        }
    }
}

# Rename computer to something a little more personal if the name contains a default generic name
Function renameComputer {
    if ($env:computername -like "*DESKTOP-*") {
        Write-Host "Rename your PC, current name: $env:computername" -ForegroundColor Green
        Write-Host "Press [Enter] to continue without renaming" -ForegroundColor Yellow
        $newCompName = Read-Host -Prompt "Enter in a new computer name, limit 15 characters"
        $newCompNameLength = $newCompName.length
        while (($newCompNameLength -gt 15) -or ($newCompName -eq "y") -or ($newCompName -eq "Y") -or ($newCompName -eq "n") -or ($newCompName -eq "N")) {
            Write-Host "The name specified is $newCompNameLength character(s) long" -ForegroundColor Red
            $renameComputer = Read-Host -Prompt "Do you wish to rename from $newCompName : [y]/[n]?"
            if (($renameComputer -eq "y") -or ($renameComputer -eq "Y") -or ($renameComputer -eq "1")) {
                Write-Host "Getting a new name... Limit 15 characters" -ForegroundColor Green
                Write-Host "Press [Enter] to continue without renaming" -ForegroundColor Yellow
                $newCompName = Read-Host -Prompt "Enter in a new computer name, limit 15 characters"
                $newCompNameLength = $newCompName.length
            }
            elseif (($renameComputer -eq "n") -or ($renameComputer -eq "N") -or ($renameComputer -eq "0")) {
                Write-Host "Proceeding..." -ForegroundColor Yellow
                $newCompNameLength = 0
            }
            else {
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red
            }
        }
        if (!$newCompName) {
            Write-Host "Skipping new name since no input was specified" -ForegroundColor Green
        }
        else {
            Rename-Computer -NewName $newCompName 
        }
    }
    else {
        Write-Host "A personalized computer name already exists: $env:computername | Skipping the renaming section" -ForegroundColor Green
    }
}

Function disableTelemetry {
    Set-Service dmwappushservice -StartupType Disabled
    Set-Service dmwappushservice -Status Stopped
    Set-Service DiagTrack -StartupType Disabled
    #Usually errors out, not a big deal since after reboot it will be disabled
    Set-Service DiagTrack -Status Stopped -ErrorAction Ignore
    echo "" > C:\ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl
}

# Sync windows time
Function setWindowsTimeZone {
    #$currentTimeZone.StandardName #Time Zone Name
    #$ipinfo.ip #Public IP address
    #$ipinfo.hostname #Public DNS Answer
    #$ipinfo.city #City
    #$ipinfo.region #State
    #$ipinfo.country #Country 
    #$ipinfo.loc #Geo Coords
    #$ipinfo.postal #Zip code
    #$ipinfo.org #ISP
    $currentTimeZoneDate = Get-TimeZone
    $currentTimeZone = $currentTimeZone.StandardName
    $ipinfo = Invoke-RestMethod https://ipinfo.io/json 
    $ipState = $ipinfo.region
    $ipCity = $ipinfo.city
    $ipLoc = $ipinfo.loc
    #split location into lattitude and longitude
    $ipLat,$ipLon = $ipLoc.split(',')
    
    #Washington, Nevada, California
    if (($currentTimeZone -ne "Pacific Standard Time") -and ($ipState -eq "Washington" -or $ipState -eq "Nevada" -or $ipState -eq "California")) {
        Write-Host "Region doesn't match current time zone, setting to Pacific Standard Time" -ForegroundColor Green
        Set-TimeZone -Name "Pacific Standard Time"
    }
    #Montana, Wyoming, Colorado, Utah, New Mexico                                           
    elseif (($currentTimeZone -ne "Mountain Standard Time") -and ($ipState -eq "Montana" -or $ipState -eq "Wyoming" -or $ipState -eq "Colorado" -or $ipState -eq "Utah" -or $ipState -eq "New Mexico")) {
        Write-Host "Region doesn't match current time zone, setting to Mountain Standard Time" -ForegroundColor Green
        Set-TimeZone -Name "Mountain Standard Time"
    }
    #Minnesota, Wisconsin, Iowa, Illinois, Missouri, Arkansas, Oklahoma, Mississippi, Alabama, Louisiana
    elseif (($currentTimeZone -ne "Central Standard Time") -and ($ipState -eq "Minnesota" -or $ipState -eq "Wisconsin" -or $ipState -eq "Iowa" -or $ipState -eq "Illinois" -or $ipState -eq "Missouri" -or $ipState -eq "Arkansas" -or $ipState -eq "Oklahoma" -or $ipState -eq "Mississippi" -or $ipState -eq "Alabama" -or $ipState -eq "Louisiana")) {
        Write-Host "Region doesn't match current time zone, setting to Central Standard Time" -ForegroundColor Green
        Set-TimeZone -Name "Central Standard Time"
    }
    #Georgia, South Carolina, North Carolina, Virginia, West Virginia, Ohio, Pennsylvania, New York, Maine, Vermont, New Hampshire, Massachusetts, Rhode Island, Connecticut, New Jersey, Delaware, Maryland, District of Columbia
    elseif (($currentTimeZone -ne "Eastern Standard Time") -and ($ipState -eq "Georgia" -or $ipState -eq "South Carolina" -or $ipState -eq "North Carolina" -or $ipState -eq "Virginia" -or $ipState -eq "West Virginia" -or $ipState -eq "Ohio" -or $ipState -eq "Pennsylvania" -or $ipState -eq "New York" -or $ipState -eq "Maine" -or $ipState -eq "Vermont" -or $ipState -eq "New Hampshire" -or $ipState -eq "Massachusetts" -or $ipState -eq "Rhode Island" -or $ipState -eq "Connecticut" -or $ipState -eq "New Jersey" -or $ipState -eq "Delaware" -or $ipState -eq "Maryland" -or $ipState -eq "District of Columbia")) {
        Write-Host "Region doesn't match current time zone, setting to Eastern Standard Time" -ForegroundColor Green
        Set-TimeZone -Name "Eastern Standard Time"
    }
    #Multi-zone-states
    #Florida
    elseif ($ipState -eq "Florida") {
        if (($currentTimeZone -ne "Central Standard Time") -and (($ipLat -ge 29.55) -and ($ipLon -lt -85.5835))) {
            #CST
            Write-Host "Region doesn't match current time zone, setting to Central Standard Time" -ForegroundColor Green
            Set-TimeZone -Name "Central Standard Time"
        }
        elseif (($currentTimeZone -ne "Eastern Standard Time") -and (($ipLat -le 31.00) -and ($ipLon -ge -85.5835))) {
            #EST
            Write-Host "Region doesn't match current time zone, setting to Eastern Standard Time" -ForegroundColor Green
            Set-TimeZone -Name "Eastern Standard Time"
        }
        else {
            Write-Host "Time Zone location could not be determined for Florida, Input a time zone manually" -ForegroundColor Red
            Write-Host "Enter either 'Central Standard Time' or 'Eastern Standard Time'" -ForegroundColor Yellow
            Set-TimeZone
        }
    }
    #needs improvment - finish time zone selection for multi-states,
    <#
    Alabama - 
    Alaska - 
    Alaska - Alaskan Standard Time
    Arizona - US Mountain Standard Time
    Arizona - Mountain Standard Time
    -------
    Florida
    -------
    Hawaii - Hawaiian Standard Time
    -------
    Idaho
    Indiana
    -------
    Kansas
    Kentucky
    -------
    Michigan
    -------
    Nebraska
    Nevada
    North Dakota
    -------
    Oregon
    -------
    South Dakota
    -------
    Tennessee
    Texas
    #>
    #etc...
    #Unique states
     #Arizona -special time zone and multi-timezone state
     #Alaska -special time zone and multi-timezone state
     #Hawaii -special time zone
    else {
        Write-Host "Region already matches current time zone, skipping and continuing with time sync" -ForegroundColor Green
    }
    Write-Host "Syncing windows time" -ForegroundColor Green
    net start w32time
    w32tm /resync
}

# Create power profile ----- (ctrl pan)
Function setPowerProfile {
    # powercfg reference https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options
    Write-Host "Power: Selecting and configuring power profile" -ForegroundColor Green
    $cpu = Get-WMIObject Win32_Processor
    $cpuName = $cpu.name

    powercfg -list
    #Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
    #Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance)
    #Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)
    #Power Scheme GUID: 9897998c-92de-4669-853f-b7cd3ecb2790  (AMD Ryzen™ Balanced)
    #Power Scheme GUID: 9935e61f-1661-40c5-ae2f-8495027d5d5d  (AMD Ryzen™ High performance)

    if ($cpuName -like "*Ryzen*") {
        #Power Scheme GUID: 9897998c-92de-4669-853f-b7cd3ecb2790  (AMD Ryzen™ Balanced)
        #Power Scheme GUID: 9935e61f-1661-40c5-ae2f-8495027d5d5d  (AMD Ryzen™ High performance)
        Write-Host "AMD Ryzen CPU Detected, selecting AMD Ryzen High Performance power profile" -ForegroundColor Green
        powercfg -setactive 9935e61f-1661-40c5-ae2f-8495027d5d5d
    }
    else {
        Write-Host "Intel CPU is present, proceeding with Windows High performance power profile" -ForegroundColor Green
        #Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
        #Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance)
        #Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)
        powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }
    # delete hibernation file to save disk space
    powercfg -h off
}

Function disableStickyKeys {
    $path="HKCU:\Control Panel\Accessibility\StickyKeys"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # disable stickykeys
    Set-ItemProperty -Path $path -Name "Flags" -Type String -Value "506" -Force
}

Function disableMouseAcceleration {
    $path="HKCU:\Control Panel\Mouse"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # disable mouse acceleration
    Set-ItemProperty -Path $path -Name "MouseSpeed" -Type String -Value 0 -Force
    Set-ItemProperty -Path $path -Name "MouseThreshold1" -Type String -Value 0 -Force
    Set-ItemProperty -Path $path -Name "MouseThreshold2" -Type String -Value 0 -Force
}

Function soundCommsAttenuation {
    $path="HKCU:\Software\Microsoft\Multimedia\Audio"
    # set communications tab to "do nothing"
    Set-ItemProperty -Path $path -Name "UserDuckingPreference" -Type DWord -Value 3 -Force
}

Function removeWin10Apps {
    foreach ($app in $win10AppBlacklist) {
        Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "$app"} | Remove-AppxPackage
    }
}

Function modifyWindowsFeatures {
    ## disable PowerShellv2
    #Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2" -NoRestart
    #Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2Root" -NoRestart
    ## disable SMBv1
    #Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart
    #Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Client" -NoRestart
    #Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Server" -NoRestart
    ## disable Telnet
    #Disable-WindowsOptionalFeature -Online -FeatureName "TelnetClient" -NoRestart
    ## uninstall windows fax and scan services
    #Disable-WindowsOptionalFeature -Online -FeatureName "FaxServicesClientPackage" -NoRestart
    ## uninstall microsoft xps document writer
    #Disable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart
    ## windows media player
    #Disable-WindowsOptionalFeature -Online -FeatureName "MediaPlayback" -NoRestart
    #Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart
    # install WSL
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart
    # install hyper-v
    #Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -All -NoRestart
    # install windows sandbox
    Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart
}

Function enableGuestSMBShares {
    $path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # enable guest SMB shares
    Set-ItemProperty -Path $path -Name "AllowInsecureGuestAuth" -Type DWord -Value 1
}

Function uninstallOneDrive {
    # uninstall onedrive
    Stop-Process -Name "OneDrive" -Force
    $path="$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
    if (!(Test-Path $path)) { $path="$env:SYSTEMROOT\System32\OneDriveSetup.exe" }
    Start-Process $path "/uninstall"
}

Function taskbarHideSearch {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # hide taskbar search icon / box
    Set-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -Type DWord -Value 0 -Force
    # disable bing web search
    Set-ItemProperty -Path $path -Name "BingSearchEnabled" -Type DWord -Value 0 -Force
    Set-ItemProperty -Path $path -Name "CortanaConsent" -Type DWord -Value 0 -Force
}

# Disable shared experiences
Function disableSharedExperiences {
    $path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    Set-ItemProperty -Path $path -Name "EnableCdp" -Type DWord -Value 0 -Force
}

Function disableWifiSense {
    # disable hot spots and wifi sense
    $path1="HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowWifiHotSpotReporting"
    if (!(Test-Path $path1)) { New-Item -Path $path1 -Force }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowWifiHotSpotReporting" -Name "Value" -Type DWord -Value 0 -Force

    $path2="HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowAutoConnectToWifiSenseHotspots"
    if (!(Test-Path $path2)) { New-Item -Path $path2 -Force }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowAutoConnectToWifiSenseHotspots" -Name "Value" -Type DWord -Value 0 -Force

    $path3="HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
    if (!(Test-Path $path3)) { New-Item -Path $path3 -Force }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WifISenseAllowed" -Type DWord -Value 0 -Force
}

Function disableLocalIntranetFileWarnings {
    # disable for 192.168.*.* - "These files might be harmful to your computer, Your internet security settings suggest that one or more files may be harmful. Do you want to use it anyway?"
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges\Range1"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    Set-ItemProperty -Path $path -Name "*" -Type DWord -Value 1 -Force
    Set-ItemProperty -Path $path -Name ":Range" -Type String -Value "192.168.*.*" -Force
}

Function advancedExplorerSettings {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # hide sync provider notifications
    Set-ItemProperty -Path $path -Name "ShowSyncProviderNotifications" -Type DWord -Value 0 -Force
    # change default Explorer view to this pc
    Set-ItemProperty -Path $path -Name "LaunchTo" -Type DWord -Value 1 -Force
    # disable windows aero shake
    Set-ItemProperty -Path $path -Name "DisallowShaking" -Type DWord -Value 1 -Force
    # set taskbar buttons to show labels and combine when taskbar is full
    Set-ItemProperty -Path $path -Name "TaskbarGlomLevel" -Type DWord -Value 1 -Force
    # hide task view button
    Set-ItemProperty -Path $path -Name "ShowTaskViewButton" -Type DWord -Value 0 -Force
    # show taskbar on all displays
    Set-ItemProperty -Path $path -Name "MMTaskbarEnabled" -Type DWord -Value 1 -Force
    # show taskbar buttons on taskbar display only where the windows is open
    Set-ItemProperty -Path $path -Name "MMTaskbarMode" -Type DWord -Value 2 -Force
    # combine taskbar buttons: only when taskbar is full
    Set-ItemProperty -Path $path -Name "MMTaskbarGlomLevel" -Type DWord -Value 1 -Force
    # show known file extensions
    Set-ItemProperty -Path $path -Name "HideFileExt" -Type DWord -Value 0 -Force
    # show hidden files
    Set-ItemProperty -Path $path -Name "Hidden" -Type DWord -Value 1 -Force
}

Function enableClipboardHistory {
    $path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # enable clipboard history
    Set-ItemProperty -Path $path -Name "AllowClipboardHistory" -Type DWord -Value 1 -Force
}

##################
# Restart Prompt #
##################
Function promptForRestart {
    Switch (Read-Host "Restart? [y]/[n]") {
        'y' {Restart-Computer}
        'n' {Write-host "Exiting" -ForegroundColor Yellow}
        default {
            Write-host "Invalid input. Please enter [y]/[n]" -ForegroundColor Red
            promptForRestart
        }
    }
}

####################
# Output Text File #
####################
Function remainingStepsToText {
    $outputFile = "C:\Users\$env:username\Desktop\Remaining Steps.txt"
    $outString = "
################
# Manual Steps #
################
https://github.com/aesser11/home-lab/wiki/Reimaging-General
https://github.com/aesser11/home-lab/wiki/Windows-10
# disable GeForce Experience game optimization (install bundled w/ nvidia drivers)
# disable GeForce Experience in-game overlay

# map network drives
Z: \\192.168.1.69\apps
Y: \\192.168.1.69\downloads
X: \\192.168.1.69\media
W: \\192.168.1.69\share
V: \\192.168.1.69\store

# 10GbE -> https://github.com/aesser11/home-lab/wiki/10GbE#windows-desktop
# plug mic into all usb ports to disable speaker device and set mic settings

# set task manager columns [process name, cpu, memory, disk, network, gpu]
# set task manager cpu to logical processors
# set task manager startup apps to disabled from running at boot
# show details during file transfers

# unpin default groups from start menu
# unpin default items from taskbar

# set which folders appear on start: file explorer, and user folders
# remove recycle bin from desktop -> ms-settings:personalization -> Themes -> Desktop icon settings
# set background, lock screen, and login photo
# adjust focus assist
# disable Windows Privacy Permissions settings manually
# check removal for missed built-in apps 
# disable xbox in-game overlay
# review default apps

# pin GitHub to QuickAccess
# pin watch to QuickAccess
# pin %username% to QuickAccess

# install powertoys choco install powertoys -y
# create cup 7zip windirstat -y ; pause -> script with shortcut (pin to start menu manually)

# pin shit to start menu

#########################
# Appended Output Steps #
#########################
$global:appendOutputSteps
###################################################################################################
###########################
# Appended Software Steps #
###########################
7zip: change file type associations, reduce context menus to extract files, check hash, and add to archive

teamviewer: whitelist my account, disable random password generation, assign to my account, anything else?

$global:appendOutputSoftware
###################################################################################################
##############
# Error List #
##############
$error
"
    $outString | Out-File -FilePath $outputFile -Width 200
}

####################
# Global Variables #
####################
$global:appendOutputSteps = $null
$global:appendOutputSoftware = $null

##################
# Function Calls #
##################
Function promptFreshInstall {
    Switch (Read-Host "Fresh Install? [y]/[n]") {
        'y' {
            Write-host "Including first install steps..." -ForegroundColor Yellow
            $firstRunFunctions1 | ForEach { Invoke-Expression $_ }
            $everyRunFunctions2 | ForEach { Invoke-Expression $_ }
            $finalFirstRunFunctions3 | ForEach { Invoke-Expression $_ }
            $finalEveryRunFunctions4 | ForEach { Invoke-Expression $_ }
        }
        'n' {
            Write-host "Skipping first install steps..." -ForegroundColor Yellow
            $everyRunFunctions2 | ForEach { Invoke-Expression $_ }
            $finalEveryRunFunctions4 | ForEach { Invoke-Expression $_ }
         }
        default {
            Write-host "Invalid input. Please enter [y]/[n]" -ForegroundColor Red
            promptFreshInstall
        }
    }
}
promptFreshInstall
}
catch {
    $error | Out-File -FilePath "C:\Users\$env:username\Desktop\CrashLog.txt" -Width 200
}

<#
notes for later:
###################################################################################################

###################################################################################################
#>
