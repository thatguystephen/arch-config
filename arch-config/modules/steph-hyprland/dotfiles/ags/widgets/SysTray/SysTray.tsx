import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import GLib from "gi://GLib?version=2.0"
import GObject from "gi://GObject?version=2.0"
import { createBinding, createState, For } from "gnim"
import AstalTray from "gi://AstalTray?version=0.1"

// ─── Persistent Order Storage ────────────────────────────
// Save/load tray icon order so it persists across restarts
const ORDER_FILE = GLib.get_user_config_dir() + "/ags/systray-order.json"

function loadSavedOrder(): string[] {
  try {
    const [ok, contents] = GLib.file_get_contents(ORDER_FILE)
    if (ok && contents) {
      const decoded =
        typeof contents === "string"
          ? contents
          : new TextDecoder().decode(contents)
      return JSON.parse(decoded) as string[]
    }
  } catch (_) {
    // No saved order yet — that's fine
  }
  return []
}

function saveOrder(order: string[]) {
  try {
    const dir = GLib.path_get_dirname(ORDER_FILE)
    GLib.mkdir_with_parents(dir, 0o755)
    GLib.file_set_contents(ORDER_FILE, JSON.stringify(order))
  } catch (e) {
    console.error("Failed to save systray order:", e)
  }
}

// ─── Order State ─────────────────────────────────────────
// Keeps a list of item IDs in the user's preferred order.
// Items not in this list are appended at the end.
const [customOrder, setCustomOrder] = createState<string[]>(loadSavedOrder())

function getItemId(item: AstalTray.TrayItem): string {
  // Use the item's id as the stable identifier
  return item.itemId ?? item.title ?? ""
}

function sortByOrder(
  items: AstalTray.TrayItem[],
  order: string[],
): AstalTray.TrayItem[] {
  const orderMap = new Map<string, number>()
  order.forEach((id, i) => orderMap.set(id, i))

  // Partition into ordered and unordered
  const ordered: AstalTray.TrayItem[] = []
  const unordered: AstalTray.TrayItem[] = []

  for (const item of items) {
    const id = getItemId(item)
    if (orderMap.has(id)) {
      ordered.push(item)
    } else {
      unordered.push(item)
    }
  }

  // Sort the ordered group by saved position
  ordered.sort((a, b) => {
    const ai = orderMap.get(getItemId(a)) ?? 0
    const bi = orderMap.get(getItemId(b)) ?? 0
    return ai - bi
  })

  return [...ordered, ...unordered]
}

// ─── Drag State ──────────────────────────────────────────
// Track which item is currently being dragged
let dragSourceId: string | null = null

