# Design Specification: Acme Dashboard

## Overview

Design system and screen specifications for the deployment dashboard.

## Design Tokens

### Colors
- Primary: #2563EB (Blue)
- Secondary: #10B981 (Green)
- Error: #EF4444 (Red)
- Warning: #F59E0B (Amber)

### Typography
- Headings: Inter, 600 weight
- Body: Inter, 400 weight
- Monospace: JetBrains Mono

## Screens

### Login Screen
- Figma Link: [placeholder]
- Components: Logo, Email input, Password input, Submit button, Forgot password link
- States: Default, Loading, Error, Success

### Dashboard
- Figma Link: [placeholder]
- Components: Header, Sidebar, Environment tabs, Deployment cards, Status indicators
- Breakpoints: Desktop (1200px), Tablet (768px), Mobile (375px)

### Deployment Detail
- Figma Link: [placeholder]
- Components: Breadcrumb, Status banner, Timeline, Logs viewer, Action buttons

## Component Library

### Buttons
- Primary: Blue background, white text, rounded-md
- Secondary: White background, blue border
- Danger: Red background, white text
- Disabled: Gray background, gray text

### Status Indicators
- Success: Green dot + "Deployed"
- In Progress: Blue spinner + "Deploying"
- Failed: Red dot + "Failed"
- Pending: Gray dot + "Pending"

### Cards
- Shadow: shadow-md
- Border radius: rounded-lg
- Padding: p-4
