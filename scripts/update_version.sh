#!/bin/bash
set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --guid)
      GUID="$2"
      shift 2
      ;;
    --checksum)
      CHECKSUM="$2"
      shift 2
      ;;
    --changelog)
      CHANGELOG="$2"
      shift 2
      ;;
    --target-abi)
      TARGET_ABI="$2"
      shift 2
      ;;
    --source-url)
      SOURCE_URL="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [[ -z "$GUID" || -z "$CHECKSUM" || -z "$CHANGELOG" || -z "$TARGET_ABI" || -z "$SOURCE_URL" || -z "$VERSION" ]]; then
  echo "Error: All arguments are required"
  echo "Usage: $0 --guid <guid> --checksum <checksum> --changelog <changelog> --target-abi <targetAbi> --source-url <sourceUrl> --version <version>"
  exit 1
fi

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S")

# Check if plugin exists
PLUGIN_EXISTS=$(jq --arg guid "$GUID" '[.[] | select(.guid == $guid)] | length' manifest.json)

if [[ "$PLUGIN_EXISTS" == "0" ]]; then
  echo "Error: Plugin with GUID $GUID not found in manifest"
  exit 1
fi

# Create new version object
NEW_VERSION=$(jq -n \
  --arg checksum "$CHECKSUM" \
  --arg changelog "$CHANGELOG" \
  --arg targetAbi "$TARGET_ABI" \
  --arg sourceUrl "$SOURCE_URL" \
  --arg timestamp "$TIMESTAMP" \
  --arg version "$VERSION" \
  '{
    checksum: $checksum,
    changelog: $changelog,
    targetAbi: $targetAbi,
    sourceUrl: $sourceUrl,
    timestamp: $timestamp,
    version: $version
  }' | jq '.changelog |= gsub("\\\\n"; "\n")')

# Update manifest: add new version at the beginning of the versions array
jq --arg guid "$GUID" \
   --argjson new_version "$NEW_VERSION" \
   'map(if .guid == $guid then .versions |= [$new_version] + . else . end)' \
   manifest.json > manifest.json.tmp

mv manifest.json.tmp manifest.json

echo "Successfully added version $VERSION for plugin $GUID"
