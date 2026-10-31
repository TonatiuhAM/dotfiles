#!/bin/sh
# Sends a signal through the FIFO. Quickshell reads it instantly.
echo t > /tmp/qs_launcher_pipe
