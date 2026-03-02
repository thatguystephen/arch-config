import Pango from "gi://Pango?version=1.0"
import { Gtk } from "ags/gtk4"
import { createBinding, With } from "gnim"
import AstalHyprland from "gi://AstalHyprland?version=0.1"

function WindowPill({ iconName, title }: { iconName: string; title: any }) {
  return (
    <box
      class="window-pill"
      spacing={4}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <label class="window-icon" label={iconName} />
      <label
        class="window-title"
        label={title}
        maxWidthChars={15}
        ellipsize={Pango.EllipsizeMode.END}
      />
    </box>
  )
}

export default function ActiveWindow() {
  const hypr = AstalHyprland.get_default()
  const focused = createBinding(hypr, "focusedClient")

  return (
    <With value={focused}>
      {(client: AstalHyprland.Client | null) => (
        <box
          class={client ? "active-window has-window" : "active-window empty"}
        >
          <WindowPill
            iconName={client ? "󰣆" : "󰕰"}
            title={
              client
                ? createBinding(client, "title").as((t) => t ?? "Desktop")
                : "Desktop"
            }
          />
        </box>
      )}
    </With>
  )
}
