import { createBinding, createState, For } from "gnim"
import AstalHyprland from "gi://AstalHyprland?version=0.1"
import Hyprland from "gi://AstalHyprland"
import { Gtk } from "ags/gtk4"

interface WorkspacesProps {
  orientation?: Gtk.Orientation
}

export default function Workspaces({
  orientation = Gtk.Orientation.HORIZONTAL,
}: WorkspacesProps = {}) {
  const hypr = AstalHyprland.get_default()
  const [wsList, setWsList] = createState(hypr.get_workspaces())

  hypr.connect("workspace-added", (_: any, ws: AstalHyprland.Workspace) => {
    setWsList((prev) => [...prev, ws])
  })
  hypr.connect("workspace-removed", (_: any, wsId: number) => {
    setWsList((prev) => prev.filter((w) => w.id !== wsId))
  })

  const sorted = (arr: Array<AstalHyprland.Workspace>) =>
    arr
      .filter((ws) => !(ws.id >= -99 && ws.id <= -2))
      .sort((a, b) => a.id - b.id)

  const focused = createBinding(hypr, "focusedWorkspace").as((ws) => ws.id)

  const isVertical = orientation === Gtk.Orientation.VERTICAL

  return (
    <box
      class="workspaces"
      orientation={orientation}
      spacing={10}
      valign={isVertical ? Gtk.Align.START : Gtk.Align.CENTER}
    >
      <For each={wsList(sorted)}>
        {(ws: AstalHyprland.Workspace) => (
          <button
            class={focused.as((f) =>
              f === ws.id ? "workspace focused" : "workspace unfocused",
            )}
            onClicked={() => ws.focus()}
            tooltipText={`Workspace ${ws.id}`}
            widthRequest={
              isVertical ? 10 : focused.as((f) => (f === ws.id ? 50 : 12))
            }
            heightRequest={
              isVertical ? focused.as((f) => (f === ws.id ? 40 : 10)) : 5
            }
          />
        )}
      </For>
    </box>
  )
}
