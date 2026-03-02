import app from "ags/gtk4/app"

export default function requestHandler(
  argv: string[],
  response: (msg: string) => void,
) {
  const [cmd, ...args] = argv

  switch (cmd) {
    case "toggle": {
      const win = app.get_window(args[0])
      if (win) win.visible = !win.visible
      return response(`toggled ${args[0]}`)
    }
    default:
      return response(`unknown command: ${cmd}`)
  }
}
