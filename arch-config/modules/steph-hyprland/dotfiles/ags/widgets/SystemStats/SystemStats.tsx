import GLib from "gi://GLib?version=2.0"
import { Gtk } from "ags/gtk4"
import { With } from "gnim"
import { createPoll } from "ags/time"

// ═══════════════════════════════════════════════════════════
// SYSTEM STATS WIDGET
// Real-time CPU, RAM, and Disk usage monitoring
// Inspired by: yuu bar system monitoring widgets
// ═══════════════════════════════════════════════════════════

interface SystemInfo {
  cpu: number
  ram: number
  disk: number
}

// Parse /proc/stat to get CPU usage
function getCpuUsage(): number {
  try {
    const [ok, contents] = GLib.file_get_contents("/proc/stat")
    if (!ok || !contents) return 0

    const lines = new TextDecoder().decode(contents).split("\n")
    if (lines.length === 0) return 0

    const cpuLine = lines[0].split(/\s+/).filter((x) => x)
    if (cpuLine.length < 8) return 0

    const idle = parseInt(cpuLine[4]) || 0
    const total = cpuLine
      .slice(1, 8)
      .reduce((acc, val) => acc + (parseInt(val) || 0), 0)

    if (!getCpuUsage.prevIdle || !getCpuUsage.prevTotal) {
      getCpuUsage.prevIdle = idle
      getCpuUsage.prevTotal = total
      return 0
    }

    const idleDelta = idle - getCpuUsage.prevIdle
    const totalDelta = total - getCpuUsage.prevTotal

    getCpuUsage.prevIdle = idle
    getCpuUsage.prevTotal = total

    if (totalDelta === 0) return 0

    const usage = 100 - (idleDelta / totalDelta) * 100
    return Math.round(Math.max(0, Math.min(100, usage)))
  } catch (e) {
    console.error("Failed to get CPU usage:", e)
    return 0
  }
}

// Static properties for CPU calculation
getCpuUsage.prevIdle = 0
getCpuUsage.prevTotal = 0

// Parse /proc/meminfo to get RAM usage
function getRamUsage(): number {
  try {
    const [ok, contents] = GLib.file_get_contents("/proc/meminfo")
    if (!ok || !contents) return 0

    const lines = new TextDecoder().decode(contents).split("\n")

    let memTotal = 0
    let memAvailable = 0

    for (const line of lines) {
      if (line.startsWith("MemTotal:")) {
        const parts = line.split(/\s+/).filter((x) => x)
        memTotal = parseInt(parts[1]) || 0
      } else if (line.startsWith("MemAvailable:")) {
        const parts = line.split(/\s+/).filter((x) => x)
        memAvailable = parseInt(parts[1]) || 0
      }
    }

    if (memTotal === 0) return 0

    const used = memTotal - memAvailable
    const percentage = (used / memTotal) * 100
    return Math.round(Math.max(0, Math.min(100, percentage)))
  } catch (e) {
    console.error("Failed to get RAM usage:", e)
    return 0
  }
}

// Get disk usage for root partition
function getDiskUsage(): number {
  try {
    // Use statvfs instead of df command to avoid shell pipe issues
    const [ok, stdout] = GLib.spawn_command_line_sync("df /")
    if (!ok || !stdout) {
      return 0
    }

    const output = new TextDecoder().decode(stdout)
    const lines = output.split("\n").filter((x) => x)

    // Get the last line which contains the actual data
    if (lines.length < 2) return 0

    const dataLine = lines[1] // Skip header line
    const parts = dataLine.split(/\s+/).filter((x) => x)

    // The percentage is typically the 5th column (Use%)
    if (parts.length >= 5) {
      const percentStr = parts[4].replace("%", "").trim()
      const parsed = parseInt(percentStr)

      if (!isNaN(parsed)) {
        return Math.round(Math.max(0, Math.min(100, parsed)))
      }
    }

    return 0
  } catch (e) {
    console.error("Failed to get disk usage:", e)
    return 0
  }
}

// Poll system stats every 2 seconds
const cpuUsage = createPoll(0, 2000, getCpuUsage)
const ramUsage = createPoll(0, 2000, getRamUsage)
const diskUsage = createPoll(0, 2000, getDiskUsage)

// Individual stat component - each in its own pill
function StatItem({
  iconName,
  value,
  label,
}: {
  iconName: string
  value: number
  label: string
}) {
  return (
    <box
      class="system-stat-pill"
      spacing={4}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <image iconName={iconName} pixelSize={14} />
      <label class="stat-value" label={`${value}%`} />
    </box>
  )
}

export default function SystemStats() {
  return (
    <box class="system-stats" spacing={4}>
      <With value={cpuUsage}>
        {(cpu) => (
          <StatItem iconName="custom-cpu" value={cpu as number} label="CPU" />
        )}
      </With>
      <With value={ramUsage}>
        {(ram) => (
          <StatItem iconName="custom-ram" value={ram as number} label="RAM" />
        )}
      </With>
      <With value={diskUsage}>
        {(disk) => (
          <StatItem
            iconName="custom-drive"
            value={disk as number}
            label="DISK"
          />
        )}
      </With>
    </box>
  )
}
