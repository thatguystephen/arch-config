# Shell Analysis: Theming Engines & Keybind Panels

## Overview
This document analyzes four modern Quickshell-based desktop shells to understand their implementation of:
1. Wallpaper/Color Theming Engines
2. Keybind Display Panels

The analyzed shells are:
- **Yahr-Quickshell** by bgibson72 (most comprehensive theming)
- **Ambxst** by Axenide
- **NibrasShell** by AhmedSaadi0
- **Nucleus-Shell** by xZepyx

---

## 1. Theming Engine Architecture

### Common Architecture Pattern

All shells follow a similar pattern:
```
Theme Definition (QML) → Theme Manager (Singleton) → Shell Components → External Apps (via sync scripts)
```

### 1.1 Yahr-Quickshell Theming System

**Most comprehensive and well-documented implementation**

#### Architecture Components:

**A. Theme Definition Files** (`~/.config/quickshell/themes/*.qml`)
```qml
// ThemeManager.qml - Catppuccin Mocha Theme
pragma Singleton
import QtQuick

QtObject {
    id: themeManager
    property string currentTheme: "catppuccin-mocha"
    
    // Accent Colors
    property color accentBlue: "#89b4fa"
    property color accentPurple: "#cba6f7"
    property color accentRed: "#f38ba8"
    
    // Foreground Colors
    property color fgPrimary: "#cdd6f4"
    property color fgSecondary: "#bac2de"
    
    // Background Colors
    property color bgBase: "#1e1e2e"
    property color surface0: "#313244"
    
    // Font Sizes
    property int fontSizeClock: 14
    property int fontSizeWorkspace: 14
}
```

**B. Theme Switcher UI** (`ThemeSwitcher.qml`)
- Visual theme picker with keyboard/mouse navigation
- Displays available themes from `~/.config/hypr/themes/`
- Shows loading overlay during theme application
- Completion detection via file watcher

**C. Main Theme Switch Script** (`switch-theme.sh`)
```bash
# Core functionality:
1. Copy theme QML file to ThemeManager.qml
2. Update Hyprland theme source
3. Update wallpaper to match theme
4. Trigger all sync scripts (background)
5. Show loading overlay with completion detection
```

**D. Sync Scripts** (One for each application)
- `sync-kitty-theme.sh` - Terminal colors
- `sync-gtk-theme.sh` - GTK apps
- `sync-firefox-theme.sh` - Browser userChrome.css
- `sync-vscode-theme.sh` - Editor
- `sync-hyprlock-theme.sh` - Lock screen
- `sync-sddm-theme.sh` - Login screen
- `sync-papirus-folders.sh` - Icon folder colors
- `sync-starship-theme.sh` - Shell prompt
- `sync-nvim-theme.sh` - Neovim colorscheme
- `sync-vencord-theme.sh` - Discord client

**E. Wallpaper Management**
```bash
# Wallpapers organized by theme
~/Pictures/Wallpapers/
├── Catppuccin/
├── Gruvbox/
├── TokyoNight/
└── Nord/

# Theme switch automatically picks random wallpaper from theme folder
```

#### Key Features:
1. **11 Pre-defined Themes** with matching wallpapers
2. **Unified Sync System** - One command updates all apps
3. **Loading Feedback** - Visual overlay during theme switch
4. **Completion Detection** - File watcher waits for all syncs
5. **Background Processing** - Doesn't block UI
6. **Hyprland Integration** - Updates compositor theme files

#### Theme Mapping Strategy:
```bash
# Maps Quickshell theme names to Hyprland theme files
declare -A HYPR_THEME_MAP=(
    ["catppuccin-mocha"]="Catppuccin"
    ["gruvbox-dark"]="Gruvbox"
    ["tokyonight-night"]="TokyoNight"
)
```

---

### 1.2 NibrasShell Theming

**Features Material 3 dynamic coloring**

#### Key Innovations:
- Material 3 color generation from wallpapers
- Support for GIF/Video wallpapers
- Deep theming across all system components
- Smart color extraction from images

#### Implementation:
- Uses Python scripts for color extraction
- Generates Material 3 color palettes
- Applies to Qt/GTK apps via kvantum/gtk themes
- Custom theme files per application

---

### 1.3 Nucleus-Shell Colorscheme System

**Modular and composable design**

#### Architecture:
```
services/Colorscheme.qml → modules/ → config/configuration.json
```

#### Features:
- Plugin-based colorscheme system
- Separate colorschemes can be loaded
- Configuration via JSON
- Extensible module system

---

### 1.4 Ambxst Theming

**Focuses on customizable components**

