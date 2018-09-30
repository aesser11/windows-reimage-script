#Windows10Personalization.ps1
########################
# Author: Austin Esser #
########################
# Relaunch the script with administrator privileges and bypass execution-policy if it isn't already
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    #Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -WorkingDirectory $pwd -Verb RunAs
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    exit
}
$allUsersAutomated = @(
    "disableNvidiaTelemetry", # always run
    "disableTelemetry", # always run
    "configureWindowsUpdates", # always run
    "configurePrivacy", # always run
    "explorerHideSyncNotifications", # always run
    "explorerSetExplorerThisPC", # always run
    "disableStickyKeys", # always run
    "enableLegacyF8Boot", # always run
    "enableGuestSMBShares", # always run
    "setVisualFXAppearance", # always run
    "setPageFileToC", # always run
    "setWindowsTimeZone", # always run
    "uninstallWindowsFeatures", # always run
    "disableRemoteAssistance", # always run
    "deleteHibernationFile", # always run
    "setPowerProfile" # always run
)
$allUsersPrompted = @(
    ### Prompt Steps ### 
    "configureNightLight", # user preference - prompt
    "disableTeamViewerPrompt", # always run - prompt
    "removeRecycleBin", # alwasy run - prompt if $global:isAustin -eq $false
    "uninstallIE", # always run - prompt
    ### Manual Steps ### 
    "configureSoundOptions", # always run - prompt
    "bluetoothManualSteps", # always run - prompt
    "disableFocusAssistNotifications" # always run - prompt
#    "configureUserFolderTargets", # always run (if more than one fixed drive exists, else skip) - prompt [not finished]
)
$powerUserAutomated = @(
    # run aggressive pre-defined user preference steps
    "powerUserDeleteApps", # user preference
    "restoreOldPhotoViewer", # user preference
    "disableAeroShake", # user preference
    "uninstallOptionalApps", # user preference
    "taskbarCombineWhenFull", # user preference
    "taskbarShowTrayIcons", # user preference
    "taskbarHideSearch", # user preference
    "taskbarHideTaskView", # user preference
    "taskbarHidePeopleIcon", # user preference
    "taskbarHideInkWorkspace", # user preference
    "taskbarMMSteps", # user preference
    "disableBingWebSearch", # user preference 
    "disableGameMode-Bar-DVR", # user preference 
#    "disableTipsTricksAndWelcomeExp", # user preference (not implemented)
    "disableLockScreenTips", # user preference
    "explorerShowKnownExtensions", # user preference
    "explorerShowHiddenFiles", # user preference
    "explorerHide3DObjectsFromThisPC", # user preference 
    "explorerHide3DObjectsFromExplorer", # user preference
    "explorerHideRecentShortcuts", # user preference
    "explorerSetControlPanelLargeIcons", # user preference
    "explorerShowFileTransferDetails", # user preference
    "showTaskManagerDetails", # user preference
    "disableMouseAcceleration", # user preference
    "enableDarkMode", # user preference
    "mkdirGodMode", # user preference
    "unPinDocsAndPicsFromQuickAccess", # user preference
    "disableHomeGroup", # user preference
    "uninstallWMP", # user preference
    "uninstallOneDrive", # user preference
    "hideOneDrive", # user preference
    "soundCommsAttenuation", # user preference
    "disableSharedExperiences", # user preference
    "disableWifiSense", # unsure
    "disableWindowsDefenderSampleSubmission", # unsure
    "removePrinters" # unsure
)
$regularUserAutomated = @(
    # run relaxed pre-defined user preference steps
    "endUserDeleteApps",
    "restoreOldPhotoViewer",
    "disableAeroShake",
    "uninstallOptionalApps",
    "taskbarCombineWhenFull",
    "taskbarShowTrayIcons",
#    "taskbarShowSearchIcon",
    "taskbarShowTaskView",
    "taskbarHidePeopleIcon",
    "taskbarHideInkWorkspace",
    "taskbarMMSteps",
    "disableBingWebSearch",
    "disableGameMode-Bar-DVR",
#    "disableTipsTricksAndWelcomeExp", # user preference (not implemented)
    "disableLockScreenTips",
    "explorerSetControlPanelLargeIcons",
    "explorerShowFileTransferDetails",
    "showTaskManagerDetails",
    "disableMouseAcceleration",
    "soundCommsAttenuation",
    "disableWifiSense", # unsure
    "disableWindowsDefenderSampleSubmission", # unsure
    "removePrinters" # unsure
)
$userPrompted = @(
    # Future improvement - need a way to show prompts to the user for all of these functions, but only if prompts are selected
    # let the user choose what they want changed for each of the user preference steps [enable/disable/leave default (and state what default is)]
)
$allUsersFirstRunAutomated = @(
    # automatically do steps relevant for a new image 
    "unpinTaskbarAndStartMenuTiles", # usually first run - automated
    "remainingStepsToText"
)
$allUsersFirstRunPrompted = @(
    # let the user choose what they want changed for each of the user preference steps that are only relevant for a new image 
#    "setWindowsColor",
    "renameComputer", # usually first run - user preference prompt
    "pinStartMenuItemsAndInstallSoftware", # always run - prompt - prompt if you want to install software and pin apps to the start menu
    "setDefaultPrograms"
)
#--------------------------------------------------------------------------------------
#Configuration phase-------------------------------------------------------------------  
#   Uninstall windows 10 apps
    Function powerUserDeleteApps{
        Write-Host "Nuking out all Windows 10 apps except Calculator" -ForegroundColor Green -BackgroundColor Black
        Get-AppxPackage -AllUsers | Where-Object {$_.name -notlike "*WindowsCalculator*"} | Remove-AppxPackage -ErrorAction SilentlyContinue
    }    
    Function endUserDeleteApps { 
        Write-Host "Nuking out all Windows 10 apps except Calculator and Windows Store" -ForegroundColor Green -BackgroundColor Black
        Get-AppxPackage -AllUsers | Where-Object {$_.name -notlike "*WindowsCalculator*"} | Where-Object {$_.name -notlike "*Store*"} | Remove-AppxPackage -ErrorAction SilentlyContinue
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
#   Disable Telemetry - Future improvement (need to ensure windows updates doesn't break from this)
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
        #Not sure if these break windows updates so commenting them out right now
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
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton"
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
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse
    
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
    Function disableSharedExperiences {
        Write-Host "Disabling shared experiences" -ForegroundColor Green -BackgroundColor Black
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")){
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableCdp" -Type DWord -Value 0
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
    Function setWindowsColor {
        if ($global:isAustin -eq $true) {
            Write-Host "Set a color scheme" -ForegroundColor Yellow -BackgroundColor Black
            Start-Process ms-settings:personalization-colors
        }
    }
    Function configureNightLight {
        $nightLightState = $false
        $changeNightLight = $false
        do {
            $nightLight = Read-Host -Prompt "Set Windows to reduce blue light [3400k color] at night [9:30pm-8:00am]? [y]/[n]?"
            if (($nightLight -eq "y") -or ($nightLight -eq "Y") -or ($nightLight -eq "1")) {
                $nightLightState = $true
                $changeNightLight = $true
            }
            elseif (($nightLight -eq "n") -or ($nightLight -eq "N") -or ($nightLight -eq "0")) {
                $nightLightState = $true
                $changeNightLight = $false
            }
            else {
                $nightLightState = $false
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($nightLightState -eq $false)

        if ($changeNightLight -eq $true) {
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
            $global:skipFlux = $true
        }
        else {
            Write-Host "Night light not set" -ForegroundColor Yellow -BackgroundColor Black
            $global:skipFlux = $false
        }
    }
    Function uninstallIE {
        $ie11State = $false
        do {
            $ie11UserInput = Read-Host -Prompt "Uninstall Internet Exploder 11? [y]/[n] | (Microsoft Edge will not be affected)"
            if (($ie11UserInput -eq "y") -or ($ie11UserInput -eq "Y") -or ($ie11UserInput -eq "1")) {
                $ie11State = $true
                Write-Host "Uninstalling IE11..." -ForegroundColor Green -BackgroundColor Black
                Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart
                Write-Host "Removing IE11 from win10 settings..." -ForegroundColor Green -BackgroundColor Black
                Get-WindowsCapability -online | ? {$_.Name -like '*InternetExplorer*'} | Remove-WindowsCapability -online
            }
            elseif (($ie11UserInput -eq "n") -or ($ie11UserInput -eq "N") -or ($ie11UserInput -eq "0")) {
                $ie11State = $true
                Write-Host "Skipping this step..." -ForegroundColor Yellow -BackgroundColor Black
            }
            else {
                $ie11State = $false
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($ie11State -eq $false)
    }
#   Manual Steps--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #   Sound options ------------ (ctrl pan)
    Function configureSoundOptions {
        $soundState = $false
        do {
            $soundUserInput = Read-Host -Prompt "Manual setp: Configure sound device settings? [y]/[n]"
            if (($soundUserInput -eq "y") -or ($soundUserInput -eq "Y") -or ($soundUserInput -eq "1")) {
                $soundState = $true
                control.exe /name Microsoft.AudioDevicesAndSoundThemes
                Write-Host "(1)Disable all enhancements (mic and speakers) | (2)Set mic level to 100 and boost to 0dB)" -ForegroundColor Yellow -BackgroundColor Black
            }
            elseif (($soundUserInput -eq "n") -or ($soundUserInput -eq "N") -or ($soundUserInput -eq "0")) {
                $soundState = $true
                Write-Host "Skipping this step..." -ForegroundColor Yellow -BackgroundColor Black
            }
            else {
                $soundState = $false
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($soundState -eq $false)
    }
    Function bluetoothManualSteps {
        $bluetoothState = $false
        do {
            $bluetoothStateUserInput = Read-Host -Prompt "Manual setp: Toggle bluetooth radio? [y]/[n]"
            if (($bluetoothStateUserInput -eq "y") -or ($bluetoothStateUserInput -eq "Y") -or ($bluetoothStateUserInput -eq "1")) {
                $bluetoothState = $true
                Write-Host "Disable bluetooth for battery life and security" -ForegroundColor Yellow -BackgroundColor Black
                Start-Process ms-settings:bluetooth
            }
            elseif (($bluetoothStateUserInput -eq "n") -or ($bluetoothStateUserInput -eq "N") -or ($bluetoothStateUserInput -eq "0")) {
                $bluetoothState = $true
                Write-Host "Skipping this step..." -ForegroundColor Yellow -BackgroundColor Black
            }
            else {
                $bluetoothState = $false
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($bluetoothState -eq $false)
    }
    Function disableFocusAssistNotifications {
    $focusAssistState = $false
    do {
        $focusAssistUserInput = Read-Host -Prompt "Manual setp: Configure focus assist notifications? [y]/[n]"
        if (($focusAssistUserInput -eq "y") -or ($focusAssistUserInput -eq "Y") -or ($focusAssistUserInput -eq "1")) {
            $focusAssistState = $true
            Write-Host "Configure focus assist for display duplicating & gaming - uncheck 'show a notification in action center...'" -ForegroundColor Yellow -BackgroundColor Black
            Start-Process ms-settings:quiethours
            #Start-Process ms-settings:quietmomentsgame
            #Start-Process ms-settings:quietmomentspresentation
            }
            elseif (($focusAssistUserInput -eq "n") -or ($focusAssistUserInput -eq "N") -or ($focusAssistUserInput -eq "0")) {
                $focusAssistState = $true
                Write-Host "Skipping this step..." -ForegroundColor Yellow -BackgroundColor Black
            }
            else {
                $focusAssistState = $false
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($focusAssistState -eq $false)
    }
    #   Pin items back into the start menu
    Function pinStartMenuItemsAndInstallSoftware {
        #Download software here
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "Select a web browser to download/save: [0]Microsoft Edge | [1]Google Chrome | [2]Mozilla FireFox"
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
                Write-Host "Select a web browser to download/save: [0]Microsoft Edge | [1]Google Chrome | [2]Mozilla FireFox" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        if ($chrome -eq $true) {
            if ($global:isAustin -eq $false) {
                $ManualChromeBrowser = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BADC0E3FC-2367-A334-848C-BA35C7C10739%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-stable-statsdef_1%26brand%3DCHBD%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe"
            }
            else {
                $ManualChromeBrowser = "https://www.google.com/chrome/browser/desktop/index.html"
            }
            if (!(Test-Path "C:\Users\$env:username\Downloads\*Chrome*") -and !(Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")) {
                Write-Host "Launching Google Chrome Download" -ForegroundColor Green -BackgroundColor Black
                #$browserPath = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
                #Start-Process $browserPath -ArgumentList $ManualChromeBrowser
                Start-Process microsoft-edge:$ManualChromeBrowser
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
                $chromeInstallCheck = $true
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
               #Start-Process $browserPath -ArgumentList $ManualFireFoxBrowser
               Start-Process microsoft-edge:$ManualFireFoxBrowser
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
                $firefoxInstallCheck = $true
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
        #Write-Host "Waiting for $browserSelection to finish installation before continuing..." -ForegroundColor Yellow -BackgroundColor Black
        while (!(Test-Path $browserPath) -and ($ie -eq $false)) {
            Start-Sleep -s 1 
        }
        if (($chrome -eq $true) -and (Test-Path $browserPath)) {
            while (!(Get-Process *chrome*) -and ($chromeInstallCheck -ne $true)) {
                Start-Sleep -s 1
            }
            Get-Process *chrome* | Stop-Process
            #Remove-Item -Path "C:\Users\$env:username\Downloads\*Chrome*"
            Remove-Item -Path "C:\Users\$env:username\Desktop\*Edge*"
        }
        elseif (($firefox -eq $true) -and (Test-Path $browserPath)) {
            while (!(Get-Process *firefox*) -and ($firefoxInstallCheck -ne $true)) {
                Start-Sleep -s 1
            }
            Get-Process *firefox* | Stop-Process
            #Remove-Item -Path "C:\Users\$env:username\Downloads\*Firefox*"
            Remove-Item -Path "C:\Users\$env:username\Desktop\*Edge*"
        }
        elseif ($ie -eq $true) {
            Write-Host "Using Microsoft Edge" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "We didn't delete a browser download or uninstall IE..." -ForegroundColor Green -BackgroundColor Black
        }
#########Start the download selection:#################################################################################
        #WinDirStat
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[21] Utilities: Do you wish to download WinDirStat? [y]/[n] | (Disk usage analyzer)"
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
            $SoftwareType = Read-Host -Prompt "[20] Utilities: Do you wish to download 7-Zip? [y]/[n] | (File & folder archiver)"
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
            $SoftwareType = Read-Host -Prompt "[19] Utilities: Do you wish to download IMG Burn? [y]/[n] | (Optical disc burning & IMG/ISO creation program)"
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
        #Rufus
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[18] Utilities: Do you wish to download Rufus? [y]/[n] | (Bootable flash drive ISO tool)"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $rufus = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $rufus = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Sublime Text [14b]
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[17b] Utilities: Do you wish to download Sublime Text? [y]/[n] | (Text and source code editor)"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $sublimetext = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $sublimetext = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Notepad++ [14a]
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[17a] Utilities: Do you wish to download Notepad++? [y]/[n] | (Text and source code editor)"
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
        #HWMonitor
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[16] Utilities: Do you wish to download HWMonitor? [y]/[n] | (PC sensor monitoring program)"
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
		#VLC
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[15] Multimedia: Do you wish to download VLC Media Player? [y]/[n] | (Open source media player)"
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
            $SoftwareType = Read-Host -Prompt "[14] Multimedia: Do you wish to download Spotify? [y]/[n] | (Music streaming platform)"
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
        #Skype
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[13] Communication Do you wish to download Skype? [y]/[n] | (Video and voice calling program)"
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
        #Discord
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[12] Communication: Do you wish to download Discord? [y]/[n] | (Voice program for gaming)"
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
            $SoftwareType = Read-Host -Prompt "[11] Gaming: Do you wish to download Steam? [y]/[n] | (Gaming platform)"
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
            $SoftwareType = Read-Host -Prompt "[10] Gaming: Do you wish to download Origin? [y]/[n] | (Gaming platform)"
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
            $SoftwareType = Read-Host -Prompt "[9] Gaming: Do you wish to download Battle.net? [y]/[n] | (Gaming platform)"
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
        #GoG Galaxy
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[8] Gaming: Do you wish to download GoG Galaxy? [y]/[n] | (Gaming platform)"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $goggalaxy = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $goggalaxy = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Uplay
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[7] Gaming: Do you wish to download Uplay? [y]/[n] | (Gaming platform)"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $uplay = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $uplay = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #Epic Games Launcher
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[6] Gaming: Do you wish to download the Epic Games Launcher? [y]/[n] | (Gaming platform)"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $epicgameslauncher = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $epicgameslauncher = $false
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
            $SoftwareType = Read-Host -Prompt "[5] Utilities: Do you wish to download MSI Afterburner? [y]/[n] | (Graphics card overclocking & monitoring program)"
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
        #Dropbox - additionally GoogleDrive [4b]
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[4b] Utilities: Do you wish to download Dropbox? [y]/[n] | (Cloud storage program)"
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
        #Google Drive [4a]
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[4a] Utilities: Do you wish to download Google Drive? [y]/[n] | (Cloud storage program)"
            if (($SoftwareType -eq "y") -or ($SoftwareType -eq "Y") -or ($SoftwareType -eq "1")) {
                $doneUser = $true
                $googledrive = $true
            }
            elseif (($SoftwareType -eq "n") -or ($SoftwareType -eq "N") -or ($SoftwareType -eq "0")){
                $doneUser = $true
                $googledrive = $false
            }
            else {
                $doneUser = $false
                Write-Host "Please input 'y' or 'n' for selection" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($doneUser -eq $false)
        #f.lux
        if ($global:skipFlux -eq $true) {
            Write-Host "[3] Utilities: Skipping f.lux automatically since windows night light has been configured" -ForegroundColor Green -BackgroundColor Black
            $flux = $false
        }
        else {
            # Prompt to download f.lux
            do {
                $doneUser = $false
                $SoftwareType = Read-Host -Prompt "[3] Utilities: Do you wish to download f.lux? [y]/[n] | (Reduces blue light at night)"
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
        }
        #Putty
        do {
            $doneUser = $false
            $SoftwareType = Read-Host -Prompt "[2] Utilities: Do you wish to download Putty? [y]/[n] | (Open source terminal emulator for SSH, SCP, Telnet, rlogin)"
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
            $SoftwareType = Read-Host -Prompt "[1] Utilities: Do you wish to download TeamViewer? [y]/[n] | (Remote computer control program)"
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
        #Download Statements
        if ($goggalaxy -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*setup_galaxy*")) {
            Write-Host "Software Chosen: GoG Galaxy" -ForegroundColor Green -BackgroundColor Black
            $GogURL = (Invoke-WebRequest -Uri "https://www.gog.com/galaxy" -UseBasicParsing).Links.Href -like "*https://content-system.gog.com/open_link/download?path=/open/galaxy/client/setup_galaxy_*.exe*"
            $GogURL0,$GogURL1,$GogURL2 = $GogURL.split("`r`n")
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$GogURL0
            }
            else {
                Start-Process $browserPath -ArgumentList $GogURL0 -WindowStyle Minimized
            }
        }
        if ($uplay -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*UplayInstaller*")) {
            #Install parameters: 
            #Download Uplay
            #http://ubi.li/4vxt9
            #Manage your account
            #http://ubi.li/y99x6
            $UplayURL = (Invoke-WebRequest -Uri "https://uplay.ubi.com/" -UseBasicParsing).Links.Href -like "*ubi.li/4vxt9*"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$UplayURL
            }
            else {
                Start-Process $browserPath -ArgumentList $UplayURL -WindowStyle Minimized
            }
        }
        if ($epicgameslauncher -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*EpicInstaller*")) {
            #Install parameters: http://www.jrsoftware.org/ishelp/
            $EGLURL = (Invoke-WebRequest -Uri "https://www.epicgames.com/site/en-US/home" -UseBasicParsing).Links.Href -like "*EpicGamesLauncherInstaller.msi*"
            $EGLURL0,$EGLURL1 = $EGLURL.split("`r`n")
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$EGLURL0
            }
            else {
                Start-Process $browserPath -ArgumentList $EGLURL0 -WindowStyle Minimized
            }
        }
        if ($rufus -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*rufus*")) {
            $RufusURL = (Invoke-WebRequest -Uri "https://rufus.akeo.ie/" -UseBasicParsing).Links.Href -notlike "*downloads/rufus-*p.exe*" -like "*downloads/rufus-*.exe*"
            $RufusDownload = "https://rufus.akeo.ie$RufusURL"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$RufusDownload
            }
            else {
                Start-Process $browserPath -ArgumentList $RufusDownload -WindowStyle Minimized
            }
        }
        if ($sublimetext -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*Sublime*")) {
            $SublimeURL = (Invoke-WebRequest -Uri "https://www.sublimetext.com/3" -UseBasicParsing).Links.Href -like "*download.sublimetext.com/Sublime*Text*x64*Setup.exe*"
            $SublimeURLConverted = $SublimeURL.Replace(' ','%20')
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$SublimeURLConverted
            }
            else {
                Start-Process $browserPath -ArgumentList $SublimeURLConverted -WindowStyle Minimized
            }
        }
        if ($googledrive -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*installbackupandsync*")) {
            # GoogleDrive - prompt for this and/or dropbox?
            if ($global:isAustin -eq $false) {
                $GDriveURL = "https://dl.google.com/tag/s/appguid%3D%7B3C122445-AECE-4309-90B7-85A6AEF42AC0%7D%26iid%3D%7B9648D435-67BA-D2A7-54D2-1E0B5656BF03%7D%26ap%3Duploader%26appname%3DBackup%2520and%2520Sync%26needsadmin%3Dtrue/drive/installbackupandsync.exe"
            }
            else {
                $GDriveURL = "https://www.google.com/drive/download/"
            }
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$GDriveURL
            }
            else {
                Start-Process $browserPath -ArgumentList $GDriveURL -WindowStyle Minimized
            }
        }
        if ($vlc -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*vlc*")) {
            Write-Host "Software Chosen: VLC Media Player" -ForegroundColor Green -BackgroundColor Black
            $vlcURL = (Invoke-WebRequest -Uri "https://www.videolan.org/vlc/" -UseBasicParsing).Links.Href -like "*get.videolan.org/vlc*win64*"
            $ManualVLC = "https:$vlcURL"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$ManualVLC
            }
            else {
                Start-Process $browserPath -ArgumentList $ManualVLC -WindowStyle Minimized
            }
        }
        if ($imgburn -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*imgburn*")){
            Write-Host "Software Chosen: IMG Burn" -ForegroundColor Green -BackgroundColor Black
            $ManualImgBurn = (Invoke-WebRequest -Uri "http://www.imgburn.com/index.php?act=download" -UseBasicParsing).Links.Href -like "*download.imgburn.com/SetupImgBurn*"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$ManualImgBurn
            }
            else {
                Start-Process $browserPath -ArgumentList $ManualImgBurn -WindowStyle Minimized
            }
        }
        if ($notepad -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*npp*")){
            Write-Host "Software Chosen: Notepad++" -ForegroundColor Green -BackgroundColor Black
            $nppURL = (Invoke-WebRequest -Uri "https://notepad-plus-plus.org/download/" -UseBasicParsing).Links.Href -like "*repository*npp*Installer.exe*"
            $ManualNotepadPP = "https://notepad-plus-plus.org$nppURL"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$ManualNotepadPP
            }
            else {
                Start-Process $browserPath -ArgumentList $ManualNotepadPP -WindowStyle Minimized
            }
        }
        if ($windirstat -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*windirstat*")){
            Write-Host "Software Chosen: WinDirStat" -ForegroundColor Green -BackgroundColor Black
            $winDirStatURL = (Invoke-WebRequest -Uri "https://www.fosshub.com/WinDirStat.html" -UseBasicParsing).Links.Href -like "*/WinDirStat.html/windirstat*_setup.exe*"
            $ManualWinDirStatFossHub = "https://www.fosshub.com$winDirStatURL"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$ManualWinDirStatFossHub
            }
            else {
                Start-Process $browserPath -ArgumentList $ManualWinDirStatFossHub -WindowStyle Minimized
            }
        }
        if ($7zip -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*7z*")){
            Write-Host "Software Chosen: 7-Zip" -ForegroundColor Green -BackgroundColor Black
            #for .exe
            $7zipURL = (Invoke-WebRequest -Uri "https://www.7-zip.org" -UseBasicParsing).Links.Href -like "a/7z*-x64.exe"
            #for .msi
            #$7zipURL = (Invoke-WebRequest -Uri "https://www.7-zip.org" -UseBasicParsing).Links.Href -like "a/7z*-x64.msi"
            $Manual7zip = "https://www.7-zip.org/$7zipURL"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$Manual7zip
            }
            else {
                Start-Process $browserPath -ArgumentList $Manual7zip -WindowStyle Minimized
            }
        }
        if ($hwmonitor -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*hwmonitor*")){
            Write-Host "Software Chosen: HWMonitor" -ForegroundColor Green -BackgroundColor Black
            $HWMonitorURL0 = (Invoke-WebRequest -Uri "https://www.cpuid.com/softwares/hwmonitor.html" -UseBasicParsing).Links.Href -like "/downloads/hwmonitor/hwmonitor_*.exe"
            $HWMonitorURL01,$HWMonitorURL02 = $HWMonitorURL0.split("`r`n")
            $HWMonitorInvoke0 = "https://www.cpuid.com$HWMonitorURL01"

            $HWMonitorURL1 = (Invoke-WebRequest -Uri "$HWMonitorInvoke0" -UseBasicParsing).Links.Href -like "http://download.cpuid.com/hwmonitor/hwmonitor_*.exe"
            #$HWMonitorInvoke1 = "$HWMonitorURL1"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$HWMonitorURL1
            }
            else {
                Start-Process $browserPath -ArgumentList $HWMonitorURL1 -WindowStyle Minimized
            }
        }
        #Write-Host "Note: Some downloads are manual, others are automatic" -ForegroundColor Yellow -BackgroundColor Black
        if ($spotify -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*spotify*")){
            Write-Host "Software Chosen: Spotify" -ForegroundColor Green -BackgroundColor Black
            $SpotifyURL = "https://download.scdn.co/SpotifySetup.exe"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$SpotifyURL
            }
            else {
                Start-Process $browserPath -ArgumentList $SpotifyURL -WindowStyle Minimized
            }
        }
        if ($discord -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*discord*")){
            Write-Host "Software Chosen: Discord" -ForegroundColor Green -BackgroundColor Black
            $DiscordURL = "https://discordapp.com/api/download?platform=win"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$DiscordURL
            }
            else {
                Start-Process $browserPath -ArgumentList $DiscordURL -WindowStyle Minimized
            }
        }
        if ($steam -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*steam*")){
            Write-Host "Software Chosen: Steam" -ForegroundColor Green -BackgroundColor Black
            $SteamURL = "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$SteamURL
            }
            else {
                Start-Process $browserPath -ArgumentList $SteamURL -WindowStyle Minimized
            }
        }
        if ($origin -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*origin*")){
            Write-Host "Software Chosen: Origin" -ForegroundColor Green -BackgroundColor Black
            $OriginURL = "https://www.dm.origin.com/download"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$OriginURL
            }
            else {
                Start-Process $browserPath -ArgumentList $OriginURL -WindowStyle Minimized
            }
        }
        if ($battlenet -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*battle.net*")){
            Write-Host "Software Chosen: Battle.net" -ForegroundColor Green -BackgroundColor Black
            $BattlenetURL = "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$BattlenetURL
            }
            else {
                Start-Process $browserPath -ArgumentList $BattlenetURL -WindowStyle Minimized
            }
        }
        if ($skype -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*skype*")){
            Write-Host "Software Chosen: Skype" -ForegroundColor Green -BackgroundColor Black
            $SkypeURL = "https://go.skype.com/windows.desktop.download"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$SkypeURL
            }
            else {
                Start-Process $browserPath -ArgumentList $SkypeURL -WindowStyle Minimized
            }
        }
        if ($msiafterburner -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*msiafterburner*")){
            Write-Host "Software Chosen: MSI Afterburner" -ForegroundColor Green -BackgroundColor Black
            $MSIAfterburnerURL = "http://download.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$MSIAfterburnerURL
            }
            else {
                Start-Process $browserPath -ArgumentList $MSIAfterburnerURL -WindowStyle Minimized
            }
        }
        if ($putty -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*putty*") -and !(Test-Path "C:\Program Files (x86)\Putty\putty.exe")){
            Write-Host "Software Chosen: Putty" -ForegroundColor Green -BackgroundColor Black
            $PuttyURL = "https://the.earth.li/~sgtatham/putty/latest/x86/putty.exe"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$PuttyURL
            }
            else {
                Start-Process $browserPath -ArgumentList $PuttyURL -WindowStyle Minimized
            }
        }
        if ($teamviewer -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*teamviewer*")){
            Write-Host "Software Chosen: TeamViewer" -ForegroundColor Green -BackgroundColor Black
            $TeamViewerURL = "https://download.teamviewer.com/download/TeamViewer_Setup_en.exe"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$TeamViewerURL
            }
            else {
                Start-Process $browserPath -ArgumentList $TeamViewerURL -WindowStyle Minimized
            }
        }
        if ($flux -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*flux*")) {
            Write-Host "Software Chosen: f.lux" -ForegroundColor Green -BackgroundColor Black
            $FluxURL = "https://justgetflux.com/dlwin.html"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$FluxURL
            }
            else {
                Start-Process $browserPath -ArgumentList $FluxURL -WindowStyle Minimized
            }
        }
        if ($dropbox -eq $true -and !(Test-Path "C:\Users\$env:username\Downloads\*dropbox*")){
            Write-Host "Software Chosen: Dropbox" -ForegroundColor Green -BackgroundColor Black
            $DropboxURL = "https://www.dropbox.com/downloading"
            if ($ie -eq $true) {
                Start-Process microsoft-edge:$DropboxURL
            }
            else {
                Start-Process $browserPath -ArgumentList $DropboxURL -WindowStyle Minimized
            }
        }
        <#
        $rufus
        $sublimetext
        $goggalaxy
        $uplay
        $epicgameslauncher
        $googledrive

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
        Write-Host "Waiting for rufus to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($rufus -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*rufus*"))) {
            Start-Sleep -s 1 
        }
        if (($rufus -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*rufus*")) {
            Write-Host "rufus successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($rufus -eq $false) {
            Write-Host "rufus not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "rufus not downloaded" -ForegroundColor Red -BackgroundColor Black
            Start-Process $browserPath -ArgumentList $RufusDownload
        }
        Write-Host "Waiting for Sublime Text to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($sublimetext -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*Sublime*"))) {
            Start-Sleep -s 1 
        }
        if (($sublimetext -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*Sublime*")) {
            Write-Host "Sublime Text successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($sublimetext -eq $false) {
            Write-Host "Sublime Text not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Sublime Text not downloaded" -ForegroundColor Red -BackgroundColor Black
            Start-Process $browserPath -ArgumentList $SublimeURLConverted
        }
        Write-Host "Waiting for GoG Galaxy to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($goggalaxy -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*setup_galaxy*"))) {
            Start-Sleep -s 1 
        }
        if (($goggalaxy -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*setup_galaxy*")) {
            Write-Host "GoG Galaxy successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($goggalaxy -eq $false) {
            Write-Host "GoG Galaxy not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "GoG Galaxy not downloaded" -ForegroundColor Red -BackgroundColor Black
            Start-Process $browserPath -ArgumentList $GogURL0
        }
        Write-Host "Waiting for Uplay to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($uplay -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*UplayInstaller*"))) {
            Start-Sleep -s 1 
        }
        if (($uplay -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*UplayInstaller*")) {
            Write-Host "Uplay successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($uplay -eq $false) {
            Write-Host "Uplay not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Uplay not downloaded" -ForegroundColor Red -BackgroundColor Black
            Start-Process $browserPath -ArgumentList $UplayURL
        }
        Write-Host "Waiting for the Epic Games Launcher to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($epicgameslauncher -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*EpicInstaller*"))) {
            Start-Sleep -s 1 
        }
        if (($epicgameslauncher -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*EpicInstaller*")) {
            Write-Host "the Epic Games Launcher successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($epicgameslauncher -eq $false) {
            Write-Host "the Epic Games Launcher not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "the Epic Games Launcher not downloaded" -ForegroundColor Red -BackgroundColor Black
            Start-Process $browserPath -ArgumentList $EGLURL0
        }
        Write-Host "Waiting for Google Drive to finish downloading..." -ForegroundColor Yellow -BackgroundColor Black
        while (($googledrive -eq $true) -and (!(Test-Path "C:\Users\$env:username\Downloads\*installbackupandsync*"))) {
            Start-Sleep -s 1 
        }
        if (($googledrive -eq $true) -and (Test-Path "C:\Users\$env:username\Downloads\*installbackupandsync*")) {
            Write-Host "Google Drive successfully downloaded" -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($googledrive -eq $false) {
            Write-Host "Google Drive not selected" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "Google Drive not downloaded" -ForegroundColor Red -BackgroundColor Black
            Start-Process $browserPath -ArgumentList $GDriveURL
        }
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
            Start-Process $browserPath -ArgumentList $FluxURL
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
            Start-Process $browserPath -ArgumentList $SpotifyURL
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
            Start-Process $browserPath -ArgumentList $DiscordURL
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
            Start-Process $browserPath -ArgumentList $SteamURL
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
            Start-Process $browserPath -ArgumentList $OriginURL
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
            Start-Process $browserPath -ArgumentList $BattlenetURL
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
            Start-Process $browserPath -ArgumentList $SkypeURL
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
            Start-Process $browserPath -ArgumentList $DropboxURL
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
            Start-Process $browserPath -ArgumentList $MSIAfterburnerURL
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
            Start-Process $browserPath -ArgumentList $PuttyURL
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
            Start-Process $browserPath -ArgumentList $TeamViewerURL
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
            Start-Process $browserPath -ArgumentList $ManualWinDirStatFossHub
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
            Start-Process $browserPath -ArgumentList $Manual7zip
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
            Start-Process $browserPath -ArgumentList $ManualImgBurn
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
            Start-Process $browserPath -ArgumentList $ManualVLC
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
            Start-Process $browserPath -ArgumentList $ManualNotepadPP
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
            Start-Process $browserPath -ArgumentList $HWMonitorURL
        }
        # Exit out of browser after all of manual software has been downloaded and installs start.
        Start-Sleep -s 1
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
        #Invoke-Item "C:\Users\$env:username\Downloads"
        
        # Disable SmartScreen Filter temporarily 
        #Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Type String -Value "Off"
        #Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0
        $env:SEE_MASK_NOZONECHECKS = 1
        $countForeground = 0
        while ($putty -and !(Test-Path "C:\Program Files (x86)\Putty\putty.exe")) {
            Write-Host "Waiting for Putty to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            if(!(Test-Path "C:\Program Files (x86)\Putty")) {
                New-Item -ItemType Directory -Path "C:\Program Files (x86)\Putty" -Force
            }
            Move-Item -Path "C:\Users\$env:username\Downloads\putty.exe" -Destination "C:\Program Files (x86)\Putty"
            $TargetFile = "C:\Program Files (x86)\Putty\putty.exe"
            $ShortcutFile = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Putty.lnk"
            $WScriptShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
            $Shortcut.TargetPath = $TargetFile
            $Shortcut.IconLocation = "C:\Program Files (x86)\Putty\putty.exe, 0"
            $Shortcut.Save()
            Start-Sleep -s 1
        }
        $rufusInfo = Get-ItemProperty -Path "C:\Users\$env:username\Downloads\*rufus*"
        $rufusName = $rufusInfo.Name
        while ($rufus -and !(Test-Path "C:\Program Files (x86)\Rufus\$rufusName")) {
            Write-Host "Waiting for Rufus to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            if(!(Test-Path "C:\Program Files (x86)\Rufus\$rufusName")) {
                New-Item -ItemType Directory -Path "C:\Program Files (x86)\Rufus" -Force
            }
            Move-Item -Path "C:\Users\$env:username\Downloads\$rufusName" -Destination "C:\Program Files (x86)\Rufus"
            $TargetFile = "C:\Program Files (x86)\Rufus\$rufusName"
            $ShortcutFile = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Rufus.lnk"
            $WScriptShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
            $Shortcut.TargetPath = $TargetFile
            $Shortcut.IconLocation = "C:\Program Files (x86)\Rufus\$rufusName, 0"
            $Shortcut.Save()
            Start-Sleep -s 1
        }
        if ($epicgameslauncher -and !(Test-Path "C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*EpicInstaller*" -ArgumentList "/qn"
            Write-Host "Waiting for Epic Games Launcher to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        # -or (Get-Process *msiexec*)
        while ($epicgameslauncher -and (!(Test-Path "C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"))) {
            Start-Sleep -s 1
            if ((Get-Process *msiexec*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *DropboxInstaller*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($sublimetext -and !(Test-Path "C:\Program Files\Sublime Text 3\sublime_text.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*Sublime*" -ArgumentList '/VERYSILENT /TASKS="contextentry"'
            Write-Host "Waiting for Sublime Text to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($sublimetext -and (!(Test-Path "C:\Program Files\Sublime Text 3\sublime_text.exe") -or (Get-Process *sublime*))) {
            Start-Sleep -s 1
            if ((Get-Process *sublime*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *DropboxInstaller*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($goggalaxy -and !(Test-Path "C:\Program Files (x86)\GOG Galaxy\GalaxyClient.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*setup_galaxy*" -ArgumentList "/VERYSILENT"
            Write-Host "Waiting for GoG Galaxy to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($goggalaxy -and (!(Test-Path "C:\Program Files (x86)\GOG Galaxy\GalaxyClient.exe") -or (Get-Process *setup_galaxy*))) {
            Start-Sleep -s 1
            if ((Get-Process *setup_galaxy*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *DropboxInstaller*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($googledrive -and !(Test-Path "C:\Program Files\Google\Drive\googledrivesync.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*installbackupandsync*"
            Write-Host "Waiting for Google Drive to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($googledrive -and (!(Test-Path "C:\Program Files\Google\Drive\googledrivesync.exe") -or (Get-Process *installbackupandsync*))) {
            Start-Sleep -s 1
            if ((Get-Process *installbackupandsync*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *DropboxInstaller*).MainWindowTitle)
                $countForeground ++
            }
            if (Get-Process *googledrivesync*) {
                Get-Process *installbackupandsync* | Stop-Process
                Get-Process *GoogleUpdate* | Stop-Process -Force
            }
        }
        if ($googledrive) {
            while (!(Get-Process *googledrivesync*)) {
                Start-Sleep -s 1
            }
            if (Get-Process *googledrivesync*) {
                #exit out of google sync first launch program here
                Get-Process *googledrivesync* | Stop-Process
            }
        }
        #Note: Dropbox installer seems to crash and relaunch file explorer.exe
        if ($dropbox -and !(Test-Path "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*dropbox*" -ArgumentList "/NOLAUNCH"
            Write-Host "Waiting for Dropbox to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($dropbox -and (!(Test-Path "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe") -or (Get-Process *DropboxInstaller*))) {
            Start-Sleep -s 1
            if ((Get-Process *DropboxInstaller*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *DropboxInstaller*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($7zip -and !(Test-Path "C:\Program Files\7-Zip\7zFM.exe")) {
            #Invoke-Item "C:\Users\$env:username\Downloads\*7z*"
            #for .exe
            #Start-Process -FilePath "C:\Users\$env:username\Downloads\*7z*" -ArgumentList "/S","/D='C:\Program Files\7-Zip'"
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*7z*" -ArgumentList "/S"
            #for .msi
            #Start-Process -FilePath "C:\Users\$env:username\Downloads\*7z*" -ArgumentList "/qn","INSTALLDIR='C:\Program Files\7-Zip'"
            Write-Host "Waiting for 7-Zip to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }                                                                           #7z1805-x64
        while ($7zip -and (!(Test-Path "C:\Program Files\7-Zip\7zFM.exe") -or (Get-Process *7z*))) {
            Start-Sleep -s 1
            if ((Get-Process *7z*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *7z*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($notepad -and !(Test-Path "C:\Program Files (x86)\Notepad++\notepad++.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*npp*" -ArgumentList "/S"
            Write-Host "Waiting for Notepad++ to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }                                                                                               #npp.7.5.8.Installer
        while ($notepad -and (!(Test-Path "C:\Program Files (x86)\Notepad++\notepad++.exe") -or (Get-Process *npp*Installer*))) {
            Start-Sleep -s 1
            if ((Get-Process *npp*Installer*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *npp*Installer*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($windirstat -and !(Test-Path "C:\Program Files (x86)\WinDirStat\windirstat.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*windirstat*" -ArgumentList "/S"
            Write-Host "Waiting for WinDirStat to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }                                                                                                    #windirstat1_1_2_setup
        while ($windirstat -and (!(Test-Path "C:\Program Files (x86)\WinDirStat\windirstat.exe") -or (Get-Process *windirstat*setup*))) {
            Start-Sleep -s 1
            if ((Get-Process *windirstat*setup*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *windirstat*setup*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($steam -and !(Test-Path "C:\Program Files (x86)\Steam\Steam.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*steam*" -ArgumentList "/S"
            Write-Host "Waiting for Steam to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($steam -and (!(Test-Path "C:\Program Files (x86)\Steam\Steam.exe") -or (Get-Process *SteamSetup*))) {
            Start-Sleep -s 1
            if ((Get-Process *SteamSetup*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *SteamSetup*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($flux -and !(Test-Path "C:\Users\$env:username\AppData\Local\FluxSoftware\Flux\flux.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*flux*" -ArgumentList "/S"
            Write-Host "Waiting for f.lux to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($flux -and (!(Test-Path "C:\Users\$env:username\AppData\Local\FluxSoftware\Flux\flux.exe") -or (Get-Process *flux-setup*))) {
            Start-Sleep -s 1
            if ((Get-Process *flux-setup*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *flux-setup*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($flux) {
            while (!(Get-Process *flux*)) {
                Start-Sleep -s 1
            }
            if (Get-Process *flux*) {
                #exit out of flux program here
                Get-Process *flux* | Stop-Process
            }
        }
        if ($skype -and !(Test-Path "C:\Program Files (x86)\Microsoft\Skype for Desktop\Skype.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*skype*" -ArgumentList "/VERYSILENT","/SP-","/NOCANCEL","/NORESTART","/SUPPRESSMSGBOXES","/NOLAUNCH"
            Write-Host "Waiting for Skype to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }                                                                                   #Skype-8.29.0.50 #Skype-8.29.0.50.tmp
        while ($skype -and (!(Test-Path "C:\Program Files (x86)\Microsoft\Skype for Desktop\Skype.exe") -or (Get-Process *Skype-*))) {
            Start-Sleep -s 1
            if ((Get-Process *Skype-*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *Skype-*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($skype) {
            while (!(Get-Process *skype*)) {
                Start-Sleep -s 1
            }
            if (Get-Process *skype*) {
                #exit out of skype program here
                Get-Process *skype* | Stop-Process
            }
        }
        if ($teamviewer -and !(Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*teamviewer*" -ArgumentList "/S"
            Write-Host "Waiting for TeamViewer to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($teamviewer -and (!(Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe") -or (Get-Process *TeamViewer_Setup*))) {
            Start-Sleep -s 1
            if ((Get-Process *TeamViewer_Setup*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *TeamViewer_Setup*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($imgburn -and !(Test-Path "C:\Program Files (x86)\ImgBurn\ImgBurn.exe")) {
            #Invoke-Item "C:\Users\$env:username\Downloads\*imgburn*"
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*imgburn*" -ArgumentList "/S","/NOCANDY"
            Write-Host "Waiting for ImgBurn to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }                                                                                         #SetupImgBurn_2.5.8.0
        while ($imgburn -and (!(Test-Path "C:\Program Files (x86)\ImgBurn\ImgBurn.exe") -or (Get-Process *SetupImgBurn*))) {
            Start-Sleep -s 1
            if ((Get-Process *SetupImgBurn*) -and ($countForeground -lt 2)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *SetupImgBurn*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($uplay -and !(Test-Path "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\Uplay.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*UplayInstaller*"
            Write-Host "Waiting for Uplay to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($uplay -and (!(Test-Path "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\Uplay.exe") -or (Get-Process *UplayInstaller*))) {
            Start-Sleep -s 1
            if ((Get-Process *UplayInstaller*) -and ($countForeground -lt 1)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *UplayInstaller*).MainWindowTitle)
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
                while (!(Get-Process *UplayInstaller*)) {
                Start-Sleep -m 100
                }
                # get the applications with the specified title
                $p = Get-Process *UplayInstaller*
                # get the window handle of the first application
                $h = $p[0].MainWindowHandle
                # set the application to foreground
                [void] [StartActivateProgramClass]::SetForegroundWindow($h)
                # send the keys sequence #more info on MSDN at http://msdn.microsoft.com/en-us/library/System.Windows.Forms.SendKeys(v=vs.100).aspx
                <#
                Key  | Code
                -----------
                SHIFT  +
                CTRL   ^
                ALT    %
                #>
                Start-Sleep -m 100
                [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep -m 100
                [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep -m 100
                [System.Windows.Forms.SendKeys]::SendWait("%{i}")
                while (!(Test-Path "C:\Users\PowerShellGuy\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Ubisoft\Uplay\Uplay.lnk")) {
                    Start-Sleep -m 100
                }
                Start-Sleep -m 100
                [System.Windows.Forms.SendKeys]::SendWait("%{n}")
                Start-Sleep -m 100
                [System.Windows.Forms.SendKeys]::SendWait("%{f}") 
                #*upc* && *uplaywebcore* 
                while (!(Get-Process *upc*)) {
                    Start-Sleep -s 1
                }
                if (Get-Process *upc*) {
                    #exit out of the program here
                    Get-Process *upc* | Stop-Process
                }
                $countForeground ++
            }
        }
        if ($hwmonitor -and !(Test-Path "C:\Program Files\CPUID\HWMonitor\HWMonitor.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*hwmonitor*"
            Write-Host "Waiting for HWMonitor to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }                                                                                                   #hwmonitor_1.35
        while ($hwmonitor -and (!(Test-Path "C:\Program Files\CPUID\HWMonitor\HWMonitor.exe") -or (Get-Process *hwmonitor_*))) {
            Start-Sleep -s 1
            if ((Get-Process *hwmonitor_*) -and ($countForeground -lt 1)) {
                #(New-Object -ComObject WScript.Shell).AppActivate((Get-Process *hwmonitor_*).MainWindowTitle)
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
                while (!(Get-Process *hwmonitor_*)) {
                Start-Sleep -m 100
                }
                # get the applications with the specified title
                $p = Get-Process *hwmonitor_*
                # get the window handle of the first application
                $h = $p[0].MainWindowHandle
                # set the application to foreground
                [void] [StartActivateProgramClass]::SetForegroundWindow($h)
                # send the keys sequence #more info on MSDN at http://msdn.microsoft.com/en-us/library/System.Windows.Forms.SendKeys(v=vs.100).aspx
                <#
                Key  | Code
                -----------
                SHIFT  +
                CTRL   ^
                ALT    %
                #>
                Start-Sleep -m 100
                [System.Windows.Forms.SendKeys]::SendWait("%{n}")
                Start-Sleep -m 100
                [System.Windows.Forms.SendKeys]::SendWait("%{n}")
                Start-Sleep -m 100
                [System.Windows.Forms.SendKeys]::SendWait("%{n}")
                Start-Sleep -m 100
                [System.Windows.Forms.SendKeys]::SendWait("%{i}")
                #Future improvement - this is contingent on the finish menu showing up within 1 second. this isn't always the case and will need another check method to wait before sending the 'f' key to finsh the installer
                <#
                while (!(Test-Path "C:\Program Files\CPUID\HWMonitor")) {
                    Start-Sleep -m 100
                }
                #>
                Start-Sleep -m 1000
                [System.Windows.Forms.SendKeys]::SendWait("%{f}") 
                while (!(Get-Process *notepad*)) {
                    Start-Sleep -s 1
                }
                if (Get-Process *notepad*) {
                    #exit out of notepad program here
                    Get-Process *notepad* | Stop-Process
                }
                $countForeground ++
            }
        }
        if ($spotify -and !(Test-Path "C:\Users\$env:username\AppData\Roaming\Spotify\Spotify.exe")) {
            # Needs to install spotify as a the current user (in non-admin mode) | The script is currently running as admin
            $spotifyEXE = Get-ChildItem "C:\Users\$env:username\Downloads\*Spotify*"
            $newPS = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
            # Specify what to run, you need the full path after explorer.exe
            $env:SEE_MASK_NOZONECHECKS = 1
            $newPS.Arguments = "explorer.exe $spotifyEXE"
            [System.Diagnostics.Process]::Start($newPS)
            Write-Host "Waiting for Spotify to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # This works but requires a password prompt 
            #Start-Process "C:\Users\$env:username\Downloads\*spotify*" -Credential "$env:username"
            # -ArgumentList "/Silent"
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($spotify -and (!(Test-Path "C:\Users\$env:username\AppData\Roaming\Spotify\Spotify.exe") -or (Get-Process *SpotifySetup*))) {
            Start-Sleep -s 1
            if ((Get-Process *SpotifySetup*) -and ($countForeground -lt 2)) {
                (New-Object -ComObject WScript.Shell).AppActivate((Get-Process *SpotifySetup*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($spotify) {
            while (!(Get-Process *spotify*)) {
                Start-Sleep -s 1
            }
            if (Get-Process *spotify*) {
                #exit out of spotify program here
                Get-Process *spotify* | Stop-Process
            }
        }
        if ($discord -and !(Test-Path "C:\Users\$env:username\AppData\Local\Discord\Update.exe")) {
            $env:SEE_MASK_NOZONECHECKS = 1
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*discord*"
            Write-Host "Waiting for Discord to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($discord -and (!(Test-Path "C:\Users\$env:username\AppData\Local\Discord\Update.exe") -or (Get-Process *DiscordSetup*))) {
            Start-Sleep -s 1
            if ((Get-Process *DiscordSetup*) -and ($countForeground -lt 2)) {
                #This install is automatic
                (New-Object -ComObject WScript.Shell).AppActivate((Get-Process *DiscordSetup*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($discord) {
            while (!(Get-Process *discord*)) {
                Start-Sleep -s 1
            }
            if (Get-Process *discord*) {
                #exit out of discord program here
                Get-Process *discord* | Stop-Process
            }
        }
        if ($origin -and !(Test-Path "C:\Program Files (x86)\Origin\Origin.exe")) {
            if ($global:isAustin -eq $true) {
                Write-Host "Uncheck 'Share hardware specifications' && 'Run Origin when Windows starts'" -ForegroundColor Red -BackgroundColor Black
                Start-Process -FilePath "C:\Users\$env:username\Downloads\*origin*"
            }
            else {
                Start-Process -FilePath "C:\Users\$env:username\Downloads\*origin*" -ArgumentList "/silent"
            }

            Write-Host "Waiting for Origin to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }                                                                                             #OriginThinSetupInternal
        while ($origin -and (!(Test-Path "C:\Program Files (x86)\Origin\Origin.exe") -or (Get-Process *OriginThinSetupInternal*))) {
            Start-Sleep -s 1
            if ((Get-Process *OriginThinSetupInternal*) -and ($countForeground -lt 2)) {
                if ($global:isAustin -eq $true) {
                    (New-Object -ComObject WScript.Shell).AppActivate((Get-Process *OriginThinSetupInternal*).MainWindowTitle)
                }
                $countForeground ++
            }
        }
        if ($origin) {
            while (!(Get-Process *origin*)) {
                Start-Sleep -s 1
            }
            if (Get-Process *origin*) {
                #exit out of origin program here
                Get-Process *origin* | Stop-Process
            }
        }
        if ($vlc -and !(Test-Path "C:\Program Files\VideoLAN\VLC\vlc.exe")) {
            if ($global:isAustin -eq $true) {
                Write-Host "Uncheck Firefox & IE Web Plugins" -ForegroundColor Red -BackgroundColor Black
                Start-Process -FilePath "C:\Users\$env:username\Downloads\*vlc*"
            }
            else {
                Start-Process -FilePath "C:\Users\$env:username\Downloads\*vlc*" -ArgumentList "/L=1033","/S"
            }
            Write-Host "Waiting for VLC Media Player to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }                                                                                    #vlc-3.0.4-win32
        while ($vlc -and (!(Test-Path "C:\Program Files\VideoLAN\VLC\vlc.exe") -or (Get-Process *vlc-*))) {
            Start-Sleep -s 1
            if ((Get-Process *vlc-*) -and ($countForeground -lt 2)) {
                if ($global:isAustin -eq $true) {
                    (New-Object -ComObject WScript.Shell).AppActivate((Get-Process *vlc-*).MainWindowTitle)
                }
                $countForeground ++
            }
        }
        #Expand-Archive seems to bust and re-launch windows file explorer.exe?
        if ($msiafterburner -and !(Test-Path "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe")) {
            Expand-Archive -Path "C:\Users\$env:username\Downloads\*msiafterburner*" -DestinationPath "C:\Users\$env:username\Downloads" -Force
            #Invoke-Item "C:\Users\$env:username\Downloads\*\*msiafterburner*"
            if ($global:isAustin -eq $true) {
                Write-Host "Uncheck Rivatuner option" -ForegroundColor Red -BackgroundColor Black
                Start-Process -FilePath "C:\Users\$env:username\Downloads\*\*msiafterburner*"
            }
            else {
                Start-Process -FilePath "C:\Users\$env:username\Downloads\*\*msiafterburner*" -ArgumentList "/S"
            }
            Write-Host "Waiting for MSI Afterburner to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }                                                                                                                      #MSIAfterburnerSetup450
        while ($msiafterburner -and (!(Test-Path "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe") -or (Get-Process *MSIAfterburnerSetup*))) {
            Start-Sleep -s 1
            if ((Get-Process *MSIAfterburnerSetup*) -and ($countForeground -lt 2)) {
                if ($global:isAustin -eq $true) {
                    (New-Object -ComObject WScript.Shell).AppActivate((Get-Process *MSIAfterburnerSetup*).MainWindowTitle)
                }
                $countForeground ++
            }
        }
        if ($global:isAustin -eq $false) {
            #Uninstall rivatuner
            while ($msiafterburner -and (!(Test-Path "C:\Program Files (x86)\RivaTuner Statistics Server\Uninstall.exe") -or ((Get-Process *dxwebsetup*) -or (Get-Process *dxwsetup*) -or (Get-Process *RTSSSetup*) -or (Get-Process *MSIAfterburnerSetup*)))) {
                Start-Sleep -s 1
            }
            if ($msiafterburner -and ((Test-Path "C:\Program Files (x86)\RivaTuner Statistics Server\Uninstall.exe") -and (!(Get-Process *dxwebsetup*) -and !(Get-Process *dxwsetup*) -and !(Get-Process *RTSSSetup*) -and !(Get-Process *MSIAfterburnerSetup*)))) {
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
                #RivaTuner uninstaller process
                while (!(Get-Process *Au_*)) {
                    Start-Sleep -s 1
                }
                # get the applications with the specified title
                $p = Get-Process *Au_*
                # get the window handle of the first application
                $h = $p[0].MainWindowHandle
                # set the application to foreground
                [void] [StartActivateProgramClass]::SetForegroundWindow($h)
                # send the keys sequence #more info on MSDN at http://msdn.microsoft.com/en-us/library/System.Windows.Forms.SendKeys(v=vs.100).aspx
                [System.Windows.Forms.SendKeys]::SendWait("n")
            }
        }
        #Manual install processes 
        #No way to silently install or feed key presses to the installer window
        if ($battlenet -and !(Test-Path "C:\Program Files (x86)\Battle.net\Battle.net Launcher.exe")) {
            Start-Process -FilePath "C:\Users\$env:username\Downloads\*battle.net*"
            Write-Host "Waiting for Battle.net to finish installing..." -ForegroundColor Yellow -BackgroundColor Black
            # Bring the window to the foreground based on name
            $countForeground = 0
        }
        while ($battlenet -and (!(Test-Path "C:\Program Files (x86)\Battle.net\Battle.net Launcher.exe") -or (Get-Process *Battle.net-Setup*))) {
            Start-Sleep -s 1
            if ((Get-Process *Battle.net-Setup*) -and ($countForeground -lt 2)) {
                (New-Object -ComObject WScript.Shell).AppActivate((Get-Process *Battle.net-Setup*).MainWindowTitle)
                $countForeground ++
            }
        }
        if ($battlenet) {
            while (!(Get-Process *battle.net*)) {
                Start-Sleep -s 1
            }
            if (Get-Process *battle.net*) {
                #exit out of battle.net program here
                Get-Process *battle.net* | Stop-Process
            }
        }
        # Re-Enable SmartScreen Filter
        #Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Type String -Value "RequireAdmin"
        #Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation"
        # Exit out of the users Downloads folder(s)
        #Write-Host "Closing out of the Downloads folder"
        ############Get-Process explorer | Stop-Process
        #$explorerShell = New-Object -ComObject Shell.Application
        ############$explorerShell.Windows() | Format-Table Name, LocationName, LocationURL
        #$downloadsWindow = $explorerShell.Windows() | Where-Object { $_.LocationURL -like "$(([uri]"C:\Users\$env:username\Downloads").AbsoluteUri)*" }
        #$downloadsWindow | ForEach-Object { $_.Quit() }

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
        # Pin Applications    
        if ($chrome -eq $true){
            while (Get-Process *ChromeSetup*) {
                Write-Host "Waiting for Google Chrome to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Google Chrome" -pin -start
        }
        Start-Sleep -m 100
        if ($firefox -eq $true){
            while (Get-Process *Firefox Installer*) {
                Write-Host "Waiting for Mozilla Firefox to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Firefox" -pin -start
        }
        Start-Sleep -m 100
        if (!($chrome) -and !($firefox)) {
            Pin-App "Microsoft Edge" -pin -start
            Start-Sleep -m 100
        }
        if ($spotify -eq $true){
            while (Get-Process *SpotifySetup*) {
                Write-Host "Waiting for Spotify to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Spotify" -pin -start
        }
        Start-Sleep -m 100
        if ($skype -eq $true){
                       #Skype-8.29.0.50
                       #Skype-8.29.0.50.tmp
            while (Get-Process *Skype-*) {
                Write-Host "Waiting for Skype to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Skype" -pin -start
        }
        Start-Sleep -m 100
        if ($steam -eq $true){
            while (Get-Process *SteamSetup*) {
                Write-Host "Waiting for Steam to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Steam" -pin -start
        }
        Start-Sleep -m 100
        if ($origin -eq $true){
                     #OriginThinSetupInternal
            while (Get-Process *Origin*Setup*) {
                Write-Host "Waiting for Origin to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Origin" -pin -start
        }
        Start-Sleep -m 100
        if ($battlenet -eq $true){
            while (Get-Process *Battle.net-Setup*) {
                Write-Host "Waiting for Battle.net to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Battle.net" -pin -start
        }
        Start-Sleep -m 100
        if ($goggalaxy -eq $true){
            while (Get-Process *setup_galaxy*) {
                Write-Host "Waiting for GoG Galaxy to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "GOG Galaxy" -pin -start
        }
        Start-Sleep -m 100
        #skip the installer check otherwise it might wait forever on an unrelated *msiexec.exe* process
        if ($epicgameslauncher -eq $true){
            <#
            while (Get-Process *????*) {
                Write-Host "Waiting for Epic Games Launcher to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            #>
            Pin-App "Epic Games Launcher" -pin -start
        }
        Start-Sleep -m 100
        if ($uplay -eq $true){
            while (Get-Process *UplayInstaller*) {
                Write-Host "Waiting for Uplay to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Uplay" -pin -start
        }
        Start-Sleep -m 100
        if ($discord -eq $true){
            while (Get-Process *DiscordSetup*) {
                Write-Host "Waiting for Discord to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
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
                          #npp.7.5.8.Installer
            while (Get-Process *npp*Installer*) {
                Write-Host "Waiting for NotePad++ to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Notepad++" -pin -start
        }
        Start-Sleep -m 100
        if ($sublimetext -eq $true){
            while (Get-Process *sublime*) {
                Write-Host "Waiting for Sublime Text to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Sublime Text 3" -pin -start
        }
        Start-Sleep -m 100
        if ($windirstat -eq $true){
                           #windirstat1_1_2_setup
            while (Get-Process *windirstat*setup*) {
                Write-Host "Waiting for WinDirStat to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "WinDirStat" -pin -start
        }
        Start-Sleep -m 100
        if ($imgburn  -eq $true){
                         #SetupImgBurn_2.5.8.0
            while (Get-Process *SetupImgBurn*) {
                Write-Host "Waiting for ImgBurn to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "ImgBurn" -pin -start
        }
        Start-Sleep -m 100
        if ($rufus -eq $true) {
            Write-Host "Attempting to pin Rufus to the start menu" -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
            Pin-App "Rufus" -pin -start
        }
        Start-Sleep -m 100
        if ($putty -eq $true) {
            Write-Host "Attempting to pin Putty to the start menu" -ForegroundColor Yellow -BackgroundColor Black
            Start-Sleep -s 1
            Pin-App "Putty" -pin -start
        }
        Start-Sleep -m 100
        Pin-App "Remote Desktop Connection" -pin -start
        Start-Sleep -m 100
        if ($teamviewer -eq $true){
            while (Get-Process *TeamViewer_Setup*) {
                Write-Host "Waiting for TeamViewer to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            #This will error out for future versions of teamviewer e.g. 14,15,16 etc...
            Pin-App "TeamViewer 13" -pin -start
        }
        Start-Sleep -m 100
        if ($msiafterburner -eq $true){
                             #MSIAfterburnerSetup450
            while (Get-Process *MSIAfterburnerSetup*) {
                Write-Host "Waiting for MSI Afterburner to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "MSI Afterburner" -pin -start
        }
        Start-Sleep -m 100
        if ($hwmonitor -eq $true){
                            #hwmonitor_1.35
            while (Get-Process *hwmonitor_*) {
                Write-Host "Waiting for HWMonitor to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "HWMonitor" -pin -start
        }
        Start-Sleep -m 100
        #Navigation
        Pin-App "This PC" -pin -start
        Start-Sleep -m 100
        Pin-App "Downloads" -pin -start
        Start-Sleep -m 100
        if ($googledrive -eq $true){
            while (Get-Process *installbackupandsync*) {
                Write-Host "Waiting for Google Drive to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Backup and Sync from Google" -pin -start
        }
        Start-Sleep -m 100
        if ($dropbox -eq $true){
            while (Get-Process *DropboxInstaller*) {
                Write-Host "Waiting for Dropbox to close before attempting to pin it to the start menu"
                Start-Sleep -s 1
            }
            Pin-App "Dropbox" -pin -start
        }
        Start-Sleep -m 100
        Pin-App "Control Panel" -pin -start
        Start-Sleep -m 100
        Pin-App "Recycle Bin" -pin -start
        Start-Sleep -m 100
    }
Function setDefaultPrograms {
    #Set default apps
    Write-Host "Set the default programs..." -ForegroundColor Yellow -BackgroundColor Black
    Start-Process ms-settings:defaultapps
}
###################################
# Remove recycle bin from desktop #
###################################
Function removeRecycleBin {
    #12*4+2 (175) = recycle bin shorcut icon #?
    $downloadsReg = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
    $downloadsLoc = $downloadsReg."{374DE290-123F-4565-9164-39C4925E467B}"
    #create a shortcut
    #43*4+3 (50) = downloads shortcut icon #?
    $TargetFile0 = $downloadsLoc
    $ShortcutFile0 = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Downloads.lnk"
    $WScriptShell0 = New-Object -ComObject WScript.Shell
    $Shortcut0 = $WScriptShell0.CreateShortcut($ShortcutFile0)
    $Shortcut0.TargetPath = $TargetFile0
    $Shortcut0.IconLocation = "C:\Windows\System32\imageres.dll, 175"
    $Shortcut0.Save()

    $TargetFile1 = "shell:RecycleBinFolder"
    $ShortcutFile1 = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Recycle Bin.lnk"
    $WScriptShell1 = New-Object -ComObject WScript.Shell
    $Shortcut1 = $WScriptShell1.CreateShortcut($ShortcutFile1)
    $Shortcut1.TargetPath = $TargetFile1
    $Shortcut1.IconLocation = "C:\Windows\System32\imageres.dll, 50"
    $Shortcut1.Save()

    if ($global:isAustin -eq $true) {
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
    else {
        $recycleBinState = $false
        do {
            $recycleBinUserInput = Read-Host -Prompt "Do you wish to remove the recycle bin from the desktop? [y]/[n]?"
            if (($recycleBinUserInput -eq "y") -or ($recycleBinUserInput -eq "Y") -or ($recycleBinUserInput -eq "1")) {
                $recycleBinState = $true
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
            elseif (($recycleBinUserInput -eq "n") -or ($recycleBinUserInput -eq "N") -or ($recycleBinUserInput -eq "0")) {
                Write-Host "Leaving recycle bin desktop shortcut alone" -ForegroundColor Yellow -BackgroundColor Black
                $recycleBinState = $true
            }
            else {
                $recycleBinState = $false
                Write-Host "Please input 'y' or 'n' to continue" -ForegroundColor Red -BackgroundColor Black
            }
        }
        while ($recycleBinState -eq $false)
    }
}
############################################################
# Output Austin specific final manual steps to a text file # 
############################################################
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

###############################
## Theme and Personalization ##
###############################
Set a color scheme
Set a background
Set a lockscreen picture
Set a user account picture

#############################
## Personal Folder Targets ##
#############################
Change the targets of the following to mass storage drive (if applicable)
Documents, Downloads, Music, Pictures, Videos

#####################################
## Install/Pin Additional Software ##
#####################################
(if applicable)
# Microsoft Office
########################################################################################################################################################################################################
"
    $outString | Out-File -FilePath $outputFile -Width 200
}
Function remainingStepsToTextForAustin {
    $outputFile = "C:\Users\$env:username\Desktop\Remaining Manual Steps.txt"
$outString = 
"
########################################################################################################################################################################################################
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

###############################
## Theme and Personalization ##
###############################
Set a color scheme
Set a background
Set a lockscreen picture
Set a user account picture

#############################
## Personal Folder Targets ##
#############################
Change the targets of the following to mass storage drive (if applicable)
Documents, Downloads, Music, Pictures, Videos

#####################################
## Install/Pin Additional Software ##
#####################################
(if applicable)
# Microsoft Office
# Electrum
# NiceHash
# PSFTP
########################################################################################################################################################################################################
"
    $outString | Out-File -FilePath $outputFile -Width 200
}
###########################
# Start main program here # 
###########################
#######################################
# Call the presets that were selected # 
#######################################
<#
#most to least automated
    $allUsersAutomated
     $powerUserAutomated
     $regularUserAutomated
     $allUsersFirstRunAutomated
     $userPrompted
    $allUsersPrompted
    $allUsersFirstRunPrompted
#>
Function optionOne {
    $global:isAustin = $false
    Write-Host "[1] New install w/ prompts & NO preset | Manual" -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $allUsersFirstRunAutomated | ForEach { Invoke-Expression $_ }
    $userPrompted | ForEach { Invoke-Expression $_ }
    $allUsersPrompted | ForEach { Invoke-Expression $_ }


    $allUsersFirstRunPrompted | ForEach { Invoke-Expression $_ }
}
Function optionTwo {
    $global:isAustin = $false
    Write-Host "[2] New install w/ prompts & aggressive preset | Semi-Auto # My preferred" -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    hideOneDrive
    $allUsersFirstRunAutomated | ForEach { Invoke-Expression $_ }
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
    
    
    $allUsersFirstRunPrompted | ForEach { Invoke-Expression $_ }
}
Function optionThree {
    $global:isAustin = $false
    Write-Host "[3] New install w/ prompts & relaxed preset | Semi-Auto" -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $regularUserAutomated | ForEach { Invoke-Expression $_ }
    $allUsersFirstRunAutomated | ForEach { Invoke-Expression $_ }
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
    
    
    $allUsersFirstRunPrompted | ForEach { Invoke-Expression $_ }
}
Function optionFour {
    $global:isAustin = $false
    Write-Host "[4] New install w/ auto only & aggressive preset | Full Auto " -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    hideOneDrive
    $allUsersFirstRunAutomated | ForEach { Invoke-Expression $_ }
}
Function optionFive {
    $global:isAustin = $false
    Write-Host "[5] New install w/ auto only & relaxed preset | Full Auto # Random user preferred" -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $regularUserAutomated | ForEach { Invoke-Expression $_ }
    $allUsersFirstRunAutomated | ForEach { Invoke-Expression $_ }
}
Function optionSix {
    $global:isAustin = $false
    Write-Host "[6] Re-run w/ prompts & NO presets | Manual" -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $userPrompted | ForEach { Invoke-Expression $_ }
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
}
Function optionSeven {
    $global:isAustin = $false
    Write-Host "[7] Re-run w/ prompts & aggressive preset | Semi-Auto # My preferred" -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    hideOneDrive
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
}
Function optionEight {
    $global:isAustin = $false
    Write-Host "[8] Re-run w/ prompts & relaxed preset | Semi-Auto" -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $regularUserAutomated | ForEach { Invoke-Expression $_ }
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
}
Function optionNine {
    $global:isAustin = $false
    Write-Host "[9] Re-run w/ auto only & aggressive preset | Full Auto" -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    hideOneDrive
}
Function optionTen {
    $global:isAustin = $false
    Write-Host "[0] Re-run w/ auto only & relaxed preset | Full Auto # Random user preferred" -ForegroundColor Green -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $regularUserAutomated | ForEach { Invoke-Expression $_ }
}
Function optionFirstSpecial {
    $global:isAustin = $true
    Write-Host "[f] Welcome back Austin" -ForegroundColor Red -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    hideOneDrive
    $allUsersFirstRunAutomated | ForEach { Invoke-Expression $_ }
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
    
    
    $allUsersFirstRunPrompted | ForEach { Invoke-Expression $_ }
    #Austin specific function calls
    remainingStepsToTextForAustin
}
Function optionRerunSpecial {
    $global:isAustin = $true
    Write-Host "[r] Welcome back Austin" -ForegroundColor Red -BackgroundColor Black
    $allUsersAutomated | ForEach { Invoke-Expression $_ }
    $powerUserAutomated | ForEach { Invoke-Expression $_ }
    # Attempt to hide OneDrive a second time since the first time doesn't stick
    hideOneDrive
    $allUsersPrompted | ForEach { Invoke-Expression $_ }
    #Austin specific function calls
    # insert function calls here
}
####################
# Restart computer # 
####################
Function promptForRestart {
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
}
#################################
# Prompt user to select presets #
#################################
Function selectionMenu {
Write-Host 
"
#############
# First-run #
#############
[1] New install w/ prompts & NO preset           | Manual - [Not finished]
[2] New install w/ prompts & aggressive preset   | Semi-Auto
[3] New install w/ prompts & relaxed preset      | Semi-Auto
[4] New install w/ auto only & aggressive preset | Full Auto - Power user recommended
[5] New install w/ auto only & relaxed preset    | Full Auto - New user recommended
###########
# Re-runs #
###########
[6] Re-run w/ prompts & NO presets          | Manual - [Not finished]
[7] Re-run w/ prompts & aggressive preset   | Semi-Auto
[8] Re-run w/ prompts & relaxed preset      | Semi-Auto
[9] Re-run w/ auto only & aggressive preset | Full Auto - Power user recommended
[0] Re-run w/ auto only & relaxed preset    | Full Auto - New user recommended
"
}
Function promptForSelection {
    $parameterSelection = Read-Host -Prompt "Make a selection [0]-[9]"
    switch ($parameterSelection) {
        1 {$result = optionOne break}
        2 {$result = optionTwo break}
        3 {$result = optionThree break}
        4 {$result = optionFour break}
        5 {$result = optionFive break}
        6 {$result = optionSix break}
        7 {$result = optionSeven break}
        8 {$result = optionEight break}
        9 {$result = optionNine break}
        0 {$result = optionTen break}
        "f" {$result = optionFirstSpecial break}
        "r" {$result = optionRerunSpecial break}
        default {$result = promptForSelection}
    }
    # Call the selected function here
    $result
}
#pre-req variables
$global:skipFlux = $false
$global:isAustin = $false
#function calls
selectionMenu
promptForSelection
promptForRestart
##########################################################################################################################################################
########################
# Improvements needed: #
########################
# OS Configurations:
# New windows 10 changes Oct 2018 - Disable cloud clipboard sync && Disable 3rd party browser install warning
# Set default programs automatically 
# Hide ease of access button on logon screen for power users
#
# Errors:
# Built-in Apps (recently uninstalled/removed) show up on start menu as 'new' - remove them
#
# Script:
# Have a check function at the end, that validates every setting was changed successfully
# Certain functions wait until the end to spit output status which jumbles the manual to-do list at the end
# Automatically determine which to display, first-run or re-run only list selection
############
# Software #
############
#
#######################
# Additional Feedback #
#######################
#
#
##########################################################################################################################################################
########################
# To add new software: #
########################
#Prompt for selection
#Invoke download URL
#Check for download to be finished
#Invoke the installation (silently if possible)
#Wait for installation to finish
#Pin to start-menu
#
##################################
# Additional Prototype Functions #
##################################
<#
#Change targets for Documents, Downloads, Music, Pictures, Videos to the appropriate drive automatically by prompting the user
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
##########################################################################################################################################################
