#Windows10Imaging-Customized.ps1
##########
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script | Disassembler <disassembler@dasm.cz>
# Author: Austin Esser
##########
# Improvements needed:
# enable old photo viewer and uninstall the windows photos app
# test each function to see if it works 
# 
<#
# Wait for key press
Function WaitForKey {
    Write-Output "`nPress any key to continue..."
    [Console]::ReadKey($true) | Out-Null
}
#>
# Variables
$powerUser = $false
$userType = $null
# Main Function call array - needs improvemnet - finish presets for power user & regular user
$powerUserMain = @(
    ### Require administrator privileges ###
    "requireAdmin",

    ### My functions ###
    "disableOneDrive",
    "uninstallOneDrive",
    "hideOneDrive",
    "disableWifiSense",
    "uninstallOptionalApps",
    "taskbarCombineWhenFull",
    "taskbarShowTrayIcons",
    "taskbarHideSearch",
    "taskbarShowSearchIcon",
    "taskbarHideTaskView",
    "taskbarShowTaskView",
    "taskbarHidePeopleIcon",
    "disableBingWebSearch",
    "disableGameMode-Bar-DVR",
    "disableTipsTricksAndWelcomeExp",
    "disableLockScreenTips",
    "disableWindowsDefenderSampleSubmission",
    "configureWindowsUpdates",
    "configurePrivacy",
    "explorerShowKnownExtensions",
    "explorerShowHiddenFiles",
    "explorerHideSyncNotifications",
    "explorerSetExplorerThisPC",
    "explorerHide3DObjectsFromThisPC",
    "explorerHide3DObjectsFromExplorer",
    "explorerHideRecentShortcuts",
    "explorerSetControlPanelLargeIcons",
    "explorerShowFileTransferDetails",
    "removePrinters",
    "disableStickyKeys",
    "showTaskManagerDetails",
    "enableLegacyF8Boot",
    "enableGuestSMBShares",
    "disableMouseAcceleration",
    "setPowerProfile",
    "configureSoundOptions",
    "configureSystemProperties",
    "setVisualFXAppearance",
    "disableHomeGroup",
    "unpinStartMenuTiles",
    "unpinTaskbarIcons",
    "setWindowsTimeZone",
    "uninstallWindowsFeatures",
    "bluetoothManualSteps",
    "taskbarManualSteps",
    "privacyManualSteps",
    "pinStartMenuItemsManually",
    "pinTaskbarItemsManually",
    "configureUserFolders",
    "mkdirGodMode",
    "promptUninstallIE",

    ### Extra Functions ###
    "restart"
)
$regularUserMain = @(
    ### Require administrator privileges ###
    "requireAdmin",

    ### My functions ###
#    "disableOneDrive",
#    "uninstallOneDrive",
#    "hideOneDrive",
#    "disableWifiSense",
#    "uninstallOptionalApps",
#    "taskbarCombineWhenFull",
#    "taskbarShowTrayIcons",
#    "taskbarHideSearch",
#    "taskbarShowSearchIcon",
#    "taskbarHideTaskView",
#    "taskbarShowTaskView",
#    "taskbarHidePeopleIcon",
#    "disableBingWebSearch",
#    "disableGameMode-Bar-DVR",
#    "disableTipsTricksAndWelcomeExp",
#    "disableLockScreenTips",
#    "disableWindowsDefenderSampleSubmission",
#    "configureWindowsUpdates",
#    "configurePrivacy",
#    "explorerShowKnownExtensions",
#    "explorerShowHiddenFiles",
#    "explorerHideSyncNotifications",
#    "explorerSetExplorerThisPC",
#    "explorerHide3DObjectsFromThisPC",
#    "explorerHide3DObjectsFromExplorer",
#    "explorerHideRecentShortcuts",
#    "explorerSetControlPanelLargeIcons",
#    "explorerShowFileTransferDetails",
#    "removePrinters",
#    "disableStickyKeys",
#    "showTaskManagerDetails",
#    "enableLegacyF8Boot",
#    "enableGuestSMBShares",
#    "disableMouseAcceleration",
#    "setPowerProfile",
#    "configureSoundOptions",
#    "configureSystemProperties",
#    "setVisualFXAppearance",
#    "disableHomeGroup",
#    "unpinStartMenuTiles",
#    "unpinTaskbarIcons",
#    "setWindowsTimeZone",
#    "uninstallWindowsFeatures",
#    "bluetoothManualSteps",
#    "taskbarManualSteps",
#    "privacyManualSteps",
#    "pinStartMenuItemsManually",
#    "pinTaskbarItemsManually",
#    "configureUserFolders",
#    "mkdirGodMode",
#    "promptUninstallIE",

    ### Extra Functions ###
    "restart"
)
# Determine if the user is a power user
do {
    $userType = Read-Host -Prompt "Are you a power user?: [y]/[n]?"
    if (($userType -eq "y") -or ($userType -eq "1")) {
        $powerUser = $true
        $doneUser = $true
    }
    elseif (($userType -eq "n") -or ($userType -eq "0")) {
        $powerUser = $false
        $doneUser = $true
    }
    else {
        $doneUser = $false
        Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
    }
}
while ($doneUser -eq $false)
Write-Host "Power user status: $powerUser" -ForegroundColor Green -BackgroundColor Black
#   Call the desired functions with main
if ($powerUser) {
    $powerUserMain | ForEach { Invoke-Expression $_ }
    Write-Host "Running through the power user config parameters"
}
elseif (!$powerUser) {
    $regularUserMain | ForEach { Invoke-Expression $_ }
    Write-Host "Running through the regular user config parameters"
}
else {
    Write-Host "Parameters couldn't be fed into the config functions to start the script"
    Write-Host "Exiting, press any key to continue..."
    Pause
    exit
}
#   Relaunch the script with administrator privileges if it isn't run as admin
Function requireAdmin {
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
        exit
    }
}
#--------------------------------------------------------------------------------------
#Configuration phase-------------------------------------------------------------------
#   Delete hibernation file -- (cmd)
    Function deleteHibernationFile{
        Write-Host "Deleting hibernation file..." -ForegroundColor White -BackgroundColor Black
        powercfg -h off
    Pause
    }
