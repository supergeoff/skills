# Mermaid CLI (mmdc) Usage Guide

This guide covers the mermaid-cli tool for generating SVG files from Mermaid diagrams.

## Installation

Install locally in your project:

```bash
npm install @mermaid-js/mermaid-cli --save-dev
```

The `mmdc` binary will be available at `./node_modules/.bin/mmdc`.

## Basic Usage

```bash
./node_modules/.bin/mmdc -i input.mmd -o output.svg
```

## Common Options

| Flag | Description | Default |
|------|-------------|---------|
| `-i, --input <file>` | Input Mermaid file (.mmd) | Required |
| `-o, --output <file>` | Output file (.svg, .png, .pdf) | Required |
| `-t, --theme <theme>` | Theme: default, dark, forest, neutral | default |
| `-b, --backgroundColor <color>` | Background color | white |
| `-w, --width <px>` | SVG width in pixels | 800 |
| `-H, --height <px>` | SVG height in pixels | 600 |
| `-s, --scale <factor>` | Puppeteer scale factor | 1 |
| `-c, --configFile <file>` | Mermaid JSON configuration file | None |
| `-p, --puppeteerConfigFile <file>` | Puppeteer configuration | None |
| `-q, --quiet` | Suppress log output | false |

## Our Configuration

We use:
- `-b transparent`: Transparent background for presentation compatibility
- `-t default`: Default theme for maximum compatibility
- `-c config/mermaid-config.json`: Configuration to preserve styling

Full command:
```bash
./node_modules/.bin/mmdc \
    -i diagram.mmd \
    -o diagram.svg \
    -b transparent \
    -t default \
    -c config/mermaid-config.json
```

## Troubleshooting

### mmdc not found after installation

If `./node_modules/.bin/mmdc` doesn't exist after `npm install`:
1. Verify npm installed successfully
2. Check `node_modules/.bin/` directory exists
3. Try: `npx mmdc --version`

### Installation fails

If `npm install @mermaid-js/mermaid-cli` fails:
1. Ensure Node.js and npm are installed: `node --version && npm --version`
2. Try with `--legacy-peer-deps` flag
3. If still failing, install globally: `npm install -g @mermaid-js/mermaid-cli`

### SVG generation fails

Common causes:
1. Invalid Mermaid syntax in .mmd file
2. Missing required configuration
3. Puppeteer issues (rare)

Solutions:
1. Validate Mermaid syntax using an online editor
2. Check the .mmd file has valid structure
3. Try with minimal config (no -c flag)

### puppeteer error

If you see puppeteer-related errors, try updating:
```bash
npm install puppeteer
```

Or use a specific version:
```bash
npm install puppeteer@latest
```

## Output Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| SVG | .svg | Recommended for presentations |
| PNG | .png | Raster format, use -s 2 for higher resolution |
| PDF | .pdf | Vector format, good for printing |

## Generating Multiple Diagrams

For multiple diagrams, generate each separately:

```bash
# Diagram 1
./node_modules/.bin/mmdc -i flowchart.mmd -o flowchart.svg -b transparent

# Diagram 2
./node_modules/.bin/mmdc -i sequence.mmd -o sequence.svg -b transparent
```

## Verification

Verify SVG was created successfully:

```bash
ls -la diagram.svg
# Should show file with size > 0

head -1 diagram.svg
# Should contain: <?xml version="1.0" encoding="UTF-8"?>
grep -q "<svg" diagram.svg && echo "Valid SVG"
# Should output: Valid SVG
```

## Cleanup

The .mmd source files are kept for re-generation. To clean up:

```bash
# Remove all .mmd files
rm *.mmd

# Keep .mmd for future use (recommended)
```