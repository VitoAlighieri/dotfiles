# POWERSHELL PROFILE

# Init Starship Prompt
Invoke-Expression (&starship init powershell)

# Load PSReadLine (autocomplete, syntax highlight)
Import-Module PSReadLine -ErrorAction SilentlyContinue

# PSReadLine Tab Completion
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# PSReadLine History Substring Search
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# PSReadLine Syntax Highlighting + Prediction
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -Colors @{
    Command          = 'Cyan'
    Parameter        = 'Yellow'
    String           = 'Green'
    Operator         = 'Gray'
    Number           = 'Magenta'
    Variable         = 'White'
    InlinePrediction = 'DarkGray'
}

Set-PSReadLineOption -ShowToolTips

#==================FUNCTIONS & ALIASES==============================#
function lsa {
    param ($file, $n = 10)
    Get-Content $file -Head $n
}
function touch {
    param ($file)
    New-Item -ItemType File -Path $file -Force | Out-Null
}
function head {
    param ($file, $n = 10)
    Get-Content $file -Head $n
}
function tail {
    param ($file, $n = 10)
    Get-Content $file -Tail $n
}
function ssrm {
    Remove-Item -Recurse "$HOME\Pictures\Screenshots\*"
}

Set-Alias -Name cat -Value bat
Set-Alias which Get-Command

#===================================================================#

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
