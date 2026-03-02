import { Gtk } from "ags/gtk4"
import { readFile } from "ags/file"
import GLib from "gi://GLib?version=2.0"
import Gio from "gi://Gio?version=2.0"
import { onMatugenChange } from "@common/matugen"

function getBarBackgroundColor(): [number, number, number] {
  try {
    const matugenPath = GLib.get_home_dir() + "/.cache/matugen/colors.json"
    const content = readFile(matugenPath)
    if (!content) return [0.078, 0.098, 0.125]

    const json = JSON.parse(content)
    const bgHex = json.defs?.surface_container_lowest || "#141620"

    const hex = bgHex.replace("#", "")
    const r = parseInt(hex.substring(0, 2), 16) / 255
    const g = parseInt(hex.substring(2, 4), 16) / 255
    const b = parseInt(hex.substring(4, 6), 16) / 255

    return [r, g, b]
  } catch (e) {
    console.error("Failed to read matugen colors:", e)
    return [0.078, 0.098, 0.125]
  }
}

interface NotchProps {
  position: "left" | "right"
  circleRadius?: number
  notchCenterX?: number
  notchCenterY?: number
  width?: number
  height?: number
}

export function Notch({
  position,
  circleRadius = 60,
  notchCenterX = 56,
  notchCenterY = 60,
  width = 60,
  height = 60,
}: NotchProps) {
  return (
    <Gtk.DrawingArea
      widthRequest={width}
      heightRequest={height}
      class="notch-canvas"
      $={(self) => {
        const drawNotch = () => self.queue_draw()

        self.set_draw_func((area, cr, w, h) => {
          cr.setFillRule(1)
          cr.rectangle(0, 0, w, h)
          cr.arc(notchCenterX, notchCenterY, circleRadius, 0, Math.PI * 2)

          const [r, g, b] = getBarBackgroundColor()
          cr.setSourceRGB(r, g, b)
          cr.fill()
        })

        const unsubscribe = onMatugenChange(drawNotch)
        self.connect("destroy", () => unsubscribe())
      }}
    />
  )
}

export function LeftNotch(props?: Partial<NotchProps>) {
  return (
    <Notch
      position="left"
      circleRadius={60}
      notchCenterX={56}
      notchCenterY={60}
      width={60}
      height={60}
      {...props}
    />
  )
}

export function RightNotch(props?: Partial<NotchProps>) {
  return (
    <Notch
      position="right"
      circleRadius={60}
      notchCenterX={4}
      notchCenterY={60}
      width={60}
      height={60}
      {...props}
    />
  )
}

export function VerticalNotch(props?: Partial<NotchProps>) {
  return (
    <Notch
      position="left"
      circleRadius={37}
      notchCenterX={35}
      notchCenterY={35}
      width={15}
      height={35}
      {...props}
    />
  )
}

export function LeftIsland({ children }: { children?: JSX.Element }) {
  return (
    <box class="island left-island">
      <box class="content">
        <Gtk.Button
          class="notch-launcher-btn"
          valign={Gtk.Align.CENTER}
          halign={Gtk.Align.CENTER}
          onClicked={() => {
            try {
              const proc = Gio.Subprocess.new(
                [
                  "bash",
                  GLib.get_home_dir() +
                    "/.config/rofi/launchers/type-1/launcher.sh",
                ],
                Gio.SubprocessFlags.NONE,
              )
            } catch (e) {
              console.error("Failed to launch rofi:", e)
            }
          }}
        >
          <image iconName="custom-arch" pixel_size={30} />
        </Gtk.Button>
        {children}
      </box>
      <LeftNotch />
    </box>
  )
}

export function RightIsland({ children }: { children?: JSX.Element }) {
  return (
    <box class="island right-island">
      <RightNotch />
      <box class="content">{children}</box>
    </box>
  )
}

export function CenterIsland({ children }: { children?: JSX.Element }) {
  return (
    <box class="island center-island">
      <RightNotch />
      <box class="content">{children}</box>
      <LeftNotch />
    </box>
  )
}
