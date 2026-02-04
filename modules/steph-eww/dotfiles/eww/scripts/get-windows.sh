#!/bin/bash

# Function to get app icon/symbol
get_app_icon() {
  case "$1" in
    "org.keepassxc.KeePassXC") echo "🔐" ;;
    "firefox") echo "🦊" ;;
    "google-chrome"|"chromium") echo "🌐" ;;
    "org.gnome.Nautilus"|"thunar") echo "📁" ;;
    "code"|"codium") echo "💻" ;;
    "spotify") echo "🎵" ;;
    *) echo "${1:0:2}" ;;  # First 2 chars of class name
  esac
}

hyprctl clients -j | jq -r '.[] | 
  select(.workspace.id > 0) | 
  {
    address: .address,
    class: .class,
    title: .title,
    workspace: .workspace.id,
    minimized: (.hidden // false),
    focused: (.focusHistoryID == 0)
  }' | jq -s 'sort_by(.workspace) | sort_by(.focused) | reverse' | \
while IFS= read -r window; do
  class=$(echo "$window" | jq -r '.class')
  icon=$(get_app_icon "$class")
  echo "$window" | jq --arg icon "$icon" '. + {icon: $icon}'
done | jq -s '.'
