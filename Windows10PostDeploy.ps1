###########################
# Windows10PostDeploy.ps1 #
###########################
# bypass execution policy - good

# function and app lists - good

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

# build software list
Function getUserInput {
    foreach ($software in $softwareList) {
        Switch (Read-Host 'Enter One or Two') {
            'One' {Write-Output 'User entered One'}
            'Two' {Write-Output 'User entered Two'}
            default {
                Write-host "Invalid input. Please enter XXXX" -ForegroundColor Yellow
                . getUserInput
            }
        }
    }
}


# Lists
###################
# Windows 10 Apps #
###################
$powerUserWin10AppWhiteList = @(
    "*WindowsCalculator*",
    "*Photos*",
    "*Paint*",
    "*ScreenSketch*"
)
$regularUserWin10AppBlacklist = @(
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

)

#############
# Functions #
#############
$allUsersFirstRunFunctions = @(

)

$allUsersFunctions = @(

)

$regularUserFunctions = @(

)
$powerUserFunctions = @(

)




