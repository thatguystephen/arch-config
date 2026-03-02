// ═══════════════════════════════════════════════════════════
// SEPARATOR COMPONENT
// Optional visual divider between island groups
// Inspired by: yuu bar minimal aesthetic
// ═══════════════════════════════════════════════════════════

interface SeparatorProps {
  className?: string
  vertical?: boolean
}

export default function Separator({
  className = "",
  vertical = true,
}: SeparatorProps) {
  return (
    <box
      class={`island-separator ${vertical ? "vertical" : "horizontal"} ${className}`}
    />
  )
}