#   Disable Windows aero shake to minimize gesture
    Function disableAeroShake{
        Write-Host "Disabling Windows shake to minimize gesture..." -ForegroundColor White -BackgroundColor Black      
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Type DWord -Value 1
    Pause
    }
#   Disable Nvidia Telemetry
    Function disableNvidiaTelemetry {
        Write-Host "Attempting to disable NVIDIA telemetry via 'Container service for NVIDIA Telemetry' aka 'NvTelemetryContainer'" -ForegroundColor Yellow -BackgroundColor Black
        Set-Service NvTelemetryContainer -StartupType Disabled
        Set-Service NvTelemetryContainer -Status Stopped
    Pause
    }
#--------------------------------------------------------------------------------------        
#   Uninstall windows 10 apps
    Function powerUserDeleteApps{
        Write-Host "Nuking out all Windows 10 apps except Calculator" -ForegroundColor Green -BackgroundColor Black
        Get-AppxPackage -AllUsers | Where-Object {$_.name -notlike "*WindowsCalculator*"} | Remove-AppxPackage -Verbose
    Pause
    }    
    Function endUserDeleteApps { 
        Write-Host "Nuking out all Windows 10 apps except Calculator and Windows Store" -ForegroundColor Green -BackgroundColor Black
        Get-AppxPackage -AllUsers | Where-Object {$_.name -notlike "*WindowsCalculator*"} | Where-Object {$_.name -notlike "*Store*"} | Remove-AppxPackage -Verbose
    Pause
    }
#   Disable Telemetry - Improvements needed (need to ensure windows updates doesn't break from this)
# Windows Update control panel may show message "Your device is at risk...", so try to disable maximum telemetry without triggering this error.
    Function disableTelemetry {
        Write-Output "Disabling Telemetry..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Name "AllowBuildPreview" -Type DWord -Value 0
        Set-Service dmwappushservice -StartupType Disabled
        Set-Service dmwappushservice -Status Stopped
        Set-Service DiagTrack -StartupType Disabled
        Set-Service DiagTrack -Status Stopped
        echo "" > C:\ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl
        <#
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
        #>
    Pause
    }
