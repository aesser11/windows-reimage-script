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