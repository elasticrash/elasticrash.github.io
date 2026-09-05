#!/usr/bin/env bash
#
# regen-sample.sh:: turn fradan's rendered PNGs into the WebP files that
# pages/fradan-samples.html and pages/fradan.html serve.
#
#   ./regen-sample.sh                                  # finds *-artifacts.png here
#   ./regen-sample.sh path/to/track-artifacts.png      # or point at one explicitly
#
# fradan writes five PNGs from one run: "<base>-artifacts.png" plus
# "-synthesis", "-timing", "-loudness" and "-room" alongside it. Passing the
# artifacts page is enough to find all five.
#
# Full renders are LOSSLESS on purpose. The charts carry hairline traces and a
# 5x8 bitmap font, and a codec-forensics tool should not publish lossy
# evidence. Thumbnails are lossy. At 600px the font is unreadable anyway, so
# they are decorative and the bytes matter more than the detail.
#
# Needs cwebp (brew install webp / pacman -S libwebp), or ImageMagick 7 as a
# fallback: the encoder is libwebp either way, only the front end differs.
#
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$repo/assets/sample"

THUMB_W=600      # displayed ~4-across on pages/fradan.html
THUMB_Q=85

if command -v cwebp >/dev/null; then
  encode_lossless() { cwebp -quiet -lossless "$1" -o "$2"; }
  encode_thumb()    { cwebp -quiet -q $THUMB_Q -resize $THUMB_W 0 "$1" -o "$2"; }
elif command -v magick >/dev/null; then
  encode_lossless() { magick "$1" -define webp:lossless=true "$2"; }
  encode_thumb()    { magick "$1" -resize ${THUMB_W}x -quality $THUMB_Q "$2"; }
else
  echo "error: need cwebp or magick. install one with:" >&2
  echo "  brew install webp   |   pacman -S libwebp   |   pacman -S imagemagick" >&2
  exit 1
fi

# sips is macOS-only and stat's size flag is not portable; identify ships with
# ImageMagick and is the one dependency this script already tolerates.
dims_of() { identify -format '%w %h' "$1"; }
bytes_of() { stat -c%s "$1" 2>/dev/null || stat -f%z "$1"; }

# Resolve the input: explicit argument, or the single *-artifacts.png here.
if [ $# -ge 1 ]; then
  src_artifacts="$1"
else
  shopt -s nullglob
  candidates=(*-artifacts.png)
  shopt -u nullglob
  case ${#candidates[@]} in
    0) echo "error: no *-artifacts.png in $(pwd). Pass one as an argument." >&2; exit 1 ;;
    1) src_artifacts="${candidates[0]}" ;;
    *) echo "error: several *-artifacts.png found; pass the one you want:" >&2
       printf '  %s\n' "${candidates[@]}" >&2; exit 1 ;;
  esac
fi

[ -f "$src_artifacts" ] || { echo "error: no such file: $src_artifacts" >&2; exit 1; }
base="${src_artifacts%.png}"

mkdir -p "$out"
echo "source: $base*.png"
echo

dims=""
for page in artifacts synthesis timing loudness room; do
  if [ "$page" = artifacts ]; then src="$base.png"; else src="$base-$page.png"; fi
  [ -f "$src" ] || { echo "error: expected sibling not found: $src" >&2; exit 1; }

  encode_lossless "$src" "$out/$page.webp"
  encode_thumb    "$src" "$out/$page-thumb.webp"

  read -r w h   <<<"$(dims_of "$src")"
  read -r tw th <<<"$(dims_of "$out/$page-thumb.webp")"

  printf '  %-10s %6.2f MB png  ->  %6.2f MB full (%sx%s)  +  %4.0f KB thumb (%sx%s)\n' \
    "$page" \
    "$(bytes_of "$src"                 | awk '{print $1/1048576}')" \
    "$(bytes_of "$out/$page.webp"      | awk '{print $1/1048576}')" "$w" "$h" \
    "$(bytes_of "$out/$page-thumb.webp"| awk '{print $1/1024}')"    "$tw" "$th"

  dims+="  $page: full width=\"$w\" height=\"$h\"   thumb width=\"$tw\" height=\"$th\""$'\n'
done

echo
echo "total in assets/sample: $(du -sh "$out" | cut -f1)"
echo
echo "The pages pin width/height on every <img> so the layout does not shift"
echo "while images load. If these differ from what is in pages/fradan-samples.html and"
echo "pages/fradan.html, update them there:"
echo
printf '%s' "$dims"
