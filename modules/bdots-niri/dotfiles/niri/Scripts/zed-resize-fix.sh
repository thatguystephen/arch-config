#!/bin/bash
niri msg event-stream | while read -r event; do
    if echo "$event" | grep -q "Windows changed:" && echo "$event" | grep -q "dev.zed.Zed"; then
        sleep 0.05
        niri msg action set-column-width "+1"
        sleep 0.05
        niri msg action set-column-width "-1"
    fi
done
