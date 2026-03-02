import { Gtk } from "ags/gtk4"
import { createBinding } from "gnim"
import AstalBluetooth from "gi://AstalBluetooth?version=0.1"

function BluetoothPill({ iconName }: { iconName: string }) {
  return (
    <box
      class="bluetooth-pill"
      spacing={4}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <label class="bluetooth-icon" label={iconName} />
    </box>
  )
}

export default function BluetoothIndicator() {
  const bt = AstalBluetooth.get_default()

  return (
    <revealer
      transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
      revealChild={createBinding(bt, "isConnected")}
    >
      <button class="bluetooth-indicator">
        <BluetoothPill iconName="󰬡" />
      </button>
    </revealer>
  )
}
