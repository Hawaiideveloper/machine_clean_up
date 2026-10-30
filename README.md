# Machine Clean Up

macOS system maintenance utilities for developers.

## Tools

### 1. Disk Cleanup (`cleanup.sh`)
Smart disk cleanup with AI-powered recommendations for freeing up space.

### 2. Mouse Fix (`mouse-fix/`)
Diagnose and fix choppy/laggy mouse movement across multiple displays.

---

## Disk Cleanup Tool

Development environments accumulate significant disk usage from build caches, dependencies, and temporary files. This tool helps identify and clean these caches safely.

### Quick Start

```bash
# See what can be cleaned (dry run)
./cleanup.sh --dry-run

# Interactive mode (pick what to clean)
./cleanup.sh

# Auto-clean all safe items
./cleanup.sh --force

# Scan specific path
./cleanup.sh -p ~/Documents/github

# Show configuration
./cleanup.sh --config
```

### Common Cache Locations

| Cache Type | Typical Size | Regenerates Via | Safety |
|------------|--------------|-----------------|--------|
| `node_modules/` | 5-10 GB | `npm install` | SAFE |
| `.next/` | 10-30 GB | `npm run dev` / `npm run build` | SAFE |
| `.claude/worktrees/` | 1-5 GB | Claude Code (automatic) | SAFE |
| `Pods/` | 1-2 GB | `pod install` | SAFE |
| `target/` (Rust/Tauri) | 1-3 GB | `cargo build` | SAFE |
| `.gradle/` | 0.5-2 GB | Gradle sync | SAFE |
| `Xcode DerivedData` | 10-50 GB | Xcode build | SAFE |
| `Homebrew cache` | 1-5 GB | Download on demand | SAFE |
| Chrome cache | 1-3 GB | Regenerates | CAUTION |
| Downloads folder | Varies | Manual review | REVIEW |

### Features

- **Smart scanning:** Detects 40+ types of caches across macOS/Linux
- **Safety levels:** SAFE (100% regenerates) / CAUTION (usually safe) / REVIEW (check first)
- **AI integration:** Ask corey-coder about specific caches
- **Archive mode:** Move files to archive instead of permanent deletion
- **Dry run:** Preview what would be deleted without making changes

---

## Mouse Fix Tool

Diagnose and fix macOS mouse choppiness, stuttering, and laggy cursor movement.

### The Problem

Mouse moves smoothly on one screen but stutters/lags when crossing to another display? This is almost always caused by:
- Multiple displays with different resolutions
- Display scaling mismatches (Retina vs non-Retina)
- Portrait vs landscape orientation mixing
- WindowServer performance issues

### Quick Fix

```bash
cd mouse-fix

# Run diagnostic
./fix-mouse.sh --diagnose

# Apply all safe fixes (recommended)
sudo ./fix-mouse.sh --fix-all

# Log out and back in to test
```

### What It Fixes

1. **Display scaling optimization**
   - Disables accessibility zoom
   - Sets optimal mouse tracking speed
   - Enables linear movement (no acceleration)

2. **WindowServer issues**
   - Detects high CPU usage
   - Can restart WindowServer if needed (logs you out)

3. **System settings**
   - Resets problematic mouse/trackpad settings
   - Optimizes Mission Control configuration

See [`mouse-fix/README.md`](mouse-fix/README.md) for detailed usage and manual fixes.

---

## System Requirements

- **macOS 10.15+** (Catalina or newer)
- Apple Silicon (M1/M2/M3) or Intel Macs
- Bash 4.0+

## License

MIT
