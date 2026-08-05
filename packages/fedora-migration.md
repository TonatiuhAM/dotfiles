# Migración de paquetes: Arch/EndeavourOS → Fedora

Este archivo es una guía curada a mano a partir de `arch-packages.txt` (pacman -Qqe)
y `arch-aur-packages.txt` (pacman -Qqem), pensada para reinstalar el software
equivalente en Fedora.

**Importante:** los nombres de paquete en Fedora cambian de versión a versión y
varios de los programas de este setup (ecosistema Hyprland, herramientas en Rust/Go)
no siempre están en los repos oficiales. Antes de instalar en bloque, valida con
`dnf search <nombre>` o `dnf info <nombre>`. Este documento es un punto de partida,
no una fuente 100% verificada contra un Fedora real.

## 0. Regenerar la lista original en Arch

```bash
pacman -Qqe  > packages/arch-packages.txt      # explícitos nativos
pacman -Qqem > packages/arch-aur-packages.txt  # explícitos de AUR
```

## 1. Repos extra que vas a necesitar antes de instalar nada

```bash
# RPM Fusion (free + nonfree) — códecs multimedia, unrar, libdvdcss, drivers, etc.
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Flatpak + Flathub (Fedora Workstation ya trae flatpak, falta el remoto)
sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# COPRs útiles para el stack Hyprland/dotfiles (revisa que sigan activos)
sudo dnf install -y dnf-plugins-core
sudo dnf copr enable -y solopasha/hyprland   # hyprland, hypridle, hyprlock, xdg-desktop-portal-hyprland, etc.
sudo dnf copr enable -y atim/lazygit         # lazygit
sudo dnf copr enable -y atim/lazydocker      # lazydocker
```

> Nota: Fedora 40+ empezó a incluir partes del stack Hyprland en repos oficiales.
> Corre `dnf search hyprland` primero; si ya aparece en los repos base, no
> necesitas el COPR de solopasha para ese paquete puntual.

## 2. Instalación directa vía dnf (nombre igual o casi igual)

Alta confianza — coinciden o son muy cercanos al nombre en Arch:

```bash
sudo dnf install -y \
  alacritty alsa-firmware alsa-utils android-tools ansifilter aspell \
  bash-completion bind-utils bluez btop btrfs-assistant btrfs-progs \
  cantarell-fonts chafa dialog diffutils dmidecode dnsmasq duf \
  e2fsprogs efibootmgr efitools ethtool exfatprogs f2fs-tools \
  fastfetch firewalld flatpak git glances gnome-keyring grim \
  haveged hdparm hwinfo inetutils inotify-tools inxi iptables iwd \
  jfsutils kdenlive keyd kitty kooha less libgsf libopenraw logrotate \
  lsd lshw lsscsi lvm2 man-db man-pages mdadm meld mesa-demos \
  ModemManager mtools nano neovim NetworkManager \
  NetworkManager-openconnect NetworkManager-openvpn nfs-utils \
  nilfs-utils nodejs-npm nss-mdns ntfs-3g nvtop okular \
  openssh openssh-clients pavucontrol perl pipewire-alsa \
  pipewire-jack-audio-connection-kit pipewire-pulseaudio plocate \
  poppler-glib power-profiles-daemon pulsemixer python3 \
  python3-defusedxml python3-jinja2 python3-packaging pipx \
  qbittorrent qt6-qtwayland rclone rsync rtkit ruby rust cargo \
  s-nail sassc sddm seahorse sg3_utils slurp smartmontools \
  fuse-sshfs stow sudo sysfsutils texinfo thunar timeshift tealdeer \
  tmux unzip upower usb_modeswitch usbutils wget which whois \
  wireplumber wl-clipboard wpa_supplicant xdg-desktop-portal-gtk \
  xdg-user-dirs xdg-utils xorg-x11-drv-libinput xfsprogs xl2tpd xterm \
  yt-dlp zoxide chrony
```

Notas puntuales de renombre:
- `mesa-utils` → `mesa-demos` (glxinfo, glxgears, etc.)
- `lsb-release` → `redhat-lsb-core` (si de verdad necesitas el comando `lsb_release`)
- `tldr` → usa `tealdeer` (paquete `tealdeer`, comando `tldr`)
- `ntp` → Fedora usa `chrony` por defecto, no reinstales `ntp`
- `sshfs` → el paquete se llama `fuse-sshfs`
- `sof-firmware` → `alsa-sof-firmware`
- `qt6-wayland` → `qt6-qtwayland`
- `bind` → si solo usas `dig`/`nslookup`, `bind-utils` basta; `bind` completo es el servidor DNS

## 3. Después de habilitar RPM Fusion / COPR