#### Features:
- Component-based theming
- Theme persistence
- Wallpaper manager integration
- Plugin system for extensions

---

## 2. Color Extraction Methods

### Method 1: Manual Theme Definitions (Yahr-Quickshell)
**Pros:**
- Predictable, curated color palettes
- Fast switching (no computation)
- Works offline
- Consistent results

**Cons:**
- Limited to pre-defined themes
- No dynamic generation from wallpapers

### Method 2: Dynamic Extraction (NibrasShell approach)
**Tools Used:**
- `imagemagick` - Color extraction
- `python-colorthief` - Dominant colors
- `python-material-color-utilities` - Material 3 palette generation

**Pros:**
- Any wallpaper can generate a theme
- Material 3 color harmony
- Automatic contrast handling

**Cons:**
- Computation time
- Requires dependencies
- Results may vary

### Method 3: Pywal Integration (Common approach)
```bash
# Generate colors from image
wal -i /path/to/wallpaper.jpg

# Outputs to ~/.cache/wal/colors
# Can be sourced by multiple apps
```

---

## 3. Keybind Display Implementations

### Research Findings:
**None of the four shells have a dedicated keybind panel implementation**

However, common patterns exist:

### Pattern 1: Hyprland Config Parsing
```bash
# Parse hyprland.conf for binds
grep "^bind" ~/.config/hypr/hyprland.conf | while read line; do
    # Extract: bind = MODS, KEY, action, #"Description"
    # Format for display
done
```

### Pattern 2: Comment-Based Documentation
```bash
# Hyprland keybinds.conf format:
##! --- SECTION HEADER ---
bind = $mainMod, B, exec, $browser #"Description"
```

**Your current format already supports this!**

### Pattern 3: QuickShell Widget
```qml
// Keybind display widget
Rectangle {
    ListView {
        model: keybindModel
        delegate: Row {
            Text { text: model.keys }
            Text { text: model.description }
        }
    }
}
```

---

## 4. Implementation Recommendations

### For Theming Engine:

**Option A: Yahr-Style Manual Themes** (Recommended)
```
Pros:
+ Quick implementation
+ Reliable and fast
+ Works with your existing setup
+ Can be implemented incrementally

Implementation:
1. Create theme definition files (.conf format for Hyprland)
2. Create sync scripts for each app (kitty, dunst, rofi, eww)
3. Add theme switcher (rofi menu or simple script)
4. Organize wallpapers by theme
```

**Option B: Dynamic Color Generation**
```
Pros:
+ Any wallpaper works
+ Automatic color harmony

Cons:
- More complex
- Requires computation
- Dependencies

Tools needed:
- pywal or custom Python script
- imagemagick
- Optional: material-color-utilities
```

**Hybrid Approach** (Best of Both)
```
1. Start with manual themes for speed
2. Add dynamic generation as optional feature
3. Cache generated themes as manual themes
4. User can switch between curated and dynamic
```

---

### For Keybind Panel:

**Implementation Strategy:**

1. **Parse Hyprland Config**
```bash
#!/bin/bash
# parse-keybinds.sh

CONFIG="$HOME/.config/hypr/keybinds.conf"
OUTPUT="$HOME/.config/hypr/keybinds.json"

# Extract sections and binds
awk '
/^##! / { section = substr($0, 5); next }
/^bind/ { 
    match($0, /#"([^"]+)"/, desc)
    if (desc[1] != "") {
        gsub(/^bind[m]* = /, "")
        split($0, parts, ",")
        print section "|" parts[1] parts[2] "|" desc[1]
    }
}
' "$CONFIG" > "$OUTPUT"
```

2. **Display Methods:**

**A. Rofi Menu** (Simplest)
```bash
rofi -dmenu -i -p "Keybinds" < keybinds-formatted.txt
```

**B. Eww Widget** (Matches your setup)
```lisp
(defwidget keybinds []
  (scroll
    (box :orientation "v" :spacing 8
      (for bind in keybinds
        (box :class "keybind-row"
          (label :text "${bind.keys}" :class "keys")
          (label :text "${bind.desc}" :class "desc"))))))
```

**C. QuickShell Widget** (If you add it later)
```qml
Rectangle {
    ListView {
        model: ListModel { /* parsed keybinds */ }
        delegate: keybindDelegate
    }
}
```

3. **Search/Filter Functionality**
- Live search as you type
- Category filtering
- Fuzzy matching

---

## 5. File Structure Recommendations

