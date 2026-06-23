---
name: Nurture & Flow
colors:
  surface: '#fbf9f8'
  surface-dim: '#dbdad9'
  surface-bright: '#fbf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f3'
  surface-container: '#efeded'
  surface-container-high: '#e9e8e7'
  surface-container-highest: '#e4e2e2'
  on-surface: '#1b1c1c'
  on-surface-variant: '#424842'
  inverse-surface: '#303030'
  inverse-on-surface: '#f2f0f0'
  outline: '#737972'
  outline-variant: '#c2c8c0'
  surface-tint: '#4a654e'
  primary: '#4a654e'
  on-primary: '#ffffff'
  primary-container: '#8ba88e'
  on-primary-container: '#233d29'
  inverse-primary: '#b0ceb2'
  secondary: '#605e58'
  on-secondary: '#ffffff'
  secondary-container: '#e6e2d9'
  on-secondary-container: '#66645e'
  tertiary: '#8d4c3f'
  on-tertiary: '#ffffff'
  tertiary-container: '#db8d7d'
  on-tertiary-container: '#5e271c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cceace'
  primary-fixed-dim: '#b0ceb2'
  on-primary-fixed: '#07200f'
  on-primary-fixed-variant: '#334d38'
  secondary-fixed: '#e6e2d9'
  secondary-fixed-dim: '#c9c6be'
  on-secondary-fixed: '#1c1c17'
  on-secondary-fixed-variant: '#484741'
  tertiary-fixed: '#ffdad3'
  tertiary-fixed-dim: '#ffb4a5'
  on-tertiary-fixed: '#390c04'
  on-tertiary-fixed-variant: '#70362a'
  background: '#fbf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e2'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 20px
  gutter: 16px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
---

## Brand & Style

The design system is centered on the concept of "Gentle Precision." It balances the clinical necessity of data tracking with the emotional needs of a nursing mother. The brand personality is nurturing, empathetic, and organized, aiming to reduce the cognitive load and stress associated with newborn care.

The visual style is a blend of **Soft Minimalism** and **Organic UI**. It prioritizes heavy whitespace to create a sense of calm and uses subtle, rounded elements to evoke a feeling of safety and comfort. By avoiding sharp edges and high-contrast aggression, the interface becomes a quiet companion during late-night feeds and busy days. The emotional response should be one of "I am supported and in control."

## Colors

The palette uses a "Natural Comfort" logic:
- **Primary (Sage Green):** Used for main actions, active states, and growth indicators. It represents vitality and tranquility.
- **Secondary (Warm Cream):** The primary surface color. It is softer on the eyes than pure white, especially during nighttime use.
- **Tertiary (Soft Coral):** An accent for biological alerts, time-sensitive reminders, or "L" vs "R" breast toggles.
- **Neutral:** A deep charcoal-grey rather than black, ensuring typography remains readable but soft.

Backgrounds should primarily utilize the warm cream, while functional areas (like tracking cards) use a pure white to create subtle separation.

## Typography

This design system utilizes **Plus Jakarta Sans** for headings and labels to provide a friendly, modern, and slightly rounded geometric feel. **Be Vietnam Pro** is used for body copy due to its exceptional readability and warm, contemporary proportions.

To maintain a clean hierarchy:
- Use `headline-lg` for daily summaries and dashboard greetings.
- `body-md` is the workhorse for instructions and logged notes.
- `label-md` should be used for button text and category headers.
- All weights are kept between 400 and 700 to ensure the "soft" brand voice is not interrupted by overly thin or aggressive strokes.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for one-handed mobile use. The core philosophy is "Thumb-Friendly Reachability," placing primary tracking triggers in the bottom third of the screen.

- **Margins:** 20px side margins provide breathing room.
- **Vertical Rhythm:** A strict 8px baseline grid ensures alignment.
- **Grouping:** Use `stack-lg` to separate distinct data sections (e.g., Feeding vs. Diapers) and `stack-sm` for internal card elements (e.g., Time vs. Amount).
- **Mobile-First:** On desktop/tablet, content is constrained to a max-width of 480px to maintain the intimate, focused feel of the mobile experience.

## Elevation & Depth

This design system avoids harsh shadows. Instead, it uses **Tonal Layers** and **Soft Ambient Occulsion**.

- **Level 0 (Base):** The Warm Cream background.
- **Level 1 (Cards):** Pure White surfaces with a very soft, 10% opacity Sage Green shadow (Blur: 12px, Y: 4px). This makes cards feel like they are gently resting on the cream surface.
- **Active State:** Elements like the "Start Timer" button should use a slightly more pronounced shadow to indicate interactability.
- **Glassmorphism:** Use a light backdrop blur (10px) for fixed navigation bars at the bottom to maintain context of the scrolled content while keeping navigation clear.

## Shapes

The shape language is "Full and Friendly." Sharp corners are strictly avoided to reflect the softness of the brand.

- **Primary Containers:** 16px (rounded-lg) for cards and main modules.
- **Buttons:** 24px (rounded-xl) or fully pill-shaped to encourage tapping.
- **Input Fields:** 12px roundedness to match the friendly aesthetic.
- **Icons:** Must use a rounded cap and join style (Stroke: 2px) to ensure they feel integrated with the typography.

## Components

- **Buttons:** Primary buttons use the Sage Green background with white text. Secondary buttons use a Sage Green outline with a 1px stroke. The "Quick Start" button should be a floating action button (FAB) in the Soft Coral color.
- **Tracking Chips:** Small, pill-shaped indicators for "Left," "Right," or "Bottle." Use Coral for active selection and Sage for non-active functional selections.
- **Cards:** White background, 16px rounded corners, with a thin 1px border in a slightly darker Cream (#F2EBDC) to define edges without using shadows everywhere.
- **Progress Rings:** Used for timer visualizations. Use a thick 8px stroke in Sage Green, with the inactive track in a faint 10% Sage.
- **Input Fields:** Background should be a very light tint of the Primary color (5% Sage) to indicate where the user can type, with no border unless focused.
- **Lists:** Clean rows with 16px vertical padding, separated by a 1px Cream divider. Each row should have a soft-colored icon (e.g., a drop icon for milk) on the left.