```bash
sudo dnf install -y \
  gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly \
  gstreamer1-libav pipewire-gstreamer mpv unrar libdvdcss \
  akmod-nvidia xorg-x11-drv-nvidia-cuda   # solo si sigues en hardware NVIDIA

sudo dnf install -y \
  hyprland hypridle hyprlock xdg-desktop-portal-hyprland \
  lazygit lazydocker
```

> `nvidia-hook`, `nvidia-inst`, `nvidia-open` (Arch) no existen como tal en Fedora:
> el driver propietario se instala con `akmod-nvidia` de RPM Fusion y el manejo de
> DKMS/kernel headers lo hace el propio paquete. Es un flujo distinto, no un
> reemplazo 1:1 — revisa la guía de RPM Fusion para NVIDIA antes de instalar.

## 4. Fuentes (nombres cambian bastante en Fedora)

```bash
sudo dnf install -y \
  google-noto-sans-fonts google-noto-serif-fonts google-noto-emoji-fonts \
  google-noto-cjk-fonts google-noto-sans-mono-fonts \
  bitstream-vera-sans-fonts bitstream-vera-sans-mono-fonts bitstream-vera-serif-fonts \
  dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts \
  liberation-fonts jetbrains-mono-fonts open-sans-fonts
```

**Maple Mono NF** (fuente principal de kitty/alacritty) y **JetBrainsMono
Nerd Font** (fallback) no están en los repos de Fedora — se instalaron a mano
en `~/.local/share/fonts/`, por lo que nunca viajan con el `stow` de los
dotfiles. `./setup-zsh.sh` las descarga e instala automáticamente (ver más
abajo); no hace falta hacerlo a mano salvo que quieras otra fuente.

`otf-sn-pro` (SN Pro) sí sigue siendo manual: no hay paquete Fedora, cópiala a
`~/.local/share/fonts/` y corre `fc-cache -f`.

## 5. Flatpak (más simple que buscar rpm/COPR para cada uno)

```bash
flatpak install -y flathub \
  md.obsidian.Obsidian \
  org.onlyoffice.desktopeditors \
  com.rustdesk.RustDesk \
  org.localsend.localsend_app \
  org.ferdium.Ferdium \
  org.prismlauncher.PrismLauncher
```

`vivaldi` sí tiene rpm y repo oficiales propios (no Flathub):
```bash
sudo dnf config-manager addrepo --from-repofile=https://repo.vivaldi.com/archive/vivaldi-fedora.repo
sudo dnf install -y vivaldi-stable
```

`tailscale` también tiene repo propio:
```bash
sudo dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
sudo dnf install -y tailscale
```

## 6. Sin paquete Fedora conocido — instalar manual / cargo / pip / git

Herramientas del ecosistema Hyprland y utilidades chicas que en Arch vienen de
AUR y en Fedora normalmente no están empaquetadas (revisa `dnf search` primero
por si ya se agregaron desde que se escribió esto):

| Paquete Arch (AUR) | Cómo resolverlo en Fedora |
| --- | --- |
| `quickshell` | Compilar desde fuente (Qt6/QML, ver repo oficial) o buscar COPR activo |
| `swaync` | Buscar COPR (ecosistema Hyprland) o compilar desde fuente |
| `wlogout` | Buscar COPR (solopasha/hyprland) o compilar desde fuente |
| `cliphist` | `go install go.senan.xyz/cliphist@latest` o COPR |
| `hypremoji` | Compilar desde fuente / revisar repo del proyecto |
| `nwg-look` | Buscar COPR o compilar desde fuente |
| `wev` | Buscar COPR o compilar desde fuente |
| `wtype` | Buscar COPR o compilar desde fuente |
| `matugen` | `cargo install matugen` |
| `pyprland` | `pipx install pyprland` |
| `impala` | `cargo install impala` (TUI de iwd) |
| `gum` | Descargar binario de releases de charmbracelet/gum, o `go install` |
| `bluetui` | `cargo install bluetui` o binario de GitHub releases |
| `yazi` | `dnf search yazi` primero; si no está, `cargo install --locked yazi-fs yazi-cli` |
| `selectdefaultapplication-git` | Script chico de AUR; revisa el fuente y adáptalo, o usa `xdg-mime`/`gio mime` manualmente |
| `sddm-silent-theme` | Clonar el tema desde su repo de GitHub a `/usr/share/sddm/themes/` |
| `openlogi-bin` | Paquete de nicho — verifica manualmente de qué proyecto viene antes de reinstalarlo |
| `spotatui-bin` | Verifica el proyecto exacto (nombre ambiguo) antes de buscar alternativa |
| `ttf-jetbrains-mono-git` / nerd font | Ver sección de fuentes arriba |
| `otf-sn-pro` | Ver sección de fuentes arriba |
| `ventoy-bin` | Descargar binario oficial de https://ventoy.net (no está empaquetado en Fedora) |
| `fancontrol-gui` | Buscar COPR o compilar desde fuente (KDE fancontrol GUI) |
| `ex-vi-compat` | Muy de nicho/Arch; probablemente no lo necesitas en Fedora, `vim`/`nano` cubren el caso de uso |

