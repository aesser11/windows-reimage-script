# Windows10PostDeploy-AllUsers.ps1

# this script is for all users


# Lists
###################
# Windows 10 Apps #
###################
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
    # alternative to sublime
    "notepadplusplus",
    "teamviewer",
    "vlc",
    "googlechrome",
    # alternative to chrome
    "firefox",
    "spotify",
    "discord",
    "steam",
    "goggalaxy",
    "origin",
    "uplay",
    "epicgameslauncher"

    # manual installs
    # "battle.net"
)

$firstRunFunctions = @(

)

$allUsersFunctions = @(

)

$regularUserFunctions = @(

)

