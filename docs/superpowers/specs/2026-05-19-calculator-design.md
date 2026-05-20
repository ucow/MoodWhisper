# Calculator - Single Page Web App

## Overview
Single HTML file calculator with basic arithmetic (+, -, *, /), decimal support, chained operations, and keyboard input. No external dependencies.

## Structure
`calculator/index.html` — all HTML, CSS, and JavaScript inline.

## Layout
- **Display**: top area showing current input/expression and result
- **Buttons**: 4-column grid below
  - Row 1: C / ( ) — but keeping minimal: C
  - Rows 2-5: digits (7-8-9, 4-5-6, 1-2-3, 0-.=)
  - Operators: +, -, *, /, =
- Centered card on neutral gray background

## Behavior
- Click buttons or type keyboard to input
- Chained operations: `2 + 3 * 4` evaluates left-to-right (= 20, not 14)
- Clear (C) resets everything
- Divide by zero shows "Error"
- Second operator press replaces previous operator (no double-operators)

## Keyboard Mapping
| Key | Action |
|-----|--------|
| 0-9 | Digit input |
| .   | Decimal point |
| +, -, *, / | Operators |
| Enter | Equals |
| Escape | Clear |
| Backspace | Delete last character |

## Styling
- Clean, minimal design
- Dark display area with light text
- Operator buttons visually distinct from digit buttons
- Hover/active states on all buttons
- Responsive but optimized for desktop

## Edge Cases
- Leading zeros handled (e.g., "007" → "7")
- Multiple decimal points prevented
- Empty input on operator press defaults to "0"
- Result used as first operand when typing operator after equals
