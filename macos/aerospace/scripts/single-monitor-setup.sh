#!/bin/bash

# AeroSpace Single Monitor Setup Script  
# Run this when you disconnect your external monitor

CONFIG_FILE="$HOME/.aerospace.toml"

echo "Setting up single monitor configuration..."

# Comment out the workspace-to-monitor assignment
sed -i '' 's/^\[workspace-to-monitor-force-assignment\]/# [workspace-to-monitor-force-assignment]/' "$CONFIG_FILE"
sed -i '' 's/^\([1-9] = \)/# \1/' "$CONFIG_FILE"

# Change Ghostty back to workspace 3 for single monitor
sed -i '' 's/run = '\''move-node-to-workspace 6'\''/run = '\''move-node-to-workspace 3'\''/' "$CONFIG_FILE"

# Reload AeroSpace
aerospace reload-config

echo "Single monitor setup complete!"
echo "All workspaces available on MacBook"
echo "Ghostty: workspace 3, WhatsApp: workspace 5"