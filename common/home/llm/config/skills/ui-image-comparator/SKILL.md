---
name: ui-image-comparator
description: Compares two images pixel-by-pixel and via vision analysis, returning a similarity percentage and a detailed list of web UI design discrepancies.
---

# UI Image Comparator

Compares `image_a.png` (baseline) and `image_b.png` (current) located in `<root_folder>/`. Returns a similarity percentage and a comprehensive list of web UI design discrepancies needed to reach full similarity.

## Prerequisites

- **ImageMagick**: `compare`, `identify` commands available.
- **Vision capabilities**: The agent must be able to analyze images visually.

## Inputs

Both images must exist in `<root_folder>/`:

- `image_a.png` — the baseline / target design
- `image_b.png` — the current implementation

## Workflow

### Step 1: Validate Inputs

Confirm both files exist:

```bash
ls -la <root_folder>/image_a.png <root_folder>/image_b.png
```

If either file is missing, halt and report which file is missing.

### Step 2: Extract Dimensions

```bash
identify -format "%w %h" <root_folder>/image_a.png
identify -format "%w %h" <root_folder>/image_b.png
```

Multiply width by height to get `Total Pixels` for each image. Use the baseline (`image_a.png`) dimensions for the similarity calculation.

### Step 3: Pixel Comparison

Run ImageMagick compare to generate a diff image and the Absolute Error (AE — number of differing pixels):

```bash
compare -metric AE -fuzz 5% <root_folder>/image_a.png <root_folder>/image_b.png <root_folder>/diff-highlight.png 2>&1
```

- `-fuzz 5%` forgives minor anti-aliasing and sub-pixel rendering differences.
- The command outputs the differing pixel count to stderr (captured via `2>&1`).

### Step 4: Calculate Similarity

```
Similarity % = ((Total Pixels - Differing Pixels) / Total Pixels) * 100
```

Round to two decimal places.

### Step 5: Vision Analysis of Discrepancies

Use vision capabilities to analyze all three images together:

1. `image_a.png` — the target design
2. `image_b.png` — the current state
3. `diff-highlight.png` — the pixel diff (red regions = differences)

Identify every visual difference, categorized for web UI:

- **Layout**: Missing/extra elements, wrong structure, incorrect flex/grid alignment
- **Spacing**: Padding, margin, gap differences
- **Typography**: Font family, size, weight, line-height, letter-spacing, color
- **Colors**: Background, text, border, shadow color mismatches
- **Borders**: Width, radius, style, color differences
- **Shadows**: Box-shadow, text-shadow discrepancies
- **Sizing**: Width, height, min/max dimensions off
- **Positioning**: Absolute/relative positioning, z-index issues
- **Missing elements**: Components present in baseline but absent in current
- **Overflow/Visibility**: Content clipped, hidden, or overflowing unexpectedly

### Step 6: Output Report

Return a structured report with:

1. **Similarity**: `XX.XX%`
2. **Total Pixels**: number
3. **Differing Pixels**: number
4. **Discrepancies**: Numbered list ordered by visual impact (largest/most noticeable first). Each entry includes:
   - What is wrong (e.g., "Header background color is #333 instead of #1a1a1a")
   - Where it appears (e.g., "Top navigation bar, full width")
   - Suggested fix (e.g., "Change background-color in the header component")

## Thresholds

- **>= 80%**: Considered acceptable similarity.
- **< 80%**: Significant discrepancies remain.

## Limitations

- Dynamic content (random images, timestamps, avatars) will always register as diffs. These should be mocked to static values before comparison.
- OS-level font rendering and sub-pixel anti-aliasing can cause minor unavoidable differences.
- Animations and transitions must be complete before capturing `image_b.png`.
