# QLPlainView

A macOS QuickLook extension that enables instant preview of plain text files, YAML, JSON, XML, Lua, and other common text formats directly in Finder with just a spacebar press.

---

## Features

- **Plain text files** — preview files with no extension
- **YAML / YML** — with syntax highlighting (keys, comments, list items)
- **JSON** — structured text preview
- **XML** — raw markup preview
- **Lua** — with syntax highlighting
- **Auto encoding detection** — UTF-8, ASCII, ISO Latin-1, UTF-16, EUC-JP, Shift-JIS
- **Large file handling** — configurable max file size (default 500MB)
- **Dark / Light mode** — fully respects system appearance
- **Dynamic window sizing** — preview window adjusts to content size
- **Text selection & copy** — copy content from preview
- **System "Open With"** — use system default apps or select alternate

---

## Requirements

- macOS 14 or later
- Xcode 15+

---

## Installation

### From App Store (when available)

1. Open `QLPlainView.app`
2. The extension is registered automatically
3. Select any supported file in Finder and press **Space**

### From Source

1. Clone the repository
2. Open the project in Xcode
3. Build the project (Shift+Cmd+B)
4. Enable the extension in Terminal:

```bash
rm -rf /Applications/QLPlainView.app && cp -r $(find ~/Library/Developer/Xcode/DerivedData -name "QLPlainView.app" 2>/dev/null | grep "Build/Products/Debug" | grep -v "Index.noindex" | head -1) /Applications/ && open /Applications/QLPlainView.app
```

5. Reset QuickLook cache:

```bash
qlmanage -r
```

---

## Supported File Types

### Standard
- Plain text files
- YAML (.yaml, .yml)
- JSON (.json)
- XML (.xml)
- Markdown (.md)
- Comma-separated values (.csv, .tsv)
- Logs (.log)
- Config files (.conf, .ini)

### Extended
- Lua (.lua) — with syntax highlighting
- TOML (.toml)
- .env files
- Lock/lock files
- Gradle files
- Modelfile files
- Dockerfile, Makefile, Podfile, Gemfile (no extension)
- Any other readable text file

---

## Build from Source

```bash
# Clone the repository
git clone <repository-url>
cd QLPlainView

# Open in Xcode
open QLPlainView.xcodeproj

# Build
# Press Shift+Cmd+B, or select Product > Build

# Enable extension
pluginkit -e use -i com.joshaken.QLPlainView.QLPlainViewExtension

# Clear QuickLook cache
qlmanage -r
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.
