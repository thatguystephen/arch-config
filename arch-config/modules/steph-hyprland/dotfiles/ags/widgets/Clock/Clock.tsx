import Gtk from "gi://Gtk?version=4.0"
import { With } from "gnim"
import { currentTime, currentDate, toggleCalendarPopup } from "@common/vars"

function DigitStack(index: number) {
  return (
    <stack
      $={(self: Gtk.Stack) => (
        <With value={currentTime}>
          {(time: string) => {
            self.visibleChildName = time?.[index] ?? "0"
            return null
          }}
        </With>
      )}
      transitionDuration={300}
      transitionType={Gtk.StackTransitionType.SLIDE_UP_DOWN}
      class="digit-stack"
    >
      {Array.from({ length: 10 }, (_, i) => (
        <label $type="named" name={i.toString()} label={i.toString()} />
      ))}
    </stack>
  )
}

export default function Clock() {
  return (
    <button
      class="clock"
      onClicked={() => toggleCalendarPopup()}
      tooltipText="Toggle calendar"
    >
      <box
        orientation={Gtk.Orientation.VERTICAL}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
        spacing={0}
      >
        <box
          class="clock-time"
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
        >
          {DigitStack(0)}
          {DigitStack(1)}
          <label label=":" class="clock-separator" />
          {DigitStack(3)}
          {DigitStack(4)}
        </box>
        <With value={currentDate}>
          {(date: string) => (
            <label
              class="clock-date"
              label={date || ""}
              halign={Gtk.Align.CENTER}
            />
          )}
        </With>
      </box>
    </button>
  )
}
