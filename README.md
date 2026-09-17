# Stardew Valley Galaxy Fix

Fixes Stardew Valley multiplayer stuck on "Connecting to Online Services" on Arch-based distros and Steam Deck.

Cause: the bundled Galaxy libs are incompatible with newer glibc.

## Quick

```sh
curl -fsSL https://raw.githubusercontent.com/mukulx/stardew-galaxy-fix/master/fix.sh | sh
```

## Files

- `fix.sh` - replaces the two Galaxy libs and keeps a backup
- `libraries.zip` - included in repo, auto-downloaded if missing

## Usage

Clone and run:

```sh
git clone https://github.com/mukulx/stardew-galaxy-fix.git
cd stardew-galaxy-fix
./fix.sh
```

Or pass the zip path:

```sh
./fix.sh ~/Downloads/libraries.zip
```

Then restart Steam and launch Stardew Valley.

The script detects the install under `steamapps/common/Stardew Valley`, backs up the originals to `~/Downloads/galaxy-backup-original`, copies the fixed `libGalaxy64.so` and `libGalaxyCSharpGlue.so`, and sets permissions.

## Notes

- Works for vanilla and SMAPI, same game folder.
- On Steam Deck, run from Desktop Mode.
- Steam "Verify integrity" restores the old files. Re-run the script after verifying.
- Keep the backup until multiplayer is confirmed working.

## Source

- https://www.reddit.com/r/StardewValley/comments/1txuh4s/fix_stardew_valley_multiplayer_connecting_to/
