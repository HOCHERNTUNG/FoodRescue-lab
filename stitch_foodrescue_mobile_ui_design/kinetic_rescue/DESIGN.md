---
name: Kinetic Rescue
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#4d4632'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f1'
  outline: '#7f775f'
  outline-variant: '#d0c6ab'
  surface-tint: '#715c00'
  primary: '#715c00'
  on-primary: '#ffffff'
  primary-container: '#ffd300'
  on-primary-container: '#705b00'
  inverse-primary: '#ecc300'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e4e2e1'
  on-secondary-container: '#656464'
  tertiary: '#7c5800'
  on-tertiary: '#ffffff'
  tertiary-container: '#ffd07c'
  on-tertiary-container: '#7b5700'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffe17a'
  primary-fixed-dim: '#ecc300'
  on-primary-fixed: '#231b00'
  on-primary-fixed-variant: '#554500'
  secondary-fixed: '#e4e2e1'
  secondary-fixed-dim: '#c8c6c6'
  on-secondary-fixed: '#1b1c1c'
  on-secondary-fixed-variant: '#474747'
  tertiary-fixed: '#ffdea8'
  tertiary-fixed-dim: '#ffba20'
  on-tertiary-fixed: '#271900'
  on-tertiary-fixed-variant: '#5e4200'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  display-lg:
    fontFamily: Epilogue
    fontSize: 34px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Epilogue
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  title-sm:
    fontFamily: Work Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Work Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Work Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Work Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 24px
  stack-gap: 16px
  section-padding: 32px
  inline-gutter: 12px
---

## Brand & Style

This design system is built for an energetic, mission-driven mobile experience that balances professional reliability with high-octane urgency. The brand personality is proactive, community-focused, and efficient. 

The aesthetic sits at the intersection of **High-Contrast Minimalism** and **Modern Corporate**. It leverages heavy white space to ensure the vibrant "Cyber-Yellow" feels like a call to action rather than an overwhelming presence. The interface avoids unnecessary ornamentation, opting for a flat, structural approach that emphasizes speed and clarity. The goal is to evoke a sense of "organized momentum"—making food rescue feel like a sleek, modern logistics operation.

## Colors

The palette is anchored by **Cyber-Yellow (#FFD300)**, used strategically for primary actions and brand identifiers to command attention. **Charcoal Grey (#333333)** provides the professional weight and legibility required for high-frequency use.

- **Primary:** Cyber-Yellow for buttons, active states, and highlights.
- **Secondary:** Charcoal Grey for high-emphasis text and structural elements.
- **Surface:** Pure white (#FFFFFF) is the primary background to maintain "generous white space."
- **Progress:** A bright amber-yellow gradient is reserved exclusively for progress indicators and data visualization, adding depth to the otherwise flat palette.
- **Status:** Standardized semantic colors (Green for success, Red for urgent/expired) should be muted to prevent clashing with the primary yellow.

## Typography

This design system uses **Epilogue** for headings to provide a distinctive, editorial edge that feels modern and urgent. **Work Sans** is used for body copy and UI labels due to its exceptional readability and professional, neutral tone.

Emphasis is achieved through "Bold Black" (#000000) for all display and headline levels. This high contrast against the Cyber-Yellow and White backgrounds ensures the hierarchy is unmistakable at a glance. Body text should maintain a slightly softer Charcoal Grey to preserve readability over long periods.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for mobile breakpoints, emphasizing a "Generous White Space" philosophy. 

- **Margins:** A strict 24px side margin keeps content away from screen edges, creating a premium, breathable feel.
- **Rhythm:** An 8px linear scaling system is used for all internal padding and margins.
- **Stacking:** Use 16px vertical gaps between standard cards and 32px between major logical sections to reinforce visual grouping.
- **Safe Areas:** Ensure interactive elements are vertically spaced to accommodate touch targets of at least 48px.

## Elevation & Depth

This design system utilizes **Soft-Shadow Layering** to define hierarchy without cluttering the interface with lines.

- **Level 0 (Base):** White or Neutral-Light backgrounds.
- **Level 1 (Cards):** Soft, diffused shadows (0px 4px 20px rgba(0,0,0,0.06)) on white containers. This creates a subtle lift that distinguishes content blocks from the background.
- **Level 2 (Active/Floating):** Higher blur radius shadows for FABs (Floating Action Buttons) or active selection states, indicating immediate interactability.
- **Flat Depth:** Progress bars, inputs, and secondary buttons remain flat, relying on color and borders rather than shadows to minimize visual noise.

## Shapes

The shape language is defined by **High-Contrast Roundedness**. A standard 16px corner radius is applied to all primary cards, containers, and buttons. 

- **Primary Radius:** 16px (rounded-lg) for main content cards and large buttons.
- **Secondary Radius:** 8px (rounded-md) for smaller inputs and utility tags.
- **Pill Shape:** Used exclusively for status chips (e.g., "Available", "Pending") and the progress bar caps to create a distinct visual language for "system state" vs "user content."

## Components

### Buttons
- **Primary:** Cyber-Yellow fill, Bold Black text, 16px rounded corners. No shadow.
- **Secondary:** Charcoal Grey fill, White text, 16px rounded corners.
- **Ghost:** Bold Black outline (2px), transparent fill.

### Cards
- White background with the defined Level 1 Soft-Shadow. 
- 16px padding internally. 
- Use for food listings, donation summaries, and profile modules.

### Progress Bars
- Background: Charcoal Grey at 10% opacity.
- Fill: Bright Amber-Yellow Gradient. 
- Height: 8px with fully rounded (pill) ends.

### Inputs
- Flat, 2px border in light grey, switching to Cyber-Yellow on focus. 
- 16px corner radius.
- Placeholder text in a subtle grey to maintain the clean aesthetic.

### Icons
- Minimalistic, flat line-art icons with a consistent 2px stroke weight.
- Use Charcoal Grey for default state and Cyber-Yellow for active navigation states.

### Additional Components
- **Impact Badge:** A large, rounded square module with Cyber-Yellow background and Display-level typography to highlight "Meals Saved" or "CO2 Reduced" metrics.