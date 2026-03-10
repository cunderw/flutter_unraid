#!/usr/bin/env python3
"""Generate the Unraid app icon — a stylized server tower on a dark background."""

from PIL import Image, ImageDraw, ImageFont
import math
import os

SIZE = 1024
CENTER = SIZE // 2
BG_COLOR = (30, 30, 30)  # Dark background
ORANGE = (255, 140, 47)  # Unraid orange #FF8C2F
DARK_ORANGE = (204, 112, 38)  # Darker shade for depth
LIGHT_ORANGE = (255, 170, 90)  # Lighter shade for highlights
WHITE = (255, 255, 255)
DARK_GRAY = (50, 50, 50)
MID_GRAY = (80, 80, 80)

def draw_rounded_rect(draw, xy, radius, fill):
    """Draw a rounded rectangle."""
    x0, y0, x1, y1 = xy
    # Main rectangle body
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
    # Four corners
    draw.pieslice([x0, y0, x0 + 2 * radius, y0 + 2 * radius], 180, 270, fill=fill)
    draw.pieslice([x1 - 2 * radius, y0, x1, y0 + 2 * radius], 270, 360, fill=fill)
    draw.pieslice([x0, y1 - 2 * radius, x0 + 2 * radius, y1], 90, 180, fill=fill)
    draw.pieslice([x1 - 2 * radius, y1 - 2 * radius, x1, y1], 0, 90, fill=fill)


def create_icon():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Background with rounded corners (for iOS-style)
    draw_rounded_rect(draw, (0, 0, SIZE - 1, SIZE - 1), 180, BG_COLOR)

    # --- Draw a stylized server/NAS tower ---

    # Server case outline
    case_left = 280
    case_right = 744
    case_top = 150
    case_bottom = 874
    case_radius = 40

    # Subtle border/glow
    draw_rounded_rect(draw, (case_left - 3, case_top - 3, case_right + 3, case_bottom + 3), case_radius + 2, (60, 60, 60))
    draw_rounded_rect(draw, (case_left, case_top, case_right, case_bottom), case_radius, DARK_GRAY)

    # Three drive bays
    bay_margin = 30
    bay_left = case_left + bay_margin
    bay_right = case_right - bay_margin
    bay_height = 140
    bay_gap = 24
    bay_radius = 16

    bays_start = case_top + 50

    for i in range(3):
        y_top = bays_start + i * (bay_height + bay_gap)
        y_bottom = y_top + bay_height

        # Bay background
        draw_rounded_rect(draw, (bay_left, y_top, bay_right, y_bottom), bay_radius, MID_GRAY)

        # Drive activity LED (left side) — glowing orange
        led_x = bay_left + 30
        led_y = y_top + bay_height // 2
        led_r = 14

        # LED glow
        for r in range(led_r + 10, led_r, -1):
            alpha = int(80 * (1 - (r - led_r) / 10))
            glow_color = (255, 140, 47, alpha)
            # Draw on a temp layer for glow effect
        draw.ellipse([led_x - led_r, led_y - led_r, led_x + led_r, led_y + led_r], fill=ORANGE)
        # LED highlight
        draw.ellipse([led_x - led_r + 4, led_y - led_r + 4, led_x + 2, led_y + 2], fill=LIGHT_ORANGE)

        # Drive label lines (decorative horizontal lines)
        line_x_start = bay_left + 70
        line_x_end = bay_right - 30
        line_y = y_top + bay_height // 2

        # Main line
        draw.rectangle([line_x_start, line_y - 3, line_x_end, line_y + 3], fill=(100, 100, 100))
        # Secondary line
        draw.rectangle([line_x_start, line_y + 16, line_x_end - 80, line_y + 22], fill=(70, 70, 70))

    # Bottom section — power/status area
    status_top = bays_start + 3 * (bay_height + bay_gap) + 10
    status_bottom = case_bottom - 25

    # Divider line
    draw.rectangle([bay_left, status_top - 5, bay_right, status_top - 2], fill=(70, 70, 70))

    # Power button (circle with line)
    power_x = CENTER
    power_y = (status_top + status_bottom) // 2
    power_r = 30

    draw.ellipse([power_x - power_r, power_y - power_r, power_x + power_r, power_y + power_r], 
                 outline=ORANGE, width=5)
    draw.rectangle([power_x - 3, power_y - power_r - 2, power_x + 3, power_y - 6], fill=ORANGE)

    # Status LED bar at very bottom of case
    led_bar_y = status_bottom - 8
    led_bar_width = 180
    led_bar_left = CENTER - led_bar_width // 2
    draw_rounded_rect(draw, (led_bar_left, led_bar_y - 4, led_bar_left + led_bar_width, led_bar_y + 4), 4, ORANGE)

    # Save
    output_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(output_dir)
    assets_dir = os.path.join(project_root, "assets")
    os.makedirs(assets_dir, exist_ok=True)

    output_path = os.path.join(assets_dir, "app_icon.png")
    img.save(output_path, "PNG")
    print(f"Icon saved to {output_path}")

    # Also save a version without transparency for Android
    android_img = Image.new("RGB", (SIZE, SIZE), BG_COLOR)
    android_img.paste(img, mask=img.split()[3])
    android_path = os.path.join(assets_dir, "app_icon_android.png")
    android_img.save(android_path, "PNG")
    print(f"Android icon saved to {android_path}")


if __name__ == "__main__":
    create_icon()
