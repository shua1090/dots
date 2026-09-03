-- Noctalia dynamic colors (Matugen 2.4.1 Syntax)
local M = {
    base00 = '{{colors.surface.dark.hex}}',          -- Background
    base01 = '{{colors.surface_bright.dark.hex}}',   -- Lighter background
    base02 = '{{colors.surface_container.dark.hex}}', -- Selection/Highlight
    base03 = '{{colors.on_surface_variant.dark.hex}}',-- Comments
    base04 = '{{colors.on_surface.dark.hex}}',        -- Dark foreground
    base05 = '{{colors.on_surface.dark.hex}}',        -- Default foreground
    base06 = '{{colors.on_surface.dark.hex}}',        -- Light foreground
    base07 = '{{colors.on_surface.dark.hex}}',        -- Bright foreground
    base08 = '{{colors.primary.dark.hex}}',           -- Variables/Red
    base09 = '{{colors.secondary.dark.hex}}',         -- Integers/Orange
    base0A = '{{colors.tertiary.dark.hex}}',          -- Classes/Yellow
    base0B = '{{colors.primary_fixed.dark.hex}}',     -- Strings/Green
    base0C = '{{colors.secondary_fixed.dark.hex}}',   -- Support/Cyan
    base0D = '{{colors.tertiary_fixed.dark.hex}}',    -- Functions/Blue
    base0E = '{{colors.primary.dark.hex}}',           -- Keywords/Magenta
    base0F = '{{colors.secondary.dark.hex}}',         -- Deprecated/Brown
}

return M
