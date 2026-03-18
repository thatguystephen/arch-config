local packages = {
    "android-studio",
    "vscodium-bin",
    "zed",
    "chromium",
    "clang",
    "cmake",
    "ninja",
    "gtk3",
    "libstdc++5",
    "curl",
    "git",
    "unzip",
    "xz",
    "zip",
    "glu",
    "helix",
    "claude-code",
    "yazi",
    "tmux",
    "ollama",
    "gnome-boxes",
}

return {
    description = "Development tools including IDEs and browsers",
    packages = packages,
    conflicts = {},
}
