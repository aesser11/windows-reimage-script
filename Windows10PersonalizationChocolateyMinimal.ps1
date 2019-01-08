##############################################################################################################
# Relaunch the script with administrator privileges and bypass execution-policy if it isn't already
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    exit
}
$allUsersAutomated = @(
    "disableNvidiaTelemetry",
    "disableTelemetry",
    "setWindowsTimeZone",
    "uninstallWindowsFeatures",
    "enableLegacyF8Boot",
    "deleteHibernationFile",
    "setPowerProfile"
)
$allUsersPrompted = @(
    "uninstallIE"
)
$regularUserAutomated = @(
#    "endUserDeleteApps",
#    "disableHomeGroup",
#    "uninstallWMP",
#    "uninstallOneDrive",
#    "removePrinters"
)
$powerUserAutomated = @(
    "enableGuestSMBShares",
    "powerUserDeleteApps",
    "uninstallOptionalApps",
    "mkdirGodMode",
    "unPinDocsAndPicsFromQuickAccess",
    "disableHomeGroup",
    "uninstallWMP",
    "uninstallOneDrive",
    "removePrinters"
)
$allUsersFirstRunPrompted = @(
    "renameComputer",
    "personalFolderTargetSteps",
    "pinStartMenuItemsAndInstallSoftware"
)
Function getPromptAnswers {
    #ask all of the prompts here as global variables and pass them through to the respective functions $true or $false

    #"uninstallIE",
    $ie11State = $false
    do {
        $ie11UserInput = Read-Host -Prompt "Uninstall Internet Exploder 11? [y]/[n] | (Microsoft Edge will not be affected)"
        if (($ie11UserInput -eq "y") -or ($ie11UserInput -eq "Y") -or ($ie11UserInput -eq "1")) {
            $ie11State = $true
            $global:uninstallIECheck = $true
        }
        elseif (($ie11UserInput -eq "n") -or ($ie11UserInput -eq "N") -or ($ie11UserInput -eq "0")) {
            $ie11State = $true
            $global:uninstallIECheck = $false
        }
        else {
            $ie11State = $false
            Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
        }
    }
    while ($ie11State -eq $false)
}

