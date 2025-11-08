#!/bin/bash
set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --category)
      CATEGORY="$2"
      shift 2
      ;;
    --guid)
      GUID="$2"
      shift 2
      ;;
    --name)
      NAME="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION="$2"
      shift 2
      ;;
    --owner)
      OWNER="$2"
      shift 2
      ;;
    --overview)
      OVERVIEW="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [[ -z "$CATEGORY" || -z "$GUID" || -z "$NAME" || -z "$DESCRIPTION" || -z "$OWNER" || -z "$OVERVIEW" ]]; then
  echo "Error: All arguments are required"
  echo "Usage: $0 --category <category> --guid <guid> --name <name> --description <description> --owner <owner> --overview <overview>"
  exit 1
fi

# Check if plugin already exists
PLUGIN_EXISTS=$(jq --arg guid "$GUID" '[.[] | select(.guid == $guid)] | length' manifest.json)

if [[ "$PLUGIN_EXISTS" != "0" ]]; then
  echo "Error: Plugin with GUID $GUID already exists in manifest"
  exit 1
fi

# Create new plugin object
NEW_PLUGIN=$(jq -n \
  --arg category "$CATEGORY" \
  --arg guid "$GUID" \
  --arg name "$NAME" \
  --arg description "$DESCRIPTION" \
  --arg owner "$OWNER" \
  --arg overview "$OVERVIEW" \
  '{
    category: $category,
    guid: $guid,
    name: $name,
    description: $description,
    owner: $owner,
    overview: $overview,
    versions: []
  }')

# Add new plugin to manifest
jq --argjson new_plugin "$NEW_PLUGIN" \
   '. += [$new_plugin]' \
   manifest.json > manifest.json.tmp

mv manifest.json.tmp manifest.json

echo "Successfully added plugin: $NAME ($GUID)"
