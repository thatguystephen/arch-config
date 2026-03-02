import app from "ags/gtk4/app"
import { Gtk, Gdk } from "ags/gtk4" // Import Gtk and Gdk
import GLib from "gi://GLib" // Import GLib
import { compileScss } from "@common/cssHotReload"
import { watchMatugenColors } from "@common/matugen"
import requestHandler from "./requestHandler"

import Bar from "@windows/bar/Bar"
import NotificationPopups from "@windows/notification_popups/NotificationPopups"
import OSD from "@windows/osd/OSD"
import MediaPopup from "@windows/media_popup/MediaPopup"
import VolumePopup from "@windows/volume_popup/VolumePopup"
import CalendarPopup from "@windows/calendar_popup/CalendarPopup"

// --- Register Assets Path ---
function registerIconTheme() {
  const display = Gdk.Display.get_default()
  if (display) {
    const iconTheme = Gtk.IconTheme.get_for_display(display)
    const assetsPath = GLib.get_current_dir() + "/assets"

    // Check if path exists just to be safe/debug
    if (GLib.file_test(assetsPath, GLib.FileTest.EXISTS)) {
      iconTheme.add_search_path(assetsPath)
      print(`Registered icon path: ${assetsPath}`)
    } else {
      print(`Warning: Assets path not found at ${assetsPath}`)
    }
  }
}

app.start({
  css: compileScss(),
  requestHandler,
  main() {
    registerIconTheme()
    watchMatugenColors()

    const monitors = app.get_monitors()

    // 1. Find your specific primary monitor (DP-4)
    let targetMonitor = monitors[0] // Fallback

    for (const m of monitors) {
      // Check connector name
      if (m.connector === "DP-4" || m.get_connector?.() === "DP-4") {
        targetMonitor = m
      }
    }

    // 2. Spawn Bar ONLY on target monitor
    Bar(targetMonitor)

    // 3. Spawn Popups ONLY on target monitor
    if (targetMonitor) {
      NotificationPopups(targetMonitor)
      OSD(targetMonitor)
      MediaPopup(targetMonitor)
      VolumePopup(targetMonitor)
      CalendarPopup(targetMonitor) // <--- Now uses the correct monitor
    }

    print(
      `\nAGS shell started on monitor: ${targetMonitor.connector || "unknown"}`,
    )
  },
})
