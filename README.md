# FixGrammar

A lightweight macOS menu bar app that adds system-wide "Fix Grammar" and "Add My Tone" services. Select text anywhere, right-click, and get AI-powered corrections via a local Ollama instance.

## Prerequisites

- macOS 13+
- [Ollama](https://ollama.com) installed and running
- A model pulled (default: `gemma3`):
  ```bash
  ollama pull gemma3
  ```

## Build

```bash
chmod +x Scripts/build.sh Scripts/install.sh
./Scripts/build.sh
```

## Install

```bash
./Scripts/install.sh
```

This copies the app to `~/Applications/` and registers the services. You may need to log out and back in (or restart target apps) for the services to appear.

## Usage

1. Launch FixGrammar from `~/Applications/` -- a checkmark icon appears in the menu bar
2. Click the icon to configure the Ollama URL, model, and tone
3. Select text in any app (browser, Slack, Notes, TextEdit, etc.)
4. Right-click > **Services** > **Fix Grammar** or **Add My Tone**
5. The selected text is replaced with the corrected/rewritten version

## Configuration

Click the menu bar icon to access settings:

- **Ollama URL** -- default: `http://localhost:11434`
- **Model** -- default: `gemma3`
- **Tone Description** -- default: `"casual and friendly, like texting a close colleague"`

Settings persist across app restarts.

## How It Works

FixGrammar registers as a macOS Services provider. When invoked:

1. Reads the selected text from the pasteboard
2. Sends it to your local Ollama instance with a tailored prompt
3. Writes the corrected text back, replacing the selection

All processing happens locally through Ollama. No data leaves your machine.

## License

MIT
