import Gdk from "gi://Gdk?version=4.0"
import Astal from "gi://Astal?version=4.0"
import app from "ags/gtk4/app"

import Clock from "@widgets/Clock/Clock"
import Workspaces from "@widgets/Workspaces/Workspaces"
import ActiveWindow from "@widgets/ActiveWindow/ActiveWindow"
import SysTray from "@widgets/SysTray/SysTray"
import BluetoothIndicator from "@widgets/BluetoothIndicator/BluetoothIndicator"
import VolumeIndicator from "@widgets/VolumeIndicator/VolumeIndicator"
import MediaPlayer from "@widgets/MediaPlayer/MediaPlayer"
import SystemStats from "@widgets/SystemStats/SystemStats"
import {
  LeftIsland,
  RightIsland,
  CenterIsland,
} from "@widgets/NotchedBar/NotchedBar"
import { Gtk } from "ags/gtk4"
import { readFile } from "ags/file"
import GLib from "gi://GLib?version=2.0"
import { onMatugenChange } from "@common/matugen"

// Utility to get workspace bar background color from matugen
function getWorkspaceBarBackgroundColor(): [number, number, number] {
  try {
    const matugenPath = GLib.get_home_dir() + "/.cache/matugen/colors.json"
    const content = readFile(matugenPath)
    if (!content) return [0.078, 0.098, 0.125] // Fallback

    const json = JSON.parse(content)
    const bgHex = json.defs?.surface_container_lowest || "#140c0c"

    // Parse hex color to RGB (0-1 range for Cairo)
    const hex = bgHex.replace("#", "")
    const r = parseInt(hex.substring(0, 2), 16) / 255
    const g = parseInt(hex.substring(2, 4), 16) / 255
    const b = parseInt(hex.substring(4, 6), 16) / 255

    return [r, g, b]
  } catch (e) {
    console.error("Failed to read matugen colors:", e)
    return [0.078, 0.098, 0.125] // Fallback
  }
}

export default function Bar(monitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor

  return (
    <>
      {/* Main top bar */}
      <window
        name="Bar"
        namespace="bar"
        class="Bar"
        visible
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        application={app}
        layer={Astal.Layer.TOP}
        anchor={TOP | LEFT | RIGHT}
      >
        <centerbox>
          <box $type="start" class="bar-left" spacing={3}>
            <LeftIsland></LeftIsland>
            <box class="side" spacing={3}>
              <ActiveWindow />
            </box>
          </box>
          <box $type="center" class="bar-center">
            <CenterIsland>
              <MediaPlayer />
            </CenterIsland>
          </box>
          <box $type="end" class="bar-right" spacing={3}>
            <box class="side" spacing={3}>
              <SystemStats />
              <VolumeIndicator />
              <BluetoothIndicator />
              <SysTray />
            </box>
            <RightIsland>
              <Clock />
            </RightIsland>
          </box>
        </centerbox>
      </window>

      {/* Left vertical sidebar for workspaces */}
      <window
        name="WorkspaceBar"
        namespace="workspace-bar"
        class="WorkspaceBar"
        visible
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        application={app}
        layer={Astal.Layer.TOP}
        anchor={LEFT | TOP}
      >
        <box class="workspace-sidebar" orientation={Gtk.Orientation.VERTICAL}>
          <box class="workspace-top-spacer" heightRequest={44} />
          <Workspaces orientation={Gtk.Orientation.VERTICAL} />

          {/* Notch integration with top bar */}
          <box class="workspace-notch">
            <Gtk.DrawingArea
              widthRequest={15}
              heightRequest={5}
              $={(self) => {
                const drawNotch = () => {
                  self.queue_draw()
                }

                self.set_draw_func((area, cr, width, height) => {
                  const circleRadius = 87
                  const notchCenterX = 5
                  const notchCenterY = 5
                  cr.setFillRule(1) // Cairo.FillRule.EVEN_ODD
                  cr.rectangle(0, 0, width, height)
                  cr.arc(
                    notchCenterX,
                    notchCenterY,
                    circleRadius,
                    0,
                    Math.PI * 2,
                  )
                  // Use matugen surface-container-lowest color (refreshed on each draw)
                  const [r, g, b] = getWorkspaceBarBackgroundColor()
                  cr.setSourceRGB(r, g, b)
                  cr.fill()
                })

                // Listen for matugen color changes and redraw
                const unsubscribe = onMatugenChange(drawNotch)

                // Cleanup listener on destroy
                self.connect("destroy", () => {
                  unsubscribe()
                })
              }}
            />
          </box>
        </box>
      </window>
    </>
  )
}
