#Windows10Personalization.ps1
########################
# Author: Austin Esser #
########################
# Relaunch the script with administrator privileges and bypass execution-policy if it isn't already
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    #Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -WorkingDirectory $pwd -Verb RunAs
    # | echo $shell.sendkeys("Y`r`n")
    #Set-ExecutionPolicy UnRestricted -Force
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    exit
}
# Main Function call array
$powerUserMain = @(
    ### My functions ###
    "powerUserDeleteApps",
#    "endUserDeleteApps",
    "disableNvidiaTelemetry",
    "deleteHibernationFile",
    "disableAeroShake",
    "restoreOldPhotoViewer",
    "disableTelemetry",
    "disableWifiSense",
    "uninstallOptionalApps",
    "taskbarCombineWhenFull",
    "taskbarShowTrayIcons",
    "taskbarHideSearch",
#    "taskbarShowSearchIcon",
    "taskbarHideTaskView",
#    "taskbarShowTaskView",
    "taskbarHidePeopleIcon",
    "taskbarHideInkWorkspace",
    "taskbarMMSteps",
    "disableBingWebSearch",
    "disableGameMode-Bar-DVR",
#    "disableTipsTricksAndWelcomeExp",
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
    "setVisualFXAppearance",
    "setPageFileToC",
    "setWindowsTimeZone",
    "enableDarkMode",
    "mkdirGodMode",
    "unPinDocsAndPicsFromQuickAccess",
    ### Optional Steps ###
    "disableHomeGroup", # always run for power user
    "uninstallWMP", # always run for power user
    "uninstallOneDrive", # always run for power user
    "hideOneDrive", # always run for power user
    "uninstallWindowsFeatures", # always run for power user
    "soundCommsAttenuation",
    "disableRemoteAssistance",
    "setPowerProfile"
)
$regularUserMain = @(
    ### My functions ###
#    "powerUserDeleteApps",
    "endUserDeleteApps",
    "disableNvidiaTelemetry",
    "deleteHibernationFile",
    "disableAeroShake",
    "restoreOldPhotoViewer",
    "disableTelemetry",
    "disableWifiSense",
    "uninstallOptionalApps",
    "taskbarCombineWhenFull",
    "taskbarShowTrayIcons",
#    "taskbarHideSearch",
    "taskbarShowSearchIcon",
#    "taskbarHideTaskView",
    "taskbarShowTaskView",
    "taskbarHidePeopleIcon",
    "taskbarHideInkWorkspace",
    "taskbarMMSteps",
#    "disableBingWebSearch",
    "disableGameMode-Bar-DVR",
#   "disableTipsTricksAndWelcomeExp",
    "disableLockScreenTips",
#    "disableWindowsDefenderSampleSubmission",
    "configureWindowsUpdates",
    "configurePrivacy",
#    "explorerShowKnownExtensions",
#    "explorerShowHiddenFiles",
    "explorerHideSyncNotifications",
    "explorerSetExplorerThisPC",
    "explorerHide3DObjectsFromThisPC",
    "explorerHide3DObjectsFromExplorer",
#    "explorerHideRecentShortcuts",
    "explorerSetControlPanelLargeIcons",
    "explorerShowFileTransferDetails",
    "removePrinters",
    "disableStickyKeys",
    "showTaskManagerDetails",
    "enableLegacyF8Boot",
#    "enableGuestSMBShares",
    "disableMouseAcceleration",
#    "setVisualFXAppearance",
    "setPageFileToC",
    "setWindowsTimeZone",
#    "enableDarkMode",
#    "mkdirGodMode",
    "soundCommsAttenuation",
    "disableRemoteAssistance",
    "setPowerProfile"
    ### Optional Steps ###
)
$firstTimeOptionalMain = @(
    "unpinTaskbarAndStartMenuTiles", # first time setup only
#    "unpinStartMenuTiles", # first time setup only
#    "unpinTaskbarIcons", # first time setup only
    "renameComputer" # first time setup only
)
# Needs improvement - try to automate these manual steps
$manualMain = @(
    ### Manual Steps ###
#    $manualStepsMain
    "configureNightLight",
    "configureSoundOptions", # always run 
    "bluetoothManualSteps", # always run 
    "disableFocusAssistNotifications"
#    "configureSystemProperties", # first time setup only -- depricated
#    "privacyManualSteps", # always run 
#    "configureUserFolderTargets", # always run
)
$firstTimeManualMain = @(
#    "pinTaskbarItemsManually", # first time setup only
    "pinStartMenuItemsAndInstallSoftware" # first time setup only
)
#--------------------------------------------------------------------------------------
#Configuration phase-------------------------------------------------------------------  
#   Uninstall windows 10 apps
    Function powerUserDeleteApps{
        Write-Host "Nuking out all Windows 10 apps except Calculator" -ForegroundColor Green -BackgroundColor Black
        Get-AppxPackage -AllUsers | Where-Object {$_.name -notlike "*WindowsCalculator*"} | Remove-AppxPackage
    }    
    Function endUserDeleteApps { 
        Write-Host "Nuking out all Windows 10 apps except Calculator and Windows Store" -ForegroundColor Green -BackgroundColor Black
        Get-AppxPackage -AllUsers | Where-Object {$_.name -notlike "*WindowsCalculator*"} | Where-Object {$_.name -notlike "*Store*"} | Remove-AppxPackage
    }
#   Delete hibernation file -- (cmd)
    Function deleteHibernationFile{
        Write-Host "Deleting hibernation file..." -ForegroundColor Green -BackgroundColor Black
        powercfg -h off
    }
#   Disable Windows aero shake to minimize gesture
    Function disableAeroShake{
        Write-Host "Disabling Windows shake to minimize gesture..." -ForegroundColor Green -BackgroundColor Black      
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Type DWord -Value 1
    }
#   Disable Nvidia Telemetry
    Function disableNvidiaTelemetry {
        Write-Host "Attempting to disable NVIDIA telemetry via 'Container service for NVIDIA Telemetry' aka 'NvTelemetryContainer'" -ForegroundColor Green -BackgroundColor Black
        Set-Service NvTelemetryContainer -StartupType Disabled
        Set-Service NvTelemetryContainer -Status Stopped
    }
#   Enabling the old photo viewer
    Function restoreOldPhotoViewer {
        Write-Host "Restoring the old photo viewer" -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKCU:\SOFTWARE\Classes")) {
            New-Item -Path "HKCU:\SOFTWARE\Classes" -Force
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.bmp" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.cr2" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.gif" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.ico" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.jfif" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.jpeg" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.jpg" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.png" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.tif" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.tiff" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\.wdp" -Name "(Default)" -Type String -Value "PhotoViewer.FileAssoc.Tiff"
        $photoValue = New-Object Byte[] 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.cr2\OpenWithProgids")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.cr2\OpenWithProgids" -Force
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.cr2\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ico\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jfif\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tif\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.tiff\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.wdp\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type None -Value $photoValue
    }
#   Disable Telemetry - Needs improvement (need to ensure windows updates doesn't break from this)
# Windows Update control panel may show message "Your device is at risk...", -- try to disable maximum telemetry without triggering this error
    Function disableTelemetry {
        Write-Host "Disabling Telemetry..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Name "AllowBuildPreview" -Type DWord -Value 0
        Set-Service dmwappushservice -StartupType Disabled
        Set-Service dmwappushservice -Status Stopped
        Set-Service DiagTrack -StartupType Disabled
        #Usually errors out, not a big deal since after reboot it will be disabled
        Set-Service DiagTrack -Status Stopped -ErrorAction SilentlyContinue
        echo "" > C:\ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl
        <#
        #Not sure if these break windows updates so leaving them alone right now
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater"
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy"
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
        Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
        #>
    }
#Previously Manual Config-------------------------------------------------------------------------
#   Disable hot spots and wifi sense
    Function disableWifiSense {
        Write-Host "Disabling Wi-Fi Sense..." -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowWifiHotSpotReporting")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowWifiHotSpotReporting" -Force
        }
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowAutoConnectToWifiSenseHotspots")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowAutoConnectToWifiSenseHotspots" -Force
        }
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowWifiHotSpotReporting" -Name "Value" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Wifi\AllowAutoConnectToWifiSenseHotspots" -Name "Value" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WifISenseAllowed" -Type DWord -Value 0
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
    }
#   Taskbar settings
    # Set taskbar buttons to show labels and combine when taskbar is full
    Function taskbarCombineWhenFull {
        Write-Host "Setting taskbar buttons to combine when taskbar is full..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 1
    }
    #Show all notification icons on the taskbar
    Function taskbarShowTrayIcons {
        Write-Host "Showing all tray icons..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWord -Value 0
    }
    # Hide Taskbar Search icon / box
    Function taskbarHideSearch {
        Write-Host "Hiding Taskbar Search icon & box..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
    }
    # Show Taskbar Search icon only
    Function taskbarShowSearchIcon {
        Write-Host "Showing Taskbar Search as an icon..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
    }
    # Hide Task View button
    Function taskbarHideTaskView {
        Write-Host "Hiding Task View button..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
    }
    # Show Task View button
    Function taskbarShowTaskView {
        Write-Host "Showing Task View button..." -ForegroundColor Green -BackgroundColor Black
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" #-ErrorAction SilentlyContinue
    }
    # Hide Taskbar People icon
    Function taskbarHidePeopleIcon {
        Write-Host "Hiding People icon..." -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Force
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
    }
    Function taskbarHideInkWorkspace {
        Write-Host "Hiding windows ink workspace..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name "PenWorkspaceButtonDesiredVisibility" -Type DWord -Value 0
    }
    #   Taskbar multi monitor steps
    Function taskbarMMSteps {
        #Multiple Display Taskbar Settings:
        Write-Host "Show taskbar on all displays" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarEnabled" -Type DWord -Value 1
        Write-Host "Show taskbar buttons on taskbar display only where the windows is open" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarMode" -Type DWord -Value 2
        Write-Host "Combine taskbar buttons: Only when taskbar is full" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarGlomLevel" -Type DWord -Value 1
    }
    # Prevent bing search within using cortana
    Function disableBingWebSearch {
        Write-Host "Disabling Bing Search in Start Menu..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
    }
