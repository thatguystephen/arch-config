import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Astal from "gi://Astal?version=4.0"
import app from "ags/gtk4/app"
import { createBinding, createState } from "gnim"
import { timeout } from "ags/time"
import AstalWp from "gi://AstalWp?version=0.1"

const HIDE_DELAY = 1500

export default function OSD(monitor: Gdk.Monitor) {
  const wp = AstalWp.get_default()!
  const speaker = wp.audio.defaultSpeaker!
  const [windowVisible, setWindowVisible] = createState(false)

  let hideTimer: ReturnType<typeof timeout> | null = null

  function show() {
    setWindowVisible(true)
    if (hideTimer) hideTimer.cancel()
    hideTimer = timeout(HIDE_DELAY, () => setWindowVisible(false))
  }

  speaker.connect("notify::volume", show)
  speaker.connect("notify::mute", show)

  return (
    <window
      name="OSD"
      namespace="osd"
      class="OSD"
      visible={windowVisible}
      gdkmonitor={monitor}
      application={app}
      layer={Astal.Layer.OVERLAY}
      anchor={Astal.WindowAnchor.BOTTOM}
      keymode={Astal.Keymode.NONE}
    >
      <box class="osd-container" orientation={Gtk.Orientation.VERTICAL}>
        <box class="osd-content" spacing={12}>
          <image
            iconName={createBinding(speaker, "volumeIcon")}
            class="osd-icon"
          />
          <levelbar
            class="osd-level"
            orientation={Gtk.Orientation.HORIZONTAL}
            widthRequest={200}
            value={createBinding(speaker, "volume")}
          />
          <label
            class="osd-value"
            label={createBinding(speaker, "volume").as(
              (v) => `${Math.round(v * 100)}%`,
            )}
          />
        </box>
      </box>
    </window>
  )
}
