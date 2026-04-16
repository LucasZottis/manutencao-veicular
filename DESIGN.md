# Design System Strategy: The Precision Mechanic

This design system is a high-end, editorial-inspired framework for a modern vehicle maintenance experience. It moves away from the "utility-first" clutter of traditional automotive apps, favoring a sophisticated, layered approach that treats vehicle data with the same reverence as a luxury timepiece.

---

## 1. Overview & Creative North Star: "The Digital Curator"

Our Creative North Star is **The Digital Curator**. Unlike standard maintenance logs that feel like a digital spreadsheet, this system is designed to feel like a high-performance dashboard—precise, authoritative, and calm. 

We break the "template" look by utilizing **Intentional Asymmetry**. Instead of perfectly centered grids, we use weighted typography and offset containers to lead the eye. We favor **Tonal Depth** over lines; the UI is not a flat canvas but a series of precision-machined layers. Every status update should feel like an insight, not just a notification.

---

## 2. Colors: Tonal Depth & The "No-Line" Rule

The palette is rooted in deep architectural blues (`primary`) and cool, industrial greys. 

*   **The "No-Line" Rule:** To maintain a premium feel, **1px solid borders are strictly prohibited for sectioning.** Boundaries must be defined solely through background shifts. For example, a `surface-container-low` section should sit on a `surface` background to create a logical break without visual noise.
*   **Surface Hierarchy & Nesting:** Treat the UI as a physical stack.
    *   **Base:** `surface` (#f7fafc)
    *   **Sectioning:** `surface-container-low` (#f1f4f6)
    *   **Interactive Cards:** `surface-container-lowest` (#ffffff)
    *   **Overlays/Modals:** `surface-container-highest` (#e0e3e5)
*   **The "Glass & Gradient" Rule:** Use `surface-tint` with 12% opacity and a `backdrop-filter: blur(20px)` for floating navigation bars or sticky headers. For primary actions, apply a subtle linear gradient from `primary` (#003b5a) to `primary-container` (#1a5276) at a 135-degree angle to provide a "machined metal" luster.
*   **Status Logic:**
    *   **Good:** Use `on-secondary-container` (Cool Teal/Blue-Grey) for a "calm" state rather than a vibrating green.
    *   **Upcoming:** Use `tertiary_fixed_dim` (#f2bd74) for a sophisticated amber glow.
    *   **Urgent:** Use `error` (#ba1a1a) sparingly, reserved for critical mechanical failures.

---

## 3. Typography: Editorial Precision

We use a high-contrast pairing of **Space Grotesk** (Display/Headlines) and **Inter** (UI/Body) to balance character with legibility.

*   **Display & Headline (Space Grotesk):** This is our "Precision" voice. Use `display-lg` for vehicle names and `headline-sm` for section headers. The wider aperture of Space Grotesk feels modern and automotive.
*   **Body & Labels (Inter):** Inter handles all data. Use `body-md` for general specs and `label-md` for technical readouts. 
*   **Hierarchy Tip:** Pair a `headline-lg` value (e.g., "75%") with a `label-sm` unit (e.g., "OIL LIFE") positioned slightly offset to the top-right to create a signature, data-dense editorial look.

---

## 4. Elevation & Depth: The Layering Principle

Depth is achieved through light and layering, never through heavy shadows or structural lines.

*   **Tonal Layering:** Place a `surface-container-lowest` card on top of a `surface-container-low` background. This creates a "soft lift."
*   **Ambient Shadows:** For floating elements (like a "Start Service" FAB), use a shadow with a 32px blur and 6% opacity, tinted with `primary` (#003b5a). This mimics the way light interacts with polished car paint.
*   **The "Ghost Border":** If a separation is required for accessibility in high-glare environments, use the `outline-variant` token at **15% opacity**. It should be felt, not seen.
*   **Glassmorphism:** Use for status widgets that overlay vehicle photography. A `surface-variant` with 40% opacity and high blur creates a "frosted windshield" effect that maintains readability over busy backgrounds.

---

## 5. Components

### Cards & Lists (The Core Component)
*   **Rule:** Forbid divider lines. 
*   **Execution:** Group related vehicle parts (Tires, Brakes, Fluids) into separate `surface-container-low` blocks. Within these blocks, use `24px` of vertical white space to separate line items. 
*   **Interactive State:** On press, transition the background from `surface-container-lowest` to `primary-fixed`.

### Buttons
*   **Primary:** Gradient of `primary` to `primary-container`. `xl` (0.75rem) roundedness.
*   **Secondary:** Ghost style. No background, `primary` text, and a `15% opacity outline-variant` ghost border.
*   **Tertiary:** `on-surface-variant` text with no container, used for "Dismiss" or "Later."

### Technical Status Chips
*   **Style:** Small, `full` rounded (pill) shapes.
*   **Coloring:** Use `tertiary-container` (#6b4604) for "Upcoming Service" to ensure it feels like a warning, not an error. Text should be `tertiary_fixed`.

### Input Fields
*   **Style:** Minimalist. No bottom line or box. Use a `surface-container-highest` background with `sm` (0.125rem) roundedness at the bottom only, creating a "tab" feel.

---

## 6. Do's and Don'ts

### Do:
*   **Do** use asymmetrical margins (e.g., 24px left, 16px right) on dashboard cards to create an "instrument cluster" feel.
*   **Do** use automotive-themed iconography with a consistent 1.5px stroke weight.
*   **Do** leverage `surface-dim` for "inactive" vehicle profiles to push them into the background.

### Don't:
*   **Don't** use pure black (#000000). Use `on-primary-fixed` (#001e30) for high-contrast text; it retains a "mechanical blue" soul.
*   **Don't** use standard "Material Design" shadows. They are too generic for a premium automotive experience.
*   **Don't** use icons as the sole indicator of status. Always pair them with Tonal Layering or a color-coded label.