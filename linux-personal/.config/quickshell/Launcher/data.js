.pragma library

// ─── Custom Scripts ────────────────────────────────────────────────────────
// Add your scripts here. Each object needs: name, icon (nerd font), command (array), type: "script"
const scripts = [
  {
    name: "Screenshot (Area)",
    icon: "󰩭",
    command: ["sh", "-c", "grim -g \"$(slurp)\" - | wl-copy"],
    type: "script"
  },
  {
    name: "Bluetooth",
    icon: "",
    command: ["kitty", "--title", "bluetui", "bluetui"],
    type: "script"
  },
  {
    name: "Volume Control",
    icon: "󰕾",
    command: ["kitty", "--title", "pulsemixer", "pulsemixer"],
    type: "script"
  },
  {
    name: "Style Picker",
    icon: "󰸉",
    keywords: ["wallpaper"],
    command: ["sh", "-c", "$XDG_CONFIG_HOME/Scripts/style-picker.sh"],
    type: "script"
  },
  {
    name: "Dev-Layout",
    icon: "󰵮",
    command: ["sh", "-c", "$XDG_CONFIG_HOME/Scripts/dev-layout.sh"],
    type: "script"
  },
  {
    name: "Curso-Layout",
    icon: "󰵮",
    command: ["sh", "-c", "$XDG_CONFIG_HOME/Scripts/cursos-layout.sh"],
    type: "script"
  },
  {
    name: "SSH",
    icon: "",
    command: ["sh", "-c", "$XDG_CONFIG_HOME/Scripts/lazyssh-manager.sh"],
    type: "script"
  },
  {
    name: "Apps",
    icon: "",
    command: ["sh", "-c", "$XDG_CONFIG_HOME/Scripts/sysman.sh"],
    type: "script"
  },
  {
    name: "Ferdium",
    icon: "",
    keywords: ["whatsapp", "telegram", "discord", "slack", "messenger"],
    command: ["sh", "-c", "gtk-launch ferdium"],
    type: "script"
  },
]

// ─── System Commands ───────────────────────────────────────────────────────
const systemCommands = [
  {
    name: "Apagar",
    icon: "󰐥",
    command: ["systemctl", "poweroff"],
    type: "system"
  },
  {
    name: "Reiniciar",
    icon: "󰜉",
    command: ["systemctl", "reboot"],
    type: "system"
  },
  {
    name: "Bloquear",
    icon: "󰌾",
    command: ["hyprlock"],
    type: "system"
  },
]
