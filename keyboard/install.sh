#!/usr/bin/env sh
# Generate and install the US-Icelandic keyboard layout.
#
# NOTE: do NOT `stow` this package. macOS ignores symlinked keylayouts, so the
# file must be a real copy in ~/Library/Keyboard Layouts/. Run this script
# instead. Re-run it whenever you edit generate.py. Adding a brand-new layout
# only shows up in System Settings after a re-login (or reboot).
set -e

dir="$(cd "$(dirname "$0")" && pwd)"
src="$dir/US-Icelandic.keylayout"
dest="$HOME/Library/Keyboard Layouts"

python3 "$dir/generate.py"
mkdir -p "$dest"
rm -f "$dest/US-Icelandic.keylayout"   # clear any stale symlink/copy
cp "$src" "$dest/"
echo "Installed US-Icelandic.keylayout -> $dest"