#   Disable game bar and game mode
    Function disableGameMode-Bar-DVR { 
        #Disable game bar
        Write-Host "Disabling the pesky Game Bar..." -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
        #Disable GameDVR
        Write-Host "Disabling the pesky GameDVR..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
        #Disable GameMode
        Write-Host "Disabling the background performance limiting Game Mode..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Type DWord -Value 0
    }
#   Disable fun facts and tips on lock screen and remove spotlight
    Function disableLockScreenTips {
    #start ms-settings:lockscreen
        Write-Host "Disabling More fun facts and tips on lock screen" -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Force
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
    }
#   Configure Windows Defender
    Function disableWindowsDefenderSampleSubmission {
        Write-Host "Disabling windows defender sample submission" -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Force
        }
        #Disable automatic sample submission (also seems to suppress automatic sample submission alerts)
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Type DWord -Value 2
        #Disable cloud based protection
        #Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -Type DWord -Value 0
        # Disable M$ account sign in prompt
        Write-Host "Hiding microsoft Account Sign-In Protection warning..." -ForegroundColor Green -BackgroundColor Black
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State" -Force
        }
        Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State" -Name "AccountProtection_MicrosoftAccount_Disconnected" -Type DWord -Value 1
    }
#   Configure windows updates
    Function configureWindowsUpdates {
        #set active hours 8am-2am
        Write-Host "Configuring Windows Updates..." -ForegroundColor Green -BackgroundColor Black
        Write-Host "Setting active hours 8am-2am" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "ActiveHoursStart" -Type DWord -Value 8
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "ActiveHoursEnd" -Type DWord -Value 2
        #show additoinal reminders for update restarts (checkbox to ON)
        Write-Host "Showing additional notifications for restarts" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed" -Type DWord -Value 1
        #set update branch to avoid the buggy (Targeted) releases
        Write-Host "Setting update branch to avoid the buggy (Targeted releases)" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "BranchReadinessLevel" -Type DWord -Value 32
        # set to allow downloads from other PCs on my local network only
        Write-Host "Restricting Windows Update P2P only to local network..." -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
        # Disable windows insider preview builds
        Write-Host "Disabling windows insider preview builds" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "InsiderProgramEnabled" -Type DWord -Value 0        
        # Disalbe Edge desktop shortcut creation
        Write-Host "Disabling Edge desktop shortcut creation" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -Type DWord -Value 1 
    }
#   Disable all privacy settings
    Function configurePrivacy {
        Write-Host "Disabling privacy settings..." -ForegroundColor Green -BackgroundColor Black
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
        #Write-Host "Disabling Application suggestions..." -ForegroundColor Green -BackgroundColor Black - check for fix
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
        #Write-Host "Disabling Feedback..." -ForegroundColor Green -BackgroundColor Black
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
    }
#   FYI - Windows 10 specific configuration roughly ends here 
#   Generic Config for all OS types
#   Configure folder options - (explorer)
    # Show known file extensions
    Function explorerShowKnownExtensions { 
        Write-Host "Showing known file extensions..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
    
    }
    # Show hidden files
    Function explorerShowHiddenFiles {
        Write-Host "Showing hidden files..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
    
    }
    # Hide sync provider notifications
    Function explorerHideSyncNotifications {
        Write-Host "Hiding sync provider notifications..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
    
    }
    # Change default Explorer view to This PC
    Function explorerSetExplorerThisPC {
        Write-Host "Changing default Explorer view to This PC..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
    
    }
    # Hide 3D Objects from this PC
    Function explorerHide3DObjectsFromThisPC {
        Write-Host "Hiding 3D Objects icon from This PC..." -ForegroundColor Green -BackgroundColor Black
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse #-ErrorAction SilentlyContinue
    
    }
    # Hide 3D Objects from File Explorer
    Function explorerHide3DObjectsFromExplorer {
        Write-Host "Hiding 3D Objects icon from Explorer namespace..." -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
        if (!(Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
            New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
    }
    # Hide recently and frequently used item shortcuts in Explorer
    Function explorerHideRecentShortcuts {
        Write-Host "Hiding recent shortcuts from file explorer context..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Type DWord -Value 0
    }   
    # Set Control Panel view to Large icons (Classic)
    Function explorerSetControlPanelLargeIcons {
        Write-Host "Setting Control Panel view to large icons..." -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Force
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 0
    }
    # Show file operations details during file transfers
    Function explorerShowFileTransferDetails {
        Write-Host "Showing file transfer details..." -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Force
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1
    }
#   Remove Default Fax and XPS Printers
    Function removePrinters {
        Write-Host "Removing Default Fax and XPS Printers..." -ForegroundColor Green -BackgroundColor Black
        Remove-Printer -Name "Fax"
        Remove-Printer -Name "Microsoft XPS Document Writer"
    }
#   Disable Sticky keys -------------- (explorer)
    Function disableStickyKeys {
        Write-Host "Disabling Sticky keys prompt..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
    
    }
#   Show Task Manager Details - build 1607 and later
    Function showTaskManagerDetails {
        Write-Host "Showing task manager details..." -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Force
        }
        # Exracted from a new registry 
        $taskManagerPreferences = "0d,00,00,00,60,00,00,00,60,00,00,00,ed,01,00,00,9f,00,00,00,68,03,00,00,13,02,00,00,00,00,01,00,01,00,00,00,c8,01,00,00,31,00,00,00,70,04,00,00,89,02,00,00,e8,03,00,00,00,00,00,00,00,00,00,00,00,00,00,00,0d,00,00,00,01,00,00,00,00,00,00,00,08,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,ea,00,00,00,1e,00,00,00,89,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,02,00,00,00,00,0d,00,00,00,00,00,00,00,30,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,96,00,00,00,1e,00,00,00,8b,90,00,00,01,00,00,00,00,00,00,00,00,10,10,01,00,00,00,00,03,00,00,00,00,00,00,00,48,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,01,00,00,00,78,00,00,00,1e,00,00,00,8c,90,00,00,02,00,00,00,00,00,00,00,01,02,12,00,00,00,00,00,04,00,00,00,00,00,00,00,60,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,96,00,00,00,1e,00,00,00,8d,90,00,00,03,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,02,00,00,00,00,00,00,00,80,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,32,00,00,00,1e,00,00,00,8a,90,00,00,04,00,00,00,00,00,00,00,00,08,20,01,00,00,00,00,05,00,00,00,00,00,00,00,98,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,c8,00,00,00,1e,00,00,00,8e,90,00,00,05,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,06,00,00,00,00,00,00,00,c0,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,04,01,00,00,1e,00,00,00,8f,90,00,00,06,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,07,00,00,00,00,00,00,00,e8,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,90,90,00,00,07,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,08,00,00,00,00,00,00,00,08,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,91,90,00,00,08,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,09,00,00,00,00,00,00,00,20,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,92,90,00,00,09,00,00,00,00,00,00,00,00,04,25,08,00,00,00,00,0a,00,00,00,00,00,00,00,38,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,93,90,00,00,0a,00,00,00,00,00,00,00,00,04,25,08,00,00,00,00,0b,00,00,00,00,00,00,00,58,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,39,a0,00,00,0b,00,00,00,00,00,00,00,00,04,25,09,00,00,00,00,1c,00,00,00,00,00,00,00,78,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,c8,00,00,00,49,00,00,00,3a,a0,00,00,0c,00,00,00,00,00,00,00,00,01,10,09,00,00,00,00,03,00,00,00,0a,00,00,00,01,00,00,00,00,00,00,00,08,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,d7,00,00,00,1e,00,00,00,89,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,02,00,00,00,00,04,00,00,00,00,00,00,00,60,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,01,00,00,00,96,00,00,00,1e,00,00,00,8d,90,00,00,01,00,00,00,00,00,00,00,01,01,10,00,00,00,00,00,03,00,00,00,00,00,00,00,48,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,00,8c,90,00,00,02,00,00,00,00,00,00,00,00,02,10,00,00,00,00,00,0c,00,00,00,00,00,00,00,a0,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,03,00,00,00,64,00,00,00,1e,00,00,00,94,90,00,00,03,00,00,00,00,00,00,00,01,02,10,00,00,00,00,00,0d,00,00,00,00,00,00,00,c8,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,00,95,90,00,00,04,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,0e,00,00,00,00,00,00,00,f0,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,05,00,00,00,32,00,00,00,1e,00,00,00,96,90,00,00,05,00,00,00,00,00,00,00,01,04,20,01,00,00,00,00,0f,00,00,00,00,00,00,00,18,cf,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,06,00,00,00,32,00,00,00,1e,00,00,00,97,90,00,00,06,00,00,00,00,00,00,00,01,04,20,01,00,00,00,00,10,00,00,00,00,00,00,00,38,cf,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,07,00,00,00,46,00,00,00,1e,00,00,00,98,90,00,00,07,00,00,00,00,00,00,00,01,01,10,01,00,00,00,00,11,00,00,00,00,00,00,00,58,cf,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,00,99,90,00,00,08,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,06,00,00,00,00,00,00,00,c0,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,09,00,00,00,04,01,00,00,1e,00,00,00,8f,90,00,00,09,00,00,00,00,00,00,00,01,01,10,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,04,00,00,00,0b,00,00,00,01,00,00,00,00,00,00,00,08,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,d7,00,00,00,1e,00,00,00,9e,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,02,00,00,00,00,12,00,00,00,00,00,00,00,80,cf,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,2d,00,00,00,1e,00,00,00,9b,90,00,00,01,00,00,00,00,00,00,00,00,04,20,01,00,00,00,00,14,00,00,00,00,00,00,00,a0,cf,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,00,9d,90,00,00,02,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,13,00,00,00,00,00,00,00,c8,cf,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,00,9c,90,00,00,03,00,00,00,00,00,00,00,00,01,10,01,00,00,00,00,03,00,00,00,00,00,00,00,48,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,01,00,00,00,64,00,00,00,1e,00,00,00,8c,90,00,00,04,00,00,00,00,00,00,00,01,02,10,00,00,00,00,00,07,00,00,00,00,00,00,00,e8,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,07,00,00,00,49,00,00,00,49,00,00,00,90,90,00,00,05,00,00,00,00,00,00,00,01,04,21,00,00,00,00,00,08,00,00,00,00,00,00,00,08,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,08,00,00,00,49,00,00,00,49,00,00,00,91,90,00,00,06,00,00,00,00,00,00,00,01,04,21,00,00,00,00,00,09,00,00,00,00,00,00,00,20,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,09,00,00,00,49,00,00,00,49,00,00,00,92,90,00,00,07,00,00,00,00,00,00,00,01,04,21,08,00,00,00,00,0a,00,00,00,00,00,00,00,38,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,0a,00,00,00,49,00,00,00,49,00,00,00,93,90,00,00,08,00,00,00,00,00,00,00,01,04,21,08,00,00,00,00,0b,00,00,00,00,00,00,00,58,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,0b,00,00,00,49,00,00,00,49,00,00,00,39,a0,00,00,09,00,00,00,00,00,00,00,01,04,21,09,00,00,00,00,1c,00,00,00,00,00,00,00,78,ce,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,49,00,00,00,3a,a0,00,00,0a,00,00,00,00,00,00,00,00,01,10,09,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,08,00,00,00,01,00,00,00,00,00,00,00,08,cd,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,c6,00,00,00,1e,00,00,00,b0,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,02,00,00,00,00,15,00,00,00,00,00,00,00,e8,cf,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6b,00,00,00,1e,00,00,00,b1,90,00,00,01,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,16,00,00,00,00,00,00,00,18,d0,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6b,00,00,00,1e,00,00,00,b2,90,00,00,02,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,18,00,00,00,00,00,00,00,40,d0,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6b,00,00,00,1e,00,00,00,b4,90,00,00,03,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,17,00,00,00,00,00,00,00,68,d0,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6b,00,00,00,1e,00,00,00,b3,90,00,00,04,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,19,00,00,00,00,00,00,00,a0,d0,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,a0,00,00,00,1e,00,00,00,b5,90,00,00,05,00,00,00,00,00,00,00,00,04,20,01,00,00,00,00,1a,00,00,00,00,00,00,00,d0,d0,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,7d,00,00,00,1e,00,00,00,b6,90,00,00,06,00,00,00,00,00,00,00,00,04,20,01,00,00,00,00,1b,00,00,00,00,00,00,00,00,d1,8c,ce,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,7d,00,00,00,1e,00,00,00,b7,90,00,00,07,00,00,00,00,00,00,00,00,04,20,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,00,00,00,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,da,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,9d,20,00,00,20,00,00,00,64,00,00,00,64,00,00,00,32,00,00,00,50,00,00,00,50,00,00,00,32,00,00,00,32,00,00,00,28,00,00,00,50,00,00,00,3c,00,00,00,50,00,00,00,50,00,00,00,32,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,28,00,00,00,50,00,00,00,23,00,00,00,23,00,00,00,23,00,00,00,23,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,32,00,00,00,32,00,00,00,32,00,00,00,78,00,00,00,78,00,00,00,50,00,00,00,3c,00,00,00,50,00,00,00,50,00,00,00,78,00,00,00,32,00,00,00,78,00,00,00,32,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,50,00,00,00,00,00,00,00,01,00,00,00,02,00,00,00,03,00,00,00,04,00,00,00,05,00,00,00,06,00,00,00,07,00,00,00,08,00,00,00,09,00,00,00,0a,00,00,00,0b,00,00,00,0c,00,00,00,0d,00,00,00,0e,00,00,00,0f,00,00,00,10,00,00,00,11,00,00,00,12,00,00,00,13,00,00,00,14,00,00,00,15,00,00,00,16,00,00,00,17,00,00,00,18,00,00,00,19,00,00,00,1a,00,00,00,1b,00,00,00,1c,00,00,00,1d,00,00,00,1e,00,00,00,1f,00,00,00,20,00,00,00,21,00,00,00,22,00,00,00,23,00,00,00,24,00,00,00,25,00,00,00,26,00,00,00,27,00,00,00,28,00,00,00,29,00,00,00,2a,00,00,00,2b,00,00,00,2c,00,00,00,00,00,00,00,00,00,00,00,1f,00,00,00,00,00,00,00,64,00,00,00,32,00,00,00,78,00,00,00,50,00,00,00,50,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,02,00,00,00,03,00,00,00,04,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,04,00,00,00,00,00,00,00,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00"
        $hexified = $taskManagerPreferences.Split(',') | % { "0x$_"}
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value ([byte[]]$hexified)           
        # Show logical processors in CPU details
        Write-Host "Showing all logical processors..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "UseStatusSetting" -Type DWord -Value 0
    }
#   Enable legacy F8 boot menu
    Function enableLegacyF8Boot {
        Write-Host "Enabling F8 boot menu options..." -ForegroundColor Green -BackgroundColor Black
        bcdedit /set `{current`} bootmenupolicy Legacy
    }
