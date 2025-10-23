# Renja Management - Corporate Theme Design

## Color Palette

### Primary Colors (Pantone)
- **Dark Navy** - `#041E42` (Pantone 282C)
  - Used for: AppBar, text headings, primary text
  - Role: Main brand color, strong authority

- **Corporate Blue** - `#135193` (Pantone 4152C)
  - Used for: Primary buttons, links, icons, focus states
  - Role: Primary action color, interactive elements

- **Lime Green** - `#93DA49` (Pantone 2285C)
  - Used for: Accent, success states, tertiary actions
  - Role: Positive feedback, highlights

### Secondary Colors (Pantone)
- **Dusty Blue** - `#5F8FB4` (Pantone 7454C)
  - Used for: Secondary buttons, secondary text
  - Role: Supporting color, secondary actions

- **Cool Gray** - `#8D949B` (Pantone 6211C)
  - Used for: Disabled states, hints, secondary labels
  - Role: Neutral, supporting text

### Neutral Colors
- **Light Background** - `#FAFBFC`
  - Used for: Scaffold background, page backgrounds
  - Role: Clean, professional backdrop

- **White** - `#FFFFFF`
  - Used for: Cards, surfaces, text on dark backgrounds
  - Role: Primary surface color

- **Light Blue** - `#E8F1F8`
  - Used for: Primary container, hover states
  - Role: Subtle background for primary elements

- **Light Gray** - `#E8EEF5`
  - Used for: Dividers, borders, secondary containers
  - Role: Subtle separation and structure

## Component Styling

### AppBar
- Background: Dark Navy (#041E42)
- Text: White
- Elevation: 2
- Title Font: 20px, Weight 600

### Buttons
**Elevated Button:**
- Background: Corporate Blue (#135193)
- Text: White
- Padding: 24px horizontal, 12px vertical
- Border Radius: 8px
- Elevation: 2

**Outlined Button:**
- Border: Corporate Blue, 1.5px
- Text: Corporate Blue
- Padding: 24px horizontal, 12px vertical
- Border Radius: 8px

**Text Button:**
- Text: Corporate Blue
- Padding: 16px horizontal, 8px vertical

### Cards
- Background: White
- Elevation: 1
- Border Radius: 12px
- Surface Tint: Corporate Blue with 5% opacity

### Input Fields
- Fill Color: Light Background (#FAFBFC)
- Border: Light Gray (#E8EEF5), 1px
- Focused Border: Corporate Blue, 2px
- Border Radius: 8px
- Label Color: Cool Gray

### Text Styles

**Display Styles:**
- Display Large: 32px, Weight 700, Dark Navy
- Display Medium: 28px, Weight 700, Dark Navy
- Display Small: 24px, Weight 700, Dark Navy

**Headline Styles:**
- Headline Large: 22px, Weight 600, Dark Navy
- Headline Medium: 20px, Weight 600, Dark Navy
- Headline Small: 18px, Weight 600, Dark Navy

**Title Styles:**
- Title Large: 16px, Weight 600, Dark Navy
- Title Medium: 14px, Weight 500, Dark Navy
- Title Small: 12px, Weight 500, Dark Navy

**Body Styles:**
- Body Large: 16px, Weight 400, Dark Navy
- Body Medium: 14px, Weight 400, Dark Navy
- Body Small: 12px, Weight 400, Cool Gray

**Label Styles:**
- Label Large: 14px, Weight 600, Dark Navy
- Label Medium: 12px, Weight 500, Dark Navy
- Label Small: 11px, Weight 500, Cool Gray

### Floating Action Button
- Background: Corporate Blue (#135193)
- Icon: White
- Elevation: 4
- Border Radius: 12px

### Chips
- Background: Light Gray (#E8EEF5)
- Selected: Corporate Blue
- Text: Dark Navy
- Border Radius: 8px

### Dividers
- Color: Light Gray (#E8EEF5)
- Thickness: 1px
- Spacing: 16px

## Design Principles

✅ **Professional** - Corporate blue and navy create authority and trust
✅ **Clean** - Light backgrounds and subtle shadows provide clarity
✅ **Accessible** - High contrast ratios for readability
✅ **Consistent** - Unified color usage across all components
✅ **Modern** - Material Design 3 with rounded corners and elevation
✅ **Functional** - Color coding for actions (blue=primary, green=success, red=error)

## Usage Guidelines

### When to Use Each Color

**Dark Navy (#041E42):**
- AppBar backgrounds
- Main headings and titles
- Primary text content
- Strong emphasis

**Corporate Blue (#135193):**
- Primary action buttons
- Links and interactive elements
- Focus states
- Icons

**Lime Green (#93DA49):**
- Success states
- Positive feedback
- Accent highlights
- Tertiary actions

**Dusty Blue (#5F8FB4):**
- Secondary buttons
- Secondary information
- Supporting elements

**Cool Gray (#8D949B):**
- Disabled states
- Hint text
- Secondary labels
- Subtle information

## Implementation

The theme is implemented in `lib/main.dart` using Flutter's Material Design 3 `ColorScheme` and `ThemeData`. All components automatically inherit the corporate color scheme through the theme system.

To customize colors, modify the color constants in the `_buildCorporateTheme()` method in `lib/main.dart`.

