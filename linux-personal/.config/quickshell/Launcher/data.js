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
    name: "Style Picker",
    icon: "󰸉",
    keywords: ["wallpaper"],
    command: ["sh", "-c", "$XDG_CONFIG_HOME/Scripts/style-picker.sh"],
    type: "script"
  },
  {
    name: "Developement",
    icon: "󰵮",
    command: ["sh", "-c", "$XDG_CONFIG_HOME/Scripts/dev-layout.sh"],
    type: "script"
  },
  {
    name: "Archivos",
    icon: "",
    keywords: ["Files"],
    command: ["sh", "-c", "thunar"],
    type: "script"
  },
  {
    name: "Spotify",
    icon: "",
    keywords: ["Spotify", "spotify"],
    command: ["kitty", "spotatui"],
    type: "script"
  },
]

// ─── System Commands ───────────────────────────────────────────────────────
const systemCommands = [
  {
    name: "Apagar",
    icon: "󰐥",
    command: ["systemctl", "poweroff"],
    type: "system",
    requiresAuth: true
  },
  {
    name: "Reiniciar",
    icon: "󰜉",
    command: ["systemctl", "reboot"],
    type: "system",
    requiresAuth: true
  },
  {
    name: "Bloquear",
    icon: "󰌾",
    command: ["hyprlock"],
    type: "system"
  },
]
