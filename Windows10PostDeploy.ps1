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
# Windows 10 Apps to Whitelist #
################################
$win10AppWhitelist = @(
    # as of 1909
    "*WindowsCalculator*",
    "*Photos*",
    "*Paint*",
    "*ScreenSketch*"
)

#############################
# 3rd Party Apps to Install #
#############################
$applicationsToInstall = @(
    # my chocolatey apps
    # auto run
    "github-desktop",
    "hwinfo",
    "powertoys",
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

    # manual installs
    "battle.net" #append-software
    #"electrum" #append-software
)

#################
# Reimage Steps #
#################
$myFirstRunFunctions = @(
    # user input required
    "renameComputer",#change-prompt-logic
    # automated
    "installSoftware",#append-software
    "personalFolderTargetSteps"
)

$myFunctions = @(
    # universal functions
    "disableTelemetry",
    "uninstallOptionalApps",
    "setWindowsTimeZone",
    "enableLegacyF8Boot",
    "deleteHibernationFile",
    "setPowerProfile",
    "configureWindowsUpdates",
    "configurePrivacy",
    "disableStickyKeys",
    "setPageFileToC",
    "disableMouseAcceleration",
    "soundCommsAttenuation",

    # my functions
    "removeWin10Apps",
    "uninstallWindowsFeatures",
    "removePrinters",
    "disableRemoteAssistance",
    "enableGuestSMBShares",
    #"disableHomeGroup",
    "uninstallOneDrive",
    "setVisualFXAppearance",
    "explorerSettings",
    "taskbarHideSearch",
    "taskbarHidePeopleIcon",
    "taskbarHideInkWorkspace",
    "disableWebSearch",
    "disableLockScreenTips",
    "explorerSetControlPanelLargeIcons",
    "enableDarkMode",
    "mkdirGodMode",
    "disableSharedExperiences",
    "disableWifiSense",
    "disableWindowsDefenderSampleSubmission",
    "disableLocalIntranetFileWarnings",
    "disableBackgroundApplications",
    "advancedExplorerSettings",
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
        # exception cases
        Switch ($software) {
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
teamviewer steps to change
"
            }
            "7zip" {
                choco install $software -y
                $global:appendOutputSoftware += "
7zip steps to change
"
            }
            "windirstat" {
                choco install $software -y
            }
            "battle.net" {
                # download manually
                if (!(Test-Path "C:\Users\$env:username\Desktop\*battle.net*")) {
                    Write-Host "Downloading: Battle.net" -ForegroundColor Green -BackgroundColor Black
                    $url = "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"
                    $output = "C:\Users\$env:username\Desktop\Battle.net-Setup.exe"
                    $start_time = Get-Date
                    (New-Object System.Net.WebClient).DownloadFile($url, $output)
                    Write-Host "Waiting for Battle.net to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
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
        Write-Host "Rename your PC, current name: $env:computername" -ForegroundColor Green -BackgroundColor Black
        Write-Host "Press [Enter] to continue without renaming" -ForegroundColor Yellow -BackgroundColor Black
        $newCompName = Read-Host -Prompt "Enter in a new computer name, limit 15 characters"
        $newCompNameLength = $newCompName.length
        while (($newCompNameLength -gt 15) -or ($newCompName -eq "y") -or ($newCompName -eq "Y") -or ($newCompName -eq "n") -or ($newCompName -eq "N")) {
            Write-Host "The name specified is $newCompNameLength character(s) long" -ForegroundColor Red -BackgroundColor Black
            $renameComputer = Read-Host -Prompt "Do you wish to rename from $newCompName : [y]/[n]?"
            if (($renameComputer -eq "y") -or ($renameComputer -eq "Y") -or ($renameComputer -eq "1")) {
                Write-Host "Getting a new name... Limit 15 characters" -ForegroundColor Green -BackgroundColor Black
                Write-Host "Press [Enter] to continue without renaming" -ForegroundColor Yellow -BackgroundColor Black
                $newCompName = Read-Host -Prompt "Enter in a new computer name, limit 15 characters"
                $newCompNameLength = $newCompName.length
            }
            elseif (($renameComputer -eq "n") -or ($renameComputer -eq "N") -or ($renameComputer -eq "0")) {
                Write-Host "Proceeding..." -ForegroundColor Yellow -BackgroundColor Black
                $newCompNameLength = 0
            }
            else {
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
            }
        }
        if (!$newCompName) {
            Write-Host "Skipping new name since no input was specified" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Rename-Computer -NewName $newCompName 
        }
    }
    else {
        Write-Host "A personalized computer name already exists: $env:computername | Skipping the renaming section" -ForegroundColor Green -BackgroundColor Black
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
    #Get-WindowsCapability -online | ? {$_.Name -like '*QuickAssist*'} | Remove-WindowsCapability -online
    #Get-WindowsCapability -online | ? {$_.Name -like '*ContactSupport*'} | Remove-WindowsCapability -online
    Get-WindowsCapability -online | ? {$_.Name -like '*Demo*'} | Remove-WindowsCapability -online
    #Get-WindowsCapability -online | ? {$_.Name -like '*Face*'} | Remove-WindowsCapability -online
    Get-WindowsCapability -online | ? {$_.Name -like '*WindowsMediaPlayer*'} | Remove-WindowsCapability -online
}

# Sync windows time -------- (explorer)
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
        Write-Host "Region doesn't match current time zone, setting to Pacific Standard Time" -ForegroundColor Green -BackgroundColor Black
        Set-TimeZone -Name "Pacific Standard Time"
    }
    #Montana, Wyoming, Colorado, Utah, New Mexico                                           
    elseif (($currentTimeZone -ne "Mountain Standard Time") -and ($ipState -eq "Montana" -or $ipState -eq "Wyoming" -or $ipState -eq "Colorado" -or $ipState -eq "Utah" -or $ipState -eq "New Mexico")) {
        Write-Host "Region doesn't match current time zone, setting to Mountain Standard Time" -ForegroundColor Green -BackgroundColor Black
        Set-TimeZone -Name "Mountain Standard Time"
    }
    #Minnesota, Wisconsin, Iowa, Illinois, Missouri, Arkansas, Oklahoma, Mississippi, Alabama, Louisiana
    elseif (($currentTimeZone -ne "Central Standard Time") -and ($ipState -eq "Minnesota" -or $ipState -eq "Wisconsin" -or $ipState -eq "Iowa" -or $ipState -eq "Illinois" -or $ipState -eq "Missouri" -or $ipState -eq "Arkansas" -or $ipState -eq "Oklahoma" -or $ipState -eq "Mississippi" -or $ipState -eq "Alabama" -or $ipState -eq "Louisiana")) {
        Write-Host "Region doesn't match current time zone, setting to Central Standard Time" -ForegroundColor Green -BackgroundColor Black
        Set-TimeZone -Name "Central Standard Time"
    }
    #Georgia, South Carolina, North Carolina, Virginia, West Virginia, Ohio, Pennsylvania, New York, Maine, Vermont, New Hampshire, Massachusetts, Rhode Island, Connecticut, New Jersey, Delaware, Maryland, District of Columbia
    elseif (($currentTimeZone -ne "Eastern Standard Time") -and ($ipState -eq "Georgia" -or $ipState -eq "South Carolina" -or $ipState -eq "North Carolina" -or $ipState -eq "Virginia" -or $ipState -eq "West Virginia" -or $ipState -eq "Ohio" -or $ipState -eq "Pennsylvania" -or $ipState -eq "New York" -or $ipState -eq "Maine" -or $ipState -eq "Vermont" -or $ipState -eq "New Hampshire" -or $ipState -eq "Massachusetts" -or $ipState -eq "Rhode Island" -or $ipState -eq "Connecticut" -or $ipState -eq "New Jersey" -or $ipState -eq "Delaware" -or $ipState -eq "Maryland" -or $ipState -eq "District of Columbia")) {
        Write-Host "Region doesn't match current time zone, setting to Eastern Standard Time" -ForegroundColor Green -BackgroundColor Black
        Set-TimeZone -Name "Eastern Standard Time"
    }
    #Multi-zone-states
    #Florida
    elseif ($ipState -eq "Florida") {
        if (($currentTimeZone -ne "Central Standard Time") -and (($ipLat -ge 29.55) -and ($ipLon -lt -85.5835))) {
            #CST
            Write-Host "Region doesn't match current time zone, setting to Central Standard Time" -ForegroundColor Green -BackgroundColor Black
            Set-TimeZone -Name "Central Standard Time"
        }
        elseif (($currentTimeZone -ne "Eastern Standard Time") -and (($ipLat -le 31.00) -and ($ipLon -ge -85.5835))) {
            #EST
            Write-Host "Region doesn't match current time zone, setting to Eastern Standard Time" -ForegroundColor Green -BackgroundColor Black
            Set-TimeZone -Name "Eastern Standard Time"
        }
        else {
            Write-Host "Time Zone location could not be determined for Florida, Input a time zone manually" -ForegroundColor Red -BackgroundColor Black
            Write-Host "Enter either 'Central Standard Time' or 'Eastern Standard Time'" -ForegroundColor Yellow -BackgroundColor Black
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
        Write-Host "Region already matches current time zone, skipping and continuing with time sync" -ForegroundColor Green -BackgroundColor Black
    }
    Write-Host "Syncing windows time" -ForegroundColor Green -BackgroundColor Black
    net start w32time
    w32tm /resync
}

# Enable legacy F8 boot menu
Function enableLegacyF8Boot {
    #bcdedit /set `{current`} bootmenupolicy Legacy
    bcdedit /set "{current}" bootmenupolicy Legacy
}

# Delete hibernation file -- (cmd)
Function deleteHibernationFile{
    powercfg -h off
}

# Create power profile ----- (ctrl pan)
Function setPowerProfile {
    Function powerSetings {
    ###############################################################################################################################################
        # Processor specific config settings to disable core parking etc 
        # https://docs.microsoft.com/en-us/previous-versions/windows/hardware/design/dn642106(v=vs.85)
        # https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/configure-processor-power-management-options 
        <#
        powercfg -setacvalueindex scheme_current sub_processor DISTRIBUTEUTIL 0
        powercfg -setdcvalueindex scheme_current sub_processor DISTRIBUTEUTIL 1
        # (Core Parking) (minimum percentage of cores that can be unparked) (100 disables core parking)
        powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
        powercfg -setdcvalueindex scheme_current sub_processor CPMINCORES 0
        # (Core Parking) (maximum percentage of cores that can be unparked)
        powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100
        powercfg -setdcvalueindex scheme_current sub_processor CPMAXCORES 100
        # (Performance boost mode) | 0 (Disabled) | 1 (Enabled) | 2 (Aggressive) | 3 (Efficient Enabled) | 4 (Efficient Aggressive)
        powercfg -setacvalueindex scheme_current sub_processor PERFBOOSTMODE 4
        powercfg -setdcvalueindex scheme_current sub_processor PERFBOOSTMODE 3
        #>
    ###############################################################################################################################################
        # (Hard Disk)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_DISK DISKIDLE 1200
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_DISK DISKIDLE 1200

        # (Internet Explorer)
        powercfg -setacvalueindex SCHEME_CURRENT 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 1
        powercfg -setdcvalueindex SCHEME_CURRENT 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 0

        # (Desktop background settings)
        # (Slide show)
        powercfg -setacvalueindex SCHEME_CURRENT 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 0
        powercfg -setdcvalueindex SCHEME_CURRENT 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 1

        # (Wireless Adapter Settings)
        powercfg -setacvalueindex SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
        powercfg -setdcvalueindex SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 3

        # (Sleep)
        # (Sleep after)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 18000
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 1800
        # (Allow hybrid sleep)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_SLEEP HYBRIDSLEEP 1
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_SLEEP HYBRIDSLEEP 1
        # (Hibernate after)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0
        # (Allow wake timers)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 2
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 0

        # (USB settings)
        # (USB selective suspend setting)
        powercfg -setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
        powercfg -setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1

        # (Intel(R) Graphics Settings)
        # (Intel(R) Graphics Power Plan)
        powercfg -setacvalueindex SCHEME_CURRENT 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 2
        powercfg -setdcvalueindex SCHEME_CURRENT 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 0

        # (Power buttons and lid)
        # (Lid close action)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
        # (Power button action)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 3
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 3
        # (Sleep button action)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
        # (Start menu power button)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BUTTONS UIBUTTON_ACTION 0
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BUTTONS UIBUTTON_ACTION 0

        # (PCI Express)
        # (Link State Power Management)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 2

        # (Processor power management)
        # (Minimum processor state)
        # set minimum frequency
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 0
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 0
        # (System cooling policy)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR SYSCOOLPOL 1
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR SYSCOOLPOL 0
        # (Maximum processor state)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100

        # (Display)
        # (Turn off display after)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 1500
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 600
        # (Display brightness)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_VIDEO aded5e82-b909-4619-9949-f5d71dac0bcb 100
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_VIDEO aded5e82-b909-4619-9949-f5d71dac0bcb 75
        # (Dimmed display brightness)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_VIDEO f1fbfde2-a960-4165-9f88-50667911ce96 50
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_VIDEO f1fbfde2-a960-4165-9f88-50667911ce96 50
        # (Enable adaptive brightness)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_VIDEO ADAPTBRIGHT 0
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_VIDEO ADAPTBRIGHT 0

        # (Multimedia settings)
        # (When sharing media)
        powercfg -setacvalueindex SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 1
        powercfg -setdcvalueindex SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 0
        # (Video playback quality bias.)
        powercfg -setacvalueindex SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 1
        powercfg -setdcvalueindex SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 0
        # (When playing video)
        powercfg -setacvalueindex SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 0
        powercfg -setdcvalueindex SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 2

        # (Battery)
        # (Critical battery notification)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BATTERY BATFLAGSCRIT 1
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BATTERY BATFLAGSCRIT 1
        # (Critical battery action)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BATTERY BATACTIONCRIT 0
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BATTERY BATACTIONCRIT 1
        # (Low battery level)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BATTERY BATLEVELLOW 10
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BATTERY BATLEVELLOW 10
        # (Critical battery level)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BATTERY BATLEVELCRIT 5
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BATTERY BATLEVELCRIT 5
        # (Low battery notification)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BATTERY BATFLAGSLOW 0
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BATTERY BATFLAGSLOW 1
        # (Low battery action)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BATTERY BATACTIONLOW 0
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BATTERY BATACTIONLOW 0
        # (Reserve battery level)
        powercfg -setacvalueindex SCHEME_CURRENT SUB_BATTERY f3c5027d-cd16-4930-aa6b-90db844a8f00 7
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_BATTERY f3c5027d-cd16-4930-aa6b-90db844a8f00 7
    }
    # powercfg reference https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options
    Write-Host "Power: Selecting and configuring power profile" -ForegroundColor Green -BackgroundColor Black
    powercfg -h off
    $cpu = Get-WMIObject Win32_Processor
    $cpuName = $cpu.name

    $powerPlans = Get-WMIObject -namespace "root\cimv2\power" -class Win32_powerplan
    $powerPlanGUIDs = $powerPlans.InstanceId
    $powerPlanGUIDAMD = $powerPlanGUIDs.split("`r`n") | ForEach {$_} | Select-String -Pattern "9897998c-92de-4669-853f-b7cd3ecb2790"

    if (($cpuName -like "*Ryzen*") -and ($powerPlanGUIDAMD)) {
        <#
        Caption           : AMD64 Family 23 Model 17 Stepping 0
        DeviceID          : CPU0
        Manufacturer      : AuthenticAMD
        MaxClockSpeed     : 3500
        Name              : AMD Ryzen 3 2200G with Radeon Vega Graphics
        SocketDesignation : AM4
        Power Scheme GUID: 9897998c-92de-4669-853f-b7cd3ecb2790  (AMD Ryzen™ Balanced) *
        #>
        Write-Host "Ryzen CPU Detected, selecting AMD Ryzen Balanced config" -ForegroundColor Green -BackgroundColor Black
        powercfg -setactive 9897998c-92de-4669-853f-b7cd3ecb2790
        powerSetings
    }
    else {
        Write-Host "CPU is not AMD Ryzen, proceeding with standard config" -ForegroundColor Green -BackgroundColor Black
        # GUID 381b4222-f694-41f0-9685-ff5bb260df2e
        powercfg -setactive SCHEME_BALANCED
        powerSetings
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
# https://privacyamp.com/knowledge-base/windows-10-privacy-settings/
#   General
    #Disable AdvertisingID
    #Write-Host "Disabling Advertising ID..." -ForegroundColor Green -BackgroundColor Black
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
    #Disable website language list access
    #Write-Host "Disabling Website Access to Language List..." -ForegroundColor Green -BackgroundColor Black
    Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
    #Let windows track app launches to imp. start and search results
    #Write-Host "Disabling Let Windows Track App Launches for Start and Search..." -ForegroundColor Green -BackgroundColor Black
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0
    #Show me sugested content in settings app 
    #Write-Host "Disabling Application suggestions..." -ForegroundColor Green -BackgroundColor Black
    if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Force
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
#   Speech Inking and Typing - Disable speech, inking, and typing getting to know you
# Turn off automatic learning 
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
    if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
# Disallow input Personalization
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
# Turn off updates to speech recognition and speech synthesis
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Speech_OneCore\Preferences" -Name "ModelDownloadAllowed" -Type DWord -Value 0
# Turn off handwriting personalization data sharing
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -Type DWord -Value 1
# Turn off handwriting recognition error reporting
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -Name "PreventHandwritingErrorReports" -Type DWord -Value 1
#   Diagnostics & Feedback
    # Disable Feedback
    if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient"
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    #Disable Improv. inking and typing recognition
    if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Name "AllowLinguisticDataCollection" -Type DWord -Value 0
    #Disable Tailored experiences
    #Write-Host "Disabling Tailored Experiences..." -ForegroundColor Green -BackgroundColor Black
    if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
    #Disable diagnostic data viewer
    if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" -Name "EnableEventTranscript" -Type DWord -Value 0
    
    #Feedback frequency
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
#   Activity History
    #Disable activity feed | #Disable Let Windows collect activites from my PC
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
    #Disable publishing of user activiites | #Disable Let windows sync activiites from my pc to the cloud
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
    #Disallow upload of User Activities
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0
#   App permissions section... - (leave this manual (unchanged) to ensure system functionality?
#Write-Host "Adjust permission settings manually" -ForegroundColor Yellow -BackgroundColor Black
#disable background apps 
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
    # suppress errors for these cmdlets, very noisy and never looked at
    foreach ($app in $win10AppWhitelist) {
        Get-AppxPackage -AllUsers | Where-Object {$_.Name -notlike "$app"} | Remove-AppxPackage -ErrorAction Ignore
        Get-AppXProvisionedPackage -Online | Where-Object {$_.DisplayName -notlike "$app"} | Remove-AppxProvisionedPackage -Online -ErrorAction Ignore
    }
    # reinstall all apps 
    # Get-AppxPackage -AllUsers| Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
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
    Write-Host "Disabling HomeGroup through 'HomeGroup Provider' && 'HomeGroup Listener' services " -ForegroundColor Green -BackgroundColor Black 
    Set-Service HomeGroupListener -StartupType Disabled
    Set-Service HomeGroupProvider -StartupType Disabled
    Set-Service HomeGroupListener -Status Stopped
    Set-Service HomeGroupProvider -Status Stopped
}
#>

Function uninstallOneDrive {
    # uninstall onedrive
    Stop-Process -Name "OneDrive" -Force
    $path = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
    if (!(Test-Path $path)) { $path = "$env:SYSTEMROOT\System32\OneDriveSetup.exe" }
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
    $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # hide taskbar search icon / box
    Set-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -Type DWord -Value 0 -Force
    # disable bing web search
    Set-ItemProperty -Path $path -Name "BingSearchEnabled" -Type DWord -Value 0 -Force
    Set-ItemProperty -Path $path -Name "CortanaConsent" -Type DWord -Value 0 -Force
}

Function taskbarHidePeopleIcon {
    $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # hide taskbar people icon
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0 -Force
}
Function taskbarHideInkWorkspace {
    $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace"
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

Function disableLockScreenTips {
# disable fun facts and tips on lock screen and remove spotlight
#start ms-settings:lockscreen
    Write-Host "Disabling More fun facts and tips on lock screen" -ForegroundColor Green -BackgroundColor Black
    if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Force
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
}

Function explorerSetControlPanelLargeIcons {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # set control panel view to large icons
    Set-ItemProperty -Path $path -Name "StartupPage" -Type DWord -Value 1 -Force
    Set-ItemProperty -Path $path -Name "AllItemsIconView" -Type DWord -Value 0 -Force
}

Function enableDarkMode {
    $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # enable dark mode
    Set-ItemProperty -Path $path -Name "AppsUseLightTheme" -Type DWord -Value 0 -Force
}

Function mkdirGodMode {
    # create god mode folder in home directory and pin shortcut to quick access
    $Path = "C:\Users\$env:username\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
    New-Item -ItemType Directory -Path $Path -Force
    $QuickAccess = New-Object -ComObject shell.application 
    $TargetObject = $QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | where {$_.Path -eq "$Path"} 
    
    if ($TargetObject -ne $null) { 
        Write-Host "GodMode Folder is already pinned to Quick Access" -ForegroundColor Yellow -BackgroundColor Black
        return 
    } 
    else { 
        $QuickAccess.Namespace("$Path").Self.InvokeVerb("pintohome") 
    } 
}

# Disable shared experiences
Function disableSharedExperiences {
    Write-Host "Disabling shared experiences" -ForegroundColor Green -BackgroundColor Black
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")){
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableCdp" -Type DWord -Value 0
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

    $path2="HKCU:\SOFTWARE\Microsoft\Windows Security Health\State"
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

Function disableBackgroundApplications {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    Set-ItemProperty -Path $path -Name "GlobalUserDisabled" -Type DWord -Value 1 -Force
}

Function advancedExplorerSettings {
    $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
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

# 10GbE -> https://github.com/aesser11/home-lab/wiki/10GbE#windows-desktop

# plug mic into all usb ports to disable speaker device and set mic settings

# set task manager columns [process name, cpu, memory, disk, network, gpu]
# set task manager cpu to logical processors
# set task manager startup apps to disabled from running at boot

# show details during file transfers

# unpin default groups from start menu
# remove recycle bin from desktop -> ms-settings:personalization -> Themes -> Desktop icon settings

# pin GitHub to QuickAccess
# pin watch to QuickAccess

#####################
# Automatable Steps #
#####################
# disable privacy diagnostic data (set to basic at the moment)
# set night light?
# enable clipboard history?
# create cup all -y ; pause script with shortcut (pin to start menu manually)
# adjust focus assist?

######################
# map network drives #
######################
# input username and password to map drives as, 10gbe must be configred first, maybe have a prompt for dest IPs -- 192.168.2.3 default
Hackerman
password in lastpass

Z: \\192.168.2.3\apps
Y: \\192.168.2.3\downloads
X: \\192.168.2.3\media
W: \\192.168.2.3\share
V: \\192.168.2.3\store
######################

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
            $myFirstRunFunctions | ForEach { Invoke-Expression $_ }
            $myFunctions | ForEach { Invoke-Expression $_ }
            remainingStepsToText
        }
        'n' {
            Write-host "Skipping first install steps..." -ForegroundColor Yellow
            $myFunctions | ForEach { Invoke-Expression $_ }
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
# map network drives #
######################
$server = Read-Host -Prompt "enter ip for mapped drives - [enter] for default of 192.168.2.3"
$cred = Get-Credential
New-PSDrive -Name "Z" -Root "\\$server\apps" -Persist -PSProvider "FileSystem" -Credential $cred
New-PSDrive -Name "Y" -Root "\\$server\downloads" -Persist -PSProvider "FileSystem" -Credential $cred
New-PSDrive -Name "X" -Root "\\$server\media" -Persist -PSProvider "FileSystem" -Credential $cred
New-PSDrive -Name "W" -Root "\\$server\share" -Persist -PSProvider "FileSystem" -Credential $cred
New-PSDrive -Name "V" -Root "\\$server\store" -Persist -PSProvider "FileSystem" -Credential $cred

###################################################################################################

#Template for changing registry
reg functions to combine 

"HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
     #Software
"HKLM:SOFTWARE\Policies\Microsoft\Windows\System"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
#>