`zinit` y `zsh-theme-powerlevel10k-git` **no hace falta instalarlos en
Fedora**: revisando `.zshrc`/.zprofile` el shell en realidad usa Oh My Zsh
(clonado por git en `$XDG_DATA_HOME/oh-my-zsh`), con powerlevel10k y los
plugins `zsh-autosuggestions`/`zsh-syntax-highlighting`/`zsh-vi-mode` también
clonados por git dentro de `oh-my-zsh/custom/`. Esos dos paquetes de AUR eran
sobrantes sin uso real. Todo ese stack (Oh My Zsh + tema + plugins) más las
fuentes Nerd Font que usa la terminal se instalan con:

```bash
./setup-zsh.sh
```

Corre esto además de `./install.sh` — `install.sh` solo crea los symlinks;
`setup-zsh.sh` instala lo que esos symlinks esperan encontrar y que vive fuera
de `~/.config` (el framework de zsh en `~/.local/share/oh-my-zsh` y las
fuentes en `~/.local/share/fonts`), y además deja zsh como shell de login.

## 7. No instalar en Fedora — específicos de Arch/EndeavourOS o sin sentido en dnf

Estos paquetes son parte del propio sistema Arch/EndeavourOS, herramientas de
`pacman`, o vienen ya resueltos por Fedora de otra forma. No tienen equivalente
que debas instalar manualmente:

```
base base-devel linux linux-firmware linux-headers amd-ucode
endeavouros-branding endeavouros-keyring endeavouros-mirrorlist
eos-apps-info eos-hooks eos-log-tool eos-packagelist eos-quickstart
eos-rankmirrors welcome hwdetect
dracut kernel-install-for-dracut systemd-sysvcompat
pacman-contrib downgrade reflector reflector-simple rebuild-detector
pkgfile snap-pac yay netctl wireless-regdb
device-mapper dmraid cryptsetup  # normalmente ya vienen con Fedora base
```

Casos particulares:
- **docker / docker-compose**: Fedora no trae Docker en repos propios (por
  licencia); o usas Podman (viene por defecto y es el enfoque nativo de
  Fedora), o agregas el repo oficial de Docker
  (`dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo`).
  Decide cuál de los dos flujos quieres antes de instalar.
- **firewall-applet**: si usas `firewalld`, el applet GUI es opcional; en GNOME
  normalmente se gestiona con `firewall-config`/`firewall-applet` — revisa si
  lo sigues necesitando bajo Hyprland (probablemente uses `nmtui`/`nm-applet` +
  `firewall-cmd` en su lugar).
- **polkit-gnome**: en Hyprland moderno se recomienda `hyprpolkitagent` en vez
  de `polkit-gnome` (que además está deprecado upstream). Revisa qué usa tu
  config de Hyprland (`linux-personal/.config/hypr`) y ajusta.

## 8. Xorg (solo si de verdad los necesitas)

Con Hyprland corres en Wayland puro; XWayland ya viene con
`xorg-x11-server-Xwayland` en Fedora por defecto con el stack de Hyprland. Los
siguientes solo tienen sentido si necesitas depurar clientes X11 sueltos:

```bash
sudo dnf install -y xorg-x11-server-Xorg xorg-x11-xinit xorg-x11-utils \
  xorg-x11-server-utils xinput
```

## Resumen del flujo sugerido

1. Instala Fedora, entra al sistema, actualiza (`sudo dnf upgrade --refresh`).
2. Sección 1: agrega RPM Fusion, Flathub y los COPR que decidas usar.
3. Sección 2: instala el bloque de paquetes de alta confianza.
4. Secciones 3–5: multimedia/NVIDIA, fuentes, Flatpaks y repos propios (Vivaldi, Tailscale).
5. Sección 6: resuelve a mano lo que no tiene paquete Fedora.
6. Clona `dotfiles`, corre `./install.sh` para crear todos los symlinks con stow.
7. Corre `./setup-zsh.sh` para instalar Oh My Zsh + powerlevel10k + plugins +
   fuentes y dejar zsh como shell de login.
8. Revisa la sección 7/8 para confirmar que no falta nada específico de tu setup.
