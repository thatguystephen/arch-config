import GLib from "gi://GLib?version=2.0"
import app from "ags/gtk4/app"
import { readFile, monitorFile } from "ags/file"

const MATUGEN_PATH = GLib.get_home_dir() + "/.cache/matugen/colors.json"

// Event listeners for matugen color changes
type MatugenListener = () => void
const matugenListeners: MatugenListener[] = []

export function onMatugenChange(callback: MatugenListener) {
  matugenListeners.push(callback)
  return () => {
    const index = matugenListeners.indexOf(callback)
    if (index > -1) matugenListeners.splice(index, 1)
  }
}

function notifyMatugenChange() {
  matugenListeners.forEach((listener) => {
    try {
      listener()
    } catch (e) {
      console.error("Matugen listener error:", e)
    }
  })
}

export function applyMatugenColors() {
  try {
    const content = readFile(MATUGEN_PATH)
    if (!content) return

    const json = JSON.parse(content)
    const c = json.defs
    if (!c) return

    // Build CSS variable assignments from all available Matugen tokens.
    // Each variable is guarded with a fallback so missing keys don't break
    // the stylesheet — the SCSS fallback colors in theme.scss take over.
    const vars: Record<string, string | undefined> = {
      // ─── Primary ─────────────────────────────────────
      "--primary": c.primary,
      "--on-primary": c.on_primary,
      "--primary-container": c.primary_container,
      "--on-primary-container": c.on_primary_container,
      "--inverse-primary": c.inverse_primary,
      "--primary-fixed": c.primary_fixed,
      "--primary-fixed-dim": c.primary_fixed_dim,
      "--on-primary-fixed": c.on_primary_fixed,
      "--on-primary-fixed-variant": c.on_primary_fixed_variant,

      // ─── Secondary ───────────────────────────────────
      "--secondary": c.secondary,
      "--on-secondary": c.on_secondary,
      "--secondary-container": c.secondary_container,
      "--on-secondary-container": c.on_secondary_container,
      "--secondary-fixed": c.secondary_fixed,
      "--secondary-fixed-dim": c.secondary_fixed_dim,
      "--on-secondary-fixed": c.on_secondary_fixed,
      "--on-secondary-fixed-variant": c.on_secondary_fixed_variant,

      // ─── Tertiary ────────────────────────────────────
      "--tertiary": c.tertiary,
      "--on-tertiary": c.on_tertiary,
      "--tertiary-container": c.tertiary_container,
      "--on-tertiary-container": c.on_tertiary_container,
      "--tertiary-fixed": c.tertiary_fixed,
      "--tertiary-fixed-dim": c.tertiary_fixed_dim,
      "--on-tertiary-fixed": c.on_tertiary_fixed,
      "--on-tertiary-fixed-variant": c.on_tertiary_fixed_variant,

      // ─── Error ───────────────────────────────────────
      "--error": c.error,
      "--on-error": c.on_error,
      "--error-container": c.error_container,
      "--on-error-container": c.on_error_container,

      // ─── Surface layers (Material 3 tonal system) ────
      "--surface": c.surface,
      "--on-surface": c.on_surface,
      "--surface-variant": c.surface_variant,
      "--on-surface-variant": c.on_surface_variant,
      "--surface-dim": c.surface_dim,
      "--surface-bright": c.surface_bright,
      "--surface-container-lowest": c.surface_container_lowest,
      "--surface-container-low": c.surface_container_low,
      "--surface-container": c.surface_container,
      "--surface-container-high": c.surface_container_high,
      "--surface-container-highest": c.surface_container_highest,

      // ─── Background ──────────────────────────────────
      "--bg": c.background,
      "--fg": c.on_background,

      // ─── Outline / Border ────────────────────────────
      "--border": c.outline,
      "--border-variant": c.outline_variant,

      // ─── Inverse (for special contrast surfaces) ─────
      "--inverse-surface": c.inverse_surface,
      "--inverse-on-surface": c.inverse_on_surface,

      // ─── Scrim / Shadow ──────────────────────────────
      "--scrim": c.scrim,
      "--shadow": c.shadow,

      // ─── Source ──────────────────────────────────────
      "--source-color": c.source_color,
    }

    // Only emit variables that actually have a value from the JSON
    const declarations = Object.entries(vars)
      .filter(([_, v]) => v !== undefined && v !== null)
      .map(([k, v]) => `  ${k}: ${v};`)
      .join("\n")

    const css = `:root {\n${declarations}\n}`

    app.apply_css(css)
    print(
      "Matugen: applied " +
        Object.entries(vars).filter(([_, v]) => v).length +
        " color tokens",
    )
  } catch (e) {
    console.error("Matugen error:", e)
  }
}

export function watchMatugenColors() {
  applyMatugenColors()
  monitorFile(MATUGEN_PATH, () => {
    applyMatugenColors()
    notifyMatugenChange()
  })
}
