import GLib from "gi://GLib?version=2.0"
import Astal from "gi://Astal?version=4.0"
import { createEffect } from "gnim"

/**
 * Bind a reactive boolean state (from `createState`) to a popup
 * window's visibility, deferring the hide to the next GLib idle
 * tick so GTK4 can drain its frame-clock handlers before the
 * native surface is unrealized.
 *
 * This prevents the noisy (but harmless) warnings:
 *   gtk_native_unrealize: assertion 'clock != NULL' failed
 *   verify_priv_unrealized: runtime check failed …
 *
 * Usage — remove the `visible={state}` binding from the window
 * JSX and instead call this inside the `$` setup callback:
 *
 *   <window
 *     visible={false}
 *     $={(self: Astal.Window) => {
 *       bindPopupVisibility(self, myVisibleState)
 *       // … other setup (key controllers, etc.)
 *     }}
 *   >
 *
 * @param win    The Astal overlay/popup window
 * @param state  The reactive getter from createState (e.g. `calendarPopupVisible`)
 */
export function bindPopupVisibility(win: Astal.Window, state: () => boolean) {
  createEffect(() => {
    const visible = state()

    if (visible) {
      // Show immediately — no risk of stale frame-clock state
      win.visible = true
    } else {
      // Defer the hide to the next idle tick so GTK4 can process
      // any pending frame-clock callbacks before unrealizing the
      // native surface.
      GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
        win.visible = false
        return GLib.SOURCE_REMOVE
      })
    }
  })
}
