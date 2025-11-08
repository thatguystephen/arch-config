# Controller Support

This module provides comprehensive game controller support for Linux gaming, including drivers, tools, and udev rules for various gaming controllers.

## Features

- **Nintendo Switch Controllers**: Pro Controller, Joy-Cons (L/R), Charging Grip
- **Xbox Controllers**: Xbox 360, Xbox One, Xbox Series X|S
- **Third-Party Controllers**: Flydigi Vader 4 Pro, Ultimate 2, and others
- **Steam Input Integration**: Proper udev tagging for Steam Input support
- **Automatic Permissions**: Udev rules grant user access to controller devices

## Installation

Enable the controller-support module:

```bash
dcli module enable controller-support
dcli sync
```

This will:
1. Install all required packages (drivers, tools, libraries)
2. Automatically install udev rules to `/etc/udev/rules.d/60-controller-support.rules`
3. Configure kernel modules (uinput) to load on boot
4. Reload udev to apply the new rules

## Installed Packages

### Drivers & Libraries
- `sdl2` - Simple DirectMedia Layer for controller input
- `game-devices-udev` - Steam hardware udev rules
- `xpadneo-dkms` - Enhanced Xbox controller support (wireless)
- `xboxdrv` - Xbox controller driver
- `ds4drv` - DualShock 4 controller driver

### Tools
- `jstest-gtk` - Joystick testing and calibration
- `antimicrox` - Controller-to-keyboard mapping
- `piper` - Gaming mouse/device configuration
- `sc-controller` - Steam Controller configuration
- `joyutils` - Joystick utilities
- `gamecon-git` - Game console controller support
- `dualshock4-tools` - DualShock 4 specific tools

## Manual Installation

If you need to manually install the udev rules (e.g., troubleshooting):

```bash
sudo /home/$USER/.config/arch-config/scripts/install-controller-udev-rules.sh
```

## Supported Controllers

### Nintendo
- Switch Pro Controller (USB & Bluetooth)
- Joy-Con Left
- Joy-Con Right
- Joy-Con Charging Grip
- Nyxi Wizard 2 (appears as Switch Pro Controller)

### Xbox
- Xbox 360 Controller
- Xbox One Controller (all variants)
- Xbox Series X|S Controller

### Third-Party
- Flydigi Vader 4 Pro (dinput mode)
- Ultimate 2 (2.4GHz & Bluetooth)
- Generic gamepads and controllers

## Troubleshooting

### Controller Not Detected

1. Check if the controller is recognized:
   ```bash
   lsusb  # For USB controllers
   jstest /dev/input/js0  # Test joystick input
   ```

2. Verify udev rules are installed:
   ```bash
   ls -la /etc/udev/rules.d/60-controller-support.rules
   ```

3. Reload udev rules manually:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

4. Unplug and replug the controller

### Permission Issues

If you get permission errors accessing the controller:

1. Check if udev rules are applied:
   ```bash
   udevadm info /dev/input/event* | grep -i "controller\|gamepad"
   ```

2. Verify your user has access:
   ```bash
   groups $USER  # Should include 'input' or similar
   ```

### Steam Input Not Working

1. Ensure the controller is properly tagged:
   ```bash
   udevadm info /dev/input/js0 | grep -i steam
   ```

2. Restart Steam to pick up the new controller

3. Check Steam Input settings in Steam:
   - Settings → Controller → General Controller Settings
   - Enable support for your controller type

## Kernel Modules

The following kernel modules are loaded on boot:
- `uinput` - Required for virtual input devices

## Files Installed

- `/etc/udev/rules.d/60-controller-support.rules` - Udev rules for controller permissions
- `/etc/modules-load.d/controller-support.conf` - Kernel modules to load on boot

## Removal

To remove controller support:

```bash
dcli module disable controller-support
dcli sync --prune
```

Then manually remove the udev rules and kernel module configuration:

```bash
sudo rm /etc/udev/rules.d/60-controller-support.rules
sudo rm /etc/modules-load.d/controller-support.conf
sudo udevadm control --reload-rules
```

## Based On

This module is based on the NixOS gaming-support configuration from black-don-os, adapted for Arch Linux's imperative package management.
