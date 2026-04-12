#!/bin/bash

set -e

MMDC_PATH="./node_modules/.bin/mmdc"

if [ -f "$MMDC_PATH" ]; then
    echo "✓ mermaid-cli already installed at $MMDC_PATH"
    exit 0
fi

echo "Installing @mermaid-js/mermaid-cli..."

if ! command -v npm &> /dev/null; then
    echo "ERROR: npm is not installed."
    echo "Please install Node.js and npm first, then re-run this script."
    exit 1
fi

npm install @mermaid-js/mermaid-cli --save-dev

if [ -f "$MMDC_PATH" ]; then
    echo "✓ mermaid-cli installed successfully"
else
    echo "ERROR: Installation failed. Please try installing manually:"
    echo "  npm install @mermaid-js/mermaid-cli --save-dev"
    exit 1
fi