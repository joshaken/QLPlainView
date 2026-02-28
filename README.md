# QLPlainView

A macOS QuickLook extension that enables instant preview of plain text files, YAML, JSON, XML directly in Finder with just a spacebar press.

---

## Features

- **Plain text files** — preview files with no extension
- **YAML / YML** — with syntax highlighting (keys, comments, list items)
- **JSON** — structured text preview
- **XML** — raw markup preview
- **Auto encoding detection** — UTF-8, ASCII, ISO Latin-1, UTF-16, EUC-JP, Shift-JIS
- **Large file handling** — files over 100KB are truncated with a notice
- **Dark / Light mode** — fully respects system appearance
- **Dynamic window sizing** — preview window adjusts to content size

---

## Requirements

- macOS 14 or later

---

## Installation

1. Download the latest `QLPlainView.dmg` from [Releases](../../releases)
2. Open the DMG and drag `QLPlainView.app` to your **Applications** folder
3. Launch `QLPlainView.app` once to register the extension
4. Select any supported file in Finder and press **Space**

> The app runs silently in the background and does not appear in the Dock.

---

## Supported File Types

| Type | Extensions |
|------|-----------|
| Plain Text | No extension, `.txt` |
| YAML | `.yaml`, `.yml` |
| JSON | `.json` |
| XML | `.xml` |


---

## Uninstall

```bash
# Remove the app
rm -rf /Applications/QLPlainView.app

# Reset QuickLook
qlmanage -r
```
---

## License

MIT License. See [LICENSE](LICENSE) for details.
