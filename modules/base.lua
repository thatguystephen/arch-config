local packages = {
    "base",
    "base-devel",
    "linux-firmware",
    "networkmanager",
    "neovim",
    "git",
    "htop",
    "man-db",
    "man-pages",
}

return {
    description = "Base packages for all machines",
    packages = packages,
}
