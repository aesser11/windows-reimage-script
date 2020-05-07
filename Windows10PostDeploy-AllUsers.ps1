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
    # non-microsoft as of 1909
    "*Solitaire*",
    "*SkypeApp*",
    "*Minecraft*",
    "*Twitter*",
    "*CandyCrush*",
    "*LinkedIn*",
    "*DisneyMagicKingdoms*",
    "*MarchofEmpires*",
    "*iHeartRadio*",
    "*FarmVille*",
    "*Duolingo*",
    "*CyberLink*",
    "*Facebook*",
    "*Asphalt8Airborne*",
    "*CookingFever*",
    "*Pandora*",
    "*FreeCasino*",
    "*Shazam*",
    "*SlingTV*",
    "*Spotify*",
    "*NYTCrossword*",
    "*TuneInRadio*",
    "*Xing*",
    "*RoyalRevolt2*",
    "*BubbleWitch3Saga*",
    "*PetRescueSaga*",
    "*FarmHeroesSaga*",
    "*Netflix*",
    "*king.com.*",
    "*Sketchable*",
    "*HotSpotShield*",
    "*WhatsApp*",
    "*PicsArt-PhotoStudio*",
    "*EclipseManager*",
    "*PolarrPhotoEditorAcademicEdition*",
    "*Wunderlist*",
    "*AutodeskSketchBook*",
    "*ActiproSoftwareLLC*",
    "*Plex*",
    "*DolbyAccess*",
    "*Drawboard*",
    "*Fitbit*",
    "*Flipboard*",
    "*Keeper*",
    "*PhototasticCollage*",
    "*WinZipUniversal*"
)

#############################
# 3rd Party Apps to Install #
#############################
$applicationsToInstall = @(
    # standard apps ever windows instance should have
    "7zip",#no pin && #append-software
    "windirstat",#no pin
    "hwinfo",
    "notepadplusplus",
    #vlc
    #rufus

    #choice: a,b,none
    "googlechrome",
    "firefox"

)

#################
# Reimage Steps #
#################
$firstRunFunctions1 = @(

)

$finalFirstRunFunctions3 = @(

)

$everyRunFunctions2 = @(

)

$finalEveryRunFunctions4 = @(

)

#############
# Functions #
#############



















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


