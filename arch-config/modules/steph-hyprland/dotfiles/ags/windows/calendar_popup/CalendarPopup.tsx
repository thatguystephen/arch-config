import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Astal from "gi://Astal?version=4.0"
import GLib from "gi://GLib?version=2.0"
import app from "ags/gtk4/app"
import { calendarPopupVisible, closeAllPopups } from "@common/vars"
import { bindPopupVisibility } from "@utils/popupVisibility"

function CalendarHeader() {
  const now = GLib.DateTime.new_now_local()!
  const monthYear = now.format("%B %Y") ?? ""

  return (
    <box class="calendar-header" spacing={8}>
      <label
        class="calendar-month-year"
        label={monthYear}
        halign={Gtk.Align.START}
        hexpand
      />
    </box>
  )
}

function CalendarWidget() {
  return (
    <box
      class="calendar-widget-container"
      $={(self: Gtk.Box) => {
        const cal = new Gtk.Calendar({
          showDayNames: true,
          showHeading: true,
          showWeekNumbers: false,
          hexpand: true,
        })
        cal.add_css_class("calendar-widget")

        // Mark today
        const now = GLib.DateTime.new_now_local()!
        cal.mark_day(now.get_day_of_month())

        self.append(cal)
      }}
    />
  )
}

function QuickInfo() {
  const now = GLib.DateTime.new_now_local()!
  const dayOfYear = now.get_day_of_year()
  const weekNum = Math.ceil(dayOfYear / 7)

  return (
    <box class="calendar-quick-info" spacing={12} halign={Gtk.Align.CENTER}>
      <box class="quick-info-item" spacing={4}>
        <label class="quick-info-icon" label="󰃭" />
        <label class="quick-info-text" label={`Week ${weekNum}`} />
      </box>
      <box class="quick-info-item" spacing={4}>
        <label class="quick-info-icon" label="󰔠" />
        <label class="quick-info-text" label={`Day ${dayOfYear}`} />
      </box>
    </box>
  )
}

export default function CalendarPopup(monitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor

  const win = (
    <window
      name="CalendarPopup"
      namespace="calendar-popup"
      class="CalendarPopup"
      visible={false}
      gdkmonitor={monitor}
      application={app}
      layer={Astal.Layer.OVERLAY}
      anchor={TOP | RIGHT}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self: Astal.Window) => {
        bindPopupVisibility(self, calendarPopupVisible)

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
        class="calendar-popup-container"
        orientation={Gtk.Orientation.VERTICAL}
        spacing={12}
      >
        <CalendarHeader />
        <CalendarWidget />
        <QuickInfo />
      </box>
    </window>
  ) as Astal.Window

  return win
}