#Previously Manual Config-------------------------------------------------------------------------
#   OneDrive
    # Disable OneDrive - Needs improvement (this might be unnecessary since uninstalling... and not sure if this will cause problems)
    Function disableOneDrive {
        Write-Output "Disabling OneDrive..."
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1
    Pause
    }
    # Uninstall OneDrive
    Function uninstallOneDrive {
        Write-Output "Uninstalling OneDrive..."
        Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
        Start-Sleep -s 2
        $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
        if (!(Test-Path $onedrive)) {
            $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
        }
        Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
        Start-Sleep -s 2
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
        Start-Sleep -s 2
        Remove-Item -Path "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
        if (!(Test-Path "HKCR:")) {
            New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
        }
        Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
    Pause
    }
    Function hideOneDrive {
    # Hide OneDrive from File Explorer Nav    
        Write-Host "Importing OneDrive reg keys to hide from Explorer nav..." -ForegroundColor White -BackgroundColor Black        
        Set-ItemProperty -Path "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Type DWord -Value 
        Set-ItemProperty -Path "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Type DWord -Value 
    Pause
    }
#   FYI Message
        Write-Host "Running through Windows settings app..." -ForegroundColor White -BackgroundColor Black
#   Disable hot spots and wifi sense
    Function disableWifiSense {
        Write-Output "Disabling Wi-Fi Sense..."
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowWifiHotSpotReporting")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowWifiHotSpotReporting" -Force | Out-Null
        }
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowAutoConnectToWifiSenseHotspots")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowAutoConnectToWifiSenseHotspots" -Force | Out-Null
        }
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowWifiHotSpotReporting" -Name "Value" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowAutoConnectToWifiSenseHotspots" -Name "Value" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WifISenseAllowed" -Type DWord -Value 0
    Pause
    }
#   Optional windows 10 Settings 
    Function uninstallOptionalApps {
        #start ms-settings:optionalfeatures - add more apps as needed
        Write-Host "Uninstalling Windows 10 Optional Apps..."
        Write-Host "Removing QuickAssist..."
        Get-WindowsCapability -online | ? {$_.Name -like '*QuickAssist*'} | Remove-WindowsCapability –online
        Write-Host "Removing ContactSupport..."
        Get-WindowsCapability -online | ? {$_.Name -like '*ContactSupport*'} | Remove-WindowsCapability –online
        Write-Host "Removing WindowsMediaPlayer..."
        Get-WindowsCapability -online | ? {$_.Name -like '*WindowsMediaPlayer*'} | Remove-WindowsCapability –online
        Write-Host "Removing all Demo apps..."
        Get-WindowsCapability -online | ? {$_.Name -like '*Demo*'} | Remove-WindowsCapability –online
    Pause
    }
#   Taskbar settings
    # Set taskbar buttons to show labels and combine when taskbar is full
    Function taskbarCombineWhenFull {
        Write-Output "Setting taskbar buttons to combine when taskbar is full..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarGlomLevel" -Type DWord -Value 1
    Pause
    }
    #Show all notification icons on the taskbar
    Function taskbarShowTrayIcons {
        Write-Output "Showing all tray icons..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWord -Value 0
    Pause
    }
    # Hide Taskbar Search icon / box - needs improvement (only do for power users)
    Function taskbarHideSearch {
        Write-Output "Hiding Taskbar Search icon & box..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
    Pause
    }
    # Show Taskbar Search icon only - needs improvement (only do for REGULAR users)
    Function taskbarShowSearchIcon {
        Write-Output "Showing Taskbar Search as an icon..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
    Pause
    }
    # Hide Task View button - needs improvement (only do if power user)
    Function taskbarHideTaskView {
        Write-Output "Hiding Task View button..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
    Pause
    }
    # Show Task View button - needs improvement (only do if a REGULAR user)
    Function taskbarShowTaskView {
        Write-Output "Showing Task View button..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -ErrorAction SilentlyContinue
    Pause
    }
    # Hide Taskbar People icon
    Function taskbarHidePeopleIcon {
        Write-Output "Hiding People icon..."
        if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
    Pause
    }
    # Prevent bing search within using cortana - needs improvement (only do if a power user)
    Function disableBingWebSearch {
        Write-Output "Disabling Bing Search in Start Menu..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
    Pause
    }
#   Disable game bar and game mode
    Function disableGameMode-Bar-DVR { 
        #Disable game bar
        Write-Output "Disabling the pesky Game Bar..."   
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
        #Disable GameDVR
        Write-Output "Disabling the pesky GameDVR..."
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
        #Disable GameMode
        Write-Output "Disabling the background performance limiting Game Mode..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Type DWord -Value 0
    Pause
    }
