# POWERSHELL PROFILE

# Configs compartidas en ~/.config (iguales en Windows y Linux).
# En Windows redirigimos aqui las herramientas con estas variables, para que
# lean la MISMA config que en Linux. (Tambien se fijan de forma persistente
# en el script .chezmoiscripts/run_onchange_after_30-windows-env.ps1.tmpl.)
$XdgConfig = Join-Path $HOME '.config'
$env:XDG_CONFIG_HOME     = $XdgConfig                       # nvim, fd, ...
$env:BAT_CONFIG_DIR      = Join-Path $XdgConfig 'bat'       # bat
$env:RIPGREP_CONFIG_PATH = Join-Path $XdgConfig 'ripgrep\config'  # ripgrep

# VS Code: VSCODE_APPDATA la fija el script run_after_35-vscode-userdata
# DESPUES de copiar sus datos a ~/.config/Code. Aqui no se fuerza: solo se
# refleja en la sesion si ya existe (asi nunca se usa la ruta nueva antes
# de migrar, y las terminales nuevas la ven aunque la ventana ya estuviera abierta).
$vscodeAppData = [Environment]::GetEnvironmentVariable('VSCODE_APPDATA', 'User')
if ($vscodeAppData) { $env:VSCODE_APPDATA = $vscodeAppData }

# Init Starship Prompt (solo si esta instalado)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Define Global Custom Paths
$Env:LESSHISTFILE= "-" # This disable the _lesshst file generation

# Load PSReadLine (autocomplete, syntax highlight)
Import-Module PSReadLine -ErrorAction SilentlyContinue
$lsd = Get-Command lsd -ErrorAction SilentlyContinue

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

if ($lsd) {
    # Quitar alias ls de PowerShell si existe (ls -> Get-ChildItem)
    if (Test-Path Alias:ls) {
        Remove-Item Alias:ls -Force
    }

    # ls: pasa todos los argumentos directamente a lsd
    function ls {
        lsd @args
    }

    # ll: listado largo
    function ll {
        lsd -l @args
    }

    # la: todo + ocultos
    function la {
        lsd -la @args
    }

    # Alias adicionales comodín
    Set-Alias l ls
    Set-Alias lla la
}

# Aliases que dependen de herramientas externas: solo se definen si la
# herramienta esta instalada, para no romper el comando nativo si falta.
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat
}
if (Get-Command neohtop-cli -ErrorAction SilentlyContinue) {
    Set-Alias -Name htop -Value neohtop-cli
}
if (Get-Command fd -ErrorAction SilentlyContinue) {
    Set-Alias -Name find -Value fd
}
if (Get-Command rg -ErrorAction SilentlyContinue) {
    Set-Alias -Name grep -Value rg
}
if (Get-Command tldr -ErrorAction SilentlyContinue) {
    Set-Alias -Name man -Value tldr
}

Set-Alias which Get-Command

#===================================================================#

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
