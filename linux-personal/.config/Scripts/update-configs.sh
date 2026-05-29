#!/bin/bash

echo "Instalando configuraciones..."

# ===== KEYD =====
sudo mkdir -p /etc/keyd
sudo cp ~/dotfiles/linux-personal/.config/keyd/default.conf /etc/keyd/default.conf
sudo systemctl restart keyd
echo "Listo keyd"
