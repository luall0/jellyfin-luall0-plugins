# Jellyfin Plugin Repository

This repository hosts a custom Jellyfin plugin manifest.

## Add to Jellyfin

To add this repository to your Jellyfin instance:

1. Open your Jellyfin dashboard
2. Navigate to **Dashboard** → **Plugins** → **Repositories**
3. Click the **+** button to add a new repository
4. Enter a name (e.g., "Custom Plugins")
5. Paste this URL:

```
https://raw.githubusercontent.com/luall0/jellyfin-luall0-plugins/refs/heads/main/manifest.json
```

6. Click **Save**
7. You can now browse and install plugins from this repository in the **Catalog** tab

## Repository Management

This repository uses GitHub Actions to automatically update the plugin manifest:

- **Add New Plugin**: Manually trigger the "Add New Plugin" workflow
- **Update Plugin Version**: Triggered automatically via `repository_dispatch` event
