#!/bin/bash
# fix-mouse.sh - Diagnose and fix macOS mouse choppiness/stuttering issues
#
# Common causes:
# - Display scaling/resolution mismatches between monitors
# - Mouse acceleration settings
# - Accessibility features interfering
# - WindowServer cache issues
# - Background processes consuming resources
# - Mission Control/Spaces settings

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
info()  { echo -e "${BLUE}[i]${NC} $1"; }
section() { echo -e "\n${BOLD}${CYAN}▶ $1${NC}\n"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Diagnose and fix macOS mouse choppiness/stuttering issues.

Options:
  --diagnose         Run diagnostic checks only (no changes)
  --fix-scaling      Fix display scaling issues (recommended)
  --fix-acceleration Reset mouse acceleration settings
  --fix-windowserver Restart WindowServer (logs you out!)
  --fix-all          Apply all fixes except WindowServer restart
  --reset-defaults   Reset all mouse/trackpad settings to defaults
  -h, --help         Show this help

Recommended workflow:
  1. Run --diagnose to see what might be wrong
  2. Try --fix-all first (safe, no logout required)
  3. If still choppy, try --fix-windowserver (requires logout)

EOF
}

DIAGNOSE_ONLY=false
FIX_SCALING=false
FIX_ACCELERATION=false
FIX_WINDOWSERVER=false
FIX_ALL=false
RESET_DEFAULTS=false

# Parse arguments
if [[ $# -eq 0 ]]; then
    DIAGNOSE_ONLY=true
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --diagnose)         DIAGNOSE_ONLY=true; shift ;;
        --fix-scaling)      FIX_SCALING=true; shift ;;
        --fix-acceleration) FIX_ACCELERATION=true; shift ;;
        --fix-windowserver) FIX_WINDOWSERVER=true; shift ;;
        --fix-all)          FIX_ALL=true; shift ;;
        --reset-defaults)   RESET_DEFAULTS=true; shift ;;
        -h|--help)          usage; exit 0 ;;
        *)                  error "Unknown option: $1"; usage; exit 1 ;;
    esac
done

if $FIX_ALL; then
    FIX_SCALING=true
    FIX_ACCELERATION=true
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           macOS Mouse Choppiness Diagnostic Tool            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# DIAGNOSTICS
# ═══════════════════════════════════════════════════════════════════════════

section "System Information"

macos_version=$(sw_vers -productVersion)
info "macOS Version: $macos_version"

# Check for multiple displays
display_count=$(system_profiler SPDisplaysDataType | grep -c "Resolution:" || echo 0)
info "Displays connected: $display_count"

if [[ $display_count -gt 1 ]]; then
    warn "Multiple displays detected - this is a common cause of mouse choppiness"
    echo ""
    echo "  Display information:"
    system_profiler SPDisplaysDataType | grep -E "Resolution:|Main Display:|Display Type:|Mirror:" | sed 's/^/    /'
fi

section "Current Mouse Settings"

# Check mouse tracking speed
tracking_speed=$(defaults read -g com.apple.mouse.scaling 2>/dev/null || echo "not set")
info "Mouse tracking speed: $tracking_speed"

# Check scroll direction
scroll_natural=$(defaults read -g com.apple.swipescrolldirection 2>/dev/null || echo "not set")
info "Natural scrolling: $scroll_natural"

# Check accessibility zoom
zoom_enabled=$(defaults read com.apple.universalaccess closeViewScrollWheelToggle 2>/dev/null || echo "0")
if [[ "$zoom_enabled" == "1" ]]; then
    warn "Accessibility zoom is ENABLED - can cause mouse lag"
else
    log "Accessibility zoom is disabled"
fi

# Check reduce motion
reduce_motion=$(defaults read com.apple.Accessibility ReduceMotionEnabled 2>/dev/null || echo "0")
info "Reduce motion: $reduce_motion"

section "WindowServer & Graphics"

# Check WindowServer CPU usage
ws_cpu=$(ps aux | grep -i windowserver | grep -v grep | awk '{print $3}' | head -1)
info "WindowServer CPU usage: ${ws_cpu}%"

