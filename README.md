# dotfiles

Dotfiles de **Vito Alighieri** gestionados con [chezmoi](https://chezmoi.io).
Multiplataforma: **una sola configuración compartida para todas las máquinas**
(Windows y Linux). Solo PowerShell y Flow Launcher son exclusivos de Windows.

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
| PowerShell 7 | `dot_config/powershell/profile.ps1`     | `Documents\PowerShell\`   | Windows   |
| Flow Launcher| `AppData/Roaming/FlowLauncher/Settings/`| `%APPDATA%\FlowLauncher\` | Windows   |

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
- En **Linux** todo es nativo. Solo ripgrep necesita una línea en tu shell:
  `export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"`.

> Tras el primer `apply` en Windows, **reinicia la terminal** (y apps como VS
> Code) para que tomen las variables nuevas.

## Instalación en un equipo nuevo

1. Instala chezmoi:

   ```powershell
   winget install --id twpayne.chezmoi      # Windows
   ```
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)"      # Linux
   ```

2. Inicializa y aplica en un solo paso:

   ```sh
   chezmoi init --apply VitoAlighieri
   ```

Al aplicar (en Windows), chezmoi: **preinstala los programas** con winget,
copia las configs a `~/.config`, fija las variables de entorno y despliega el
`profile.ps1` en la ruta real de PowerShell 7.

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

Esto vale para todo lo compartido (bat, lsd, nvim, ripgrep, starship) y también
para Flow Launcher (que se gestiona como archivo normal: `apply` impone la
versión del repo, así que acuérdate de `re-add` cuando cambies sus ajustes).

## Preinstalación automática (winget)

La lista de programas está en **`.chezmoidata/packages.yaml`**. En cada
`chezmoi apply`, por cada programa: si **no** está instalado → `winget install`;
si hay **versión más nueva** → `winget upgrade`. El script se reejecuta al
editar la lista y, además, una vez al día.

Por defecto asegura **Neovim, Starship, lsd, bat, fd, ripgrep, tldr, coreutils
(comandos Unix nativos), Git, PowerShell 7, Flow Launcher** y la **Nerd Font
JetBrainsMono**. Hay extras comentados (delta, toolchains de LSP…) listos para
activar.

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

## Notas

- **Coreutils**: añade ~75 comandos Unix (`wc`, `cut`, `head`, `sha256sum`…).
  Tus alias (`ls`→lsd, `cat`→bat, `grep`→rg, `find`→fd) y los de PowerShell
  (`cp`, `mv`, `rm`, `pwd`…) tienen prioridad; para forzar la versión coreutils
  llámala con `.exe` (p. ej. `cp.exe`). Requiere PowerShell 7.4+.
- **Nerd Font**: recuerda seleccionarla en los ajustes de tu terminal.

## Estructura

```
.chezmoi.toml.tmpl    Config de chezmoi
.chezmoiignore.tmpl   Qué NO desplegar (por SO)
.chezmoiremove        Limpieza de rutas antiguas (Windows)
.chezmoidata/         Datos para plantillas (lista de paquetes)
.chezmoiscripts/      Scripts (winget, variables de entorno, profile)
dot_config/           -> ~/.config  (común a todos los SO)
AppData/              -> ~/AppData  (solo Windows: Flow Launcher)
```

## Licencia

[MIT](LICENSE)
