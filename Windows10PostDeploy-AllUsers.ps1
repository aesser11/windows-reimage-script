####################################
# Windows10PostDeploy-AllUsers.ps1 #
####################################
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
    # microsoft as of 1909
    "*Microsoft.Advertising.Xaml*",

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
    # standard apps every windows instance should have
    "hwinfo",
    "notepadplusplus",
    #vlc
    #rufus

    # requires case statements
    "7zip",#no pin && #append-software
    "windirstat"#no pin

    #choice: a,b,both,none
    #"googlechrome",
    #"firefox"
)

#################
# Reimage Steps #
#################
$firstRunFunctions1 = @(
    # user input required
    "renameComputer",#change-prompt-logic #missing (fix on main script first)

    # tailored for AllUsers (choice for browser)
    "installSoftware",

    # automated and universal
    "personalFolderTargetSteps"
)

$finalFirstRunFunctions3 = @(
    # tailored for AllUsers
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

    # tailored for AllUsers
    "uninstallWindowsFeatures",
    "configureWindowsUpdates",
    "uninstallOptionalApps",
    "taskbarHideSearch",
    "removeWin10Apps"

    # functions exclusively for AllUsers
    #n/a
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

    Function browserChoice {
        Switch (Read-Host "Install Chrome[1], FireFox[2], Both[3], or Neither[0]?") {
            '0' {
                Write-host "Skipping 3rd party browser installation..." -ForegroundColor Yellow
                break;
            }
            '1' {
                Write-host "Installing Chrome..." -ForegroundColor Yellow
                choco install googlechrome -y
                #choco pin add -n="googlechrome"
                
            }
            '2' {
                Write-host "Installing FireFox..." -ForegroundColor Yellow
                choco install firefox -y
                #choco pin add -n="firefox"

            }
            '3' {
                Write-host "Installing Both Chrome & FireFox..." -ForegroundColor Yellow
                choco install googlechrome -y
                #choco pin add -n="googlechrome"

                choco install firefox -y
                #choco pin add -n="firefox"
            }

            default {
                Write-host "Invalid input. Please enter [1], [2], [3] or [0]" -ForegroundColor Red
                browserChoice
            }
        }
    }
    browserChoice

    foreach ($software in $applicationsToInstall) {
        Switch ($software) {
            # exception cases
            "7zip" {
                choco install $software -y
                $global:appendOutputSoftware += "
7zip: change file type associations, reduce context menus to extract files, check hash, and add to archive
"
            }
            "windirstat" {
                choco install $software -y
            }
            # default behavior for all other apps
            default {
                choco install $software -y
                # choco pin add -n="$software"
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
#Speech
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

#App permissions
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
Function soundCommsAttenuation {
    $path="HKCU:\Software\Microsoft\Multimedia\Audio"
    # set communications tab to "do nothing"
    Set-ItemProperty -Path $path -Name "UserDuckingPreference" -Type DWord -Value 3 -Force
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

Function disableMouseAcceleration {
    $path="HKCU:\Control Panel\Mouse"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # disable mouse acceleration
    Set-ItemProperty -Path $path -Name "MouseSpeed" -Type String -Value 0 -Force
    Set-ItemProperty -Path $path -Name "MouseThreshold1" -Type String -Value 0 -Force
    Set-ItemProperty -Path $path -Name "MouseThreshold2" -Type String -Value 0 -Force
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
    #Disable-WindowsOptionalFeature -Online -FeatureName "FaxServicesClientPackage" -NoRestart
    # uninstall microsoft xps document writer
    #Disable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart
    # windows media player
    #Disable-WindowsOptionalFeature -Online -FeatureName "MediaPlayback" -NoRestart
    #Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart
}

# configure windows updates
Function configureWindowsUpdates {
    $path1="HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
    if (!(Test-Path $path1)) { New-Item -Path $path1 -Force }
    # set active hours 8am-2am
    #Set-ItemProperty -Path $path1 -Name "ActiveHoursStart" -Type DWord -Value 8 -Force
    #Set-ItemProperty -Path $path1 -Name "ActiveHoursEnd" -Type DWord -Value 2 -Force
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

Function uninstallOptionalApps {
    #Get-WindowsCapability -online | ? {$_.Name -like '*QuickAssist*'} | Remove-WindowsCapability -online
    #Get-WindowsCapability -online | ? {$_.Name -like '*ContactSupport*'} | Remove-WindowsCapability -online
    Get-WindowsCapability -online | ? {$_.Name -like '*Demo*'} | Remove-WindowsCapability -online
    #Get-WindowsCapability -online | ? {$_.Name -like '*Face*'} | Remove-WindowsCapability -online
    #Get-WindowsCapability -online | ? {$_.Name -like '*WindowsMediaPlayer*'} | Remove-WindowsCapability -online
}

Function taskbarHideSearch {
    $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (!(Test-Path $path)) { New-Item -Path $path -Force }
    # hide taskbar search icon / box
    Set-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -Type DWord -Value 1 -Force
    # disable bing web search
    #Set-ItemProperty -Path $path -Name "BingSearchEnabled" -Type DWord -Value 0 -Force
    #Set-ItemProperty -Path $path -Name "CortanaConsent" -Type DWord -Value 0 -Force
}

Function removeWin10Apps {
    foreach ($app in $win10AppBlacklist) {
        Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "$app"} | Remove-AppxPackage
    }
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
# set task manager startup apps to disabled from running at boot
# unpin default groups from start menu
# disable 5 tabs for windows permissions privacy settings manually
# review default apps

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
