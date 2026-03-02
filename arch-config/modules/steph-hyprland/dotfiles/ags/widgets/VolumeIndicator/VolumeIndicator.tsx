import { createBinding } from "gnim"
import { Gtk } from "ags/gtk4"
import AstalWp from "gi://AstalWp?version=0.1"
import { toggleVolumePopup } from "@common/vars"

function VolumePill({ iconName, value }: { iconName: any; value: any }) {
  return (
    <box
      class="volume-pill"
      spacing={4}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <image iconName={iconName} pixelSize={14} />
      <label class="volume-value" label={value} />
    </box>
  )
}

export default function VolumeIndicator() {
  const wp = AstalWp.get_default()!
  const speaker = wp.audio.defaultSpeaker!

  return (
    <button
      class={createBinding(speaker, "mute").as((m) =>
        m ? "volume-indicator muted" : "volume-indicator",
      )}
      onClicked={() => toggleVolumePopup()}
      tooltipText={createBinding(speaker, "volume").as(
        (v) => `Volume: ${Math.round(v * 100)}%`,
      )}
    >
      <VolumePill
        iconName={createBinding(speaker, "volumeIcon")}
        value={createBinding(speaker, "volume").as(
          (v) => `${Math.round(v * 100)}%`,
        )}
      />
    </button>
  )
}
