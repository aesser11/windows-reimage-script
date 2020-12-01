###########################
# Windows10PostDeploy.ps1 #
###########################
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
    # my chocolatey apps
    # auto run
    "github-desktop",
    "hwinfo",
    #"powertoys",
    "rufus",
    "putty",
    "sublimetext3",
    "vlc",
    "googlechrome",
    "discord",
    "steam",
    "goggalaxy",
    "uplay",
    "epicgameslauncher",

    # requires case statements
    "spotify",#--ignore-checksums
    "origin",#--ignore-checksums
    "teamviewer",#append-software
    "7zip",#no pin && #append-software
    "windirstat",#no pin

    # manual downloads
    "battle.net" #append-software
    #"electrum" #append-software
)

#################
# Reimage Steps #
#################
$firstRunFunctions1 = @(
    # user input required
    "renameComputer",#change-prompt-logic
    "installSoftware",#append-software

    # automated and universal
    "personalFolderTargetSteps"
)

$finalFirstRunFunctions3 = @(
    # tailored to my desired settings
    "mapNetworkDrives",
    "remainingStepsToText"
)

$everyRunFunctions2 = @(
    # universal functions
    "disableTelemetry",
    "setWindowsTimeZone",
    "configurePrivacy",#needs updates
    "disableStickyKeys",
    "setPageFileToC",
    "soundCommsAttenuation",
    "disableWindowsDefenderSampleSubmission",
    "disableMouseAcceleration",

    # tailored to my desired settings
    "uninstallWindowsFeatures",
    "configureWindowsUpdates",
    "deleteHibernationFile",
    "uninstallOptionalApps",
    "setPowerProfile",#what about plans like "DellOptimized"? set logic to check if GUID for Power Saver || Balanced || High Performance, is set, else leave alone
    "taskbarHideSearch",

    # functions exclusively for myself
    "removeWin10Apps",
    #"disableHomeGroup",
    "removePrinters",
    "disableRemoteAssistance",
    "enableGuestSMBShares",
    "uninstallOneDrive",
    "setVisualFXAppearance",
    "explorerSettings",
    "taskbarHidePeopleIcon",
    "taskbarHideInkWorkspace",
    "disableWebSearch",
    "explorerSetControlPanelLargeIcons",
    "enableDarkMode",
    "mkdirGodMode",
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
    #Disable File Security Checks for this PowerShell instance
    $env:SEE_MASK_NOZONECHECKS = 1

    ##########################
    # Download software here #
    ##########################
    #Install Chocolatey package manager
    #PowerShell
    #Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    #PowerShell v3+
    #Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
    #Pulled from https://chocolatey.org/install
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    foreach ($software in $applicationsToInstall) {
        Switch ($software) {
            # exception cases
            "spotify" {
                choco install $software -y --ignore-checksums
                choco pin add -n="$software"
            }
            "origin" {
                choco install $software -y --ignore-checksums
                choco pin add -n="$software"
            }
            "teamviewer" {
                choco install $software -y
                choco pin add -n="$software"
                $global:appendOutputSoftware += "
teamviewer: whitelist my account, disable random password generation, assign to my account, anything else?
"
            }
            "7zip" {
                choco install $software -y
                $global:appendOutputSoftware += "
7zip: change file type associations, reduce context menus to extract files, check hash, and add to archive
"
            }
            "windirstat" {
                choco install $software -y
            }
            "battle.net" {
                # download manually
                if (!(Test-Path "C:\Users\$env:username\Desktop\*battle.net*")) {
                    Write-Host "Downloading: Battle.net" -ForegroundColor Green
                    $url = "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"
                    $output = "C:\Users\$env:username\Desktop\Battle.net-Setup.exe"
                    $start_time = Get-Date
                    (New-Object System.Net.WebClient).DownloadFile($url, $output)
                    Write-Host "Waiting for Battle.net to finish downloading..." -ForegroundColor Yellow
                    $global:appendOutputSoftware += "
Battle.net-Setup.exe downloaded to desktop
"
                }
            }
            <#
            "electrum" {
                # download manually - get hardcoded version in download
                # https://electrum.org/#download
                # https://download.electrum.org/3.3.8/electrum-3.3.8-setup.exe
                # $version = (Invoke-WebRequest -Uri "https://download.electrum.org/" -UseBasicParsing).Links.Href | %{ new-object System.Version ($_) } | sort
            }
            #>
            # default behavior for all other apps
            default {
                choco install $software -y
                choco pin add -n="$software"
            }
        }
    }
}

