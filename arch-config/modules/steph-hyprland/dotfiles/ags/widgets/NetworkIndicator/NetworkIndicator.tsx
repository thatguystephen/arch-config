import { createBinding, With } from "gnim"
import { Gtk } from "ags/gtk4"
import AstalNetwork from "gi://AstalNetwork?version=0.1"

function NetworkPill({ iconName, tooltip }: { iconName: any; tooltip?: any }) {
  return (
    <box
      class="network-pill"
      spacing={4}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <image iconName={iconName} pixelSize={14} tooltipText={tooltip} />
    </box>
  )
}

export default function NetworkIndicator() {
  const network = AstalNetwork.get_default()
  const primary = createBinding(network, "primary")

  return (
    <button
      class="network-indicator"
      visible={primary.as((p) => p !== AstalNetwork.Primary.UNKNOWN)}
    >
      <With value={primary}>
        {(p: AstalNetwork.Primary) =>
          p === AstalNetwork.Primary.WIFI ? (
            <NetworkPill
              iconName={createBinding(network.wifi, "iconName")}
              tooltip={createBinding(network.wifi, "ssid")}
            />
          ) : (
            p === AstalNetwork.Primary.WIRED && (
              <NetworkPill
                iconName={createBinding(network.wired, "iconName")}
              />
            )
          )
        }
      </With>
    </button>
  )
}
