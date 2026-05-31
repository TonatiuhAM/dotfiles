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
    name: "Style Picker",
    icon: "󰸉",
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
    name: "Lock Screen",
    icon: "󰌾",
    command: ["hyprlock"],
    type: "system"
  },
]
