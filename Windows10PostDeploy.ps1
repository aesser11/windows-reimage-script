
# prompts -- find new/smaller/maintainable way to user-input prompt with the same functionality

# functions -- add logging/status capture functionality in output.txt

# specific functions needing review
<#
    pinStartMenuItemsAndInstallSoftware - pin all apps except software with NO auto-updaters built in
    remainingStepsToText - only list functions that failed
    remainingStepsToTextForAustin - combine with other text doc into one
    option*Run* - simplify or better adjust : endUser, 'austin personal', 'austin other (power user, but no specific tweaks that would break something like htpc install)',?
#>

# $global: variable declarations - revisit how this is implemented

# start function list selection state - reposition and update same as "# prompts" section


###########################
# Windows10PostDeploy.ps1 #
###########################
# Relaunch the script with administrator privileges and bypass execution-policy if it isn't already
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    exit
}

# Lists
###################
# Windows 10 Apps #
###################
$powerUserWin10AppWhiteList = @(
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
    "7zip",
    "hwinfo",
    "msiafterburner",
    "powertoys",
    "windirstat",
    "rufus",
    "putty",
    "github-desktop",
    "sublimetext3",
    "teamviewer",
    "vlc",
    "googlechrome",
    "spotify",
    "discord",
    "steam",
    "goggalaxy",
    "origin",
    "uplay",
    "epicgameslauncher"

    # install later - write to text file - pin y/n?
    #"imgburn"

    # manual installs
    # "battle.net" - run function for myself, write to output.txt if other
    # "electrum" - myself only write w/ url to output.txt
    # "geforce experience" - myself only write to output.txt
)

#############
# Functions #
#############
$firstRunFunctions = @(

)

$allUsersFunctions = @(

)


$powerUserFunctions = @(

)