Function getSoftwareAnswers {
    #ask all software prompts here as global variables and pass them through later [$true or $false]
    #"renameComputer", # usually first run - user preference prompt
    if ($env:computername -like "*DESKTOP-*") {
        Write-Host "Rename your PC, current name: $env:computername" -ForegroundColor Green -BackgroundColor Black
        Write-Host "Press [Enter] to continue without renaming" -ForegroundColor Yellow -BackgroundColor Black
        $global:newCompName = Read-Host -Prompt "Enter in a new computer name, limit 15 characters"
        $newCompNameLength = $global:newCompName.length
        while (($newCompNameLength -gt 15) -or ($global:newCompName -eq "y") -or ($global:newCompName -eq "Y") -or ($global:newCompName -eq "n") -or ($global:newCompName -eq "N")) {
            Write-Host "The name specified is $newCompNameLength character(s) long" -ForegroundColor Red -BackgroundColor Black
            $renameComputer = Read-Host -Prompt "Do you wish to rename from $global:newCompName : [y]/[n]?"
            if (($renameComputer -eq "y") -or ($renameComputer -eq "Y") -or ($renameComputer -eq "1")) {
                Write-Host "Getting a new name... Limit 15 characters" -ForegroundColor Green -BackgroundColor Black
                Write-Host "Press [Enter] to continue without renaming" -ForegroundColor Yellow -BackgroundColor Black
                $global:newCompName = Read-Host -Prompt "Enter in a new computer name, limit 15 characters"
                $newCompNameLength = $global:newCompName.length
            }
            elseif (($renameComputer -eq "n") -or ($renameComputer -eq "N") -or ($renameComputer -eq "0")) {
                Write-Host "Proceeding..." -ForegroundColor Yellow -BackgroundColor Black
                $newCompNameLength = 0
            }
            else {
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
            }
        }
        if (!$global:newCompName) {
            Write-Host "Skipping new name since no input was specified" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            $global:renameComputerAnswer = $true
        }
    }
    else {
        Write-Host "A personalized computer name already exists: $env:computername | Skipping the renaming section" -ForegroundColor Green -BackgroundColor Black
    }

    #"pinStartMenuItemsAndInstallSoftware", # always run - prompt - prompt if you want to install software and pin apps to the start menu
    #Prompt the user to select software here
        #Install for every image
        $global:7zip = $true
        $global:hwinfo = $true
        $global:vlc = $true
        $global:windirstat = $true

        ################
        # Web Browsers #
        ################
        do {
            $browserPrompt = 
"
[18] Install Web Browsers: 
[1] for Google Chrome
[2] for FireFox
[3] for Both
[0] for None
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $browserPrompt
            if ($SoftwareType -eq "0") {
                $doneUser = $true
            }
            elseif ($SoftwareType -eq "1") {
                $doneUser = $true
                $global:chrome = $true
            }
            elseif ($SoftwareType -eq "2") {
                $doneUser = $true
                $global:firefox = $true
            }
            elseif ($SoftwareType -eq "3") {
                $doneUser = $true
                $global:chrome = $true
                $global:firefox = $true
                $global:edge = $true
            }
            else {
                $doneUser = $false
                Write-Host "Please input [1] [2] or [3] for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)

        #################
        # Cloud Storage #
        #################
        do {
            $storagePrompt = 
"
[17] Install Cloud Storage: 
[1] for Dropbox
[2] for Google Drive
[3] for Both
[0] for None
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $storagePrompt
            if ($SoftwareType -eq "0") {
                $doneUser = $true
            }
            elseif ($SoftwareType -eq "1") {
                $doneUser = $true
                $global:dropbox = $true
            }
            elseif ($SoftwareType -eq "2") {
                $doneUser = $true
                $global:googledrive = $true
            }
            elseif ($SoftwareType -eq "3") {
                $doneUser = $true
                $global:dropbox = $true
                $global:googledrive = $true
            }
            else {
                $doneUser = $false
                Write-Host "Please input [1] [2] or [3] for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)

        ################
        # Text Editors #
        ################
        do {
            $textPrompt = 
"
[16] Install Text Editors: 
[1] for Notepad++
[2] for SublimeText3
[3] for Both
[0] for None
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $textPrompt
            if ($SoftwareType -eq "0") {
                $doneUser = $true
            }
            elseif ($SoftwareType -eq "1") {
                $doneUser = $true
                $global:notepadpp = $true 
            }
            elseif ($SoftwareType -eq "2") {
                $doneUser = $true
                $global:sublimetext = $true
            }
            elseif ($SoftwareType -eq "3") {
                $doneUser = $true
                $global:notepadpp = $true 
                $global:sublimetext = $true
            }
            else {
                $doneUser = $false
                Write-Host "Please input [1] [2] or [3] for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)

        ######################
        # Optional Utilities #
        ######################
        #f.lux
        if ($global:skipFlux -eq $true) {
            Write-Host "[15] Utilities: Skipping f.lux automatically since windows night light has been configured" -ForegroundColor Green -BackgroundColor Black
            $global:flux = $false
        }
        else {
            # Prompt to download f.lux
            do {
                $fluxPrompt = 
"
[15] Utilities: Install f.lux?: Reduces blue light at night
[y] for yes
[n] for no
"
                $doneUser = $false
                $SoftwareType = Read-Host -Prompt $fluxPrompt
                if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                    $doneUser = $true
                    $global:flux = $true
                }
                elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "0")){
                    $doneUser = $true
                    $global:flux = $false
                }
                else {
                    $doneUser = $false
                    Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
                }
            }
            while ($doneUser -eq $false)
        }
        #IMG Burn
        do {
            $imgburnPrompt = 
"
[14] Utilities: Install IMG Burn?: Optical disc burning & IMG/ISO creation program
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $imgburnPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:imgburn = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:imgburn = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Rufus
        do {
            $rufusPrompt = 
"
[13] Utilities: Install Rufus?: Bootable flash drive creation tool
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $rufusPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:rufus = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:rufus = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Putty
        do {
            $puttyPrompt = 
"
[12] Utilities: Install PuTTY?: Open source terminal emulator for SSH, SCP, Telnet, rlogin
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $puttyPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:putty = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:putty = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #TeamViewer.host needs improvement - implement this functionality
        #TeamViewer
        do {
            $teamviewerPrompt0 = 
"
[11] Utilities: Install TeamViewer?: Remote computer control program
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $teamviewerPrompt0
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:teamviewer = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:teamviewer = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #MSI Afterburner
        do {
            $msiafterburnerPrompt = 
"
[10] Utilities: Install MSI Afterburner?: Graphics card overclocking & monitoring program
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $msiafterburnerPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:msiafterburner = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:msiafterburner = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)

        #########################
        # Everyday Applications #
        #########################
        #Spotify
        do {
            $spotifyPrompt = 
"
[9] Multimedia: Install Spotify?: Music streaming platform
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $spotifyPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:spotify = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:spotify = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Skype
        do {
            $skypePrompt = 
"
[8] Communication: Install Skype?: Video and voice calling program
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $skypePrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:skype = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:skype = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)

        ##########
        # Gaming #
        ##########
        #Discord
        do {
            $discordPrompt = 
"
[7] Communication: Install Discord?: Voice program for gaming
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $discordPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:discord = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:discord = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Steam
        do {
            $steamPrompt = 
"
[6] Gaming: Install Steam?: Gaming platform
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $steamPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:steam = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:steam = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #GoG Galaxy
        do {
            $goggalaxyPrompt = 
"
[5] Gaming: Install GoG Galaxy?: Gaming platform
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $goggalaxyPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:goggalaxy = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:goggalaxy = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Battle.net
        do {
            $battlenetPrompt = 
"
[4] Gaming: Install Battle.net?: Gaming platform
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $battlenetPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:battlenet = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:battlenet = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Origin
        do {
            $originPrompt = 
"
[3] Gaming: Install Origin?: Gaming platform
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $originPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:origin = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:origin = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Uplay
        do {
            $uplayPrompt = 
"
[2] Gaming: Install Uplay?: Gaming platform
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $uplayPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:uplay = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:uplay = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Epic Games Launcher
        do {
            $epicgameslauncherPrompt = 
"
[1] Gaming: Install Epic Games Launcher?: Gaming platform
[y] for yes
[n] for no
"
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt $epicgameslauncherPrompt
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $global:epicgameslauncher = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $global:epicgameslauncher = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)

    #"setDefaultPrograms"
}
#   Disable Nvidia Telemetry
    Function disableNvidiaTelemetry {
        Write-Host "Attempting to disable NVIDIA telemetry via 'Container service for NVIDIA Telemetry' aka 'NvTelemetryContainer'" -ForegroundColor Green -BackgroundColor Black
        Set-Service NvTelemetryContainer -StartupType Disabled
        Set-Service NvTelemetryContainer -Status Stopped
    }
    # Windows Update control panel may show message "Your device is at risk...", -- try to disable maximum telemetry without triggering this error
    Function disableTelemetry {
        Write-Host "Disabling Telemetry..." -ForegroundColor Green -BackgroundColor Black
        Set-Service dmwappushservice -StartupType Disabled
        Set-Service dmwappushservice -Status Stopped
        Set-Service DiagTrack -StartupType Disabled
        #Usually errors out, not a big deal since after reboot it will be disabled
        Set-Service DiagTrack -Status Stopped -ErrorAction SilentlyContinue
        echo "" > C:\ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl
    }
#   Sync windows time -------- (explorer)
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
#   Remove windows features (# Get-WindowsOptionalFeature -online)
    Function uninstallWindowsFeatures {
        # Disable PowerShellv2
        Write-Host "Uninstalling PowerShellv2..." -ForegroundColor Green -BackgroundColor Black
        Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2" -NoRestart
        Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2Root" -NoRestart
        # Disable SMBv1
        Write-Host "Uninstalling SMBv1..." -ForegroundColor Green -BackgroundColor Black
        Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart
        Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Client" -NoRestart
        Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Server" -NoRestart
        # Disable Telnet 
        Write-Host "Uninstalling Telnet..." -ForegroundColor Green -BackgroundColor Black
        Disable-WindowsOptionalFeature -Online -FeatureName "TelnetClient" -NoRestart
        # Uninstall windows fax and scan Services
        Write-Host "Uninstalling Windows Fax and Scan Services..." -ForegroundColor Green -BackgroundColor Black
        Disable-WindowsOptionalFeature -Online -FeatureName "FaxServicesClientPackage" -NoRestart
        # Uninstall Microsoft XPS Document Writer
        Write-Host "Uninstalling Microsoft XPS Document Writer..." -ForegroundColor Green -BackgroundColor Black
        Disable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart
    }
#   Enable Guest SMB shares
    Function enableGuestSMBShares {
        Write-Host "Enabling Guest SMB Share Access" -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" -Name "AllowInsecureGuestAuth" -Type DWord -Value 1
    }
#   Enable legacy F8 boot menu
    Function enableLegacyF8Boot {
        Write-Host "Enabling F8 boot menu options..." -ForegroundColor Green -BackgroundColor Black
        bcdedit /set `{current`} bootmenupolicy Legacy
    }
#   Delete hibernation file -- (cmd)
    Function deleteHibernationFile{
        Write-Host "Deleting hibernation file..." -ForegroundColor Green -BackgroundColor Black
        powercfg -h off
    }
#   Create power profile ----- (ctrl pan)
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
    Function uninstallIE {
        if ($global:uninstallIECheck) {
            Write-Host "Uninstalling IE11..." -ForegroundColor Green -BackgroundColor Black
            Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart
            Write-Host "Removing IE11 from win10 settings..." -ForegroundColor Green -BackgroundColor Black
            Get-WindowsCapability -online | ? {$_.Name -like '*InternetExplorer*'} | Remove-WindowsCapability -online
        }
        else {
            Write-Host "Skipping this step..." -ForegroundColor Yellow -BackgroundColor Black
        }
    }
#   Uninstall windows 10 apps
    Function powerUserDeleteApps {
        Write-Host "Nuking out all Windows 10 apps except Calculator" -ForegroundColor Green -BackgroundColor Black
        Get-AppxPackage -AllUsers | Where-Object {$_.name -notlike "*WindowsCalculator*"} | Where-Object {$_.name -notlike "*Store*"} | Where-Object {$_.name -notlike "*Photos*"} | Where-Object {$_.name -notlike "*Paint*"} | Where-Object {$_.name -notlike "*ScreenSketch*"} | Remove-AppxPackage -ErrorAction SilentlyContinue
    }    
    Function endUserDeleteApps { 
        Write-Host "Nuking out all Windows 10 apps except Calculator and Windows Store" -ForegroundColor Green -BackgroundColor Black
        Get-AppxPackage -AllUsers | Where-Object {$_.name -notlike "*WindowsCalculator*"} | Where-Object {$_.name -notlike "*Store*"} | Where-Object {$_.name -notlike "*Photos*"} | Where-Object {$_.name -notlike "*Paint*"} | Where-Object {$_.name -notlike "*ScreenSketch*"} | Remove-AppxPackage -ErrorAction SilentlyContinue
        #needs improvement - only delete packages that can be deleted by clicking the uninstall button in the app menu. do they have a property like that?

    }
#   Optional windows 10 Settings - include more apps as needed
    Function uninstallOptionalApps {
        Write-Host "Uninstalling Windows 10 Optional Apps..." -ForegroundColor Green -BackgroundColor Black
        Write-Host "Removing QuickAssist..." -ForegroundColor Green -BackgroundColor Black
        Get-WindowsCapability -online | ? {$_.Name -like '*QuickAssist*'} | Remove-WindowsCapability -online
        Write-Host "Removing ContactSupport..." -ForegroundColor Green -BackgroundColor Black
        Get-WindowsCapability -online | ? {$_.Name -like '*ContactSupport*'} | Remove-WindowsCapability -online
        Write-Host "Removing all Demo apps..." -ForegroundColor Green -BackgroundColor Black
        Get-WindowsCapability -online | ? {$_.Name -like '*Demo*'} | Remove-WindowsCapability -online
        Write-Host "Removing Windows Hello Face..." -ForegroundColor Green -BackgroundColor Black
        Get-WindowsCapability -online | ? {$_.Name -like '*Face*'} | Remove-WindowsCapability -online
    }
#   HomeGroup
    Function disableHomeGroup {
        Write-Host "Disabling HomeGroup through 'HomeGroup Provider' && 'HomeGroup Listener' services " -ForegroundColor Green -BackgroundColor Black 
        Set-Service HomeGroupListener -StartupType Disabled
        Set-Service HomeGroupProvider -StartupType Disabled
        Set-Service HomeGroupListener -Status Stopped
        Set-Service HomeGroupProvider -Status Stopped
    }
    Function uninstallWMP { 
        Write-Host "Uninstalling WMP..." -ForegroundColor Green -BackgroundColor Black
        Disable-WindowsOptionalFeature -Online -FeatureName "MediaPlayback" -NoRestart
        Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart
        Write-Host "Removing WMP from win10 settings..." -ForegroundColor Green -BackgroundColor Black
        Get-WindowsCapability -online | ? {$_.Name -like '*WindowsMediaPlayer*'} | Remove-WindowsCapability -online
    }
#   OneDrive removal
    # Uninstall OneDrive
    Function uninstallOneDrive {
        Write-Host "Uninstalling OneDrive..." -ForegroundColor Green -BackgroundColor Black
        Stop-Process -Name "OneDrive" -Force

        $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
        if (!(Test-Path $onedrive)) {
            $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
        }
        Start-Process $onedrive "/uninstall"
    }
#   Remove Default Fax and XPS Printers
    Function removePrinters {
        Write-Host "Removing Default Fax and XPS Printers..." -ForegroundColor Green -BackgroundColor Black
        Remove-Printer -Name "Fax"
        Remove-Printer -Name "Microsoft XPS Document Writer"
    }
#   Rename computer to something a little more personal if the name contains a default generic name
    Function renameComputer {
        if ($global:renameComputerAnswer) {
            Rename-Computer -NewName $global:newCompName 
        }
        else {
            Write-Warning "Skipping the computer renaming process for some reason"    
        }
    }
#   Append disk steps to the text file if applicable
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
        if (($diskCount -gt 1) -and ($greatestDiskSize -gt 400000000000)) {
            $global:personalFolderTargets = 
"
#############################
## Personal Folder Targets ##
#############################
Mass storage drive detected. Change personal folder targets to the mass storage drive:
Documents, Downloads, Music, Pictures, Videos
"
        }
    }
#   Pin items back into the start menu
    Function pinStartMenuItemsAndInstallSoftware {
        #Disable File Security Checks for this PowerShell instance
        $env:SEE_MASK_NOZONECHECKS = 1

        ##########################
        # Download software here #
        ##########################
        #Install Chocolatey package manager
        #PowerShell
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        #PowerShell v3+
        #Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
        #-----------------------#
        #choco install chocolatey
        #-----------------------#
 
        #Install various software that the user has selected
        ##############################
        # Software to Always Install #
        ##############################
        if ($global:7zip){
            choco install 7zip -y
        }
        if ($global:hwinfo){
            choco install hwinfo -y
            $global:appendHwinfo = "hwinfo [Program -> Settings -> General\User Interface -> Uncheck: Automatic Update"
        }
        if ($global:vlc){
            choco install vlc -y
            $global:appendVlc = "vlc [disable at initial launch || Tools -> Preferences -> Interface -> Uncheck: Activate updates notifier]"
        }
        if ($global:windirstat){
            choco install windirstat -y
        }
        ################
        # Web Browsers #
        ################
        if ($global:chrome){
            choco install googlechrome -y
            choco pin add -n=googlechrome
        }
        if ($global:firefox){
            choco install firefox -y
            choco pin add -n=firefox
        }
        if ($global:edge){
            #edge
        }
        #################
        # Cloud Storage #
        #################
        if ($global:dropbox){
            choco install dropbox -y
            choco pin add -n=dropbox
        }
        if ($global:googledrive){
            choco install googledrive -y
            choco pin add -n=googledrive
        }
        ################
        # Text Editors #
        ################
        if ($global:notepadpp){
            choco install notepadplusplus -y
            $global:appendNpp = "notepad++ [Settings -> Preferences -> MISC. -> Disable auto-updater]"
        }
        if ($global:sublimetext){
            choco install sublimetext3 -y
            $global:appendSublime = "sublimetext [Preferences -> Settings (User) -> add 'update_check': false (with double quotes)]"
        }
        ######################
        # Optional Utilities #
        ######################
        if ($global:flux){
            choco install f.lux -y
            choco pin add -n=f.lux
            #launches automatically
            #launches automatically, will want to close this out until reboot | #also check for $global:skipFlux variable
            while (!(Get-Process *flux*)) {
                Start-Sleep -m 10
            }
            if (Get-Process *flux*) {
                #exit out of flux program here
                Get-Process *flux* | Stop-Process
            }
        }
        if ($global:imgburn){
            choco install imgburn -y
            $global:appendImgburn = "imgburn [Tools -> Settings... -> Events -> Check For Program Update: Never]"
        }
        if ($global:rufus){
            choco install rufus -y
            $global:appendRufus = "rufus [Show application settings -> Check for updates: Disabled]"
            <#
            $rufusInfo = Get-ItemProperty -Path "C:\ProgramData\chocolatey\lib\rufus\tools\*rufus*"
            $rufusName = $rufusInfo.Name
            $TargetFile = "C:\ProgramData\chocolatey\lib\rufus\tools\$rufusName"
            $ShortcutFile = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Rufus.lnk"
            $WScriptShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
            $Shortcut.TargetPath = $TargetFile
            $Shortcut.IconLocation = "C:\ProgramData\chocolatey\lib\rufus\tools\$rufusName, 0"
            $Shortcut.Save()
            #>
        }
        if ($global:putty){
            choco install putty.install -y
            #also installs psftp | choco install putty -y
        }
        if ($global:teamviewer){
            choco install teamviewer -y
            $global:appendTeamviewer = "teamviewer [Extras -> Options -> Advanced -> Check for new version: Never && Install new versions automatically: No automatic updates]"
            #also has a listener version, choco install teamviewer.host -y | will want to avoid prompting to disable service if .host is installed
            #choco install teamviewer.host -y
            #$global:teamviewerhost choco install teamviewer.host -y
        }
        
        ########################
        # General Applications #
        ########################
        if ($global:spotify){
            #Errors out on checksum values not matching
            #Skipping checksum since they can vary with spotify
            choco install spotify -y --ignore-checksums
            choco pin add -n=spotify
        }
        if ($global:skype){
            choco install skype -y
            choco pin add -n=skype
            #Close out of skype after install finishes
            while (!(Get-Process *skype*)) {
                Start-Sleep -m 10
            }
            if (Get-Process *skype*) {
                #exit out of skype program here
                Get-Process *skype* | Stop-Process
            }
        }
        ##########
        # Gaming #
        ##########
        if ($global:discord){
            choco install discord -y
            choco pin add -n=discord
        }
        if ($global:steam){
            choco install steam -y
            choco pin add -n=steam
        }
        if ($global:goggalaxy){
            choco install goggalaxy -y
            choco pin add -n=goggalaxy
        }
        if ($global:origin){
            choco install origin -y
            choco pin add -n=origin
        }
        if ($global:uplay){
            choco install uplay -y
            choco pin add -n=uplay
        }
        if ($global:epicgameslauncher){
            choco install epicgameslauncher -y
            choco pin add -n=epicgameslauncher
        }

        ###################
        # Manual Installs #
        ###################
        if ($global:msiafterburner){
            #Note: also installs rivatuner
            choco install msiafterburner -y
            $global:appendMsiafterburner = "msi afterburner [Settings gear -> Check for available product updates: never]"
            #installs rivatuner, will want to skip this somehow or uninstall it afterwards
            #Uninstall rivatuner
            while ($global:msiafterburner -and (!(Test-Path "C:\Program Files (x86)\RivaTuner Statistics Server\Uninstall.exe"))) {
                Write-Warning "Waiting for RivaTuner Statistics Server uninstaller to become available"
                Start-Sleep -m 100
            }
            if ($global:msiafterburner -and ((Test-Path "C:\Program Files (x86)\RivaTuner Statistics Server\Uninstall.exe"))) {
                Start-Process -FilePath "C:\Program Files (x86)\RivaTuner Statistics Server\Uninstall.exe" -ArgumentList "/S"
                # answer no to the saving profile preferences prompt
                #https://invista.wordpress.com/2013/08/16/a-simple-powershell-script-to-send-keys-to-an-application-windows/
                # load assembly cotaining class System.Windows.Forms.SendKeys
                [void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
# add a C# class to access the WIN32 API SetForegroundWindow
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class StartActivateProgramClass {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
"@
                #Waiting for the RivaTuner uninstaller process
                while (!(Get-Process *Au_*)) {
                    Start-Sleep -m 100
                }
                # get the applications with the specified title
                $p = Get-Process *Au_*
                # get the window handle of the first application
                $h = $p[0].MainWindowHandle
                # set the application to foreground
                [void] [StartActivateProgramClass]::SetForegroundWindow($h)
                # send the keys sequence #more info on MSDN at http://msdn.microsoft.com/en-us/library/System.Windows.Forms.SendKeys(v=vs.100).aspx
                [System.Windows.Forms.SendKeys]::SendWait("n")
                #needs improvement - i beleive there's another prompt that needs to be answered at the end of the uninstall process asking the user if they wish to restart
            }
        }
        if ($global:battlenet) {
            #errors out on checksum checking sometimes - skip checksum?
            #choco install battle.net -y
            #choco pin add -n=battle.net
            #Manual process
            #Download
            if (!(Test-Path "C:\Users\$env:username\Downloads\*battle.net*")) {
                Write-Host "Downloading: Battle.net" -ForegroundColor Green -BackgroundColor Black
                $global:battlenetURL = "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"
                $output = "C:\Users\$env:username\Downloads\Battle.net-Setup.exe"
                $start_time = Get-Date
                (New-Object System.Net.WebClient).DownloadFile($global:battlenetURL, $output)
                Write-Host "Waiting for Battle.net to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
            }
            #Check 
            while (!(Test-Path "C:\Users\$env:username\Downloads\*battle.net*")) {
                Start-Sleep -m 10
            }
            if (Test-Path "C:\Users\$env:username\Downloads\*battle.net*") {
                Write-Host "Battle.net successfully downloaded" -ForegroundColor Green -BackgroundColor Black
                Write-Host "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
            }
            else {
                Write-Error "Error downloading Battle.net"
            }

            #Install
            if (!(Test-Path "C:\Program Files (x86)\Battle.net\Battle.net Launcher.exe")) {
                Start-Process -FilePath "C:\Users\$env:username\Downloads\*battle.net*"
                Write-Host "Waiting for Battle.net to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
                # Bring the window to the foreground based on name
                $countForeground = 0
            }
            while (!(Test-Path "C:\Program Files (x86)\Battle.net\Battle.net Launcher.exe") -or (Get-Process *Battle.net-Setup*)) {
                Start-Sleep -m 10
             
                if ((Get-Process *Battle.net-Setup*) -and (((New-Object -ComObject WScript.Shell).AppActivate((Get-Process *Battle.net-Setup*).MainWindowTitle)) -and ($countForeground -lt 1))) {
                    Write-Host "Bringing Battle.net to the foreground" -ForegroundColor Yellow -BackgroundColor Black
                    (New-Object -ComObject WScript.Shell).AppActivate((Get-Process *Battle.net-Setup*).MainWindowTitle)
                    $countForeground ++
                }
            }
            while (!(Get-Process *battle.net*)) {
                Start-Sleep -m 10
            }
            #Close
            Get-Process *battle.net* | Stop-Process
        }

        #Create scheduled auto update task for chocolatey packages
        Write-Host "Creating an auto update scheduled task for chocolatey packages" -ForegroundColor Green -BackgroundColor Black
        $Name = "Update Chocolatey Packages"
        $Username = $env:username
        $Trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Wednesday -At 1am
        $Action = New-ScheduledTaskAction -Execute "cup" -Argument "all -y"
        $Settings = New-ScheduledTaskSettingsSet -Hidden -Compatibility Win8 -RunOnlyIfIdle -IdleDuration (New-TimeSpan -Minutes 10) -IdleWaitTimeout (New-TimeSpan -Minutes 30) -DontStopOnIdleEnd -StartWhenAvailable -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 3 -ExecutionTimeLimit (New-TimeSpan -Hours 2) -MultipleInstances IgnoreNew

        Register-ScheduledTask -TaskName $Name -User $Username -RunLevel Highest -Trigger $Trigger -Action $Action -Settings $Settings -Force
    }
#############################################
# Prompt user to disable TeamViewer service #
#############################################
#needs improvement - don't ask or execute this if choco install teamviewer.host is selected
Function disableTeamViewerPrompt {
    #"disableTeamViewerPrompt",
    $teamviewerIsInstalled = Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe"
    if ($global:teamviewer -or $teamviewerIsInstalled) {
        $teamviewerState = $false
        do {
            $teamviewerPrompt = Read-Host -Prompt "Disable TeamViewer remote listener service?: [y]/[n]"
            if (($teamviewerPrompt -eq "y") -or ($teamviewerPrompt -eq "Y") -or ($teamviewerPrompt -eq "1")) {
                Write-Host "Disabling TeamViewer listening service for security since it's not going to be used..." -ForegroundColor Green -BackgroundColor Black
                Set-Service TeamViewer -StartupType Disabled
                Set-Service TeamViewer -Status Stopped
                $teamviewerState = $true
            }
            elseif (($teamviewerPrompt -eq "n") -or ($teamviewerPrompt -eq "N") -or ($teamviewerPrompt -eq "0")) {
                Write-Host "Leaving TeamViewer listening service alone" -ForegroundColor Green -BackgroundColor Black
                $teamviewerState = $true
                $disableTeamViewer = $false
            }
            else {
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
                $teamviewerState = $false
            }
        }
        while ($teamviewerState -eq $false)
    }
}
Function remainingStepsToText {
    $outputFile = "C:\Users\$env:username\Desktop\Remaining Manual Steps.txt"
$outString = 
"
##########################################################################
## Start Menu App Categories ##
###############################
Applications
Tools
Navigation

$global:personalFolderTargets

########################
## Additional Changes ##
########################
#Reg-Key Automation Only
#File Explorer
    #explorerSetExplorerThisPC
    #explorerHideSyncNotifications
    #explorerShowFileTransferDetails
#Task Manager
    #showTaskManagerDetails
#Control Panel
    #ctrlpanSetControlPanelLargeIcons
    #ctrlpanSoundCommsAttenuation
    #ctrlpanSoundOptions
#System settings
    #setPageFileToC
#Start Menu
    #unpinTaskbarAndStartMenuTiles
#Win 10 Settings
#Network & Internet
    #disableWifiSense
#Personalization
    #Set a background
    #Set a lockscreen picture
    #disableLockScreenTips
#Apps
    #setDefaultPrograms
#Ease of Access
    #disableStickyKeys
#Privacy
    #configurePrivacy
#Update & Security
    #configureWindowsUpdates
#Windows Defender
    #disableWindowsDefenderSampleSubmission
#########################
## Additional Software ##
#########################
#Install (if applicable)
# Microsoft Office

#Disable updates for the following to prevent a conflict with Chocolatey's auto updater:
$global:appendHwinfo
$global:appendVlc
$global:appendNpp
$global:appendSublime
$global:appendImgburn
$global:appendRufus
$global:appendTeamviewer
$global:appendMsiafterburner
##########################################################################
"
    $outString | Out-File -FilePath $outputFile -Width 200
}
Function remainingStepsToTextForAustin {
    $outputFile = "C:\Users\$env:username\Desktop\Remaining Manual Steps.txt"
$outString = 
"
##########################################################################
## Start Menu App Categories ##
###############################
Applications
Tools
Navigation
Pin a local games folder to the start menu as well

########################
## Map Network Drives ##
########################
V: Store 192.168.1.106 | aesser FreeNAS user
W: Media 192.168.1.106 | aesser FreeNAS user
X: NVR   192.168.1.106 | aesser FreeNAS user
Y: Share 192.168.1.106 | aesser FreeNAS user
Z: Watch 192.168.20.20 | mediasvc01 MediaSrv user

##################
## Quick Access ##
##################
Pin FreeFileSyncBackupLogs to QuickAccess
Pin Torrents watch directory to QuickAccess

$global:personalFolderTargets

########################
## Additional Changes ##
########################
#Reg-Key Automation Only
#Task Bar
    #taskbarHidePeopleIcon
    #taskbarHideSearch
    #taskbarHideTaskView
    #taskbarHideInkWorkspace
#File Explorer
    #explorerSetExplorerThisPC - all
    #explorerHideRecentShortcuts
    #explorerShowHiddenFiles
    #explorerShowKnownExtensions
    #explorerHideSyncNotifications - all
    #explorerShowFileTransferDetails - all
#Task Manager
    #showTaskManagerDetails - all
#Control Panel
    #ctrlpanSetControlPanelLargeIcons - all
    #ctrlpanDisableMouseAcceleration
    #ctrlpanSoundCommsAttenuation - all
    #ctrlpanSoundOptions - all
#System settings
    #disableRemoteAssistance
    #explorerSetVisualFXAppearance
    #setPageFileToC - all
#Start Menu
    #unpinTaskbarAndStartMenuTiles - all
#Win 10 Settings
#System
    #configureNightLight
    #disableSharedExperiences
    #enableClipboardSync
#Devices
#Phone
#Network & Internet
    #disableWifiSense - all
    #bluetoothManualSteps
#Personalization
    #Set a background - all
    #Set a color scheme
    #enableDarkMode
    #Set a lockscreen picture - all
    #disableLockScreenTips - all
    #editStartMenu
    #taskbarShowTrayIcons
    #taskbarCombineWhenFull
    #taskbarMMSteps
#Apps
    #setDefaultPrograms - all
#Accounts
    #Set a user account picture
#Time & Language
#Gaming
    #disableGameMode-Bar-DVR
#Ease of Access
    #disableStickyKeys - all
#Privacy
    #configurePrivacy - all
#Update & Security
    #configureWindowsUpdates - all
#Search
    #disableBingWebSearch
#Windows Defender
    #disableWindowsDefenderSampleSubmission - all
#########################
## Additional Software ##
#########################
#Install (if applicable)
# Microsoft Office
# Electrum -> choco install electrum.install

#Disable updates for the following to prevent a conflict with Chocolatey's auto updater:
$global:appendHwinfo
$global:appendVlc
$global:appendNpp
$global:appendSublime
$global:appendImgburn
$global:appendRufus
$global:appendTeamviewer
$global:appendMsiafterburner
##########################################################################
"
    $outString | Out-File -FilePath $outputFile -Width 200
}
Function optionTwo {
    $global:isAustin = $false
    Write-Host "[2] New install w/ prompts & aggressive preset | Semi-Auto # My preferred" -ForegroundColor Green -BackgroundColor Black
    getPromptAnswers
    getSoftwareAnswers
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    #hideOneDrive
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
    $allUsersFirstRunPrompted | ForEach { Invoke-Expression $_ }
    disableTeamViewerPrompt
    remainingStepsToText
}
Function optionSeven {
    $global:isAustin = $false
    Write-Host "[7] Re-run w/ prompts & aggressive preset | Semi-Auto # My preferred" -ForegroundColor Green -BackgroundColor Black
    getPromptAnswers
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    #hideOneDrive
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
    disableTeamViewerPrompt
}
Function optionFirstSpecial {
    $global:isAustin = $true
    Write-Host "[F] Welcome Austin" -ForegroundColor Red -BackgroundColor Black
    getPromptAnswers
    getSoftwareAnswers
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    #hideOneDrive
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
    $allUsersFirstRunPrompted | ForEach { Invoke-Expression $_ }
    disableTeamViewerPrompt
    #Austin specific function calls
    remainingStepsToTextForAustin
}
Function optionRerunSpecial {
    $global:isAustin = $true
    Write-Host "[R] Welcome back Austin" -ForegroundColor Red -BackgroundColor Black
    #getPromptAnswers
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    #hideOneDrive
    #$allUsersPrompted | ForEach { Invoke-Expression $_ }
    disableTeamViewerPrompt
    #Austin specific function calls
    # insert function calls here
}
####################
# Restart computer # 
####################
Function promptForRestart {
    $restartState = $false
    do {
        $restartHost = Read-Host -Prompt "Script finished, some changes require a restart to take effect: Restart now? [y]/[n]?"
        if (($restartHost -eq "y") -or ($restartHost -eq "Y") -or ($restartHost -eq "1")) {
            Write-Host "Restarting..." -ForegroundColor Green -BackgroundColor Black
            $restartState = $true
            Restart-Computer
        }
        elseif (($restartHost -eq "n") -or ($restartHost -eq "N") -or ($restartHost -eq "0")) {
            Write-Host "Restart manually, exiting..." -ForegroundColor Yellow -BackgroundColor Black
            $restartState = $true
        }
        else {
            $restartState = $false
            Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
        }
    }
    while ($restartState -eq $false)
}
#################################
# Prompt user to select presets #
#################################
#pre-req variables
$global:skipFlux = $false
$global:isAustin = $false
$global:appendHwinfo = $null
$global:appendVlc = $null
$global:appendNpp = $null
$global:appendSublime = $null
$global:appendImgburn = $null
$global:appendRufus = $null
$global:appendTeamviewer = $null
$global:appendMsiafterburner = $null
#function calls
#selectionMenu
#promptForSelection

$selectionState = $false
do {
    $actionPrompt = 
"
[1] For running this script for the first time after a fresh Windows install
[2] For re-running this script
"
    $selectionPrompt = Read-Host -Prompt $actionPrompt
    if ($selectionPrompt -eq "1") {
        $selectionState = $true
        optionTwo
    }
    elseif ($selectionPrompt -eq "2") {
        $selectionState = $true
        optionSeven
    }
    elseif (($selectionPrompt -eq "f") -or ($selectionPrompt -eq "F")) {
        $selectionState = $true
        optionFirstSpecial
    }
    elseif (($selectionPrompt -eq "r") -or ($selectionPrompt -eq "R")) {
        $selectionState = $true
        optionRerunSpecial
    }
    else {
        $selectionState = $false
        Write-Host "Select [1] or [2] to start" -ForegroundColor Red -BackgroundColor Black
    }
}
while ($selectionState -eq $false)

##################################
# First time running this script #
##################################
#[2] New install w/ prompts & aggressive preset
#optionTwo
#[F] New install w/ prompts & aggressive preset (customized for Austin)
#optionFirstSpecial

##########################
# Re-running this script #
##########################
#[7] Re-run w/ prompts & aggressive preset
#optionSeven

#[R] Re-run w/ prompts & aggressive preset (customized for Austin)
#optionRerunSpecial

#########################################
# Last thing to do: Prompt for a reboot #
#########################################
promptForRestart