### For Theming:
```
~/.config/hypr/
├── themes/
│   ├── catppuccin.conf
│   ├── gruvbox.conf
│   └── nord.conf
├── scripts/
│   ├── theme-switch.sh
│   ├── sync-kitty.sh
│   ├── sync-dunst.sh
│   ├── sync-eww.sh
│   └── sync-rofi.sh
└── .current-theme

~/Pictures/Wallpapers/
├── Catppuccin/
├── Gruvbox/
└── Nord/
```

### For Keybinds:
```
~/.config/hypr/
├── keybinds.conf (your existing file)
├── scripts/
│   ├── parse-keybinds.sh
│   ├── show-keybinds-rofi.sh
│   └── show-keybinds-eww.sh
└── cache/
    └── keybinds.json
```

---

## 6. Integration with Your Setup

### Current Setup Analysis:
```
- Shell Switcher: ✓ Already modular
- Hyprland: ✓ Organized configs
- Apps: dunst, hyprpaper, eww, rofi
- Theme files exist in separate shell configs
```

### Integration Strategy:

**Phase 1: Basic Theming**
1. Extract common themes from existing shells
2. Create theme definition files
3. Add basic sync scripts for core apps

**Phase 2: Switcher UI**
1. Create rofi theme selector
2. Add wallpaper management
3. Integrate with shell-switcher

**Phase 3: Keybind Panel**
1. Parse existing keybinds.conf
2. Create display widget (rofi/eww)
3. Add search functionality

**Phase 4: Advanced Features**
1. Dynamic color generation (optional)
2. Theme preview
3. Per-monitor wallpapers

---

## 7. Code Snippets for Your Implementation

### Theme Definition Format (Hyprland .conf)
```conf
# Catppuccin Mocha Theme

# Accent Colors
$accentBlue = rgb(89b4fa)
$accentRed = rgb(f38ba8)
$accentGreen = rgb(a6e3a1)

# Background Colors
$bgBase = rgb(1e1e2e)
$bgSurface = rgb(313244)

# Foreground Colors
$fgPrimary = rgb(cdd6f4)
$fgSecondary = rgb(bac2de)

# Window Colors
col.active_border = $accentBlue
col.inactive_border = $bgSurface
```

### Minimal Theme Switcher Script
```bash
#!/bin/bash
THEME="$1"
THEME_FILE="$HOME/.config/hypr/themes/${THEME}.conf"

if [ ! -f "$THEME_FILE" ]; then
    echo "Theme not found: $THEME"
    exit 1
fi

# Update Hyprland source
sed -i "s|^source = .*/themes/.*\.conf|source = $THEME_FILE|" \
    "$HOME/.config/hypr/hyprland.conf"

# Reload Hyprland
hyprctl reload

# Update other apps
~/.config/hypr/scripts/sync-kitty.sh "$THEME"
~/.config/hypr/scripts/sync-dunst.sh "$THEME"
~/.config/hypr/scripts/sync-rofi.sh "$THEME"

echo "Theme switched to: $THEME"
```

---

## 8. Next Steps

1. **Decide on theming approach** (manual vs dynamic vs hybrid)
2. **Create theme definition files** for your preferred colorschemes
3. **Implement sync scripts** for your apps (dunst, rofi, eww, kitty)
4. **Build theme switcher UI** (rofi menu as MVP)
5. **Implement keybind parser** using your existing comments
6. **Create keybind display** (rofi or eww widget)

---

## Resources

### Tools:
- `imagemagick` - Image manipulation
- `pywal` - Color scheme generation
- `jq` - JSON parsing
- `yq` - YAML parsing
- `rofi` - Menu display
- `dunst` - Notifications

### References:
- Hyprland Wiki: https://wiki.hyprland.org/
- QuickShell Docs: https://quickshell.outfoxxed.me/
- Material 3 Colors: https://m3.material.io/styles/color
- Catppuccin Palette: https://catppuccin.com/

---

## Conclusion

**Best Approach for Your Setup:**

1. **Theming Engine**: Hybrid approach
   - Start with manual theme definitions (5-10 curated themes)
   - Add sync scripts for dunst, rofi, eww, hyprpaper, kitty
   - Use your shell-switcher infrastructure
   - Optional: Add pywal integration later

2. **Keybind Panel**: Parse existing comments
   - Your keybinds.conf already has descriptions
   - Simple parser to extract bind + description
   - Display in rofi (quick MVP) or eww (polished)
   - Add search/filter functionality

This approach:
- ✓ Works with your existing setup
- ✓ Minimal dependencies
- ✓ Incremental implementation
- ✓ Maintains your modular structure
- ✓ Compatible with shell-switcher

**Estimated Implementation Time:**
- Theming Engine: 4-6 hours
- Keybind Panel: 2-3 hours
- Total: 6-9 hours for MVP