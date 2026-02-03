#!/usr/bin/env sh
set -eu

# Configuration
MONITOR_CONF="$HOME/.config/hypr/monitors.conf"
INTERNAL_DESC="Lenovo Group Limited 0x4146"
EXTERNAL_DESC="Acer Technologies EDA343CUR H 2411019992X00"

# Helper to write the config and reload
apply_monitor_config() {
    echo "$1" > "$MONITOR_CONF"
    hyprctl reload
}

internal_only() {
    echo "Switching to Internal Monitor..."
    CONF="monitor=desc:${INTERNAL_DESC},preferred,0x0,2.0
monitor=desc:${EXTERNAL_DESC},disable"
    apply_monitor_config "$CONF"
}

external_only() {
    echo "Switching to External Monitor..."
    CONF="monitor=desc:${EXTERNAL_DESC},preferred,0x0,1.0
monitor=desc:${INTERNAL_DESC},disable"
    apply_monitor_config "$CONF"
}

has_external() {
    hyprctl monitors -j 2>/dev/null | grep -Fq "${EXTERNAL_DESC}"
}

# Initial state check
if has_external; then
    current_state="external"
    external_only
else
    current_state="internal"
    internal_only
fi

# Main loop
while :; do
    # Check if external monitor is connected/active
    if has_external; then
        if [ "${current_state}" != "external" ]; then
            external_only
            current_state="external"
        fi
    else
        if [ "${current_state}" != "internal" ]; then
            internal_only
            current_state="internal"
        fi
    fi
    sleep 2
done
