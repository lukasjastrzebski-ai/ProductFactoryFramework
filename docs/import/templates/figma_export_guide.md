# Figma Export Guide

How to export Figma designs for Product Factory import.

## What to Export

| Content Type | Export Method |
|--------------|---------------|
| Component specs | Figma JSON via API or plugin |
| Design tokens | Variables export |
| Screen flows | Frames as PNG + annotation JSON |
| Design decisions | Comments export or manual doc |

## Method 1: Figma API Export

### Prerequisites
- Figma access token
- File ID from Figma URL

### Export Command
```bash
# Set your token
export FIGMA_TOKEN="your-token-here"

# Export file data
curl -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/FILE_ID" \
  > docs/import/sources/figma/design_spec.json
```

## Method 2: Plugin Export

Recommended plugins:
- **Figma to JSON** - Exports component structure
- **Design Tokens** - Exports design system tokens
- **Annotation Kit** - Exports specs with annotations

## Method 3: Manual Documentation

Create `docs/import/sources/figma/design_spec.md`:

```markdown
# Design Specification

## Screens

### Login Screen
- Figma Link: [URL]
- Components: Email input, Password input, Submit button
- States: Default, Error, Loading, Success

### Dashboard
- Figma Link: [URL]
- Components: Header, Sidebar, Main content, Cards
- Breakpoints: Desktop (1200px), Tablet (768px), Mobile (375px)

## Component Library

### Buttons
- Primary: Blue background, white text
- Secondary: White background, blue border
- Disabled: Gray background, gray text

### Form Inputs
- Height: 40px
- Border radius: 4px
- States: Default, Focus, Error, Disabled
```

## File Organization

```
docs/import/sources/figma/
├── design_spec.json      # API export
├── design_spec.md        # Manual documentation
├── tokens.json           # Design tokens
└── screens/
    ├── login.png
    ├── dashboard.png
    └── annotations.json
```

## Integration with Factory

Figma content maps to:
- `specs/features/*.md` - UI behavior specifications
- `architecture/system.md` - Component architecture
- `docs/product/journeys.md` - User flow documentation