#   Disable tips tricks, and welcome experience - needs improvement (power user only and find reg key and prompt user if they want to remove)
    Function disableTipsTricksAndWelcomeExp {
        #start ms-settings:notifications
        #Write-Host "Disable tips tricks, and welcome exp disable" -ForegroundColor Green -BackgroundColor Black
        #Pause
    }
#   Disable fun facts and tips on lock screen - needs improvement (find reg key)
    Function disableLockScreenTips {
    #also change the background to a static image (not windows spotlight)
        start ms-settings:lockscreen
        Write-Host "Disable MORE fun facts and tips on lock screen" -ForegroundColor Green -BackgroundColor Black
        Pause
    }
#   Configure Windows Defender - Improvements needed (initial config - power user only)
    Function disableWindowsDefenderSampleSubmission {
        # disable automatic sample submission 
        # disable prompt for user to sign in with M$ account
    }
#   Configure windows updates
    Function configureWindowsUpdates {
        #set active hours 8am-2am
        Write-Output "Configuring Windows Updates..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "ActiveHoursStart" -Type DWord -Value 8
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "ActiveHoursEnd" -Type DWord -Value 2
        #show additoinal reminders for update restarts (checkbox to ON)
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed" -Type DWord -Value 1
        #set update branch to avoid the buggy (Targeted) releases
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "BranchReadinessLevel" -Type DWord -Value 32
        # set to allow downloads from other PCs on my local network only
        Write-Output "Restricting Windows Update P2P only to local network..."
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
        # Disable windows insider preview builds
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "InsiderProgramEnabled" -Type DWord -Value 0        
        # Disalbe Edge desktop shortcut creation - needs improvement (maybe leave this alone?)
        Write-Output "Disabling Edge shortcut creation..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -Type DWord -Value 1 
    Pause
    }
#   Disable all privacy settings  - Improvements needed (automate) [ensure to leave the permissions settings like microphone etc...]
    Function configurePrivacy {
        Write-Host "Configuring privacy settings"
# https://privacyamp.com/knowledge-base/windows-10-privacy-settings/
#   General
        #Disable AdvertisingID
        Write-Output "Disabling Advertising ID..."
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
        Set-ItemProperty -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
        #Disable website language list access
        Write-Output "Disabling Website Access to Language List..."
        Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
        #Let windows track app launches to improve start and search results - needs improvement (need to find reg entry)
        #Show me sugested content in settings app 
        Write-Output "Disabling Application suggestions..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
#   Speech Inking and Typing - Disable speech, inking, and typing getting to know you - needs improvement (need to find reg entry)
#   Diagnostics & Feedback
        #Disable Diagnostic and feedback data
        # Disable Feedback
        Write-Output "Disabling Feedback..."
        if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
        #Disable Improve inking and typing recognition - needs improvement (need to find reg key)
        #Disable Tailored experiences
        Write-Output "Disabling Tailored Experiences..."
        if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
            New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
        #Disable diagnostic data viewer - needs improvement (reg key)
        #Feedback frequency - needs improvement (reg key)
#   Activity History - needs improvement (reg key)
        #Disable Let Windows collect activites from my PC - needs improvement (reg key)
        #Disable Let windows sync activiites from my pc to the Cloud - needs improvement (reg key)
#   App permissions section... - needs improvement (maybe leave this alone to ensure system functionality??? - only uncheck system apps that show up?)
    Pause
    }
#   FYI - Windows 10 specific configuration roughly ends here 
#   Generic Config for all OS types------------------------------------------------------------------------
    Write-Host "Generic Config------------------------------------------------------------------------"        
