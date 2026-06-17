# dotfiles

Dotfiles de **Vito Alighieri** gestionados con [chezmoi](https://chezmoi.io).
Orientados a **Windows + PowerShell 7**.

## Qué gestiona

| Programa      | Config en el repo                          | Se despliega en                         |
| ------------- | ------------------------------------------ | --------------------------------------- |
| PowerShell 7  | `dot_config/powershell/profile.ps1`        | `Documents\PowerShell\...profile.ps1`   |
| Starship      | `dot_config/starship.toml`                 | `~/.config/starship.toml`               |
| Neovim        | `AppData/Local/nvim/`                      | `~/AppData/Local/nvim/`                 |
| bat           | `AppData/Roaming/bat/`                     | `~/AppData/Roaming/bat/`                |
| lsd           | `AppData/Roaming/lsd/`                     | `~/AppData/Roaming/lsd/`                |

## Instalación en un equipo nuevo

1. Instala chezmoi (con winget):

   ```powershell
   winget install --id twpayne.chezmoi
   ```

2. Inicializa y aplica los dotfiles en un solo paso:

   ```powershell
   chezmoi init --apply VitoAlighieri
   ```

   (o usando la URL completa del repo si el atajo no resuelve:
   `chezmoi init --apply https://github.com/VitoAlighieri/dotfiles.git`)

Al aplicar, chezmoi:

1. **Preinstala los programas** (ver abajo) con winget — *antes* de copiar configs.
2. Copia todas las configuraciones a su sitio.
3. Despliega el `profile.ps1` en la ruta real de PowerShell 7.

## Preinstalación automática (winget)

La lista de programas está en **`.chezmoidata/packages.yaml`** y la aplica el
script `.chezmoiscripts/run_onchange_before_10-install-packages.ps1.tmpl`.

En cada `chezmoi apply`, por cada programa de la lista:

- si **no** está instalado → `winget install`
- si está instalado y hay **versión más nueva** → `winget upgrade`

El script se reejecuta automáticamente cuando editas `packages.yaml` y, además,
**una vez al día** para comprobar actualizaciones.

Por defecto asegura: **Neovim, Starship, lsd, bat, Git, PowerShell 7** y la
**Nerd Font JetBrainsMono** (necesaria para que se vean bien los iconos de
starship / lsd / Neovim). En `packages.yaml` hay extras comentados que puedes
activar (ripgrep, fd, delta y los toolchains de los LSP de Neovim).

### Añadir / quitar un programa

Edita `.chezmoidata/packages.yaml` y añade su Id exacto de winget:

```yaml
packages:
  windows:
    winget:
      - id: Microsoft.WindowsTerminal
```

Busca el Id con `winget search <nombre>`. Luego ejecuta `chezmoi apply`.

## Requisitos

- **winget** (App Installer). Viene de serie en Windows 10 (1709+) y 11.
- Una **Nerd Font** activa en tu terminal (el script instala JetBrainsMono;
  recuerda seleccionarla en los ajustes de tu terminal).

## Estructura

```
.chezmoi.toml.tmpl        Config de chezmoi
.chezmoiignore.tmpl       Qué NO desplegar (por SO)
.chezmoidata/             Datos para plantillas (lista de paquetes)
.chezmoiscripts/          Scripts de arranque (winget + profile)
dot_config/               -> ~/.config
AppData/                  -> ~/AppData (Neovim, bat, lsd)
```

## Licencia

[MIT](LICENSE)
