# Machine Clean Up

A utility for managing and cleaning development machine caches to free up disk space.

## Overview

Development environments accumulate significant disk usage from build caches, dependencies, and temporary files. This tool helps identify and clean these caches safely.

## Common Cache Locations

| Cache Type | Typical Size | Regenerates Via |
|------------|--------------|-----------------|
| `.next/` | 10-30 GB | `npm run dev` / `npm run build` |
| `node_modules/` | 5-10 GB | `npm install` |
| `.claude/worktrees/` | 1-5 GB | Claude Code (automatic) |
| `Pods/` | 1-2 GB | `pod install` |
| `target/` (Rust/Tauri) | 1-3 GB | `cargo build` |
| `.gradle/` | 0.5-2 GB | Gradle sync |

## Usage

Check disk usage before cleanup:
```bash
df -h ~
```

All caches can be safely deleted as they regenerate on next build/install.

## License

MIT
