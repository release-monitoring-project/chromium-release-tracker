#!/bin/bash

LOG_FILE="chromium_snapshot_fetch.log"
OUTPUT_JSON="chromium_download_links.json"
TAG_NAME=$(date +"%Y-%m-%d_%H-%M-%S")
RELEASE_URL="https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html"

echo "[$(date)] Starting Chromium ZIP release fetch..." > "$LOG_FILE"

# OS/Arch identifiers and zip file names
declare -A OS_IDS=(
    [windows_x64]="Win_x64"
    [windows_arm64]="Win_Arm64"
    [macos_x64]="Mac"
    [macos_arm64]="Mac_Arm"
    [linux_x64]="Linux_x64"
)
declare -A ZIP_NAMES=(
    [windows_x64]="chrome-win.zip"
    [windows_arm64]="chrome-win.zip"
    [macos_x64]="chrome-mac.zip"
    [macos_arm64]="chrome-mac.zip"
    [linux_x64]="chrome-linux.zip"
)

# Fetch latest revision for each OS/arch
declare -A REVISIONS
declare -A URLS

for key in "${!OS_IDS[@]}"; do
    OS_ID="${OS_IDS[$key]}"
    LAST_CHANGE_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/${OS_ID}%2FLAST_CHANGE?alt=media"
    REVISION=$(curl -s -S "$LAST_CHANGE_URL")
    REVISIONS[$key]="$REVISION"
    ZIP_NAME="${ZIP_NAMES[$key]}"
    URLS[$key]="https://commondatastorage.googleapis.com/chromium-browser-snapshots/${OS_ID}/${REVISION}/${ZIP_NAME}"
    echo "[$(date)] $key: revision $REVISION, url ${URLS[$key]}" >> "$LOG_FILE"
done

# Build JSON structure
WINDOWS_JSON=""
MACOS_JSON=""
LINUX_JSON=""

for key in "${!URLS[@]}"; do
    ARCH="${key##*_}"
    ZIP="${URLS[$key]}"
    # No SHA256 available for Chromium snapshots
    ENTRY="\"$ARCH\": {\"zip\": \"$ZIP\"}"
    case "$key" in
        windows_*) WINDOWS_JSON="${WINDOWS_JSON}${ENTRY}," ;;
        macos_*)   MACOS_JSON="${MACOS_JSON}${ENTRY}," ;;
        linux_*)   LINUX_JSON="${LINUX_JSON}${ENTRY}," ;;
    esac
done

WINDOWS_JSON="{${WINDOWS_JSON%,}}"
MACOS_JSON="{${MACOS_JSON%,}}"
LINUX_JSON="{${LINUX_JSON%,}}"

# Create and write output
jq -n \
  --arg tag "$TAG_NAME" \
  --arg releasePage "$RELEASE_URL" \
  --argjson windows "$WINDOWS_JSON" \
  --argjson macos "$MACOS_JSON" \
  --argjson linux "$LINUX_JSON" \
  '{
    tag: $tag,
    releasePage: $releasePage,
    downloads: {
      windows: $windows,
      macos: $macos,
      linux: $linux
    }
  }' > "$OUTPUT_JSON"

echo "[$(date)] JSON written to $OUTPUT_JSON" >> "$LOG_FILE"
echo "[$(date)] Script completed." >> "$LOG_FILE"