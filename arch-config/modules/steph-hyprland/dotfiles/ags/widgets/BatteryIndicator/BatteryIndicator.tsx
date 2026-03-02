import { createBinding } from "gnim"
import { Gtk } from "ags/gtk4"
import AstalBattery from "gi://AstalBattery?version=0.1"

function BatteryPill({ iconName, value }: { iconName: any; value: any }) {
  return (
    <box
      class="battery-pill"
      spacing={4}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <image iconName={iconName} pixelSize={14} />
      <label class="battery-value" label={value} />
    </box>
  )
}

export default function BatteryIndicator() {
  const bat = AstalBattery.get_default()

  return (
    <button class="battery-indicator" visible={createBinding(bat, "isPresent")}>
      <BatteryPill
        iconName={createBinding(bat, "batteryIconName")}
        value={createBinding(bat, "percentage").as(
          (p) => `${Math.floor(p * 100)}%`,
        )}
      />
    </button>
  )
}
