import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Astal from "gi://Astal?version=4.0"
import Pango from "gi://Pango?version=1.0"
import app from "ags/gtk4/app"
import { timeout } from "ags/time"
import { createBinding, createState, createEffect, For } from "gnim"
import AstalNotifd from "gi://AstalNotifd?version=0.1"
import { setNotificationCount } from "@common/vars"

const TIMEOUT_MS = 5000

function Notification({
  n,
  onDismiss,
}: {
  n: AstalNotifd.Notification
  onDismiss: () => void
}) {
  return (
    <box class="notification" orientation={Gtk.Orientation.VERTICAL} spacing={4}>
      <box class="notification-header" spacing={8}>
        <label
          class="notification-appname"
          label={createBinding(n, "appName")}
          halign={Gtk.Align.START}
          hexpand
        />
        <button class="notification-close" onClicked={onDismiss}>
          <label label="x" />
        </button>
      </box>
      <label
        class="notification-summary"
        label={createBinding(n, "summary")}
        halign={Gtk.Align.START}
        ellipsize={Pango.EllipsizeMode.END}
        maxWidthChars={40}
      />
      <label
        class="notification-body"
        label={createBinding(n, "body")}
        halign={Gtk.Align.START}
        wrap
        maxWidthChars={40}
      />
    </box>
  )
}

export default function NotificationPopups(monitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor
  const notifd = AstalNotifd.get_default()
  const [popups, setPopups] = createState<AstalNotifd.Notification[]>([])

  function removePopup(id: number) {
    setPopups((prev) => prev.filter((p) => p.id !== id))
  }

  notifd.connect("notified", (_: any, id: number) => {
    const n = notifd.get_notification(id)
    if (!n) return

    setPopups((prev) => [n, ...prev])
    setNotificationCount((c) => c + 1)

    timeout(TIMEOUT_MS, () => removePopup(id))
  })

  notifd.connect("resolved", (_: any, id: number) => {
    removePopup(id)
  })

  const win = (
    <window
      name="NotificationPopups"
      namespace="notification-popups"
      class="NotificationPopups"
      visible={false}
      gdkmonitor={monitor}
      application={app}
      layer={Astal.Layer.OVERLAY}
      anchor={TOP | RIGHT}
      keymode={Astal.Keymode.ON_DEMAND}
    >
      <box orientation={Gtk.Orientation.VERTICAL} class="notification-popups" spacing={6}>
        <For each={popups}>
          {(n: AstalNotifd.Notification) => (
            <Notification
              n={n}
              onDismiss={() => {
                removePopup(n.id)
                n.dismiss()
              }}
            />
          )}
        </For>
      </box>
    </window>
  ) as Astal.Window

  // Show window only when there are popups
  createEffect(() => {
    win.visible = popups().length > 0
  })

  return win
}
