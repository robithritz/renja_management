# Renja Management - Design Patterns & Components

## Component Library

### 1. Info Chip Component

**Purpose:** Display metadata with icon and label

**Usage:**
```dart
_buildInfoChip(
  icon: Icons.business,
  label: 'Instansi Name',
)
```

**Styling:**
- Background: Corporate Blue 8% opacity
- Border: Corporate Blue 20% opacity
- Icon: Corporate Blue
- Text: Corporate Blue, 12px, Weight 500
- Padding: 12px horizontal, 6px vertical
- Border Radius: 8px

**Used in:**
- Renja List (Instansi, Hijriah date)
- Shaf List (Rakit name, PU count)

---

### 2. Stat Card Component

**Purpose:** Display statistics with icon and label

**Usage:**
```dart
_buildStatCard(
  label: 'BN PU',
  value: '45',
  icon: Icons.people,
)
```

**Styling:**
- Background: Corporate Blue 8% opacity
- Border: Corporate Blue 20% opacity
- Icon: Corporate Blue, 20px
- Value: Corporate Blue, 18px, Bold
- Label: Cool Gray, 11px, Weight 500
- Padding: 12px all
- Border Radius: 8px

**Used in:**
- Monev List (BN PU, MAL PU, New members)

---

### 3. Class Card Component

**Purpose:** Display class breakdown

**Usage:**
```dart
_buildClassCard('A', 25)
```

**Styling:**
- Background: Lime Green 10% opacity
- Border: Lime Green 30% opacity
- Class Name: Dark Green, 10px, Weight 600
- Count: Lime Green, 16px, Bold
- Padding: 8px all
- Border Radius: 8px

**Used in:**
- Shaf List (Kelas A, B, C, D)

---

### 4. Status Badge

**Purpose:** Show activity status

**Styling:**
- **Tergelar (Success):**
  - Background: Lime Green 15% opacity
  - Border: Lime Green 50% opacity
  - Text: Dark Green
  - Padding: 12px horizontal, 6px vertical

- **Tidak Tergelar (Failure):**
  - Background: Red 15% opacity
  - Border: Red 50% opacity
  - Text: Dark Red
  - Padding: 12px horizontal, 6px vertical

- Border Radius: 8px

**Used in:**
- Renja List (Activity status)

---

### 5. List Card Component

**Purpose:** Display item in list with actions

**Structure:**
```
┌─────────────────────────────────────┐
│ Title                    [Badge]    │
│ Subtitle                           │
├─────────────────────────────────────┤
│ [Info Chip] [Info Chip]            │
├─────────────────────────────────────┤
│ [Optional Content]                 │
├─────────────────────────────────────┤
│                    [Edit] [Delete]  │
└─────────────────────────────────────┘
```

**Styling:**
- Background: White
- Elevation: 2
- Border Radius: 12px
- Padding: 16px all
- Spacing: 12px between sections

**Used in:**
- Renja List
- Monev List
- Shaf List

---

### 6. Navigation Drawer

**Header:**
- Background: Dark Navy (#041E42)
- Icon: Dashboard, White, 32px
- Title: "Renja Management", White, 18px, Bold
- Subtitle: "Management System", White 70%, 12px

**Menu Items:**
- Icon: Corporate Blue
- Text: Dark Navy
- Selected: Light blue background (10% opacity)
- Divider: Light Gray

**Used in:**
- All list pages

---

## Layout Patterns

### List Page Layout
```
┌─────────────────────────────────────┐
│ AppBar (Dark Navy)                  │
├─────────────────────────────────────┤
│ [Filter Bar / Search]               │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Card Item 1                     │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Card Item 2                     │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Card Item 3                     │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [FAB: Add]                          │
└─────────────────────────────────────┘
```

### Card Item Layout
```
┌─────────────────────────────────────┐
│ Title                    [Badge]    │
│ Subtitle                           │
│                                    │
│ [Chip 1]  [Chip 2]  [Chip 3]      │
│                                    │
│ [Optional Stats/Info]              │
│                                    │
│                    [Edit] [Delete]  │
└─────────────────────────────────────┘
```

---

## Color Usage Guide

| Element | Color | Usage |
|---------|-------|-------|
| AppBar | Dark Navy | Main header |
| Primary Buttons | Corporate Blue | Main actions |
| Icons | Corporate Blue | Interactive elements |
| Success Badge | Lime Green | Completed items |
| Error Badge | Red | Failed items |
| Info Chips | Corporate Blue | Metadata |
| Stat Cards | Corporate Blue | Statistics |
| Class Cards | Lime Green | Class breakdown |
| Text | Dark Navy | Primary text |
| Secondary Text | Cool Gray | Hints, labels |
| Backgrounds | Light Gray/White | Surfaces |

---

## Spacing Standards

- **Padding:** 16px (cards), 12px (sections), 8px (elements)
- **Margin:** 12px (between cards), 8px (between elements)
- **Gap:** 12px (between chips/buttons)
- **Border Radius:** 8px (components), 12px (cards)

---

## Typography

- **Titles:** 16-20px, Weight 600, Dark Navy
- **Subtitles:** 12-14px, Weight 500, Dark Navy
- **Body:** 14px, Weight 400, Dark Navy
- **Labels:** 11-12px, Weight 500, Cool Gray
- **Buttons:** 14px, Weight 600, Corporate Blue

---

## Responsive Design

- **Mobile:** < 600px width
  - Single column layout
  - Full-width cards
  - Bottom sheet modals for filters

- **Tablet/Desktop:** ≥ 600px width
  - Multi-column layouts
  - Inline filters
  - Dialog modals

---

## Accessibility

✅ **Color Contrast:** WCAG AA compliant
✅ **Touch Targets:** Minimum 48x48px
✅ **Text Size:** Minimum 12px
✅ **Icons:** Always paired with labels
✅ **Focus States:** Visible keyboard navigation

