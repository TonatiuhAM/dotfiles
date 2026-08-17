# 🐧 Tona's Dotfiles 

<div align="center">
  <img src="https://img.shields.io/badge/OS-EndeavourOS-blueviolet?style=flat-square&logo=arch-linux&logoColor=white" />
  <img src="https://img.shields.io/badge/WM-Hyprland-81c8be?style=flat-square&logo=hyprland&logoColor=white" />
  <img src="https://img.shields.io/badge/Editor-Neovim-57a143?style=flat-square&logo=neovim&logoColor=white" />
  <img src="https://img.shields.io/badge/Shell-ZSH-f15a24?style=flat-square&logo=zsh&logoColor=white" />
</div>


# ✳️ Overview

```text
~/dotfiles -----------------------------------------------------------------------------------
» tona --version

tona-dotfiles v2.4.0 (Keyboard-driven, minimalist ecosystem)
"La simplicidad es la máxima sofisticación."
```

```text

~/dotfiles -----------------------------------------------------------------------------------
» fastfetch --source ascii.txt

⚡ CORE SYSTEMS
├── OS       :: EndeavourOS (Arch Linux)
├── WM       :: Hyprland (Wayland Tiling Compositor)
└── Shell    :: ZSH (Zoxide + FZF + Autosuggestions)

🪐 UI & NOTIFICATIONS
├── Quickshell :: Flexible, QML-based desktop shell component toolkit
├── SwayNC     :: Lightweight, Wayland-native notification daemon
└── Matugen    :: Material You color generation CLI utility

💻 APPLICATIONS
├── Terminal :: Kitty (Fast, GPU-accelerated)
├── Editor   :: Neovim (Custom Lua configuration, Lazy-powered)
├── Multiplex:: tmux (Session management)
├── File Mngr:: Yazi (Blazing fast terminal file manager)
└── Git UI   :: Lazygit (Keyboard-driven git workflow)
```


## 📸 Screenshots


| Desktop | Tiling Manager |
| --- | --- |
| ![Escritorio](assets/escritorio.png)  | ![Tiling Manager](assets/tiling-manager.png)  |
| **App Launcher & Notifications** | **Style Picker** |
| ![Launcher y Noti](assets/launcher-notif.png)  | ![Style Picker](assets/style-picker.png)  |


# ⌨️ Usability

```text
~/dotfiles -----------------------------------------------------------------------------------
» man dotfiles

DOTFILES(1)                     Manual del Usuario                    DOTFILES(1)

NAME
       dotfiles - gestión de configuraciones vía GNU Stow

SYNOPSIS
       stow -d <carpeta-de-paquetes> -t <destino> <paquete> [paquete ...]

DESCRIPTION
       Cada carpeta de primer nivel dentro de linux/ (o macos-personal/) es un
       paquete de Stow independiente, con su propia ruta relativa a $HOME ya
       incluida adentro (linux/hypr/.config/hypr/hyprland.lua -> ~/.config/
       hypr/hyprland.lua). Instala, quita o prueba cada app por separado sin
       arrastrar las demás.

REQUIREMENTS
       stow   sudo pacman -S stow   /   sudo dnf install stow   /   brew install stow

OPTIONS
       -d, --dir=DIR
              Carpeta donde viven los paquetes (linux o macos-personal).

       -t, --target=DIR
              Carpeta destino donde se crean los symlinks (normalmente ~).

       -n, --no, --simulate
              No toca nada, solo imprime qué haría. Úsalo siempre antes de
              aplicar algo nuevo.

       -v, -vv, -vvv
              Verbosidad creciente: qué archivos enlaza o desenlaza.

       -S, --stow
              Instala (crea symlinks). Es el modo por default.

       -D, --delete
              Desinstala: borra los symlinks del paquete sin tocar el repo.

       -R, --restow
              Equivale a -D seguido de -S. Útil tras agregar o quitar
              archivos dentro de un paquete.

       --adopt
              PELIGROSO. Absorbe archivos ya existentes en $HOME hacia el
              repo, sobrescribiendo lo que ya tenías versionado. Revisa
              "git diff" de inmediato si lo usas.

EXAMPLES
       stow -nv -d linux -t ~ hypr
              Simula (no aplica nada) e imprime cada symlink que crearía.

       stow -d linux -t ~ hypr quickshell
              Instala varios paquetes de un jalón.

       stow -R -d linux -t ~ kitty
              Re-enlaza "kitty" después de editar qué archivos tiene el
              paquete.

       stow -D -d linux -t ~ waybar
              Quita los symlinks de "waybar" sin tocar el repo.

       for app in linux/*/; do stow -d linux -t ~ "${app#linux/}"; done
              Instala todo de un jalón. No es el flujo recomendado: el punto
              de tener paquetes por app es justo no instalar lo que no usas.

SEE ALSO
       macos-personal/ usa el mismo patrón, solo cambia -d:

              stow -nv -d macos-personal -t ~ nvim kitty tmux

WARNINGS
       Estos archivos están estrictamente personalizados para mi hardware y
       flujo de trabajo. No ejecutes nada a ciegas: simula primero con -n,
       revisa qué haría, y adopta bajo tu propio riesgo.

DOTFILES(1)                                                            DOTFILES(1)
```

# 🎓 More of Me

```md
~/dotfiles -----------------------------------------------------------------------------------
» curl -s https://tonatiuham.dev

🧑‍💻 Tonatiuh
├── Role   :: DevOps & Linux SysAdmin Enthusiast
├── Stack  :: Python • Linux • TUI Workflow
└── Domain :: https://tonatiuham.dev
```

<div align="center">
  <span style="font-size: 1.1em;"><b><a href="https://tonatiuham.dev">tonatiuham.dev</a></b></span>
</div>
