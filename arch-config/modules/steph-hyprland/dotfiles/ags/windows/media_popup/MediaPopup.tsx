import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Astal from "gi://Astal?version=4.0"
import Pango from "gi://Pango?version=1.0"
import app from "ags/gtk4/app"
import { createBinding, With } from "gnim"
import { createPoll } from "ags/time"
import AstalMpris from "gi://AstalMpris?version=0.1"
import { mediaPopupVisible, closeAllPopups } from "@common/vars"
import { bindPopupVisibility } from "@utils/popupVisibility"

function formatTime(seconds: number): string {
  if (!seconds || seconds < 0) return "0:00"
  const m = Math.floor(seconds / 60)
  const s = Math.floor(seconds % 60)
  return `${m}:${s.toString().padStart(2, "0")}`
}

function CoverArt({ player }: { player: AstalMpris.Player }) {
  return (
    <box class="media-popup-cover" halign={Gtk.Align.CENTER}>
      <image
        class="cover-image"
        file={createBinding(player, "coverArt")}
        pixelSize={220}
      />
    </box>
  )
}

function TrackInfo({ player }: { player: AstalMpris.Player }) {
  return (
    <box
      class="media-popup-info"
      orientation={Gtk.Orientation.VERTICAL}
      spacing={2}
      halign={Gtk.Align.CENTER}
    >
      <label
        class="media-popup-title"
        label={createBinding(player, "title").as((t) => t || "Unknown Title")}
        maxWidthChars={35}
        ellipsize={Pango.EllipsizeMode.END}
        halign={Gtk.Align.CENTER}
      />
      <label
        class="media-popup-artist"
        label={createBinding(player, "artist").as((a) => a || "Unknown Artist")}
        maxWidthChars={35}
        ellipsize={Pango.EllipsizeMode.END}
        halign={Gtk.Align.CENTER}
      />
      <label
        class="media-popup-album"
        label={createBinding(player, "album").as((a) => a || "")}
        maxWidthChars={35}
        ellipsize={Pango.EllipsizeMode.END}
        halign={Gtk.Align.CENTER}
        visible={createBinding(player, "album").as(
          (a) => a !== null && a !== "",
        )}
      />
    </box>
  )
}

function PositionBar({ player }: { player: AstalMpris.Player }) {
  // Poll position every second for smooth updates
  const position = createPoll(0, 1000, () => player.position)

  return (
    <box
      class="media-popup-position"
      orientation={Gtk.Orientation.VERTICAL}
      spacing={4}
    >
      <slider
        class="position-slider"
        drawValue={false}
        orientation={Gtk.Orientation.HORIZONTAL}
        widthRequest={240}
        value={position((pos) => {
          const len = player.length
          if (!len || len <= 0) return 0
          return pos / len
        })}
        onChangeValue={(self, _, val) => {
          const len = player.length
          if (len && len > 0) {
            player.position = val * len
          }
        }}
      />
      <box class="position-times" spacing={4}>
        <label
          class="position-current"
          label={position((p) => formatTime(p))}
          halign={Gtk.Align.START}
          hexpand
        />
        <label
          class="position-length"
          label={createBinding(player, "length").as((l) => formatTime(l))}
          halign={Gtk.Align.END}
        />
      </box>
    </box>
  )
}

function PlaybackControls({ player }: { player: AstalMpris.Player }) {
  const status = createBinding(player, "playbackStatus")

  return (
    <box
      class="media-popup-controls"
      spacing={16}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <button
        class="control-btn shuffle-btn"
        onClicked={() => player.shuffle()}
        tooltipText="Shuffle"
        visible={createBinding(player, "canGoNext")}
      >
        <label label="󰒝" />
      </button>

      <button
        class="control-btn prev-btn"
        onClicked={() => player.previous()}
        visible={createBinding(player, "canGoPrevious")}
        tooltipText="Previous"
      >
        <label label="󰒮" />
      </button>

      <button
        class={status.as((s) =>
          s === AstalMpris.PlaybackStatus.PLAYING
            ? "control-btn play-btn playing"
            : "control-btn play-btn paused",
        )}
        onClicked={() => player.play_pause()}
        visible={createBinding(player, "canControl")}
        tooltipText="Play / Pause"
      >
        <label
          label={status.as((s) =>
            s === AstalMpris.PlaybackStatus.PLAYING ? "󰏤" : "󰐊",
          )}
        />
      </button>

      <button
        class="control-btn next-btn"
        onClicked={() => player.next()}
        visible={createBinding(player, "canGoNext")}
        tooltipText="Next"
      >
        <label label="󰒭" />
      </button>

      <button
        class="control-btn loop-btn"
        onClicked={() => player.loop()}
        tooltipText="Loop"
        visible={createBinding(player, "canGoNext")}
      >
        <label label="󰑖" />
      </button>
    </box>
  )
}

function PlayerContent({ player }: { player: AstalMpris.Player }) {
  return (
    <box
      class="media-popup-content"
      orientation={Gtk.Orientation.VERTICAL}
      spacing={12}
    >
      <CoverArt player={player} />
      <TrackInfo player={player} />
      <PositionBar player={player} />
      <PlaybackControls player={player} />
    </box>
  )
}

function NoPlayer() {
  return (
    <box
      class="media-popup-empty"
      orientation={Gtk.Orientation.VERTICAL}
      spacing={8}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <label class="empty-icon" label="󰝚" />
      <label class="empty-label" label="No media playing" />
    </box>
  )
}

export default function MediaPopup(monitor: Gdk.Monitor) {
  const { TOP } = Astal.WindowAnchor
  const mpris = AstalMpris.get_default()

  const win = (
    <window
      name="MediaPopup"
      namespace="media-popup"
      class="MediaPopup"
      visible={false}
      gdkmonitor={monitor}
      application={app}
      layer={Astal.Layer.OVERLAY}
      anchor={TOP}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self: Astal.Window) => {
        bindPopupVisibility(self, mediaPopupVisible)

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
      <box class="media-popup-container">
        <With value={createBinding(mpris, "players")}>
          {(ps: Array<AstalMpris.Player>) =>
            ps[0] ? <PlayerContent player={ps[0]} /> : <NoPlayer />
          }
        </With>
      </box>
    </window>
  ) as Astal.Window

  return win
}
