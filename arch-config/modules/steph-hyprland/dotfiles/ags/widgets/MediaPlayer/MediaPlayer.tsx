import Pango from "gi://Pango?version=1.0"
import { createBinding, With } from "gnim"
import AstalMpris from "gi://AstalMpris?version=0.1"
import { toggleMediaPopup } from "@common/vars"

function getTitle(player: AstalMpris.Player): string {
  return player.artist
    ? `${player.artist} - ${player.title}`
    : player.album
      ? `${player.album} - ${player.title}`
      : `${player.title}`
}

export default function MediaPlayer() {
  const mpris = AstalMpris.get_default()

  return (
    <With value={createBinding(mpris, "players")}>
      {(ps: Array<AstalMpris.Player>) =>
        ps[0] ? (
          <button class="media-player" onClicked={() => toggleMediaPopup()}>
            <box spacing={3}>
              <label
                class="media-player-icon"
                label={createBinding(ps[0], "playbackStatus").as((s) =>
                  s === AstalMpris.PlaybackStatus.PLAYING ? "󰐊" : "󰏤",
                )}
              />
              <label
                class={createBinding(ps[0], "playbackStatus").as((s) =>
                  s === AstalMpris.PlaybackStatus.PLAYING
                    ? "playing"
                    : "paused",
                )}
                maxWidthChars={15}
                ellipsize={Pango.EllipsizeMode.END}
                label={createBinding(ps[0], "metadata").as(() =>
                  getTitle(ps[0]),
                )}
              />
            </box>
          </button>
        ) : (
          <box />
        )
      }
    </With>
  )
}
