import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Astal from "gi://Astal?version=4.0"
import app from "ags/gtk4/app"
import { createBinding } from "gnim"
import AstalWp from "gi://AstalWp?version=0.1"
import { volumePopupVisible, closeAllPopups } from "@common/vars"
import { bindPopupVisibility } from "@utils/popupVisibility"

function SpeakerSection() {
  const wp = AstalWp.get_default()!
  const speaker = wp.audio.defaultSpeaker!

  return (
    <box
      class="volume-section speaker-section"
      orientation={Gtk.Orientation.VERTICAL}
      spacing={8}
    >
      <box class="volume-section-header" spacing={8}>
        <image
          class="volume-section-icon"
          iconName={createBinding(speaker, "volumeIcon")}
        />
        <label
          class="volume-section-label"
          label="Speaker"
          hexpand
          halign={Gtk.Align.START}
        />
        <label
          class="volume-section-value"
          label={createBinding(speaker, "volume").as(
            (v) => `${Math.round(v * 100)}%`,
          )}
        />
      </box>

      <box class="volume-slider-row" spacing={8}>
        <slider
          class="volume-slider"
          drawValue={false}
          orientation={Gtk.Orientation.HORIZONTAL}
          hexpand
          value={createBinding(speaker, "volume")}
          onChangeValue={(self, _, val) => {
            speaker.volume = Math.max(0, Math.min(1.5, val))
          }}
        />
      </box>

      <button
        class={createBinding(speaker, "mute").as((m) =>
          m ? "mute-btn muted" : "mute-btn",
        )}
        onClicked={() => {
          speaker.mute = !speaker.mute
        }}
        halign={Gtk.Align.START}
      >
        <box spacing={6}>
          <label
            label={createBinding(speaker, "mute").as((m) => (m ? "󰖁" : "󰕾"))}
            class="mute-icon"
          />
          <label
            label={createBinding(speaker, "mute").as((m) =>
              m ? "Unmute" : "Mute",
            )}
            class="mute-label"
          />
        </box>
      </button>
    </box>
  )
}

function MicrophoneSection() {
  const wp = AstalWp.get_default()!
  const mic = wp.audio.defaultMicrophone

  if (!mic) return <box />

  return (
    <box
      class="volume-section mic-section"
      orientation={Gtk.Orientation.VERTICAL}
      spacing={8}
    >
      <box class="section-divider" />

      <box class="volume-section-header" spacing={8}>
        <label class="volume-section-icon mic-icon" label="󰍬" />
        <label
          class="volume-section-label"
          label="Microphone"
          hexpand
          halign={Gtk.Align.START}
        />
        <label
          class="volume-section-value"
          label={createBinding(mic, "volume").as(
            (v) => `${Math.round(v * 100)}%`,
          )}
        />
      </box>

      <box class="volume-slider-row" spacing={8}>
        <slider
          class="volume-slider mic-slider"
          drawValue={false}
          orientation={Gtk.Orientation.HORIZONTAL}
          hexpand
          value={createBinding(mic, "volume")}
          onChangeValue={(self, _, val) => {
            mic.volume = Math.max(0, Math.min(1, val))
          }}
        />
      </box>

      <button
        class={createBinding(mic, "mute").as((m) =>
          m ? "mute-btn muted" : "mute-btn",
        )}
        onClicked={() => {
          mic.mute = !mic.mute
        }}
        halign={Gtk.Align.START}
      >
        <box spacing={6}>
          <label
            label={createBinding(mic, "mute").as((m) => (m ? "󰍭" : "󰍬"))}
            class="mute-icon"
          />
          <label
            label={createBinding(mic, "mute").as((m) =>
              m ? "Unmute Mic" : "Mute Mic",
            )}
            class="mute-label"
          />
        </box>
      </button>
    </box>
  )
}

export default function VolumePopup(monitor: Gdk.Monitor) {
  const { TOP } = Astal.WindowAnchor

  const win = (
    <window
      name="VolumePopup"
      namespace="volume-popup"
      class="VolumePopup"
      visible={false}
      gdkmonitor={monitor}
      application={app}
      layer={Astal.Layer.OVERLAY}
      anchor={TOP}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self: Astal.Window) => {
        bindPopupVisibility(self, volumePopupVisible)

        const keyCtrl = new Gtk.EventControllerKey()
        keyCtrl.connect(
          "key-pressed",
          (_: Gtk.EventControllerKey, keyval: number) => {
            if (keyval === Gdk.KEY_Escape) {
              closeAllPopups()
            }
          },
        )
        self.add_controller(keyCtrl)
      }}
    >
      <box
        class="volume-popup-container"
        orientation={Gtk.Orientation.VERTICAL}
        spacing={4}
      >
        <SpeakerSection />
        <MicrophoneSection />
      </box>
    </window>
  ) as Astal.Window

  return win
}
