import app from "ags/gtk4/app"
import { monitorFile } from "ags/file"
import { exec } from "ags/process"

const TMP = "/tmp"

export function compileScss(): string {
  try {
    exec(`sass ${SRC}/style.scss ${TMP}/style.css`)
    return `${TMP}/style.css`
  } catch (err) {
    printerr("Error compiling scss:", err)
    return ""
  }
}

// Hot-reload: watch all .scss files and recompile on change
;(function () {
  const scssFiles = exec(`find -L ${SRC} -iname '*.scss'`).split("\n")

  compileScss()

  scssFiles.forEach((file) =>
    monitorFile(file, () => {
      const css = compileScss()
      if (css) app.apply_css(css)
    }),
  )
})()