#   Configure folder options - (explorer)
    #   Show known file extensions - needs improvement (only change for power users)
    Function explorerShowKnownExtensions { 
        Write-Output "Showing known file extensions..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
    Pause
    }
    #   Show hidden files - needs improvement (only change for power users)
    Function explorerShowHiddenFiles {
        Write-Output "Showing hidden files..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
    Pause
    }
    #   Hide sync provider notifications
    Function explorerHideSyncNotifications {
        Write-Output "Hiding sync provider notifications..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
    Pause
    }
    #   Change default Explorer view to This PC
    Function explorerSetExplorerThisPC {
        Write-Output "Changing default Explorer view to This PC..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
    Pause
    }
    #   Hide 3D Objects from this PC
    Function explorerHide3DObjectsFromThisPC {
        Write-Output "Hiding 3D Objects icon from This PC..."
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue
    Pause
    }
    #   Hide 3D Objects from File Explorer
    Function explorerHide3DObjectsFromExplorer {
        Write-Output "Hiding 3D Objects icon from Explorer namespace..."
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
        if (!(Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
            New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
    Pause
    }
    #   Hide recently and frequently used item shortcuts in Explorer - Needs improvement (for power users only?)
    Function explorerHideRecentShortcuts {
        Write-Output "Hiding recent shortcuts from file explorer context..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Type DWord -Value 0
    Pause
    }   
    #   Set Control Panel view to Large icons (Classic)
    Function explorerSetControlPanelLargeIcons {
        Write-Output "Setting Control Panel view to large icons..."
        if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 0
    Pause
    }
    # Show file operations details during file transfers
    Function explorerShowFileTransferDetails {
        Write-Output "Showing file transfer details..."
        if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1
    Pause
    }
#   Remove Default Fax and XPS Printers
    Function removePrinters {
        Write-Output "Removing Default Fax and XPS Printers..."
        Remove-Printer -Name "Fax"
        Remove-Printer -Name "Microsoft XPS Document Writer"
    Pause
    }
#   Disable Sticky keys -------------- (explorer)
    Function disableStickyKeys {
        Write-Output "Disabling Sticky keys prompt..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
    Pause
    }
#   Show Task Manager Details - build 1607 and later - needs improvement (might need to ensure version "1607" is the full version and not something like "160701" or something)
    Function showTaskManagerDetails {
        if ([System.Environment]::OSVersion.Version.Build -ge 1607) {
        Write-Output "Showing task manager details..."
        $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
        Do {
            Start-Sleep -Milliseconds 100
            $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
        } Until ($preferences)
        Stop-Process $taskmgr
        $preferences.Preferences[28] = 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
        }
        # Show logical processors in CPU details - needs improvement (tests show mixed results)
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "UseStatusSetting" -Type DWord -Value 0
    Pause
    }
#   Enable legacy F8 boot menu
    Function enableLegacyF8Boot {
        Write-Output "Enabling F8 boot menu options..."
        bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
    Pause
    }
#   Enable Guest SMB shares
    Function enableGuestSMBShares {
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation\")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation\" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation\" -Name "AllowInsecureGuestAuth" -Type DWord -Value 0
    Pause
    }
#   Disable mouse acceleration (ctrl pan) - needs improvement (find reg key for this)
    Function disableMouseAcceleration {
        control.exe mouse
        Write-Host "Mouse: Disable mouse acceleration" -ForegroundColor Green -BackgroundColor Black
        Write-Host " "
    Pause
    }
#   Create power profile ----- (ctrl pan) - needs improvement (going to want to have a prompt for this incase a laptop vs desktop plan already exists)
    # Modify the balanced power profile and select that as default
    Function setPowerProfile {
        control.exe /name Microsoft.PowerOptions /page pageCreateNewPlan
        Write-Host "Power: Create power profile" -ForegroundColor Yellow -BackgroundColor Black
        Write-Host " "
    Pause
    }
#   Sound options ------------ (ctrl pan) - needs improvement (find reg key for this)
    Function configureSoundOptions {
        control.exe /name Microsoft.AudioDevicesAndSoundThemes
        Write-Host "Sound: Disable all enhancements (mic and speakers, turn mic level to 100 and boost to 0)" -ForegroundColor Green -BackgroundColor Black
        Write-Host "Sound: Set the volume reduction setting in Communications tab to 'do nothing'" -ForegroundColor Green -BackgroundColor Black
        Write-Host " "
    Pause
    }
<#
#   Action center & UAC ------ (explorer) [depreciated]
        control.exe /name Microsoft.ActionCenter
        Write-Host "Action Center & UAC: Configure Action Center & UAC" -ForegroundColor Green -BackgroundColor Black
        Write-Host " "
#>
#{
#   Advanced system settings - (explorer) - needs improvement (automate)
    Function configureSystemProperties {
        SystemPropertiesRemote.exe
        # Remote tab: uncheck "allow remote assistance connections to this computer"
        # Advanced tab & Performance settings: adjust appearance and set page file to be windows managed on C: drive only
        # Computer Name tab: Name computer - prompt the user for a PC name
        Write-Host " "
    Pause
    }
    #   Adjusts visual effects for "Appearance" mode - needs improvement (only set for power users, keep regular users to the default "let windows choose...")
    # needs improvement - there may be a simple reg key to select "Adjust for best appearance" rather than changing each box individually
    Function setVisualFXAppearance {
        Write-Output "Adjusting visual effects for appearance..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 1
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 400
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](158,30,7,128,18,0,0,0))
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 1
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 1
    Pause
    }
