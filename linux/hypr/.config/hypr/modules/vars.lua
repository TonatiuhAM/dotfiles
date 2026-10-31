-- Variables

local M = {}

M.terminal = "kitty"
M.fileManager = "thunar /home/tona/downloads/"

-- ChillPill (barra en ~/.config/quickshell/chillpill); run = lanzarla, ipc = prefijo para llamar a sus estados
-- QML_IMPORT_PATH apunta al plugin compilado (wifi/bluetooth), se genera con chillpill/build-backend.sh
M.chillpill = "/home/tona/.config/quickshell/chillpill"
M.chillpillRun = "QML_IMPORT_PATH=" .. M.chillpill .. "/build/qml qs -p " .. M.chillpill
M.chillpillIpc = "qs ipc -p " .. M.chillpill .. " call"
M.menu = M.chillpillIpc .. " spotlight toggle"

return M
