#!/usr/bin/env bash
#
# regen-sample.sh:: turn fradan's rendered PNGs into the WebP files that
# pages/fs.html and pages/dt.html serve.
#
#   ./regen-sample.sh                                  # finds *-artifacts.png here
#   ./regen-sample.sh path/to/track-artifacts.png      # or point at one explicitly
#
# fradan writes four PNGs from one run: "<base>-artifacts.png" plus
# "-synthesis", "-timing" and "-loudness" alongside it. Passing the artifacts
# page is enough to find all four.
#
# Full renders are LOSSLESS on purpose. The charts carry hairline traces and a
# 5x8 bitmap font, and a codec-forensics tool should not publish lossy
# evidence. Thumbnails are lossy. At 600px the font is unreadable anyway, so
# they are decorative and the bytes matter more than the detail.
#
# Needs cwebp:  brew install webp
#
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$repo/assets/sample"

THUMB_W=600      # displayed ~4-across on pages/dt.html
THUMB_Q=85

command -v cwebp >/dev/null || {
  echo "error: cwebp not found. install it with:  brew install webp" >&2
  exit 1
}

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
for page in artifacts synthesis timing loudness; do
  if [ "$page" = artifacts ]; then src="$base.png"; else src="$base-$page.png"; fi
  [ -f "$src" ] || { echo "error: expected sibling not found: $src" >&2; exit 1; }

  cwebp -quiet -lossless "$src"                       -o "$out/$page.webp"
  cwebp -quiet -q $THUMB_Q -resize $THUMB_W 0 "$src"  -o "$out/$page-thumb.webp"

  read -r w h <<<"$(sips -g pixelWidth -g pixelHeight "$src" | awk '/pixelWidth|pixelHeight/{printf "%s ", $2}')"
  read -r tw th <<<"$(sips -g pixelWidth -g pixelHeight "$out/$page-thumb.webp" | awk '/pixelWidth|pixelHeight/{printf "%s ", $2}')"

  printf '  %-10s %6.2f MB png  ->  %6.2f MB full (%sx%s)  +  %4.0f KB thumb (%sx%s)\n' \
    "$page" \
    "$(stat -f%z "$src"                 | awk '{print $1/1048576}')" \
    "$(stat -f%z "$out/$page.webp"      | awk '{print $1/1048576}')" "$w" "$h" \
    "$(stat -f%z "$out/$page-thumb.webp"| awk '{print $1/1024}')"    "$tw" "$th"

  dims+="  $page: full width=\"$w\" height=\"$h\"   thumb width=\"$tw\" height=\"$th\""$'\n'
done

echo
echo "total in assets/sample: $(du -sh "$out" | cut -f1)"
echo
echo "The pages pin width/height on every <img> so the layout does not shift"
echo "while images load. If these differ from what is in pages/fs.html and"
echo "pages/dt.html, update them there:"
echo
printf '%s' "$dims"