#}    
#   HomeGroup - needs improvement (user selectable option on whether they want to remove homegroup functionality)
    Function disableHomeGroup {
        Write-Host "disabling 'HomeGroup Provider' && 'HomeGroup Listener' to remove homegroup functionality" -ForegroundColor Yellow -BackgroundColor Black 
        set-service HomeGroupListener -StartupType Disabled
        set-service HomeGroupProvider -StartupType Disabled
        set-service HomeGroupListener -Status Stopped
        set-service HomeGroupProvider -Status Stopped
        Write-Host "HomeGroup disabled" -ForegroundColor Green -BackgroundColor Black
    Pause
    }
#   Start menu pinning ------- (explorer/win 81 UI) - needs improvement (prompt the user for an option to skip this [useful if re-running later])
    # Unpins all Start Menu tiles - Note: This function has no counterpart. You have to pin the tiles back manually.
    # needs improvement - start menu tiles won't be unpinned sine this doesn't account for new versions
    Function unpinStartMenuTiles {
        Write-Output "Unpinning all Start Menu tiles..."
        if ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 16299) {
            Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Include "*.group" -Recurse | ForEach-Object {
                $data = (Get-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data").Data -Join ","
                $data = $data.Substring(0, $data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
                Set-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data" -Type Binary -Value $data.Split(",")
            }
        } 
        elseif ([System.Environment]::OSVersion.Version.Build -eq 17134) {
            $key = Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse | Where-Object { $_ -like "*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"}
            $data = (Get-ItemProperty -Path $key.PSPath -Name "Data").Data[0..25] + ([byte[]](202,50,0,226,44,1,1,0,0))
            Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $data
        }
    Pause
    }
#   Taskbar pinning - needs improvement (prompt the user for an option to skip)
    # Unpins all Taskbar icons - Note: This function has no counterpart. You have to pin the icons back manually.
    Function unpinTaskbarIcons {
        Write-Output "Unpinning all Taskbar icons..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites" -Type Binary -Value ([byte[]](255))
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "FavoritesResolve" -ErrorAction SilentlyContinue
    Pause
    }
#   Sync windows time -------- (explorer) - needs improvement (automatically select time zone?)
    Function setWindowsTimeZone {
        control.exe /name Microsoft.DateAndTime
        Write-Host "Windows Time: Sync windows time" -ForegroundColor Yellow -BackgroundColor Black 
        Write-Host " "
    Pause
    }
#   Remove windows features (# Get-WindowsOptionalFeature -online) - need improvement (see notes within function below)
    Function uninstallWindowsFeatures {
        # Disable PowerShellv2
        Write-Output "Uninstalling PowerShellv2..."
        Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2" -NoRestart -WarningAction SilentlyContinue | Out-Null
        Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2Root" -NoRestart -WarningAction SilentlyContinue | Out-Null
        # Disable SMBv1
        Write-Output "Uninstalling SMBv1..."
        Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -WarningAction SilentlyContinue | Out-Null
        Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Client" -NoRestart -WarningAction SilentlyContinue | Out-Null
        Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Server" -NoRestart -WarningAction SilentlyContinue | Out-Null
        # Disable Telnet 
        Write-Output "Uninstalling Telnet..."
        Disable-WindowsOptionalFeature -Online -FeatureName "TelnetClient" -NoRestart -WarningAction SilentlyContinue | Out-Null
        # Disable MediaFeatures - windows media player - needs improvement (might be automated already via the settings menu)
        Write-Output "Uninstalling WindowsMediaPlayer..."
        Disable-WindowsOptionalFeature -Online -FeatureName "MediaPlayback" -NoRestart -WarningAction SilentlyContinue | Out-Null
        Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
        # Disable IE11? Power user only and give a prompt - needs improvement (can this be done via ms:settings app with other optional features?)
        Write-Output "Uninstalling IE11..."
        Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart -WarningAction SilentlyContinue | Out-Null
        # Uninstall windows fax and scan Services
        Write-Output "Uninstalling Windows Fax and Scan Services..."
        Disable-WindowsOptionalFeature -Online -FeatureName "FaxServicesClientPackage" -NoRestart -WarningAction SilentlyContinue | Out-Null
        # Uninstall Microsoft XPS Document Writer
        Write-Output "Uninstalling Microsoft XPS Document Writer..."
        Disable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
    Pause
    }
    #needs improvement - (prompt to ask to continue to manual steps? y/n?)
#   Manual Steps--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#   Also disable bluetooth - improvements needed (manual only, add to bottom of script) - # https://blogs.technet.microsoft.com/letsdothis/2017/06/20/disable-bluetooth-in-windows-10-updated/ 
    Function bluetoothManualSteps {
        Write-Host "Disable bluetooth for battery life and security, leave be if you want" -ForegroundColor Green -BackgroundColor Black
        start ms-settings:bluetooth
    Pause
    }
#   Taskbar manual steps
    Function taskbarManualSteps {
        start ms-settings:taskbar
        #Taskbar - needs improvements (automate) 
        #Multiple Display Taskbar Settings:
         #Show taskbar on all displays - needs imrpovement (find reg key for this)
         #show taskbar buttons on taskbar display where the windows is open - needs improvement (find reg key for this)
         #Combine taskbar buttons: Only when taskbar is full - needs improvement (find reg key for this)
        Write-Host "Launch Cortana, turn all settings 'OFF'" -ForegroundColor Red -BackgroundColor Black
    Pause
    }
    Function privacyManualSteps {
        start ms-settings:privacy # - needs improvement (will still have to uncheck all of individual apps for permissions, but leave permissions enabled since this breaks programs)
        Write-Host "Disable ALL privacy settings" -ForegroundColor Green -BackgroundColor Black
    Puase
    }
    #   Pin items back into the start menu manually - needs improvement (can this be automated)?
    Function pinStartMenuItemsManually {
        Write-Host " "
        Write-Host "Categories: Applications [All Software Later], Tools [Calculator, Snip Tool, MS Paint, RDP], Navigation [This PC, Downloads, Control Panel, Recycle Bin]" -ForegroundColor Green -BackgroundColor Black
        Write-Host " "  
    Pause
    }
    Function pinTaskbarItemsManually {
        Write-Host " "
    Pause
    }
    Function configureUserFolders {
        <#
        Give the option to input and change the drive for paths of the documents/downloads/music/videos user folders to: 
        (D:\, E:\, etc... if multiple drives exist on the system)
        #>
    Pause
    }
    # create a power user folder - needs improvement (power user only)
    Function mkdirGodMode {
        #make a GodMode folder on the desktop
        #mkdir -Name "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
    Pause
    }
    Function promptUninstallIE { # needs improvement - finish            
        #Read-Host "Do you wish to uninstall Internet Explorer as well? [y]/[n]"
        #Write-Host "Uninstalling Internet Explorer..."
        #Get-WindowsCapability -online | ? {$_.Name -like '*Browser.InternetExplorer*'} | Remove-WindowsCapability –online
    Pause
    }

# Restart computer
Function restart {
    Write-Output "Going to restart, press any key to continue..."
    Pause
    Write-Output "Restarting..."
    Restart-Computer
}
<#

#Can also improve by installing the software with powershell and feeding it configuration parameters?

Need to add the following software below:
Discord***********
Prime95************
HWMonitor************
Fraps************
CPU-Z************
GPU-Z************
Remote Desktop************BUILT-IN
NiceHashMiner************
Rufus************??? already have this as a stand-alone in dropbox?

#>

#OS configuration completed, continue to software downloads?: [y]/[n]?---------------------------------------------------------------
#create prompt for default browser?

#--------------------------------------------------------------------------------------------------------

<# Enabling the old photo viewer - import this as a reg key

Windows Registry Editor Version 5.00
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll]
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell]
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open]
“MuiVerb“=”@photoviewer.dll,-3043?
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
00,31,00,00,00
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget]
“Clsid“=”{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}”
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print]
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
00,31,00,00,00
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\DropTarget]
“Clsid“=”{60fd46de-f830-4894-a628-6fa81bc0190d}”

#>