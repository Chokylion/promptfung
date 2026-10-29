#!/usr/bin/env bash
# Creates the PRIVATE GitHub repo "promptfung" and uploads the 15 full-HD episodes of
# 15 วันก่อนหิมะตก (winter arc) as one Release. Private: only the owner (and invited collaborators) can see or download.
set -euo pipefail
cd "$(dirname "$0")"
VDO="/c/Users/KWatamat/OneDrive - Analog Devices, Inc/Desktop/Project/chonimate/vdo"
TAG="15-days-before-snow-winter"
TITLES=("" "ตายแล้วตื่น" "ตุนเสบียง" "ห้องปลอดภัยชั้นสี่" "คนที่ประตู" "วิทยุสื่อสาร" "ทางเดินหิมะ" "ตลาดแลกของ" "ห้องพยาบาล" "ไฟฟ้าส่วนกลาง" "สวนในแล็บ" "หาเสบียงสามย่าน" "คนจากนอกมหาลัย" "ติดต่อข้างนอก" "คืนที่หนาวที่สุด" "ฤดูใบไม้ผลิ")

# 1. repo with README + logo
if [ ! -d .git ]; then
  git init -q -b main
  git add README.md logo.svg
  git commit -q -m "promptfung: README + logo" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
fi
gh repo view promptfung >/dev/null 2>&1 || gh repo create promptfung --private --source . --push \
  --description "promptfung · พร้อมฟัง — Thai 2D animated series (full-HD downloads in Releases)"

# 2. copy masters to ASCII names (GitHub strips Thai from asset file names)
mkdir -p assets
NOTES="15 วันก่อนหิมะตก · ภาคฤดูหนาว — Full HD 1080×1920, ตอนละ 2 นาที"$'\n\n'
for n in $(seq 1 15); do
  src="$VDO/chula-snow-${n}_ep$((n + 9)).mp4"
  dst="assets/15-days-before-snow-ep$(printf %02d "$n").mp4"
  [ -f "$dst" ] || cp "$src" "$dst"
  NOTES+="- ตอนที่ $n · ${TITLES[$n]} → \`$(basename "$dst")\`"$'\n'
done

# 3. release + upload (about 950 MB, takes a while)
gh release view "$TAG" -R "$(gh repo view promptfung --json nameWithOwner -q .nameWithOwner)" >/dev/null 2>&1 || \
  gh release create "$TAG" -R "$(gh repo view promptfung --json nameWithOwner -q .nameWithOwner)" \
    --title "❄️ 15 วันก่อนหิมะตก · ภาคฤดูหนาว (15 ตอน)" --notes "$NOTES"
gh release upload "$TAG" assets/*.mp4 --clobber -R "$(gh repo view promptfung --json nameWithOwner -q .nameWithOwner)"
echo "DONE: https://github.com/$(gh repo view promptfung --json nameWithOwner -q .nameWithOwner)/releases/tag/$TAG"
