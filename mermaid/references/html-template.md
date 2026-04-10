# HTML Template for Mermaid Diagram Rendering

This is the complete HTML template for rendering Mermaid diagrams with professional styling.

## Usage

1. Replace `__MERMAID_CODE__` with the Mermaid diagram code
2. Replace `__DIAGRAM_TITLE__` with the diagram title
3. Replace `__DIAGRAM_TYPE__` with the type (e.g., "Flowchart", "Sequence Diagram")
4. For multiple diagrams, duplicate the `<div class="mermaid">` section

---

## Complete Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>__DIAGRAM_TITLE__</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
    <style>
        :root {
            --bg-primary: #ffffff;
            --bg-secondary: #f8f9fa;
            --bg-card: #ffffff;
            --text-primary: #1a1a2e;
            --text-secondary: #6c757d;
            --border-color: #e0e0e0;
            --accent: #4A90D9;
            --accent-hover: #357ABD;
            --shadow: 0 2px 12px rgba(0,0,0,0.08);
            --radius: 8px;
        }

        [data-theme="dark"] {
            --bg-primary: #1a1a2e;
            --bg-secondary: #16213e;
            --bg-card: #0f3460;
            --text-primary: #e0e0e0;
            --text-secondary: #a0a0b0;
            --border-color: #333355;
            --accent: #5BA0E9;
            --accent-hover: #4A90D9;
            --shadow: 0 2px 12px rgba(0,0,0,0.3);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: var(--bg-secondary);
            color: var(--text-primary);
            line-height: 1.6;
            min-height: 100vh;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 24px;
            background: var(--bg-card);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            margin-bottom: 20px;
        }

        header h1 {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        header .subtitle {
            font-size: 0.9rem;
            color: var(--text-secondary);
            margin-top: 2px;
        }

        .header-actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .btn {
            padding: 8px 16px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            background: var(--bg-card);
            color: var(--text-primary);
            cursor: pointer;
            font-size: 0.875rem;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn:hover {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
        }

        .btn-primary {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
        }

        .btn-primary:hover {
            background: var(--accent-hover);
        }

        .diagram-card {
            background: var(--bg-card);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            margin-bottom: 20px;
            overflow: hidden;
        }

        .diagram-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 24px;
            background: var(--bg-secondary);
            border-bottom: 1px solid var(--border-color);
        }

        .diagram-header h2 {
            font-size: 1.1rem;
            font-weight: 600;
        }

        .diagram-header .type-badge {
            font-size: 0.75rem;
            padding: 3px 10px;
            background: var(--accent);
            color: white;
            border-radius: 12px;
            font-weight: 500;
        }

        .diagram-body {
            padding: 24px;
            overflow-x: auto;
            display: flex;
            justify-content: center;
            min-height: 200px;
        }

        .diagram-body .mermaid {
            width: 100%;
            max-width: 100%;
        }

        /* Zoom controls */
        .zoom-controls {
            position: fixed;
            bottom: 24px;
            right: 24px;
            display: flex;
            flex-direction: column;
            gap: 4px;
            z-index: 100;
        }

        .zoom-btn {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            background: var(--bg-card);
            color: var(--text-primary);
            cursor: pointer;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            box-shadow: var(--shadow);
        }

        .zoom-btn:hover {
            background: var(--accent);
            color: white;
        }

        /* Code toggle */
        .code-section {
            display: none;
            background: var(--bg-secondary);
            border-top: 1px solid var(--border-color);
        }

        .code-section.visible {
            display: block;
        }

        .code-section pre {
            margin: 0;
            padding: 16px 24px;
            overflow-x: auto;
            font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', monospace;
            font-size: 0.875rem;
            line-height: 1.5;
            color: var(--text-primary);
        }

        /* Toast notification */
        .toast {
            position: fixed;
            bottom: 80px;
            left: 50%;
            transform: translateX(-50%) translateY(20px);
            background: #333;
            color: white;
            padding: 10px 20px;
            border-radius: 6px;
            font-size: 0.875rem;
            opacity: 0;
            transition: all 0.3s ease;
            z-index: 1000;
            pointer-events: none;
        }

        .toast.show {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }

        /* Error display */
        .error-display {
            display: none;
            padding: 16px 24px;
            background: #fff5f5;
            border: 1px solid #fc8181;
            border-radius: var(--radius);
            color: #c53030;
            font-size: 0.9rem;
            margin: 16px 24px;
        }

        .error-display.visible {
            display: block;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .container { padding: 12px; }
            header { flex-direction: column; gap: 12px; text-align: center; }
            .header-actions { justify-content: center; }
            .diagram-body { padding: 16px; }
        }

        /* Print styles */
        @media print {
            header, .zoom-controls, .header-actions { display: none; }
            .diagram-card { box-shadow: none; border: 1px solid #ccc; }
            body { background: white; }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div>
                <h1>__DIAGRAM_TITLE__</h1>
                <div class="subtitle">__DIAGRAM_TYPE__</div>
            </div>
            <div class="header-actions">
                <button class="btn" onclick="toggleTheme()" title="Toggle dark/light theme">🌓 Theme</button>
                <button class="btn" onclick="toggleCode()" title="Show/hide Mermaid source code">{ } Code</button>
                <button class="btn" onclick="copyCode()" title="Copy Mermaid code to clipboard">📋 Copy</button>
                <button class="btn" onclick="downloadSVG()" title="Download as SVG">⬇ SVG</button>
                <button class="btn btn-primary" onclick="toggleFullscreen()" title="View fullscreen">⛶ Fullscreen</button>
            </div>
        </header>

        <div class="diagram-card">
            <div class="diagram-header">
                <h2>__DIAGRAM_TITLE__</h2>
                <span class="type-badge">__DIAGRAM_TYPE__</span>
            </div>
            <div id="error-display" class="error-display"></div>
            <div class="diagram-body" id="diagram-container">
                <div class="mermaid" id="mermaid-diagram">
__MERMAID_CODE__
                </div>
            </div>
            <div class="code-section" id="code-section">
                <pre id="mermaid-code"></pre>
            </div>
        </div>
    </div>

    <div class="zoom-controls">
        <button class="zoom-btn" onclick="zoomIn()" title="Zoom in">+</button>
        <button class="zoom-btn" onclick="zoomOut()" title="Zoom out">−</button>
        <button class="zoom-btn" onclick="zoomReset()" title="Reset zoom">⟲</button>
    </div>

    <div class="toast" id="toast"></div>

    <script>
        // Mermaid initialization
        mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            themeVariables: {
                primaryColor: '#4A90D9',
                primaryTextColor: '#fff',
                primaryBorderColor: '#2C5F8A',
                lineColor: '#555',
                secondaryColor: '#7ED321',
                tertiaryColor: '#F5A623',
                fontSize: '16px',
            },
            flowchart: {
                htmlLabels: true,
                curve: 'basis',
                rankSpacing: 50,
                nodeSpacing: 30,
            },
            sequence: {
                diagramMarginX: 50,
                diagramMarginY: 10,
                actorMargin: 50,
                width: 150,
                height: 65,
                mirrorActors: true,
            },
        });

        // Store original mermaid code
        const mermaidCode = `__MERMAID_CODE__`;

        // Theme toggle
        let currentTheme = localStorage.getItem('mermaid-theme') || 'light';
        if (currentTheme === 'dark') {
            document.documentElement.setAttribute('data-theme', 'dark');
        }

        function toggleTheme() {
            currentTheme = currentTheme === 'light' ? 'dark' : 'light';
            document.documentElement.setAttribute('data-theme', currentTheme);
            localStorage.setItem('mermaid-theme', currentTheme);
            
            // Re-render mermaid with appropriate theme
            const theme = currentTheme === 'dark' ? 'dark' : 'default';
            mermaid.initialize({ startOnLoad: false, theme: theme });
            const diagramEl = document.getElementById('mermaid-diagram');
            diagramEl.removeAttribute('data-processed');
            diagramEl.innerHTML = mermaidCode;
            mermaid.run({ nodes: [diagramEl] });
        }

        // Code toggle
        let codeVisible = false;
        function toggleCode() {
            codeVisible = !codeVisible;
            const codeSection = document.getElementById('code-section');
            codeSection.classList.toggle('visible', codeVisible);
            if (codeVisible) {
                document.getElementById('mermaid-code').textContent = mermaidCode;
            }
        }

        // Copy code
        function copyCode() {
            navigator.clipboard.writeText(mermaidCode).then(() => {
                showToast('Mermaid code copied to clipboard!');
            }).catch(() => {
                // Fallback
                const textarea = document.createElement('textarea');
                textarea.value = mermaidCode;
                document.body.appendChild(textarea);
                textarea.select();
                document.execCommand('copy');
                document.body.removeChild(textarea);
                showToast('Mermaid code copied to clipboard!');
            });
        }

        // Download SVG
        function downloadSVG() {
            const svgEl = document.querySelector('#mermaid-diagram svg');
            if (!svgEl) {
                showToast('No diagram found to download');
                return;
            }
            const svgData = new XMLSerializer().serializeToString(svgEl);
            const blob = new Blob([svgData], { type: 'image/svg+xml' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'diagram.svg';
            a.click();
            URL.revokeObjectURL(url);
            showToast('SVG downloaded!');
        }

        // Fullscreen
        function toggleFullscreen() {
            const container = document.getElementById('diagram-container');
            if (!document.fullscreenElement) {
                container.requestFullscreen().catch(err => {
                    showToast('Fullscreen not available');
                });
            } else {
                document.exitFullscreen();
            }
        }

        // Zoom
        let zoomLevel = 1;
        function zoomIn() {
            zoomLevel = Math.min(zoomLevel + 0.2, 3);
            applyZoom();
        }
        function zoomOut() {
            zoomLevel = Math.max(zoomLevel - 0.2, 0.3);
            applyZoom();
        }
        function zoomReset() {
            zoomLevel = 1;
            applyZoom();
        }
        function applyZoom() {
            const svg = document.querySelector('#mermaid-diagram svg');
            if (svg) {
                svg.style.transform = `scale(${zoomLevel})`;
                svg.style.transformOrigin = 'center top';
                svg.style.transition = 'transform 0.2s ease';
            }
        }

        // Toast notification
        function showToast(message) {
            const toast = document.getElementById('toast');
            toast.textContent = message;
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 2500);
        }

        // Error handling
        mermaid.parseError = function(err) {
            const errorDisplay = document.getElementById('error-display');
            errorDisplay.textContent = 'Mermaid syntax error: ' + err.message;
            errorDisplay.classList.add('visible');
        };
    </script>
</body>
</html>
```

---

## Multiple Diagrams Template

For multiple diagrams in one page, duplicate the `diagram-card` section and give each diagram a unique ID:

```html
<div class="diagram-card">
    <div class="diagram-header">
        <h2>Overview Diagram</h2>
        <span class="type-badge">Flowchart</span>
    </div>
    <div class="diagram-body">
        <div class="mermaid" id="diagram-1">
            %% Overview flowchart here
        </div>
    </div>
</div>

<div class="diagram-card">
    <div class="diagram-header">
        <h2>Sequence Detail</h2>
        <span class="type-badge">Sequence Diagram</span>
    </div>
    <div class="diagram-body">
        <div class="mermaid" id="diagram-2">
            %% Sequence diagram here
        </div>
    </div>
</div>
```

For the copy function with multiple diagrams, collect all mermaid code blocks and join them with double newlines.

---

## Template Variables

When generating HTML from this template, replace:

| Placeholder | Description | Example |
|---|---|---|
| `__DIAGRAM_TITLE__` | Main title of the diagram | "User Authentication Flow" |
| `__DIAGRAM_TYPE__` | Type of diagram | "Flowchart" |
| `__MERMAID_CODE__` | The Mermaid diagram code (indented properly) | `flowchart TD\n    A --> B` |

**Important**: The Mermaid code must be placed directly inside the `<div class="mermaid">` element, not in a `<script>` tag. Mermaid.js scans for elements with the `mermaid` class and renders them.