# dotfiles

Dotfiles de **Vito Alighieri** gestionados con [chezmoi](https://chezmoi.io).
Multiplataforma: **una sola configuración compartida para todas las máquinas**
(Windows y Linux). Solo PowerShell y Flow Launcher son exclusivos de Windows.
VS Code se instala solo en Windows, pero sus settings son comunes a todos.

## Idea principal

Todo lo común vive en **`~/.config`** (en el repo, bajo `dot_config/`). En Linux
es la ruta nativa; en Windows redirigimos las herramientas a esa misma carpeta
con variables de entorno, así que **el mismo archivo de config sirve en todos los
SO** y, si lo cambias en uno y lo subes, se aplica igual en el resto.

## Qué gestiona

| Programa     | Config en el repo                       | Se aplica en              | SO        |
| ------------ | --------------------------------------- | ------------------------- | --------- |
| Starship     | `dot_config/starship.toml`              | `~/.config/starship.toml` | Todos     |
| Neovim       | `dot_config/nvim/`                      | `~/.config/nvim/`         | Todos     |
| bat          | `dot_config/bat/`                       | `~/.config/bat/`          | Todos     |
| lsd          | `dot_config/lsd/`                       | `~/.config/lsd/`          | Todos     |
| ripgrep      | `dot_config/ripgrep/config`             | `~/.config/ripgrep/config`| Todos     |
| VS Code      | `dot_config/Code/User/settings.json`    | `~/.config/Code/User/`    | Todos (\*)|
| PowerShell 7 | `dot_config/powershell/profile.ps1`     | `Documents\PowerShell\`   | Windows   |
| Flow Launcher| `AppData/Roaming/FlowLauncher/Settings/`| `%APPDATA%\FlowLauncher\` | Windows   |

(\*) VS Code solo se **instala** en Windows; en Linux, si lo instalas tú, usa
los mismos settings y extensiones. Ver [VS Code](#vs-code).

### Cómo se comparten en Windows

`~/.config` no es la ruta por defecto de algunas apps en Windows, así que se
fijan estas variables de entorno de usuario (de forma persistente, mediante
`.chezmoiscripts/run_onchange_after_30-windows-env.ps1.tmpl`, y también en el
profile):

| Variable             | Valor               | Para            |
| -------------------- | ------------------- | --------------- |
| `XDG_CONFIG_HOME`    | `~/.config`         | Neovim, fd, …   |
| `BAT_CONFIG_DIR`     | `~/.config/bat`     | bat             |
| `RIPGREP_CONFIG_PATH`| `~/.config/ripgrep/config` | ripgrep  |

- **lsd** y **starship** ya leen de `~/.config` en Windows de forma nativa, no
  necesitan variable.
- **VS Code** no usa variable: su carpeta `%APPDATA%\Code\User` se convierte en
  un enlace (*junction*) a `~/.config/Code/User`, así funciona igual se abra
  desde donde se abra (ver [VS Code](#vs-code)).
- En **Linux** todo es nativo. Solo ripgrep necesita una línea en tu shell:
  `export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"`.

> Tras el primer `apply` en Windows, lo más fiable es **cerrar sesión y volver
> a entrar**: los programas que ya estaban abiertos (terminales, Flow
> Launcher…) siguen con las variables de entorno antiguas.

## Instalación en un equipo nuevo

1. Instala chezmoi:

   ```powershell
   winget install --id twpayne.chezmoi      # Windows: luego abre una terminal NUEVA
   ```
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"   # Linux
   ```

2. Inicializa y aplica en un solo paso:

   ```sh
   chezmoi init --apply VitoAlighieri
   ```

Al aplicar (en Windows), chezmoi: **preinstala los programas** con winget,
copia las configs a `~/.config`, fija las variables de entorno, prepara VS Code
y despliega el `profile.ps1` en la ruta real de PowerShell 7. Los scripts se
ejecutan con Windows PowerShell 5.1 y `-ExecutionPolicy Bypass` (configurado en
`.chezmoi.toml.tmpl`), así que funcionan aunque el Windows sea recién instalado.

### Actualizar un equipo que ya usa estos dotfiles

```sh
chezmoi git pull      # trae los cambios del repo
chezmoi init          # solo si cambió .chezmoi.toml.tmpl (chezmoi te avisa)
chezmoi diff          # revisa qué va a cambiar
chezmoi apply
```

(`chezmoi update` hace `git pull` + `apply` de una vez.)

## Sincronizar cambios entre máquinas

chezmoi es **unidireccional** (repo → equipo). Para llevar un cambio de una
máquina a otra:

1. En la máquina donde tocaste la config (vale cualquier SO):
   ```sh
   chezmoi re-add        # mete tus cambios en vivo de vuelta al repo
   chezmoi cd            # entra al repo
   git add -A && git commit -m "..." && git push
   ```
2. En las demás máquinas:
   ```sh
   chezmoi update        # hace git pull + apply
   ```

Esto vale para todo lo compartido (bat, lsd, nvim, ripgrep, starship, VS Code)
y también para Flow Launcher. VS Code y Flow Launcher escriben sus propios
ajustes, y `apply` impone la versión del repo, así que acuérdate de hacer
`re-add` cuando cambies algo desde su interfaz (`chezmoi diff` te enseña qué
ha cambiado).

## Preinstalación automática (winget)

La lista de programas está en **`.chezmoidata/packages.yaml`**. En cada
`chezmoi apply`, por cada programa: si **no** está instalado → `winget install`;
si hay **versión más nueva** → `winget upgrade`. El script se reejecuta al
editar la lista y, además, una vez al día.

Por defecto asegura **Neovim, Starship, lsd, bat, fd, ripgrep, tldr, coreutils
(comandos Unix nativos), Git, PowerShell 7, Flow Launcher, VS Code** y la
**Nerd Font JetBrainsMono**. Hay extras comentados (delta, toolchains de LSP…)
listos para activar.

Para añadir un programa, añade su Id de winget (búscalo con
`winget search <nombre>`) y ejecuta `chezmoi apply`.

## Tema (Catppuccin Macchiato)

El mismo tema en todo, en todas las máquinas:

- **starship, lsd, nvim**: el tema va dentro de su config (compartida), se
  aplica solo.
- **bat**: el tema custom se registra automáticamente con `bat cache --build`
  (script `run_onchange_after_40-bat-cache`), también en máquinas nuevas.
- **Flow Launcher**: el tema `Catppuccin Macchiato.xaml` se despliega en
  `%APPDATA%\FlowLauncher\Themes\` y queda activado en su `Settings.json`.
- **VS Code**: `settings.json` activa *Catppuccin Macchiato* y sus iconos; las
  extensiones del tema se instalan solas (ver [VS Code](#vs-code)).

## VS Code

- **Settings comunes**: `dot_config/Code/User/settings.json` → tema Catppuccin
  Macchiato, JetBrainsMono Nerd Font (editor y terminal) y las mismas
  preferencias de edición que Neovim (tabs de 4 espacios sin autodetección,
  números relativos, `scrolloff=8`, sin espacios finales…).
- **Instalación**: solo en Windows (winget). No lo actualiza winget porque VS
  Code se actualiza solo. En Linux, si tienes VS Code (paquete oficial
  `.deb`/`.rpm`/snap), usa los mismos settings y extensiones; Flatpak, VSCodium
  y WSL leen de otras rutas y no se gestionan.
- **Extensiones**: la lista está en `.chezmoidata/packages.yaml`
  (`vscode.extensions`). Los scripts `run_onchange_after_50-vscode-extensions`
  instalan las que falten y reintentan solas si alguna falla (hay extras
  comentados equivalentes a los LSP de Neovim).

### Cómo se comparte en Windows

El script `run_onchange_before_20-vscode-userdir` convierte
`%APPDATA%\Code\User` en una *junction* (enlace de carpeta, no necesita permisos
de administrador) que apunta a `~/.config/Code/User`. VS Code sigue usando su
ruta de siempre, pero los settings son los compartidos, se abra desde donde se
abra.

**Primera vez en un Windows donde ya usabas VS Code:**

1. **Cierra VS Code** antes del `apply`. Si está abierto el script no hace nada
   y se reintenta en el siguiente `chezmoi apply`.
2. Se **copia** tu carpeta de usuario (atajos, snippets, estado de extensiones,
   sesiones, historial…) a `~/.config/Code/User`. El original se conserva entero
   como copia de seguridad en `%APPDATA%\Code\User.pre-dotfiles-<fecha>`
   (incluido tu `settings.json` anterior). Puedes borrarla cuando compruebes que
   todo va bien.
3. **Settings Sync**: si alguna vez usaste la sincronización de VS Code, el
   script se para y te avisa. Si siguiera activa, subiría los settings
   compartidos a la nube y **borraría tus otros ajustes en todas las máquinas
   sincronizadas**. Desactívala (Ctrl+Shift+P → `Sync: Turn Off`), cierra VS
   Code y confirma con:
   ```powershell
   $env:DOTFILES_VSCODE_MIGRATE='1'; chezmoi apply
   ```
4. Si usas **perfiles** de VS Code, los settings compartidos solo se aplican al
   perfil *Default*.

**Deshacerlo** (con VS Code cerrado): borra el enlace con
`cmd /c rmdir "%APPDATA%\Code\User"` (borra solo el enlace, no los datos) y
renombra la copia `User.pre-dotfiles-<fecha>` a `User`.

### En Linux

La primera vez que chezmoi gestiona `~/.config/Code/User/settings.json` lo
sobrescribe sin preguntar. Por eso, si ya tenías uno, antes se guarda en
`settings.json.pre-dotfiles` (script `run_onchange_before_05-vscode-settings-backup`).

### Atajos y snippets

No se gestionan por defecto (así la migración conserva los tuyos). Para
sincronizarlos también:

```sh
chezmoi add ~/.config/Code/User/keybindings.json ~/.config/Code/User/snippets
```

Ojo: después, el primer `apply` en cada otra máquina sustituirá los atajos y
snippets que tuviera. El resto de `~/.config/Code` (sesiones, cachés, tokens…)
es estado de cada equipo: `.chezmoiignore` impide que acabe en el repo.

## Notas

- **Coreutils**: añade ~75 comandos Unix (`wc`, `cut`, `head`, `sha256sum`…).
  Tus alias (`ls`→lsd, `cat`→bat, `grep`→rg, `find`→fd) y los de PowerShell
  (`cp`, `mv`, `rm`, `pwd`…) tienen prioridad; para forzar la versión coreutils
  llámala con `.exe` (p. ej. `cp.exe`). Requiere PowerShell 7.4+.
- **Nerd Font**: en Windows se instala sola (JetBrainsMono); recuerda
  seleccionarla en los ajustes de tu terminal (VS Code ya la usa). En Linux
  instálala tú, por ejemplo descomprimiendo `JetBrainsMono.zip` de
  [nerd-fonts](https://github.com/ryanoasis/nerd-fonts/releases) en
  `~/.local/share/fonts` y ejecutando `fc-cache -f`.

## Estructura

```
.chezmoi.toml.tmpl    Config de chezmoi
.chezmoiignore.tmpl   Qué NO desplegar (por SO)
.chezmoiremove        Limpieza de rutas antiguas (Windows)
.chezmoidata/         Datos para plantillas (lista de paquetes)
.chezmoiscripts/      Scripts (winget, variables de entorno, profile, bat, VS Code)
dot_config/           -> ~/.config  (común a todos los SO)
AppData/              -> ~/AppData  (solo Windows: Flow Launcher)
```

## Licencia

[MIT](LICENSE)
