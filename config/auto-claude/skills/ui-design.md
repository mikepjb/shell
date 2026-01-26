---
name: ui-design
description: Build functional, utilitarian user interfaces. Use this skill when creating web components, pages, or applications. Prioritizes clarity, usability, and information density over decoration.
---

# UI Design Skill

Build interfaces where function dictates form. No decoration, no flourishes—just clear, usable UI.

## Principles

1. **Function over form**: Every element earns its place by doing something useful
2. **Obvious affordances**: Users should never guess what's clickable or how things work
3. **Information density**: Show what matters, hide what doesn't, waste no space
4. **Consistency**: Same patterns everywhere, no surprises
5. **Speed**: Fast to load, fast to understand, fast to use

## Technology Stack

- **Vanilla JS** for simple interactions
- **HTMX** for server-driven UI updates
- **Alpine.js** for reactive components when needed
- **Plain CSS** - no frameworks, no utility classes

## Design Approach

### Layout
- Use native HTML elements correctly (`<nav>`, `<main>`, `<aside>`, `<form>`)
- Simple grid or flexbox layouts
- Consistent spacing using a scale (4px, 8px, 16px, 24px, 32px)
- No decorative whitespace—whitespace should aid scanning

### Typography
- System font stack: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`
- Or a single readable sans-serif (e.g., IBM Plex Sans, Source Sans)
- Clear hierarchy: one size for body, one for headings, one for small text
- High contrast text (near-black on white, or white on near-black)

### Color
- Minimal palette: 1-2 colors maximum
- Use color for meaning, not decoration:
  - Blue for links/actions
  - Red for errors/destructive
  - Green for success
  - Yellow for warnings
- Gray scale for everything else

### Components
- Standard HTML form controls (style minimally)
- Visible focus states for keyboard navigation
- Clear disabled states
- Loading states that don't block interaction

### Tables & Data
- When showing data, tables are often correct
- Align numbers right, text left
- Zebra striping or borders for row separation
- Sortable columns where useful

## Anti-Patterns to Avoid

- Rounded corners everywhere
- Drop shadows for depth
- Gradient backgrounds
- Icons without labels
- Hamburger menus when space exists
- Modals for simple actions
- Skeleton loaders (show nothing or show content)
- Animations that delay interaction
- Custom styled form controls that break accessibility

## Example Patterns

### Form
```html
<form hx-post="/api/users" hx-swap="outerHTML">
  <label for="email">Email</label>
  <input type="email" id="email" name="email" required>

  <label for="role">Role</label>
  <select id="role" name="role">
    <option value="user">User</option>
    <option value="admin">Admin</option>
  </select>

  <button type="submit">Create User</button>
</form>
```

### Data Table with Actions
```html
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Email</th>
      <th>Status</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>John Smith</td>
      <td>john@example.com</td>
      <td>Active</td>
      <td>
        <a href="/users/1/edit">Edit</a>
        <button hx-delete="/api/users/1" hx-confirm="Delete this user?">Delete</button>
      </td>
    </tr>
  </tbody>
</table>
```

### Alpine.js Toggle
```html
<div x-data="{ open: false }">
  <button @click="open = !open" aria-expanded="open">
    Filters <span x-text="open ? '−' : '+'"></span>
  </button>
  <div x-show="open" x-cloak>
    <!-- filter controls -->
  </div>
</div>
```

## CSS Foundation

```css
:root {
  --text: #1a1a1a;
  --text-muted: #666;
  --bg: #fff;
  --border: #ccc;
  --link: #0066cc;
  --error: #cc0000;
  --success: #007700;
}

* { box-sizing: border-box; }

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  font-size: 16px;
  line-height: 1.5;
  color: var(--text);
  background: var(--bg);
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
}

a { color: var(--link); }
a:hover { text-decoration: none; }

button, input, select, textarea {
  font: inherit;
  padding: 0.5rem;
  border: 1px solid var(--border);
}

button {
  background: var(--text);
  color: var(--bg);
  border: none;
  cursor: pointer;
}

button:hover { opacity: 0.9; }
button:disabled { opacity: 0.5; cursor: not-allowed; }

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 0.5rem;
  text-align: left;
  border-bottom: 1px solid var(--border);
}

th { font-weight: 600; }

.error { color: var(--error); }
.success { color: var(--success); }
.muted { color: var(--text-muted); }
```

## Guidelines

- Start with semantic HTML, add interactivity only where needed
- Test without JavaScript—basic functionality should work
- Use HTMX for server roundtrips, Alpine for client-only state
- If you're adding CSS classes, you're probably overcomplicating it
- Reference gov.uk and Linear as north stars for utilitarian UI
