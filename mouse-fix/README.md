# Mouse Fix Tool

Diagnose and fix macOS mouse choppiness, stuttering, and laggy cursor movement across multiple displays.

## The Problem You Found

Your system has **4 displays** with different resolutions:
- Built-in: 2560 x 1600 (Retina)
- External 1: 1080 x 1920 (portrait mode)
- External 2: 1920 x 1080 (landscape)
- External 3: 1920 x 1080 (landscape)

This resolution/scaling mismatch is the **#1 cause** of choppy mouse movement when crossing between screens.

## Quick Fix

Run the diagnostic first:
```bash
./fix-mouse.sh --diagnose
```

Then apply recommended fixes:
```bash
sudo ./fix-mouse.sh --fix-all
```

## What It Fixes

### 1. Display Scaling Issues
- Disables accessibility zoom (causes lag)
- Optimizes mouse tracking speed
- Enables linear mouse movement (consistent speed)

### 2. Mouse Acceleration
- Resets acceleration settings
- Provides smooth cursor movement

### 3. WindowServer Issues (last resort)
- Restarts WindowServer if it's consuming too much CPU
- **Warning:** This logs you out!

## Usage

```bash
# Diagnose only (no changes)
./fix-mouse.sh --diagnose

# Apply all safe fixes (no logout required)
sudo ./fix-mouse.sh --fix-all

# Fix specific issues
./fix-mouse.sh --fix-scaling
./fix-mouse.sh --fix-acceleration

# Nuclear option (logs you out)
sudo ./fix-mouse.sh --fix-windowserver

# Reset everything to macOS defaults
./fix-mouse.sh --reset-defaults
```

## Additional Manual Fixes

### For Multi-Display Setups

1. **Match refresh rates:** System Settings > Displays > ensure all displays are 60Hz
2. **Reduce scaling:** Set all external displays to native resolution (no scaling)
3. **Disable portrait display temporarily** to test if that's the culprit
4. **Use one display for testing:** Disconnect all but one external display to isolate the issue

### System Settings Changes

1. System Settings > Accessibility > Display
   - Turn OFF "Reduce motion"
   - Turn OFF "Shake mouse pointer to locate"

2. System Settings > Desktop & Dock
   - Turn OFF "Automatically rearrange Spaces"
   - Turn OFF "Displays have separate Spaces"

3. System Settings > Mouse
   - Set tracking speed to middle (or run `--fix-all`)

## Compatibility

- macOS 10.15+ (Catalina and newer)
- Works with Apple Silicon (M1/M2/M3) and Intel Macs
- Safe to run multiple times

## Recommended Workflow

1. Run diagnostic: `./fix-mouse.sh --diagnose`
2. Try safe fixes: `sudo ./fix-mouse.sh --fix-all`
3. **Log out and back in** to test
4. If still choppy, try disconnecting displays one-by-one to find the culprit
5. Last resort: `sudo ./fix-mouse.sh --fix-windowserver` (logs you out)

## Why This Happens

When macOS manages multiple displays with different:
- Resolutions (2560x1600 vs 1920x1080)
- Orientations (portrait vs landscape)
- Scaling factors (Retina vs non-Retina)

The WindowServer has to constantly recalculate cursor position as you cross screen boundaries. This causes the choppy/laggy feeling you're experiencing.
