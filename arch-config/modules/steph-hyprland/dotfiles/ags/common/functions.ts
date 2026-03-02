import GLib from "gi://GLib?version=2.0"

export function pathToURI(path: string): string {
  if (/^[/]/.test(path)) return `file://${path}`
  if (/^[~]/.test(path))
    return `file://${GLib.get_home_dir()}/${path.replace(/^~\/?/, "")}`
  return path
}

export function escapeMarkup(text: string): string {
  return text.replace(/&/g, "&amp;")
}
