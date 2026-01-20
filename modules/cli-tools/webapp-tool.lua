local packages = {
    "gum",
    "curl",
    "gtk3",
    "chromium",
}

return {
    description = "Web app installer tools for creating desktop entries from URLs",
    post_install_hook = "webapp-tool/install-webapp-tools.sh",
    hook_behavior = "skip",
    packages = packages,
}