if [[ $(echo "$ws_cpu > 20" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
    warn "WindowServer CPU usage is high (${ws_cpu}%) - may cause mouse lag"
fi

# Check for external GPU issues
gpu_info=$(system_profiler SPDisplaysDataType | grep "Chipset Model:" | head -1)
info "GPU: $(echo "$gpu_info" | cut -d: -f2 | xargs)"

section "Mission Control & Spaces"

# Check spaces count
spaces_count=$(defaults read com.apple.spaces SpacesDisplayConfiguration 2>/dev/null | grep -c "ManagedSpaceID" || echo "unknown")
info "Number of spaces/desktops: $spaces_count"

# Check Mission Control settings
mc_group_windows=$(defaults read com.apple.dock expose-group-apps 2>/dev/null || echo "not set")
info "Mission Control groups windows by app: $mc_group_windows"

section "Performance Indicators"

# Check memory pressure
memory_pressure=$(memory_pressure 2>/dev/null | grep "System-wide memory free percentage:" | awk '{print $5}' | tr -d '%')
if [[ -n "$memory_pressure" ]]; then
    info "Memory free: ${memory_pressure}%"
    if [[ $memory_pressure -lt 10 ]]; then
        warn "Low memory available - may cause system-wide lag"
    fi
fi

# Check for resource-heavy processes
echo ""
info "Top CPU-consuming processes:"
ps aux | sort -rk 3 | head -6 | tail -5 | awk '{printf "    %5s%% - %s\n", $3, $11}'

section "Common Issues Found"

issues_found=0

# Issue 1: Multiple displays with different scaling
if [[ $display_count -gt 1 ]]; then
    echo -e "${YELLOW}[1]${NC} Multiple displays can cause mouse lag when crossing screens"
    echo "    Fix: Use --fix-scaling to optimize display settings"
    ((issues_found++))
fi

# Issue 2: Accessibility zoom enabled
if [[ "$zoom_enabled" == "1" ]]; then
    echo -e "${YELLOW}[2]${NC} Accessibility zoom is enabled"
    echo "    Fix: Will be disabled with --fix-all or System Settings > Accessibility > Zoom"
    ((issues_found++))
fi

# Issue 3: High WindowServer CPU
if [[ $(echo "$ws_cpu > 20" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
    echo -e "${YELLOW}[3]${NC} WindowServer using high CPU (${ws_cpu}%)"
    echo "    Fix: Use --fix-windowserver to restart (requires logout)"
    ((issues_found++))
fi

# Issue 4: Low memory
if [[ -n "$memory_pressure" ]] && [[ $memory_pressure -lt 10 ]]; then
    echo -e "${YELLOW}[4]${NC} Low available memory (${memory_pressure}% free)"
    echo "    Fix: Close unused applications or run disk cleanup"
    ((issues_found++))
fi

if [[ $issues_found -eq 0 ]]; then
    log "No obvious issues detected"
    echo ""
    info "If mouse is still choppy, try:"
    echo "    1. Run 'sudo ./fix-mouse.sh --fix-all' (requires password)"
    echo "    2. Check for macOS updates (System Settings > Software Update)"
    echo "    3. Try --fix-windowserver as a last resort (logs you out)"
fi

# ═══════════════════════════════════════════════════════════════════════════
# FIXES
# ═══════════════════════════════════════════════════════════════════════════

if $DIAGNOSE_ONLY; then
    echo ""
    info "Diagnostic complete. Run with --fix-all to apply fixes."
    exit 0
fi

apply_fixes=false

if $FIX_SCALING || $FIX_ACCELERATION || $FIX_WINDOWSERVER || $RESET_DEFAULTS; then
    apply_fixes=true
fi

if ! $apply_fixes; then
    exit 0
fi

section "Applying Fixes"

if $RESET_DEFAULTS; then
    warn "Resetting all mouse/trackpad settings to macOS defaults..."

    defaults delete -g com.apple.mouse.scaling 2>/dev/null || true
    defaults delete -g com.apple.trackpad.scaling 2>/dev/null || true
    defaults delete -g com.apple.swipescrolldirection 2>/dev/null || true

    log "Mouse/trackpad settings reset to defaults"
fi

if $FIX_SCALING; then
    info "Optimizing display scaling for mouse performance..."

    # Disable accessibility zoom if enabled
    if [[ "$zoom_enabled" == "1" ]]; then
        defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool false
        log "Disabled accessibility zoom"
    fi

    # Set optimal mouse tracking (1.5 is a good balance)
    defaults write -g com.apple.mouse.scaling -float 1.5
    log "Set mouse tracking speed to optimal value"

    # Disable mouse acceleration for consistent movement
    defaults write -g com.apple.mouse.linear -bool true
    log "Enabled linear mouse movement (disabled acceleration)"

    # Restart Dock to apply some settings
    killall Dock 2>/dev/null || true
    log "Restarted Dock"
fi

if $FIX_ACCELERATION; then
    info "Resetting mouse acceleration settings..."

    # Reset mouse scaling
    defaults write -g com.apple.mouse.scaling -float 1.0

    # Try both linear and non-linear to reset
    defaults delete -g com.apple.mouse.linear 2>/dev/null || true

    log "Mouse acceleration reset"
fi

if $FIX_WINDOWSERVER; then
    warn "This will restart WindowServer and LOG YOU OUT!"
    read -p "Continue? [y/N] " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Restarting WindowServer in 3 seconds..."
        sleep 3
        sudo killall -HUP WindowServer
    else
        warn "Skipped WindowServer restart"
    fi
fi

section "Summary"

log "Fixes applied successfully"
echo ""
info "You may need to:"
echo "  1. Log out and back in for all changes to take effect"
echo "  2. Restart your Mac if issues persist"
echo "  3. Check System Settings > Displays for scaling options"
echo ""
info "Test your mouse across screens now. If still choppy:"
echo "  - Try reducing display resolution/scaling"
echo "  - Disconnect external displays temporarily to isolate the issue"
echo "  - Check for macOS updates"
echo ""