# Append disk steps to the text file if applicable
Function personalFolderTargetSteps {
    $previousDiskSize = 0
    $getDisksSizes = (Get-Disk).size
    $diskCount = (Get-Disk).number.count
    foreach ($diskSize in $getDisksSizes) {
        if ($diskSize -gt $previousDiskSize) {
            $greatestDiskSize = $diskSize
        }
        $previousDiskSize = $diskSize
    }
    if (($diskCount -gt 1) -and ($greatestDiskSize -gt 900000000000)) {
        $global:appendOutputSteps += 
"
#############################
## Personal Folder Targets ##
#############################
Mass storage drive detected. Change personal folder targets to the mass storage drive:
Documents, Downloads, Music, Pictures, Videos
"
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

Function uninstallOptionalApps {
    Get-WindowsCapability -online | ? {$_.Name -like '*QuickAssist*'} | Remove-WindowsCapability -online
    Get-WindowsCapability -online | ? {$_.Name -like '*ContactSupport*'} | Remove-WindowsCapability -online
    Get-WindowsCapability -online | ? {$_.Name -like '*Demo*'} | Remove-WindowsCapability -online
    #Get-WindowsCapability -online | ? {$_.Name -like '*Face*'} | Remove-WindowsCapability -online
    Get-WindowsCapability -online | ? {$_.Name -like '*WindowsMediaPlayer*'} | Remove-WindowsCapability -online
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

# Delete hibernation file -- (cmd)
Function deleteHibernationFile{
    powercfg -h off
}

# Create power profile ----- (ctrl pan)
Function setPowerProfile {
    # powercfg reference https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options
    Write-Host "Power: Selecting and configuring power profile" -ForegroundColor Green
    #powercfg -h off
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
}

# configure windows updates
Function configureWindowsUpdates {
    $path1="HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
    if (!(Test-Path $path1)) { New-Item -Path $path1 -Force }
    # set active hours 8am-2am
    Set-ItemProperty -Path $path1 -Name "ActiveHoursStart" -Type DWord -Value 8 -Force
    Set-ItemProperty -Path $path1 -Name "ActiveHoursEnd" -Type DWord -Value 2 -Force
    # set update branch to avoid the buggy (Targeted) releases
    Set-ItemProperty -Path $path1 -Name "BranchReadinessLevel" -Type DWord -Value 32 -Force
    # disable windows insider preview builds
    Set-ItemProperty -Path $path1 -Name "InsiderProgramEnabled" -Type DWord -Value 0 -Force
    
    $path2="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
    if (!(Test-Path $path2)) { New-Item -Path $path2 -Force }
    # set to allow downloads from other PCs on my local network only
    Set-ItemProperty -Path $path2 -Name "DODownloadMode" -Type DWord -Value 1 -Force

    $path3="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    if (!(Test-Path $path3)) { New-Item -Path $path3 -Force }
    # disable edge desktop shortcut creation
    Set-ItemProperty -Path $path3 -Name "DisableEdgeDesktopShortcutCreation" -Type DWord -Value 1 -Force
}

# Disable all privacy settings
Function configurePrivacy {
#Windows permissions
#General - Change privacy options
    #Let apps use advertising ID to make ads more interesting to you based on your app activity
        $adiPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        if (!(Test-Path $adiPath)) { New-Item -Path $adiPath -Force }
        Set-ItemProperty -Path $adiPath -Name "Enabled" -Type DWord -Value 0 -Force
    #Let websites provide locally relevant content by accessing my language list
        $upPath="HKCU:\Control Panel\International\User Profile\"
        if (!(Test-Path $upPath)) { New-Item -Path $upPath -Force }
        Set-ItemProperty -Path $upPath -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1 -Force
    #Let Windows track app launches to improve Start and search results
        $expadvPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        if (!(Test-Path $expadvPath)) { New-Item -Path $expadvPath -Force }
        Set-ItemProperty -Path $expadvPath -Name "Start_TrackProgs" -Type DWord -Value 0 -Force
    #Show me suggested content in the Settings app
        $cdmPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        if (!(Test-Path $cdmPath)) { New-Item -Path $cdmPath -Force }
        Set-ItemProperty -Path $cdmPath -Name "ContentDeliveryAllowed" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "PreInstalledAppsEnabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0 -Force
    # disable fun facts and tips on lock screen and remove spotlight
    #start ms-settings:lockscreen
        Set-ItemProperty -Path $cdmPath -Name "RotatingLockScreenEnabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -Force
#Speech - left off privacy adjustments here
    #Online speech recognition
        $path="HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"
        if (!(Test-Path $path)) { New-Item -Path $path -Force }
        Set-ItemProperty -Path $path -Name "HasAccepted" -Type DWord -Value 0 -Force
#Inking & typing personalization
    #Getting to know you
        $path="HKCU:\Software\Microsoft\Input\TIPC"
        if (!(Test-Path $path)) { New-Item -Path $path -Force }
        Set-ItemProperty -Path $path -Name "Enabled" -Type DWord -Value 0 -Force
# Turn off automatic learning
        $path="HKCU:\Software\Microsoft\Personalization\Settings"
        if (!(Test-Path $path)) { New-Item -Path $path -Force }
        Set-ItemProperty -Path $path -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0 -Force
        $path="HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"
        if (!(Test-Path $path)) { New-Item -Path $path -Force }
        Set-ItemProperty -Path $path -Name "HarvestContacts" -Type DWord -Value 0 -Force
#Diagnostics & feedback
    #Diagnostic data
        $dcPath="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if (!(Test-Path $dcPath)) { New-Item -Path $dcPath -Force }
        Set-ItemProperty -Path $dcPath -Name "AllowTelemetry" -Type DWord -Value 0 -Force
    #Improving inking and typing
        #?
    #Tailored experiences
        $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
        if (!(Test-Path $path)) { New-Item -Path $path -Force }
        Set-ItemProperty -Path $path -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0 -Force
    #View diagnostic data
        $etkPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey"
        if (!(Test-Path $etkPath)) { New-Item -Path $etkPath -Force }
        Set-ItemProperty -Path $etkPath -Name "EnableEventTranscript" -Type DWord -Value 0 -Force
    #Delete diagnostic data
        #?
    #Feedback frequency
        $path="HKCU:\Software\Microsoft\Siuf\Rules"
        if (!(Test-Path $path)) { New-Item -Path $path -Force }
        Set-ItemProperty -Path $path -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0 -Force
        $path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if (!(Test-Path $path)) { New-Item -Path $path -Force }
        Set-ItemProperty -Path $path -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1 -Force
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient"
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    #Recommended troubleshooting
        #?
#Activity history
    #Store my activity history on this device
        $path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
        if (!(Test-Path $path)) { New-Item -Path $path -Force }
        Set-ItemProperty -Path $path -Name "PublishUserActivities" -Type DWord -Value 0 -Force
    #Send my activity history to Microsoft
        #?
    #Clear activity history
        #?
        #Disable activity feed | #Disable Let Windows collect activites from my PC
        #Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0 -Force
        #Disable publishing of user activiites | #Disable Let windows sync activiites from my pc to the cloud
        #Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0 -Force

<#
#OLD-FUNCTIONS
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1 -Force
# Diagnostics & Feedback
    # Disable Feedback
    if (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
        New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1 -Force
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient"
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    #Disable Improv. inking and typing recognition
    if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Name "AllowLinguisticDataCollection" -Type DWord -Value 0 -Force
    
    #Disable Tailored experiences
    #Write-Host "Disabling Tailored Experiences..." -ForegroundColor Green -BackgroundColor Black
    if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent")) {
        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Force
    }
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1 -Force

    #Feedback frequency
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1 -Force
# Activity History
    #Disable activity feed | #Disable Let Windows collect activites from my PC
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0 -Force
    #Disable publishing of user activiites | #Disable Let windows sync activiites from my pc to the cloud
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0 -Force
    #Disallow upload of User Activities
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0 -Force


# Disallow input Personalization
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1 -Force
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1 -Force
# Turn off updates to speech recognition and speech synthesis
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Speech_OneCore\Preferences" -Name "ModelDownloadAllowed" -Type DWord -Value 0 -Force
# Turn off handwriting personalization data sharing
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -Type DWord -Value 1 -Force
# Turn off handwriting recognition error reporting
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -Name "PreventHandwritingErrorReports" -Type DWord -Value 1 -Force
#>

#App permissions
    #Location
        $lopath="HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
        if (!(Test-Path $lopath)) { New-Item -Path $lopath -Force }
        #Allow access to location on this device
        #Allow apps to access your location
        #Location history
        Set-ItemProperty -Path $lopath -Name "Value" -Type String -Value "Deny" -Force
    #Voice activation
        $vaPath="HKCU:\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps"
        if (!(Test-Path $vaPath)) { New-Item -Path $vaPath -Force }
        #Allow apps to use voice activation
        Set-ItemProperty -Path $vaPath -Name "AgentActivationEnabled" -Type DWord -Value 2 -Force
        #Allow apps to use voice activation when this device is locked
        Set-ItemProperty -Path $vaPath -Name "AgentActivationOnLockScreenEnabled" -Type DWord -Value 2 -Force
    #Radios
        $raPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios"
        if (!(Test-Path $raPath)) { New-Item -Path $raPath -Force }
        Set-ItemProperty -Path $raPath -Name "Value" -Type String -Value "Deny" -Force
    #Other devices - #Communicate with unpaired devices
        $bsPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync"
        if (!(Test-Path $bsPath)) { New-Item -Path $bsPath -Force }
        Set-ItemProperty -Path $bsPath -Name "Value" -Type String -Value "Deny" -Force
    #Background apps
        $baPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
        if (!(Test-Path $baPath)) { New-Item -Path $baPath -Force }
        #Let apps run in the background
        Set-ItemProperty -Path $baPath -Name "GlobalUserDisabled" -Type DWord -Value 1 -Force
}

Function disableStickyKeys {
    $path="HKCU:\Control Panel\Accessibility\StickyKeys"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # disable stickykeys
    Set-ItemProperty -Path $path -Name "Flags" -Type String -Value "506" -Force
}

Function setPageFileToC {
    $path="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # set page file settings to C: drive with "system managed size"
    Set-ItemProperty -Path $path -Name "PagingFiles" -Type MultiString -Value "C:\pagefile.sys 0 0" -Force
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

Function uninstallWindowsFeatures {
    # disable PowerShellv2
    Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2Root" -NoRestart
    # disable SMBv1
    Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Client" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Server" -NoRestart
    # disable Telnet
    Disable-WindowsOptionalFeature -Online -FeatureName "TelnetClient" -NoRestart
    # uninstall windows fax and scan services
    Disable-WindowsOptionalFeature -Online -FeatureName "FaxServicesClientPackage" -NoRestart
    # uninstall microsoft xps document writer
    Disable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart
    # windows media player
    Disable-WindowsOptionalFeature -Online -FeatureName "MediaPlayback" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart
}

Function removePrinters {
    # remove default fax and xps printers    
    Remove-Printer -Name "Fax"
    Remove-Printer -Name "Microsoft XPS Document Writer"
}

Function disableRemoteAssistance {
    $path="HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # disable allow remote assistance connections to this computer automatically
    Set-ItemProperty -Path $path -Name "fAllowToGetHelp" -Type DWord -Value 0 -Force
    Set-ItemProperty -Path $path -Name "fAllowFullControl" -Type DWord -Value 0 -Force
}

Function enableGuestSMBShares {
    $path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # enable guest SMB shares
    Set-ItemProperty -Path $path -Name "AllowInsecureGuestAuth" -Type DWord -Value 1
}

# HomeGroup
<#
Function disableHomeGroup {
    Write-Host "Disabling HomeGroup through 'HomeGroup Provider' && 'HomeGroup Listener' services " -ForegroundColor Green 
    Set-Service HomeGroupListener -StartupType Disabled
    Set-Service HomeGroupProvider -StartupType Disabled
    Set-Service HomeGroupListener -Status Stopped
    Set-Service HomeGroupProvider -Status Stopped
}
#>

Function uninstallOneDrive {
    # uninstall onedrive
    Stop-Process -Name "OneDrive" -Force
    $path="$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
    if (!(Test-Path $path)) { $path="$env:SYSTEMROOT\System32\OneDriveSetup.exe" }
    Start-Process $path "/uninstall"
}

Function setVisualFXAppearance {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # set visual effects for "appearance" mode
    Set-ItemProperty -Path $path -Name "VisualFXSetting" -Type DWord -Value 1 -Force
}

Function explorerSettings {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # show all tray notification icons on the taskbar
    Set-ItemProperty -Path $path -Name "EnableAutoTray" -Type DWord -Value 0 -Force
    # hide recent shortcuts from file explorer/quick access context
    Set-ItemProperty -Path $path -Name "ShowRecent" -Type DWord -Value 0 -Force
    Set-ItemProperty -Path $path -Name "ShowFrequent" -Type DWord -Value 0 -Force
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

Function taskbarHidePeopleIcon {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # hide taskbar people icon
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0 -Force
}
Function taskbarHideInkWorkspace {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # hide windows ink workspace
    Set-ItemProperty -Path $path -Name "PenWorkspaceButtonDesiredVisibility" -Type DWord -Value 0 -Force
}

Function disableWebSearch {
    $path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # disable web search 
    Set-ItemProperty -Path $path -Name "DisableWebSearch" -Type DWord -Value 1 -Force
}

Function explorerSetControlPanelLargeIcons {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # set control panel view to large icons
    Set-ItemProperty -Path $path -Name "StartupPage" -Type DWord -Value 1 -Force
    Set-ItemProperty -Path $path -Name "AllItemsIconView" -Type DWord -Value 0 -Force
}

Function enableDarkMode {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # enable dark mode
    Set-ItemProperty -Path $path -Name "AppsUseLightTheme" -Type DWord -Value 0 -Force
}

Function mkdirGodMode {
    # create god mode folder in home directory and pin shortcut to quick access
    $Path="C:\Users\$env:username\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
    New-Item -ItemType Directory -Path $Path -Force
    $QuickAccess = New-Object -ComObject shell.application 
    $TargetObject = $QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | where {$_.Path -eq "$Path"} 
    
    if ($TargetObject -ne $null) { 
        Write-Host "GodMode Folder is already pinned to Quick Access" -ForegroundColor Yellow
        return 
    } 
    else { 
        $QuickAccess.Namespace("$Path").Self.InvokeVerb("pintohome") 
    } 
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

Function disableWindowsDefenderSampleSubmission {
    # configure windows defender
    $path1="HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
    if (!(Test-Path $path1)) { New-Item -Path $path1 -Force }
    # disable windows defender automatic sample submission - (also seems to suppress automatic sample submission alerts)
    Set-ItemProperty -Path $path1 -Name "SubmitSamplesConsent" -Type DWord -Value 2 -Force
    # disable cloud based protection
    #Set-ItemProperty -Path $path1 -Name "SpynetReporting" -Type DWord -Value 0

    $path2="HKCU:\Software\Microsoft\Windows Security Health\State"
    if (!(Test-Path $path1)) { New-Item -Path $path1 -Force }
    # hide m$ account sign in warning
    Set-ItemProperty $path2 -Name "AccountProtection_MicrosoftAccount_Disconnected" -Type DWord -Value 1 -Force
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

Function mapNetworkDrives {
    #$server = "192.168.2.3" #10GbE config
    $server = "192.168.1.69"
    Write-Host  "Assuming a server ip of $server" -ForegroundColor Yellow
    Write-Host  "Ensure 10+GbE is configured before continuing!!!" -ForegroundColor Red

    net use Z: \\$server\apps /savecred /persistent:Yes
    net use Y: \\$server\downloads /savecred /persistent:Yes
    net use X: \\$server\media /savecred /persistent:Yes
    net use W: \\$server\share /savecred /persistent:Yes
    net use V: \\$server\store /savecred /persistent:Yes

    #$cred = Get-Credential (string caption, string message, string userName, string targetName);
    #$cred = $host.ui.PromptForCredential("Credentials to Map Network Drives", "Ensure 10+GbE is configured before continuing!!!", "Hackerman", "NetBiosUserName")
    #New-PSDrive -Name "Z" -Root "\\$server\apps" -Scope "Global" -Persist -PSProvider "FileSystem" -Credential $cred
    #New-PSDrive -Name "Y" -Root "\\$server\downloads" -Scope "Global" -Persist -PSProvider "FileSystem" -Credential $cred
    #New-PSDrive -Name "X" -Root "\\$server\media" -Scope "Global" -Persist -PSProvider "FileSystem" -Credential $cred
    #New-PSDrive -Name "W" -Root "\\$server\share" -Scope "Global" -Persist -PSProvider "FileSystem" -Credential $cred
    #New-PSDrive -Name "V" -Root "\\$server\store" -Scope "Global" -Persist -PSProvider "FileSystem" -Credential $cred
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

# 10GbE -> https://github.com/aesser11/home-lab/wiki/10GbE#windows-desktop
# plug mic into all usb ports to disable speaker device and set mic settings

# set task manager columns [process name, cpu, memory, disk, network, gpu]
# set task manager cpu to logical processors
# set task manager startup apps to disabled from running at boot
# show details during file transfers

# unpin default groups from start menu
# unpin default items from taskbar

# set which folders appear on start: file explorer, and user folders
# set notification center icons
# remove recycle bin from desktop -> ms-settings:personalization -> Themes -> Desktop icon settings
# set background, lock screen, and login photo
# adjust focus assist
# review windows permissions privacy settings
# set night light
# check for missed built-in apps 
# disable xbox in-game overlay
# review default apps

# pin GitHub to QuickAccess
# pin watch to QuickAccess

# install powertoys choco install powertoys -y ; pin add n=powertoys
# install electrum -> https://electrum.org/#download
# create cup all -y ; pause -> script with shortcut (pin to start menu manually)

# pin shit to start menu

#########################
# Appended Output Steps #
#########################
$global:appendOutputSteps
###################################################################################################
###########################
# Appended Software Steps #
###########################
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