// ─── Tray Item Component ─────────────────────────────────
function TrayItem({ item }: { item: AstalTray.TrayItem }) {
  const itemId = getItemId(item)

  const setupItem = (btn: Gtk.Button) => {
    // ── Popover for right-click context menu ────────────
    const popover = Gtk.PopoverMenu.new_from_model(item.menuModel)
    popover.set_parent(btn)
    popover.set_has_arrow(false)

    // Keep the action group in sync so menu items work
    btn.insert_action_group("dbusmenu", item.actionGroup)
    item.connect("notify::action-group", () => {
      btn.insert_action_group("dbusmenu", item.actionGroup)
    })

    // Update the popover model if it changes
    item.connect("notify::menu-model", () => {
      popover.menuModel = item.menuModel
    })

    // ── Right-click gesture → show context menu ─────────
    const rightClick = new Gtk.GestureClick()
    rightClick.set_button(Gdk.BUTTON_SECONDARY)
    rightClick.connect("released", () => {
      popover.popup()
    })
    btn.add_controller(rightClick)

    // ── Middle-click gesture → secondary activate ───────
    const middleClick = new Gtk.GestureClick()
    middleClick.set_button(Gdk.BUTTON_MIDDLE)
    middleClick.connect("released", () => {
      try {
        item.secondary_activate(0, 0)
      } catch (_) {
        // Not all tray items support secondary activate
      }
    })
    btn.add_controller(middleClick)

    // ── Drag Source ──────────────────────────────────────
    const dragSource = new Gtk.DragSource()
    dragSource.set_actions(Gdk.DragAction.MOVE)

    dragSource.connect("prepare", () => {
      dragSourceId = itemId

      // Add a visual drag class
      btn.add_css_class("dragging")

      // Create a content provider with a string (the item ID)
      return Gdk.ContentProvider.new_for_value(itemId)
    })

    dragSource.connect(
      "drag-begin",
      (_self: Gtk.DragSource, drag: Gdk.Drag) => {
        // Create a drag icon from the button's paintable snapshot
        const snapshot = new Gtk.Snapshot()
        const alloc = btn.get_allocation()

        // Use an icon paintable for the drag visual
        const paintable = new Gtk.WidgetPaintable({ widget: btn })
        const icon = Gtk.DragIcon.get_for_drag(drag)
        if (icon instanceof Gtk.DragIcon) {
          icon.set_child(
            new Gtk.Image({
              paintable: paintable,
              pixelSize: Math.max(alloc.width, alloc.height),
            }),
          )
        }
      },
    )

    dragSource.connect("drag-end", () => {
      btn.remove_css_class("dragging")
      dragSourceId = null
    })

    dragSource.connect("drag-cancel", () => {
      btn.remove_css_class("dragging")
      dragSourceId = null
      return false
    })

    btn.add_controller(dragSource)

    // ── Drop Target ─────────────────────────────────────
    const dropTarget = Gtk.DropTarget.new(
      GObject.TYPE_STRING,
      Gdk.DragAction.MOVE,
    )

    dropTarget.connect("enter", () => {
      btn.add_css_class("drop-hover")
      return Gdk.DragAction.MOVE
    })

    dropTarget.connect("leave", () => {
      btn.remove_css_class("drop-hover")
    })

    dropTarget.connect("drop", (_self: Gtk.DropTarget, value: unknown) => {
      btn.remove_css_class("drop-hover")

      const sourceId = typeof value === "string" ? value : dragSourceId
      if (!sourceId || sourceId === itemId) return false

      // Perform the reorder
      setCustomOrder((prev) => {
        // Get the current full list of item IDs from the tray
        const tray = AstalTray.get_default()
        const allItems = tray.get_items()
        const currentIds = allItems.map(getItemId)

        // Build the working order: start with saved, add any new ones
        const workingOrder: string[] = []
        for (const id of prev) {
          if (currentIds.includes(id)) workingOrder.push(id)
        }
        for (const id of currentIds) {
          if (!workingOrder.includes(id)) workingOrder.push(id)
        }

        // Find positions and swap
        const srcIdx = workingOrder.indexOf(sourceId)
        const dstIdx = workingOrder.indexOf(itemId)
        if (srcIdx === -1 || dstIdx === -1) return prev

        // Remove source and insert at destination
        workingOrder.splice(srcIdx, 1)
        workingOrder.splice(dstIdx, 0, sourceId)

        // Persist the new order
        saveOrder(workingOrder)
        return workingOrder
      })

      return true
    })

    btn.add_controller(dropTarget)
  }

  return (
    <button
      class="tray-item"
      tooltipText={createBinding(item, "tooltipMarkup")}
      onClicked={() => {
        try {
          item.activate(0, 0)
        } catch (_) {
          // Some tray items don't support activate
        }
      }}
      $={(self: Gtk.Button) => setupItem(self)}
    >
      <image gicon={createBinding(item, "gicon")} pixelSize={14} />
    </button>
  )
}

// ─── SysTray Pill Component ──────────────────────────────
function SysTrayPill({ items }: { items: any }) {
  return (
    <box
      class="systray-pill"
      spacing={0}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <For each={items}>
        {(item: AstalTray.TrayItem) => <TrayItem item={item} />}
      </For>
    </box>
  )
}

// ─── SysTray Container ───────────────────────────────────
export default function SysTray() {
  const tray = AstalTray.get_default()
  const items = createBinding(tray, "items")

  // Derive a sorted list from items + customOrder
  const sortedItems = items.as((rawItems: AstalTray.TrayItem[]) => {
    const order = customOrder() as unknown as string[]
    return sortByOrder(rawItems, order)
  })

  return (
    <box class="systray">
      <SysTrayPill items={sortedItems} />
    </box>
  )
}