#   Enable Guest SMB shares
    Function enableGuestSMBShares {
    Write-Host "Enabling Guest SMB Share Access" -ForegroundColor Green -BackgroundColor Black
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" -Name "AllowInsecureGuestAuth" -Type DWord -Value 1
    }
#   Disable mouse acceleration (ctrl pan)
    Function disableMouseAcceleration {
        #control.exe mouse
        Write-Host "Disabling mouse acceleration" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type String -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type String -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type String -Value 0
    }
#   Adjusts visual effects for "Appearance" mode
    Function setVisualFXAppearance {
        Write-Host "Adjusting visual effects for appearance..." -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Force
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 1
    }
#    Adjust page filing settings to C: drive specifically with 'system managed size'
    Function setPageFileToC {
        Write-Host "Adjust page filing settings to C: drive specifically with 'system managed size'" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\" -Name "PagingFiles" -Type MultiString -Value "c:\pagefile.sys 0 0"
    }
#   Switch to start menu dark theme for power user
    Function enableDarkMode {
        Write-Host "Enabling dark mode..." -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0
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
        # create a power user folder
    Function mkdirGodMode {
        Write-Host "Creating GodMode directory in user context and pinning it to QuickAccess" -ForegroundColor Green -BackgroundColor Black
        New-Item -ItemType Directory -Path "C:\Users\$env:username\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}" -Force
        
        $Path = "C:\Users\$env:username\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
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
    Function unPinDocsAndPicsFromQuickAccess {
        $picturesRegName = "My Pictures"
        $picturesReg = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Pictures"
        $documentsReg = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal"
        $picturesRegPath = $picturesReg.$picturesRegName
        $documentsRegPath = $documentsReg.Personal
        $QuickAccess = New-Object -ComObject shell.application
        $picturesTargetObject = $QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | where {$_.Path -eq "$picturesRegPath"} 
        $documentsTargetObject = $QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | where {$_.Path -eq "$documentsRegPath"}

        if (($picturesTargetObject -eq $null) -and ($documentsTargetObject -eq $null)) { 
            Write-Host "Paths are not pinned to Quick Access" -ForegroundColor Yellow -BackgroundColor Black
            return 
        }
        elseif (($picturesTargetObject -eq $null) -and ($documentsTargetObject -ne $null)) {
            Write-Host "Only Documents is available to unpin, unpinning only that..." -ForegroundColor Yellow -BackgroundColor Black
            $documentsTargetObject.InvokeVerb("unpinfromhome") 
        } 
        elseif (($picturesTargetObject -ne $null) -and ($documentsTargetObject -eq $null)) {
            Write-Host "Only Pictures is available to unpin, unpinning only that..." -ForegroundColor Yellow -BackgroundColor Black
            $picturesTargetObject.InvokeVerb("unpinfromhome") 
        }
        else { 
            Write-Host "Unpinning documents and pictures from QuickAccess" -ForegroundColor Green -BackgroundColor Black
            $picturesTargetObject.InvokeVerb("unpinfromhome") 
            $documentsTargetObject.InvokeVerb("unpinfromhome") 
        }
    }


#	Optional steps ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
#   HomeGroup
    Function disableHomeGroup {
        Write-Host "Disabling HomeGroup through 'HomeGroup Provider' && 'HomeGroup Listener' services " -ForegroundColor Green -BackgroundColor Black 
        Set-Service HomeGroupListener -StartupType Disabled
        Set-Service HomeGroupProvider -StartupType Disabled
        Set-Service HomeGroupListener -Status Stopped
        Set-Service HomeGroupProvider -Status Stopped
    }
#   Start menu pinning ------- (explorer/win 81 UI)
    # Unpins all Start Menu tiles - Note: This function has no counterpart. You have to pin the tiles back manually.
    Function unpinTaskbarAndStartMenuTiles {
        # Start Menu and TaskBar using shell
        #https://www.tenforums.com/customization/21002-how-automatically-cmd-powershell-script-unpin-all-apps-start.html
        #Pin-App -Unpin -Start
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt()}
        #Pin-App -Unpin -Start
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from Start'} | %{$_.DoIt()}

# Alternate method according to Disassembler0 -> invoking both methods for maximum effort
#https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/8
$getstring = @'
    [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr GetModuleHandle(string lpModuleName);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    internal static extern int LoadString(IntPtr hInstance, uint uID, StringBuilder lpBuffer, int nBufferMax);

    public static string GetString(uint strId) {
        IntPtr intPtr = GetModuleHandle("shell32.dll");
        StringBuilder sb = new StringBuilder(255);
        LoadString(intPtr, strId, sb, sb.Capacity);
        return sb.ToString();
    }
'@
        $getstring = Add-Type $getstring -PassThru -Name GetStr -Using System.Text
        $unpinFromStart = $getstring[0]::GetString(51394)
        (New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | ForEach { $_.Verbs() | Where {$_.Name -eq $unpinFromStart} | ForEach {$_.DoIt()}}
    }
###############################################################
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
    # Hide OneDrive from File Explorer Nav
    Function hideOneDrive {    
        Write-Host "Importing OneDrive reg keys to hide from Explorer nav..." -ForegroundColor Green -BackgroundColor Black   
        # Set HKEY_CLASSES_ROOT registry location 
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT     
        Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
        Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
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
    Function soundCommsAttenuation {
        Write-Host "Setting Communications tab to 'do nothing'" -ForegroundColor Green -BackgroundColor Black
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Multimedia\Audio" -Name "UserDuckingPreference" -Type DWord -Value 3
    }
    # Disable allow remote assistance connections to this computer automatically
    Function disableRemoteAssistance {
        Write-Host "Disabling remote assistance" -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance")){
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Force
        }
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowFullControl" -Type DWord -Value 0
    }
#   Rename computer to something a little more personal if the name contains a default generic name
    Function renameComputer {
        if ($env:computername -like "*DESKTOP-*") {
            Write-Host "Rename your PC, current name: $env:computername" -ForegroundColor Green -BackgroundColor Black
            Write-Host "Press [Enter] to continue without renaming" -ForegroundColor Yellow -BackgroundColor Black
            $newCompName = Read-Host -Prompt "Enter in a new computer name, limit 15 characters"
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
    Function configureNightLight {
        #Write-Host "Configure night light'" -ForegroundColor Yellow -BackgroundColor Black
        #ms-settings:nightlight
        $nightLightState = $false
        do {
            $nightLight = Read-Host -Prompt "Set Windows to automatically tint the screen red at night? [y]/[n]?"
            if (($nightLight -eq "y") -or ($nightLight -eq "Y") -or ($nightLight -eq "1")) {
                $nightLightState = $true
            }
            elseif (($nightLight -eq "n") -or ($nightLight -eq "N") -or ($nightLight -eq "0")) {
                $nightLightState = $true
            }
            else {
                $nightLightState = $false
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($nightLightState -eq $false)

        if ($nightLight -eq $true) {
            Function Set-BlueLightReductionSettings {
                # Source
                # https://superuser.com/questions/1200222/configure-windows-creators-update-night-light-via-registry
                [CmdletBinding()]
                Param (
                    [Parameter(Mandatory=$true)] [ValidateRange(0, 23)] [int]$StartHour,
                    [Parameter(Mandatory=$true)] [ValidateSet(0, 15, 30, 45)] [int]$StartMinutes,
                    [Parameter(Mandatory=$true)] [ValidateRange(0, 23)] [int]$EndHour,
                    [Parameter(Mandatory=$true)] [ValidateSet(0, 15, 30, 45)] [int]$EndMinutes,
                    [Parameter(Mandatory=$true)] [bool]$Enabled,
                    [Parameter(Mandatory=$true)] [ValidateRange(1200, 6500)] [int]$NightColorTemperature
                )
                $data = (2, 0, 0, 0)
                $data += [BitConverter]::GetBytes((Get-Date).ToFileTime())
                $data += (0, 0, 0, 0, 0x43, 0x42, 1, 0)
                If ($Enabled) {$data += (2, 1)}
                $data += (0xCA, 0x14, 0x0E)
                $data += $StartHour
                $data += 0x2E
                $data += $StartMinutes
                $data += (0, 0xCA, 0x1E, 0x0E)
                $data += $EndHour
                $data += 0x2E
                $data += $EndMinutes
                $data += (0, 0xCF, 0x28)
                $tempHi = [Math]::Floor($NightColorTemperature / 64)
                $tempLo = (($NightColorTemperature - ($tempHi * 64)) * 2) + 128
                $data += ($tempLo, $tempHi)
                $data += (0xCA, 0x32, 0, 0xCA, 0x3C, 0, 0)
                Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\$$windows.data.bluelightreduction.settings\Current' -Name 'Data' -Value ([byte[]]$data) -Type Binary
            }
            Set-BlueLightReductionSettings -StartHour 21 -StartMinutes 30 -EndHour 8 -EndMinutes 0 -Enabled $true -NightColorTemperature 3400
        }
        else {
            Write-Host "Night light not set" -ForegroundColor Yellow -BackgroundColor Black
        }
    }
#   Manual Steps--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #   Sound options ------------ (ctrl pan)
    Function configureSoundOptions {
        control.exe /name Microsoft.AudioDevicesAndSoundThemes
        Write-Host "-----------------------------------------------------------"
        Write-Host "Sound: Disable all enhancements (mic and speakers, turn mic level to 100 and boost to 0)" -ForegroundColor Yellow -BackgroundColor Black
    }
    Function bluetoothManualSteps {
        Write-Host " "
        Write-Host "Optional: Disable bluetooth for battery life and security" -ForegroundColor Yellow -BackgroundColor Black
        start ms-settings:bluetooth
        Pause
    }
    Function disableFocusAssistNotifications {
        Write-Host " "
        Write-Host "Configure Focus Assist - gaming/duplicating - uncheck 'show a notification in action center...'" -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "-----------------------------------------------------------"
        start ms-settings:quiethours
        #start ms-settings:quietmomentsgame
        #Pause
        #start ms-settings:quietmomentspresentation
        #Pause
    }
    <#
    Function privacyManualSteps {
        Write-Host "Disable ALL remaining privacy settings" -ForegroundColor Yellow -BackgroundColor Black
        start ms-settings:privacy
    }
    #>
    # Advanced system settings - (explorer)
    <#
    Function configureSystemProperties {
        Write-Host " "
        Write-Host "Uncheck 'allow remote assistance connections to this computer'" -ForegroundColor Yellow -BackgroundColor Black
        SystemPropertiesRemote.exe
    }
    #>
    #   Pin items back into the start menu manually
    Function pinStartMenuItemsAndInstallSoftware {
        #Download software here
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Select a web browser: [0]Microsoft Edge | [1]Google Chrome | [2]Mozilla FireFox"
            if ($SoftwareType -eq "0") {
                $doneUser = $true
                $ie = $true
                $chrome = $false
                $firefox = $false
            }
            elseif ($SoftwareType -eq "1") {
                $doneUser = $true
                $chrome = $true
                $ie = $false
                $firefox = $false

            }
            elseif ($SoftwareType -eq "2"){
                $doneUser = $true
                $firefox = $true
                $ie = $false
                $chrome = $false
            }
            else {
                $doneUser = $false
                Write-Host "Select a web browser to install: [0]Microsoft Edge | [1]Google Chrome | [2]Mozilla FireFox" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        Function uninstallIE {
            Write-Host "Uninstalling IE11..." -ForegroundColor Green -BackgroundColor Black
            Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart
            Write-Host "Removing IE11 from win10 settings..." -ForegroundColor Green -BackgroundColor Black
            Get-WindowsCapability -online | ? {$_.Name -like '*InternetExplorer*'} | Remove-WindowsCapability -online
        }
        if ($chrome -eq $true) {
            $ManualChromeBrowser = "https://www.google.com/chrome/browser/desktop/index.html"
            if (!(Test-Path "C:\Users\$env:username\Downloads\*Chrome*") -and !(Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")) {
                Write-Host "Launching Google Chrome Download" -ForegroundColor Green -BackgroundColor Black
                #$browserPath = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
                #start $browserPath -ArgumentList $ManualChromeBrowser
                start microsoft-edge:$ManualChromeBrowser
            }
            $browserPath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
            $browserSelection = "Google Chrome"
            # Wait until the file has been downloaded, then auto start the launcher
            while (!(Test-Path "C:\Users\$env:username\Downloads\*Chrome*") -and !(Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")) {
                Start-Sleep -s 1 
            }
            if (Test-Path "C:\Users\$env:username\Downloads\*Chrome*") {
                #Get-Process iexplore | Stop-Process
                taskkill /F /IM MicrosoftEdge.exe /T
                Write-Host "Install Google Chrome" -ForegroundColor Green -BackgroundColor Black
                Invoke-Item "C:\Users\$env:username\Downloads\*Chrome*"
            }
            elseif (Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe") {
                Write-Host "Google Chrome is already installed... exiting" -ForegroundColor Yellow -BackgroundColor Black
            }
            else {
                Write-Host "Couldn't find Google Chrome's Setup.exe" -ForegroundColor Red -BackgroundColor Black
            }
        }
        elseif ($firefox -eq $true) {
            $ManualFireFoxBrowser = "https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US"
            if (!(Test-Path "C:\Users\$env:username\Downloads\*Firefox*") -and !(Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe")) {
               Write-Host "Launching Firefox Download" -ForegroundColor Green -BackgroundColor Black
               #$browserPath = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
               #start $browserPath -ArgumentList $ManualFireFoxBrowser
               start microsoft-edge:$ManualFireFoxBrowser
            }
            $browserPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
            $browserSelection = "Mozilla Firefox"
            # Wait until the file has been downloaded, then auto start the launcher
            while (!(Test-Path "C:\Users\$env:username\Downloads\*Firefox*") -and !(Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe")) {
                Start-Sleep -s 1 
            }
            if (Test-Path "C:\Users\$env:username\Downloads\*Firefox*") {
                #Get-Process iexplore | Stop-Process
                taskkill /F /IM MicrosoftEdge.exe /T
                Write-Host "Install Firefox" -ForegroundColor Green -BackgroundColor Black
                Invoke-Item "C:\Users\$env:username\Downloads\*Firefox*"
            }
            elseif (Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe") {
                Write-Host "Mozilla Firefox is already installed... exiting" -ForegroundColor Yellow -BackgroundColor Black
            }
            else {
                Write-Host "Couldn't find Mozilla Firefox's setup.exe" -ForegroundColor Red -BackgroundColor Black
            }
        }
        elseif ($ie -eq $true){
            Write-Host "Setting Microsoft Edge as the default downloader for software" -ForegroundColor Yellow -BackgroundColor Black
            $browserPath = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
            $browserSelection = "Microsoft Edge"
        }
        else {
            Write-Host "No browser could be determined for selection" -ForegroundColor Red -BackgroundColor Black
        }

        Write-Host "Waiting for $browserSelection to finish installation before continuing..." -ForegroundColor Yellow -BackgroundColor Black
        while (!(Test-Path $browserPath) -and ($ie -eq $false)) {
            Start-Sleep -s 1 
        }
        if (($chrome -eq $true) -and (Test-Path $browserPath)) {
            Start-Sleep -s 1
            Get-Process *chrome* | Stop-Process
            Remove-Item -Path "C:\Users\$env:username\Downloads\*Chrome*"
            Remove-Item -Path "C:\Users\$env:username\Desktop\*Edge*"
            # Nuke out internet exploder
            uninstallIE
        }
        elseif (($firefox -eq $true) -and (Test-Path $browserPath)) {
            Start-Sleep -s 1
            Get-Process *firefox* | Stop-Process
            Remove-Item -Path "C:\Users\$env:username\Downloads\*Firefox*"
            Remove-Item -Path "C:\Users\$env:username\Desktop\*Edge*"
            # Nuke out internet exploder
            uninstallIE
        }
        elseif ($ie -eq $true) {
            Write-Host "Using Microsoft Edge" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "We didn't delete a browser download or uninstall IE..." -ForegroundColor Green -BackgroundColor Black
        }
#########Start the download selection:#################################################################################
        #F.lux
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download f.lux?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $flux = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $flux = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #WinDirStat
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download WinDirStat?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $windirstat = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $windirstat = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #7-Zip
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download 7-Zip?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $7zip = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $7zip = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #IMG Burn
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download IMG Burn?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $imgburn = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $imgburn = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
		#VLC
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download VLC Media Player?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $vlc = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $vlc = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Spotify
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Entertainment: Do you wish to download Spotify?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $spotify = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $spotify = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Discord
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Entertainment: Do you wish to download Discord?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $discord = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $discord = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Steam
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Entertainment: Do you wish to download Steam?:  [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $steam = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $steam = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Origin
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Entertainment: Do you wish to download Origin?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $origin = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $origin = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Battle.net
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Entertainment: Do you wish to download Battle.net?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $battlenet = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $battlenet = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Skype
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Entertainment: Do you wish to download Skype?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $skype = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $skype = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Dropbox
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Productivity: Do you wish to download Dropbox?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $dropbox = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $dropbox = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Notepad++
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download Notepad++?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $notepad = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $notepad = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #MSI Afterburner
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download MSI Afterburner?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $msiafterburner = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $msiafterburner = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #HWMonitor
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download HWMonitor?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $hwmonitor = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $hwmonitor = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Putty
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download Putty?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $putty = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $putty = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #TeamViewer
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Tools: Do you wish to download TeamViewer?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $teamviewer = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $teamviewer = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Arduino
        <#
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Productivity: Do you wish to download the Arduino IDE?: [y]/[n]?"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $arduino = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $arduino = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #>
#########Start the downloads themselves:#################################################################################
        #Download Statements - Manual required download button clicks first----------------------------------------------
        <#
        if ($arduino -eq $true){
            Write-Host "Software Chosen: Arduino" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\ManualArduino.url"
            $ManualArduino = "https://www.arduino.cc/en/Main/Software"
            start $browserPath -ArgumentList $ManualArduino
        }
        #>
        if ($vlc -eq $true){
            Write-Host "Software Chosen: VLC Media Player" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\ManualVLC.url"
            $ManualVLC = "https://www.videolan.org/vlc/"
            if ($ie -eq $true) {
                start microsoft-edge:$ManualVLC
            }
            else {
                start $browserPath -ArgumentList $ManualVLC
            }
        }
        if ($imgburn -eq $true){
            Write-Host "Software Chosen: IMG Burn" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\ManualImgBurn.url"
            $ManualImgBurn = "http://www.imgburn.com/index.php?act=download"
            if ($ie -eq $true) {
                start microsoft-edge:$ManualImgBurn
            }
            else {
                start $browserPath -ArgumentList $ManualImgBurn
            }
        }
        if ($notepad -eq $true){
            Write-Host "Software Chosen: Notepad++" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\ManualNotepad++.url"
            $ManualNotepadPP = "https://notepad-plus-plus.org/download/"
            if ($ie -eq $true) {
                start microsoft-edge:$ManualNotepadPP
            }
            else {
                start $browserPath -ArgumentList $ManualNotepadPP
            }
        }
        if ($windirstat -eq $true){
            Write-Host "Software Chosen: WinDirStat" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\ManualWinDirStatFossHub.url"
            $ManualWinDirStatFossHub = "https://www.fosshub.com/WinDirStat.html"
            if ($ie -eq $true) {
                start microsoft-edge:$ManualWinDirStatFossHub
            }
            else {
                start $browserPath -ArgumentList $ManualWinDirStatFossHub
            }
        }
        if ($7zip -eq $true){
            Write-Host "Software Chosen: 7-Zip" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\Manual7zip.url"
            $Manual7zip = "http://www.7-zip.org/download.html"
            if ($ie -eq $true) {
                start microsoft-edge:$Manual7zip
            }
            else {
                start $browserPath -ArgumentList $Manual7zip
            }
        }
        if ($hwmonitor -eq $true){
            Write-Host "Software Chosen: HWMonitor" -ForegroundColor Green -BackgroundColor Black
            $HWMonitorURL = "https://www.cpuid.com/softwares/hwmonitor.html"
            if ($ie -eq $true) {
                start microsoft-edge:$HWMonitorURL
            }
            else {
                start $browserPath -ArgumentList $HWMonitorURL
            }
        }
        #Write-Host "Note: Some downloads are manual, others are automatic" -ForegroundColor Yellow -BackgroundColor Black
        if ($spotify -eq $true){
            Write-Host "Software Chosen: Spotify" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\Spotify.url"
            $SpotifyURL = "https://download.scdn.co/SpotifySetup.exe"
            if ($ie -eq $true) {
                start microsoft-edge:$SpotifyURL
            }
            else {
                start $browserPath -ArgumentList $SpotifyURL
            }
        }
        if ($discord -eq $true){
            Write-Host "Software Chosen: Discord" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\Spotify.url"
            $DiscordURL = "https://discordapp.com/api/download?platform=win"
            if ($ie -eq $true) {
                start microsoft-edge:$DiscordURL
            }
            else {
                start $browserPath -ArgumentList $DiscordURL
            }
        }
        if ($steam -eq $true){
            Write-Host "Software Chosen: Steam" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\Steam.url"
            $SteamURL = "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe"
            if ($ie -eq $true) {
                start microsoft-edge:$SteamURL
            }
            else {
                start $browserPath -ArgumentList $SteamURL
            }
        }
        if ($origin -eq $true){
            Write-Host "Software Chosen: Origin" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\Origin.url"
            $OriginURL = "https://www.dm.origin.com/download"
            if ($ie -eq $true) {
                start microsoft-edge:$OriginURL
            }
            else {
                start $browserPath -ArgumentList $OriginURL
            }
        }
        if ($battlenet -eq $true){
            Write-Host "Software Chosen: Battle.net" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\Battlenet.url"
            $BattlenetURL = "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"
            if ($ie -eq $true) {
                start microsoft-edge:$BattlenetURL
            }
            else {
                start $browserPath -ArgumentList $BattlenetURL
            }
        }
        if ($skype -eq $true){
            Write-Host "Software Chosen: Skype" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\Skype.url"
            $SkypeURL = "https://go.skype.com/windows.desktop.download"
            if ($ie -eq $true) {
                start microsoft-edge:$SkypeURL
            }
            else {
                start $browserPath -ArgumentList $SkypeURL
            }
        }
        if ($msiafterburner -eq $true){
            Write-Host "Software Chosen: MSI Afterburner" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\MSIAfterburner.url"
            $MSIAfterburnerURL = "http://download.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip"
            if ($ie -eq $true) {
                start microsoft-edge:$MSIAfterburnerURL
            }
            else {
                start $browserPath -ArgumentList $MSIAfterburnerURL
            }
        }
        if ($putty -eq $true){
            Write-Host "Software Chosen: Putty" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\Putty.url"
            $PuttyURL = "https://the.earth.li/~sgtatham/putty/latest/x86/putty.exe"
            if ($ie -eq $true) {
                start microsoft-edge:$PuttyURL
            }
            else {
                start $browserPath -ArgumentList $PuttyURL
            }
        }
        if ($teamviewer -eq $true){
            Write-Host "Software Chosen: TeamViewer" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\TeamViewer.url"
            $TeamViewerURL = "https://download.teamviewer.com/download/TeamViewer_Setup_en.exe"
            if ($ie -eq $true) {
                start microsoft-edge:$TeamViewerURL
            }
            else {
                start $browserPath -ArgumentList $TeamViewerURL
            }
        }
        if ($flux -eq $true) {
            Write-Host "Software Chosen: f.lux" -ForegroundColor Green -BackgroundColor Black
            $FluxURL = "https://justgetflux.com/dlwin.html"
            if ($ie -eq $true) {
                start microsoft-edge:$FluxURL
            }
            else {
                start $browserPath -ArgumentList $FluxURL
            }
        }
        if ($dropbox -eq $true){
            Write-Host "Software Chosen: Dropbox" -ForegroundColor Green -BackgroundColor Black
            #Invoke-Item "$workingDir\URLs\Dropbox.url"
            $DropboxURL = "https://www.dropbox.com/downloading"
            if ($ie -eq $true) {
                start microsoft-edge:$DropboxURL
            }
            else {
                start $browserPath -ArgumentList $DropboxURL
            }
        }
        else{
            Write-Host "This is the software else statement" -ForegroundColor Red -BackgroundColor Black
        }
        Write-Host "Wait for ALL software to finish downloading before continuing to install..." -ForegroundColor Yellow -BackgroundColor Black
        <#
        $flux
        $windirstat
        $7zip
        $imgburn
        $vlc
        $spotify
        $discord
        $steam
        $origin
        $battlenet
        $skype
        $dropbox
        $notepad
        $msiafterburner
        $hwmonitor
        $putty
        $teamviewer
        #>
        <#
        # Check that all software was downloaded successfully. If not downloaded successfully, reattempt download
        # implement a while loop to ensure that everything is continually checked for successfull downloads after re-attempts are made
        #>
        Write-Host "Waiting for f.lux to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($flux -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*flux*"))) {
            Start-Sleep -s 1 
        }
        if (($flux -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*flux*")) {
            Write-Host "f.lux successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($flux -eq $false) {
            Write-Host "f.lux not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "f.lux not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $FluxURL
        }
        Write-Host "Waiting for Spotify to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($spotify -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*spotify*"))) {
            Start-Sleep -s 1 
        }
        if (($spotify -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*spotify*")) {
            Write-Host "Spotify successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($spotify -eq $false) {
            Write-Host "Spotify not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Spotify not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $SpotifyURL
        }
        Write-Host "Waiting for Discord to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($discord -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*discord*"))) {
            Start-Sleep -s 1 
        }
        if (($discord -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*discord*")) {
            Write-Host "Discord successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($discord -eq $false) {
            Write-Host "Discord not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Discord not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $DiscordURL
        }
        Write-Host "Waiting for Steam to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($steam -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*steam*"))) {
            Start-Sleep -s 1 
        }
        if (($steam -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*steam*")) {
            Write-Host "Steam successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($steam -eq $false) {
            Write-Host "Steam not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Steam not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $SteamURL
        }
        Write-Host "Waiting for Origin to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($origin -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*origin*"))) {
            Start-Sleep -s 1 
        }
        if (($origin -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*origin*")) {
            Write-Host "Origin successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($origin -eq $false) {
            Write-Host "Origin not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Origin not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $OriginURL
        }
        Write-Host "Waiting for Battle.net to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($battlenet -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*battle.net*"))) {
            Start-Sleep -s 1 
        }
        if (($battlenet -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*battle.net*")) {
            Write-Host "Battle.net successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($battlenet -eq $false) {
            Write-Host "Battle.net not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Battle.net not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $BattlenetURL
        }
        Write-Host "Waiting for Skype to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($skype -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*skype*"))) {
            Start-Sleep -s 1 
        }
        if (($skype -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*skype*")) {
            Write-Host "Skype successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($skype -eq $false) {
            Write-Host "Skype not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Skype not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $SkypeURL
        }
        Write-Host "Waiting for Dropbox to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($dropbox -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*dropbox*"))) {
            Start-Sleep -s 1 
        }
        if (($dropbox -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*dropbox*")) {
            Write-Host "Dropbox successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($dropbox -eq $false) {
            Write-Host "Dropbox not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Dropbox not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $DropboxURL
        }
        Write-Host "Waiting for MSI Afterburner to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($msiafterburner -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*msiafterburner*"))) {
            Start-Sleep -s 1 
        }
        if (($msiafterburner -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*msiafterburner*")) {
            Write-Host "MSI Afterburner successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($msiafterburner -eq $false) {
            Write-Host "MSI Afterburner not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "MSI Afterburner not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $MSIAfterburnerURL
        }
        Write-Host "Waiting for Putty to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($putty -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*putty*"))) {
            Start-Sleep -s 1 
        }
        if (($putty -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*putty*")) {
            Write-Host "Putty successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($putty -eq $false) {
            Write-Host "Putty not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Putty not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $PuttyURL
        }
        Write-Host "Waiting for TeamViewer to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($teamviewer -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*teamviewer*"))) {
            Start-Sleep -s 1 
        }
        if (($teamviewer -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*teamviewer*")) {
            Write-Host "TeamViewer successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($teamviewer -eq $false) {
            Write-Host "TeamViewer not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "TeamViewer not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $TeamViewerURL
        }
        # Manual download checks are below
        Write-Host "Waiting for WinDirStat to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($windirstat -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*windirstat*"))) {
            Start-Sleep -s 1 
        }
        if (($windirstat -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*windirstat*")) {
            Write-Host "WinDirStat successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($windirstat -eq $false) {
            Write-Host "WinDirStat not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "WinDirStat not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $ManualWinDirStatFossHub
        }
        Write-Host "Waiting for 7-Zip to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($7zip -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*7z*"))) {
            Start-Sleep -s 1 
        }
        if (($7zip -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*7z*")) {
            Write-Host "7-Zip successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($7zip -eq $false) {
            Write-Host "7-Zip not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "7-Zip not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $Manual7zip
        }
        Write-Host "Waiting for ImgBurn to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($imgburn -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*imgburn*"))) {
            Start-Sleep -s 1 
        }
        if (($imgburn -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*imgburn*")) {
            Write-Host "ImgBurn successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($imgburn -eq $false) {
            Write-Host "ImgBurn not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "ImgBurn not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $ManualImgBurn
        }
        Write-Host "Waiting for vlc to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($vlc -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*vlc*"))) {
            Start-Sleep -s 1 
        }
        if (($vlc -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*vlc*")) {
            Write-Host "VLC Media Player successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($vlc -eq $false) {
            Write-Host "VLC Media Player not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "VLC Media Player not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $ManualVLC
        }
        Write-Host "Waiting for Notepad++ to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($notepad -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*npp*"))) {
            Start-Sleep -s 1 
        }
        if (($notepad -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*npp*")) {
            Write-Host "Notepad++ successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($notepad -eq $false) { 
            Write-Host "Notepad++ not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Notepad++ not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $ManualNotepadPP
        }
        Write-Host "Waiting for hwmonitor to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($hwmonitor -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*hwmonitor*"))) {
            Start-Sleep -s 1 
        }
        if (($hwmonitor -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*hwmonitor*")) {
            Write-Host "HWMonitor successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($hwmonitor -eq $false) {
            Write-Host "HWMonitor not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "HWMonitor not downloaded" -ForegroundColor Red -BackgroundColor Black
            start $browserPath -ArgumentList $HWMonitorURL
        }
        Start-Sleep -s 1

        # Exit out of browser after all of manual software has been downloaded and installs start.
        if ($firefox) {
            Get-Process *firefox* | Stop-Process
        }
        elseif ($chrome) {
            Get-Process *chrome* | Stop-Process
        }
        elseif ($ie) {
            taskkill /F /IM MicrosoftEdge.exe /T
            #Get-Process iexplore | Stop-Process
        }
        else {
            Write-Host "No browsers were killed after downloads have completed" -ForegroundColor Yellow -BackgroundColor Black
        }
        Write-Host "Waiting until all programs are installed before continuing..." -ForegroundColor Green -BackgroundColor Black
        Invoke-Item "C:\Users\$env:username\Downloads"
        # Start the setup.exes for installation - Needs improvement (will launch multiple installation files if multiple are downloaded | change to only 1 instance)
        while ($putty -and !(Test-Path "C:\Program Files (x86)\Putty\putty.exe")) {
            Write-Host "Waiting for Putty to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            if(!(Test-Path "C:\Program Files (x86)\Putty")) {
                New-Item -ItemType Directory -Path "C:\Program Files (x86)\Putty" -Force
            }
            Move-Item -Path "C:\Users\$env:username\Downloads\putty.exe" -Destination "C:\Program Files (x86)\Putty"
            $TargetFile = "C:\Program Files (x86)\Putty\putty.exe"
            $ShortcutFile = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Putty.lnk"
            $WScriptShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
            $Shortcut.TargetPath = $TargetFile
            $ShortCut.IconLocation = "C:\Program Files (x86)\Putty\putty.exe, 0"
            $Shortcut.Save()
            Start-Sleep -s 1
        }
        if ($flux -and !(Test-Path "C:\Users\$env:username\AppData\Local\FluxSoftware\Flux\flux.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*flux*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *flux-setup*).MainWindowTitle)
        }
        while ($flux -and !(Test-Path "C:\Users\$env:username\AppData\Local\FluxSoftware\Flux\flux.exe")) {
            Write-Host "Waiting for f.lux to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        } 
        if ($windirstat -and !(Test-Path "C:\Program Files (x86)\WinDirStat\windirstat.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*windirstat*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *windirstat*).MainWindowTitle)
        }
        while ($windirstat -and !(Test-Path "C:\Program Files (x86)\WinDirStat\windirstat.exe")) {
            Write-Host "Waiting for WinDirStat to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($7zip -and !(Test-Path "C:\Program Files\7-Zip\7zFM.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*7z*"
            # Bring the window to the foreground based on name          7z1805-x64
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *7z*).MainWindowTitle)
        } 
        while ($7zip -and !(Test-Path "C:\Program Files\7-Zip\7zFM.exe")) {
            Write-Host "Waiting for 7-Zip to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($imgburn -and !(Test-Path "C:\Program Files (x86)\ImgBurn\ImgBurn.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*imgburn*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *imgburn*).MainWindowTitle)
        }
        while ($imgburn -and !(Test-Path "C:\Program Files (x86)\ImgBurn\ImgBurn.exe")) {
            Write-Host "Waiting for ImgBurn to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($vlc -and !(Test-Path "C:\Program Files\VideoLAN\VLC\vlc.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*vlc*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *vlc*).MainWindowTitle)
        }
        while ($vlc -and !(Test-Path "C:\Program Files\VideoLAN\VLC\vlc.exe")) {
            Write-Host "Waiting for VLC Media Player to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($spotify -and !(Test-Path "C:\Users\$env:username\AppData\Roaming\Spotify\Spotify.exe")) {
            # Needs to install spotify as a the current user (in non-admin mode) | The script is currently running as admin
            $spotifyEXE = Get-ChildItem "C:\Users\$env:username\Downloads\*Spotify*"
            $newPS = new-object System.Diagnostics.ProcessStartInfo "PowerShell"
            # Specify what to run, you need the full path after explorer.exe
            $newPS.Arguments = "explorer.exe $spotifyEXE"
            [System.Diagnostics.Process]::Start($newPS)
            # This works but requires a password prompt 
            #Start-Process "C:\Users\$env:username\Downloads\*spotify*" -Credential "$env:username"
            
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *spotify*).MainWindowTitle)
        }
        while ($spotify -and !(Test-Path "C:\Users\$env:username\AppData\Roaming\Spotify\Spotify.exe")) {
            Write-Host "Waiting for Spotify to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($discord -and !(Test-Path "C:\Users\$env:username\AppData\Local\Discord\Update.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*discord*"
            #commenting out... this install is automatic
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *discord*).MainWindowTitle)
        }
        while ($discord -and !(Test-Path "C:\Users\$env:username\AppData\Local\Discord\Update.exe")) {
            Write-Host "Waiting for Discord to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($steam -and !(Test-Path "C:\Program Files (x86)\Steam\Steam.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*steam*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *steam*).MainWindowTitle)
        }
        while ($steam -and !(Test-Path "C:\Program Files (x86)\Steam\Steam.exe")) {
            Write-Host "Waiting for Steam to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($origin -and !(Test-Path "C:\Program Files (x86)\Origin\Origin.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*origin*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *origin*).MainWindowTitle)
        }
        while ($origin -and !(Test-Path "C:\Program Files (x86)\Origin\Origin.exe")) {
            Write-Host "Waiting for Origin to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($battlenet -and !(Test-Path "C:\Program Files (x86)\Battle.net\Battle.net Launcher.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*battle.net*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *battle.net*).MainWindowTitle)
        }
        while ($battlenet -and !(Test-Path "C:\Program Files (x86)\Battle.net\Battle.net Launcher.exe")) {
            Write-Host "Waiting for Battle.net to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($skype -and !(Test-Path "C:\Program Files (x86)\Microsoft\Skype for Desktop\Skype.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*skype*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *skype*).MainWindowTitle)
        }
        while ($skype -and !(Test-Path "C:\Program Files (x86)\Microsoft\Skype for Desktop\Skype.exe")) {
            Write-Host "Waiting for Skype to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($dropbox -and !(Test-Path "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*dropbox*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *dropboxinstaller*).MainWindowTitle)
        }
        while ($dropbox -and !(Test-Path "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe")) {
            Write-Host "Waiting for Dropbox to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($notepad -and !(Test-Path "C:\Program Files (x86)\Notepad++\notepad++.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*npp*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *npp*).MainWindowTitle)
        }
        while ($notepad -and !(Test-Path "C:\Program Files (x86)\Notepad++\notepad++.exe")) {
            Write-Host "Waiting for Notepad++ to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($hwmonitor -and !(Test-Path "C:\Program Files\CPUID\HWMonitor\HWMonitor.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*hwmonitor*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *hwmonitor*).MainWindowTitle)
        }
        while ($hwmonitor -and !(Test-Path "C:\Program Files\CPUID\HWMonitor\HWMonitor.exe")) {
            Write-Host "Waiting for HWMonitor to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        if ($teamviewer -and !(Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe")) {
            Invoke-Item "C:\Users\$env:username\Downloads\*teamviewer*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *teamviewer*).MainWindowTitle)
        }
        while ($teamviewer -and !(Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe")) {
            Write-Host "Waiting for TeamViewer to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }
        # Putting MSI Afterburner last since Expand-Archive seems to bust and re-launch windows file explorer.exe
        if ($msiafterburner -and !(Test-Path "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe")) {
            Expand-Archive -Path "C:\Users\$env:username\Downloads\*msiafterburner*" -DestinationPath "C:\Users\$env:username\Downloads" -Force
            Invoke-Item "C:\Users\$env:username\Downloads\*\*msiafterburner*"
            # Bring the window to the foreground based on name
            #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *msiafterburner*).MainWindowTitle)
        }
        while ($msiafterburner -and !(Test-Path "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe")) {
            Write-Host "Waiting for MSI Afterburner to be installed..." -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
        }

        # Exit out of the users Downloads folder(s)
        Write-Host "Closing out of the Downloads folder"
        #Get-Process explorer | Stop-Process
        $explorerShell = New-Object -ComObject Shell.Application
        # $explorerShell.Windows() | Format-Table Name, LocationName, LocationURL
        $downloadsWindow = $explorerShell.Windows() | Where-Object { $_.LocationURL -like "$(([uri]"C:\Users\$env:username\Downloads").AbsoluteUri)*" }
        $downloadsWindow | ForEach-Object { $_.Quit() }

        function Pin-App ([string]$appname, [switch]$unpin, [switch]$start, [switch]$taskbar, [string]$path) {
            if ($unpin.IsPresent) {
                $action = "Unpin"
            } else {
                $action = "Pin"
            }
            
            if (-not $taskbar.IsPresent -and -not $start.IsPresent) {
                Write-Error "Specify -taskbar and/or -start!"
            }
            
            if ($taskbar.IsPresent) {
                try {
                    $exec = $false
                    if ($action -eq "Unpin") {
                        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
                        if ($exec) {
                            Write "App '$appname' unpinned from Taskbar"
                        } else {
                            if (-not $path -eq "") {
                                Pin-App-by-Path $path -Action $action
                            } else {
                                Write "'$appname' not found or 'Unpin from taskbar' not found on item!"
                            }
                        }
                    } else {
                        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Pin to taskbar'} | %{$_.DoIt(); $exec = $true}
                        
                        if ($exec) {
                            Write "App '$appname' pinned to Taskbar"
                        } else {
                            if (-not $path -eq "") {
                                Pin-App-by-Path $path -Action $action
                            } else {
                                Write "'$appname' not found or 'Pin to taskbar' not found on item!"
                            }
                        }
                    }
                } catch {
                    Write-Error "Error Pinning/Unpinning $appname to/from taskbar!"
                }
            }
            
            if ($start.IsPresent) {
                try {
                    $exec = $false
                    if ($action -eq "Unpin") {
                        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from Start'} | %{$_.DoIt(); $exec = $true}
                        
                        if ($exec) {
                            Write "App '$appname' unpinned from Start"
                        } else {
                            if (-not $path -eq "") {
                                Pin-App-by-Path $path -Action $action -start
                            } else {
                                Write "'$appname' not found or 'Unpin from Start' not found on item!"
                            }
                        }
                    } else {
                        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Pin to Start'} | %{$_.DoIt(); $exec = $true}
                        
                        if ($exec) {
                            Write "App '$appname' pinned to Start"
                        } else {
                            if (-not $path -eq "") {
                                Pin-App-by-Path $path -Action $action -start
                            } else {
                                Write "'$appname' not found or 'Pin to Start' not found on item!"
                            }
                        }
                    }
                } catch {
                    Write-Error "Error Pinning/Unpinning $appname to/from Start!"
                }
            }
        }
        function Pin-App-by-Path([string]$Path, [string]$Action, [switch]$start) {
            if ($Path -eq "") {
                Write-Error -Message "You need to specify a Path" -ErrorAction Stop
            }
            if ($Action -eq "") {
                Write-Error -Message "You need to specify an action: Pin or Unpin" -ErrorAction Stop
            }
            if ((Get-Item -Path $Path -ErrorAction SilentlyContinue) -eq $null){
                Write-Error -Message "$Path not found" -ErrorAction Stop
            }
            $Shell = New-Object -ComObject "Shell.Application"
            $ItemParent = Split-Path -Path $Path -Parent
            $ItemLeaf = Split-Path -Path $Path -Leaf
            $Folder = $Shell.NameSpace($ItemParent)
            $ItemObject = $Folder.ParseName($ItemLeaf)
            $Verbs = $ItemObject.Verbs()
            
            if ($start.IsPresent) {
                switch($Action){
                    "Pin"   {$Verb = $Verbs | Where-Object -Property Name -EQ "&Pin to Start"}
                    "Unpin" {$Verb = $Verbs | Where-Object -Property Name -EQ "Un&pin from Start"}
                    default {Write-Error -Message "Invalid action, should be Pin or Unpin" -ErrorAction Stop}
                }
            } else {
                switch($Action){
                    "Pin"   {$Verb = $Verbs | Where-Object -Property Name -EQ "Pin to Tas&kbar"}
                    "Unpin" {$Verb = $Verbs | Where-Object -Property Name -EQ "Unpin from Tas&kbar"}
                    default {Write-Error -Message "Invalid action, should be Pin or Unpin" -ErrorAction Stop}
                }
            }
            
            if($Verb -eq $null){
                Write-Error -Message "That action is not currently available on this Path" -ErrorAction Stop
            } else {
                $Result = $Verb.DoIt()
            }
        }
        <#
        f.lux
        vlc
        imgburn 
        notepad
        windirstat
        7zip
        hwmonitor
        spotify
        discord
        steam
        origin
        battlenet
        skype
        dropbox
        msiafterburner
        putty
        teamviewer
        #>
        #Applications
        # needs improvement - could implement a wait function if selected apps 'get-process -name *' is running, then wait before attempting to pin things to the start menu since sometimes it starts this too fast
        Start-Sleep -s 5
        if ($chrome -eq $true){
            #while (!(Get-Process *chrome*)) {
            #    Write-Host "Waiting for Google Chrome to close before attempting to pin it to the start menu"
            #    Start-Sleep -s 1
            #}
            Pin-App "Google Chrome" -pin -start
        }
        Start-Sleep -m 100
        if ($firefox -eq $true){
            Pin-App "Firefox" -pin -start
        }
        Start-Sleep -m 100
        if (!($chrome) -and !($firefox)) {
            Pin-App "Microsoft Edge" -pin -start
            Start-Sleep -m 100
        }
        if ($spotify -eq $true){
            Pin-App "Spotify" -pin -start
        }
        Start-Sleep -m 100
        if ($skype -eq $true){
            Pin-App "Skype" -pin -start
        }
        Start-Sleep -m 100
        if ($steam -eq $true){
            Pin-App "Steam" -pin -start
        }
        Start-Sleep -m 100
        if ($origin -eq $true){
            Pin-App "Origin" -pin -start
        }
        Start-Sleep -m 100
        if ($battlenet -eq $true){
            Pin-App "Battle.net" -pin -start
        }
        Start-Sleep -m 100
        if ($discord -eq $true){
            Pin-App "Discord" -pin -start
        }
        Start-Sleep -m 100
        #Tools
        Pin-App "Calculator" -pin -start
        Start-Sleep -m 100
        Pin-App "Snipping Tool" -pin -start
        Start-Sleep -m 100
        Pin-App "Paint" -pin -start
        Start-Sleep -m 100
        if ($notepad -eq $true){
            Pin-App "Notepad++" -pin -start
        }
        Start-Sleep -m 100
        if ($windirstat -eq $true){
            Pin-App "WinDirStat" -pin -start
        }
        Start-Sleep -m 100
        if ($imgburn  -eq $true){
            Pin-App "ImgBurn" -pin -start
        }
        Start-Sleep -m 100
        if ($putty -eq $true) {
            Write-Host "Attempting to pin Putty to start menu" -ForegroundColor Yellow -BackgroundColor Black
            Pin-App "Putty" -pin -start
        }
        Start-Sleep -m 100
        Pin-App "Remote Desktop Connection" -pin -start
        Start-Sleep -m 100
        if ($teamviewer -eq $true){
            #This will error out for future versions of teamviewer e.g. 14,15,16 etc...
            Pin-App "TeamViewer 13" -pin -start
        }
        Start-Sleep -m 100
        if ($msiafterburner -eq $true){
            Pin-App "MSI Afterburner" -pin -start
        }
        Start-Sleep -m 100
        if ($hwmonitor -eq $true){
            Pin-App "HWMonitor" -pin -start
        }
        Start-Sleep -m 100
        #Navigation
        Pin-App "This PC" -pin -start
        Start-Sleep -m 100
        #Errors out
        #Pin-App "Downloads" -pin -start
        if ($dropbox -eq $true){
            Pin-App "Dropbox" -pin -start
        }
        Start-Sleep -m 100
        Pin-App "Control Panel" -pin -start
        Start-Sleep -m 100
        #Errors out
        #Pin-App "Recycle Bin" -pin -start
        #Set default apps - needs improvement, could possibly set these automatically if ($appOfChoice -eq $true)? | yes, but looks like it has to be the same way I did for the restoreOldPhotoViewer function
        Write-Host "Set the default apps..." -ForegroundColor Yellow -BackgroundColor Black
        start ms-settings:defaultapps
    }
###########################
# Start main program here # 
###########################
# Initialize the call functions
$powerUserMainCall = $false
$regularUserMainCall = $false
$firstTimeOptionalMainCall = $false
$manualMainCall = $false
$firstTimeManualMainCall = $false
#################################
# Prompt user to select presets # 
#################################
# First time run?
$redoFirstTimePrompt = $false
do {
    $firstTimePrompt = Read-Host -Prompt "Is this a new install of Windows 10? | Unpin apps & install software? [y]/[n]"
    if (($firstTimePrompt -eq "y") -or ($firstTimePrompt -eq "Y") -or ($firstTimePrompt -eq "1")) {
        Write-Host "Adding additional steps for first run" -ForegroundColor Green -BackgroundColor Black
        # invoke fresh image config presets
        $firstTimeOptionalMainCall = $true
        $firstTimeManualMainCall = $true
        $redoFirstTimePrompt = $false
    }
    elseif (($firstTimePrompt -eq "n") -or ($firstTimePrompt -eq "N") -or ($firstTimePrompt -eq "0")) {
        Write-Host "Skipping first run steps since it may kill existing configurations" -ForegroundColor Green -BackgroundColor Black
        # skip fresh image config presets
        $firstTimeOptionalMainCall = $false
        $firstTimeManualMainCall = $false
        $redoFirstTimePrompt = $false
    }
    else {
        Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
        $redoFirstTimePrompt = $true
    }
}
while ($redoFirstTimePrompt -eq $true)
# Power user?
$redoUserPrompt = $false
do {
    $userPrompt = Read-Host -Prompt "Run through power user preset?: [y]/[n]?"
    if (($userPrompt -eq "y") -or ($userPrompt -eq "Y") -or ($userPrompt -eq "1")) {
        Write-Host "Running through the power user config parameters" -ForegroundColor Green -BackgroundColor Black
        # Call the desired functions with power user presets
        $powerUserMainCall = $true
        # Invoke manual steps as well
        $manualMainCall = $true
        $redoUserPrompt = $false
    }
    elseif (($userPrompt -eq "n") -or ($userPrompt -eq "N") -or ($userPrompt -eq "0")) {
        Write-Host "Running through the regular user config parameters" -ForegroundColor Green -BackgroundColor Black
        # Call the predefined functions with regular user presets
        $regularUserMainCall = $true
        # Invoke manual steps as well
        $manualMainCall = $true
        $redoUserPrompt = $false
    }
    else {
        Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
        $redoUserPrompt = $true
    }
}
while ($redoUserPrompt -eq $true)
#######################################
# Call the presets that were selected # 
#######################################
if ($powerUserMainCall) {
    $powerUserMain | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    hideOneDrive
}
if ($regularUserMainCall) {
    $regularUserMain | ForEach { Invoke-Expression $_ }
}
if ($firstTimeOptionalMainCall) {
    $firstTimeOptionalMain | ForEach { Invoke-Expression $_ }
}
if ($manualMainCall) {
    $manualMain | ForEach { Invoke-Expression $_ }
}
if ($firstTimeManualMainCall) {
    $firstTimeManualMain | ForEach { Invoke-Expression $_ }
}
else {
    Write-Host "No functions were called to run" -ForegroundColor Yellow -BackgroundColor Black
}
#############################################
# Prompt user to disable TeamViewer service #
#############################################
Function disableTeamViewerPrompt {
    $teamViewerIsInstalled = Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe"
    if ($teamViewerIsInstalled) {
        Function disableTeamViewer {
            Write-Host "Disabling TeamViewer listening service for security since it's not going to be used..." -ForegroundColor Green -BackgroundColor Black
            Set-Service TeamViewer -StartupType Disabled
            Set-Service TeamViewer -Status Stopped
        }
        do {
            $teamViewerPrompt = Read-Host -Prompt "Will you be using TeamViewer to listen for connections? i.e. let people remote control your PC?: [y]/[n]"
            if (($teamViewerPrompt -eq "y") -or ($teamViewerPrompt -eq "Y") -or ($teamViewerPrompt -eq "1")) {
                Write-Host "Leaving TeamViewer Alone" -ForegroundColor Green -BackgroundColor Black
                $redoDisableTeamViewerCheck = $false
            }
            elseif (($teamViewerPrompt -eq "n") -or ($teamViewerPrompt -eq "N") -or ($teamViewerPrompt -eq "0")) {
                disableTeamViewer
                $redoDisableTeamViewerCheck = $false
            }
            else {
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
                $redoDisableTeamViewerCheck = $true
            }
        }
        while ($redoDisableTeamViewerCheck -eq $true)
    }
    else {
        Write-Host "TeamViewer isn't installed, skipping..." -ForegroundColor Green -BackgroundColor Black
    }
}
disableTeamViewerPrompt
############################################
# Output final manual steps to a text file # 
############################################
Function remainingStepsToText {
    $outputFile = "C:\Users\$env:username\Desktop\Remaining Manual Steps.txt"
$outString = 
"
########################################################################################################################################################################################################
## Start Menu App Categories ##
###############################
Applications
Tools
Navigation
Pin 'Recycle Bin' and 'Downloads' manually
Create a Shortcut folder for local games and pin to the start menu

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

#############################
## Personal Folder Targets ##
#############################
Change the targets for 
Documents, Downloads, Music, Pictures, Videos

#############################
### Backgrounds and Images ##
#############################
Set a background
Set a lockscreen picture
Set a user account picture

#################################
## Install Additional Software ##
#################################
# psftp
# rufus
# msOffice
# electrum
# nicehash
########################################################################################################################################################################################################
"
    $outString | Out-File -FilePath $outputFile -Width 200
}
remainingStepsToText
####################
# Restart computer # 
####################
$restartState = $false
do {
    $restartHost = Read-Host -Prompt "Script finished, restart for changes to take effect: Restart now? [y]/[n]?"
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
#>
########################################################################################################################################################################################################
# Improvements needed:
# Configurations:
# Set default programs automatically 
# Hide ease of access button on logon screen for power users
# If only one local drive exists, Create a separate local games folder in user context and pin to start menu?
#
# Errors:
# Apps (recently uninstalled) show up on start menu as 'new' - remove them
#
# Script: 
# Possible to install software with powershell and feed it configuration parameters?
#
# Additional Software to Add to Software section:
# epic games launcher
# uPlay
# GoG Galaxy
########################################################################################################################################################################################################
#>
# Needs improvement - not sure where to put this since Recycle Bin has to be pinned to start menu manually after it's removed from the desktop
###################################
# Remove recycle bin from desktop #
###################################
Function removeRecycleBin {
    Write-Host "Removing Recycle Bin from the desktop" -ForegroundColor Green -BackgroundColor Black
    if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")){
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 1
    if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")){
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 1
}

########################################################################################################################################################################################################
<#
# Needs improvement - Change targets for Documents, Downloads, Music, Pictures, Videos to the appropriate drive automatically by prompting the user
Function configureUserFolderTargets {
    Write-Host "Set user folder targets to separate drive..." -ForegroundColor Green -BackgroundColor Black
    #Give the option to input and change the drive for paths of the documents/downloads/music/videos user folders to: 
    #(D:\, E:\, etc... if multiple drives exist on the system)
    
    #"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal /t REG_SZ /d "d:\mydocs" /f
    $fixedDrives = Get-WMIObject -query "SELECT * from win32_logicaldisk where DriveType = '3'"
    $fixedDriveCount = 0
    ForEach ($_ in $fixedDrives) {
        $fixedDriveCount++
    }
    #Non C: drive drives have more than 100GB and 20% freespace
    if ($fixedDriveCount -gt 1 -and )# and non-C-drive

    $driveSpaceInGB = $fixedDrives.FreeSpace/1073741824
    $driveSpaceInGBRounded = [Math]::Round($driveSpaceInGB,2)
    $powerPlanGUIDAMD = $powerPlanGUIDs.split("`r`n") | ForEach {$_} | Select-String -Pattern "9897998c-92de-4669-853f-b7cd3ecb2790"   

    if fixed drives > 1 
    
    #DeviceID     : C:
    #DriveType    : 3
    #ProviderName :
    #FreeSpace    : 18786136064
    #Size         : 33781968896
    #VolumeName   :
Pause
}
#>
########################################################################################################################################################################################################