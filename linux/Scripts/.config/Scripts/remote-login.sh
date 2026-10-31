#!/usr/bin/env bash

USER_NAME="tona"
GDM_CONF="/etc/gdm/custom.conf"

echo "[+] Activando inicio de sesión automático para $USER_NAME..."

# 1. Habilitar Autologin en custom.conf usando sed
sudo sed -i "s/^#\?AutomaticLoginEnable\s*=.*/AutomaticLoginEnable=True/" "$GDM_CONF" || true
if ! grep -q "AutomaticLoginEnable=True" "$GDM_CONF"; then
  sudo sed -i "/\[daemon\]/a AutomaticLoginEnable=True" "$GDM_CONF"
fi

if grep -q "AutomaticLogin=" "$GDM_CONF"; then
  sudo sed -i "s/^#\?AutomaticLogin=.*/AutomaticLogin=$USER_NAME/" "$GDM_CONF"
else
  sudo sed -i "/AutomaticLoginEnable=True/a AutomaticLogin=$USER_NAME" "$GDM_CONF"
fi

echo "[+] Reiniciando GDM para entrar a Hyprland..."
sudo systemctl restart gdm

# Esperar unos segundos a que GDM procese el autologin
sleep 5

echo "[+] Restaurando configuración de GDM para pedir contraseña en el próximo reinicio..."
sudo sed -i "s/^AutomaticLoginEnable=True/#AutomaticLoginEnable=True/" "$GDM_CONF"
sudo sed -i "s/^AutomaticLogin=$USER_NAME/#AutomaticLogin=$USER_NAME/" "$GDM_CONF"

echo "[+] Sesión iniciada. Esperando a que Sunshine arranque..."
for i in {1..30}; do
  if systemctl --user is-active --quiet app-dev.lizardbyte.app.Sunshine; then
    echo "[✓] Sunshine activo. Ya puedes conectar con Moonlight."
    exit 0
  fi
  sleep 2
done
echo "[x] Sunshine no arrancó. Revisa: journalctl --user -u app-dev.lizardbyte.app.Sunshine -e"
exit 1
