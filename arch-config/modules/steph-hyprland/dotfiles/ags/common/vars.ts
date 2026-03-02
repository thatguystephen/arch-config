import GLib from "gi://GLib?version=2.0"
import { createPoll } from "ags/time"
import { createState } from "gnim"

// ─── Clock ───
export const currentTime = createPoll(
  "",
  1000,
  () => GLib.DateTime.new_now_local()!.format("%H:%M")!,
)

export const currentDate = createPoll(
  "",
  60000,
  () => GLib.DateTime.new_now_local()!.format("%A, %B %e")!,
)

// ─── Notifications ───
export const [notificationCount, setNotificationCount] = createState(0)
export const [doNotDisturb, setDoNotDisturb] = createState(false)

// ─── Popup Visibility ───
// Shared toggle states so bar widgets can open/close popup windows
export const [mediaPopupVisible, setMediaPopupVisible] = createState(false)
export const [volumePopupVisible, setVolumePopupVisible] = createState(false)
export const [calendarPopupVisible, setCalendarPopupVisible] =
  createState(false)

export function toggleMediaPopup() {
  setVolumePopupVisible(false)
  setCalendarPopupVisible(false)
  setMediaPopupVisible((v) => !v)
}

export function toggleVolumePopup() {
  setMediaPopupVisible(false)
  setCalendarPopupVisible(false)
  setVolumePopupVisible((v) => !v)
}

export function toggleCalendarPopup() {
  setMediaPopupVisible(false)
  setVolumePopupVisible(false)
  setCalendarPopupVisible((v) => !v)
}

export function closeAllPopups() {
  setMediaPopupVisible(false)
  setVolumePopupVisible(false)
  setCalendarPopupVisible(false)
}
