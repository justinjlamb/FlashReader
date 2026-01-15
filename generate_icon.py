#!/usr/bin/env python3
"""Generate FlashReader app icon at all required sizes."""

from PIL import Image, ImageDraw, ImageFilter, ImageFont
import os

# Colors
BLACK = (0, 0, 0, 255)
RED = (204, 77, 77, 255)  # Muted red, easier on eyes
WHITE = (255, 255, 255, 255)
RED_GLOW = (204, 77, 77, 80)

def create_rounded_mask(size, radius):
    """Create a rounded rectangle mask."""
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([0, 0, size-1, size-1], radius=radius, fill=255)
    return mask

def create_icon(size):
    """Create the FlashReader icon at the given size."""
    # Create base image with transparency
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # macOS icon corner radius is roughly 22.37% of size
    corner_radius = int(size * 0.2237)

    # Draw black rounded rectangle background
    draw.rounded_rectangle(
        [0, 0, size-1, size-1],
        radius=corner_radius,
        fill=BLACK
    )

    # Calculate element positions for the ORP visualization
    # Three horizontal bars representing letters, center one is amber (ORP)
    center_y = size // 2
    bar_height = max(2, size // 12)
    bar_spacing = max(3, size // 6)
    bar_width_short = size // 4
    bar_width_long = size // 3

    # For larger sizes, add a subtle glow behind the amber bar
    if size >= 128:
        glow_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        glow_draw = ImageDraw.Draw(glow_layer)

        # Draw amber glow (larger, semi-transparent)
        glow_bar_width = bar_width_long + size // 8
        glow_bar_height = bar_height + size // 16
        glow_x = (size - glow_bar_width) // 2
        glow_y = center_y - glow_bar_height // 2

        glow_draw.rounded_rectangle(
            [glow_x, glow_y, glow_x + glow_bar_width, glow_y + glow_bar_height],
            radius=glow_bar_height // 2,
            fill=RED_GLOW
        )

        # Blur the glow
        glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=size // 20))

        # Composite glow onto main image
        img = Image.alpha_composite(img, glow_layer)
        draw = ImageDraw.Draw(img)

    # Top bar (before ORP) - white, dimmer, shorter
    top_y = center_y - bar_spacing - bar_height
    top_x = (size - bar_width_short) // 2 + size // 16  # Slightly right of center
    draw.rounded_rectangle(
        [top_x, top_y, top_x + bar_width_short, top_y + bar_height],
        radius=bar_height // 2,
        fill=(255, 255, 255, 100)
    )

    # Center bar (ORP) - amber, bright, longest
    center_x = (size - bar_width_long) // 2
    center_bar_y = center_y - bar_height // 2
    draw.rounded_rectangle(
        [center_x, center_bar_y, center_x + bar_width_long, center_bar_y + bar_height],
        radius=bar_height // 2,
        fill=RED
    )

    # Bottom bar (after ORP) - white, dimmer, shorter
    bottom_y = center_y + bar_spacing
    bottom_x = (size - bar_width_short) // 2 - size // 16  # Slightly left of center
    draw.rounded_rectangle(
        [bottom_x, bottom_y, bottom_x + bar_width_short, bottom_y + bar_height],
        radius=bar_height // 2,
        fill=(255, 255, 255, 100)
    )

    # Apply the rounded mask
    mask = create_rounded_mask(size, corner_radius)
    img.putalpha(mask)

    return img

def main():
    # Output directory
    output_dir = "/Users/justin/Developer/FlashReader/FlashReader/Assets.xcassets/AppIcon.appiconset"

    # Required sizes for macOS
    # Format: (size, scale, filename)
    sizes = [
        (16, 1, "icon_16x16.png"),
        (32, 2, "icon_16x16@2x.png"),
        (32, 1, "icon_32x32.png"),
        (64, 2, "icon_32x32@2x.png"),
        (128, 1, "icon_128x128.png"),
        (256, 2, "icon_128x128@2x.png"),
        (256, 1, "icon_256x256.png"),
        (512, 2, "icon_256x256@2x.png"),
        (512, 1, "icon_512x512.png"),
        (1024, 2, "icon_512x512@2x.png"),
    ]

    print("Generating FlashReader icons...")

    for pixel_size, scale, filename in sizes:
        icon = create_icon(pixel_size)
        filepath = os.path.join(output_dir, filename)
        icon.save(filepath, "PNG")
        print(f"  Created {filename} ({pixel_size}x{pixel_size})")

    print("\nDone! Icons saved to AppIcon.appiconset")

    # Update Contents.json with filenames
    contents = {
        "images": [
            {"idiom": "mac", "scale": "1x", "size": "16x16", "filename": "icon_16x16.png"},
            {"idiom": "mac", "scale": "2x", "size": "16x16", "filename": "icon_16x16@2x.png"},
            {"idiom": "mac", "scale": "1x", "size": "32x32", "filename": "icon_32x32.png"},
            {"idiom": "mac", "scale": "2x", "size": "32x32", "filename": "icon_32x32@2x.png"},
            {"idiom": "mac", "scale": "1x", "size": "128x128", "filename": "icon_128x128.png"},
            {"idiom": "mac", "scale": "2x", "size": "128x128", "filename": "icon_128x128@2x.png"},
            {"idiom": "mac", "scale": "1x", "size": "256x256", "filename": "icon_256x256.png"},
            {"idiom": "mac", "scale": "2x", "size": "256x256", "filename": "icon_256x256@2x.png"},
            {"idiom": "mac", "scale": "1x", "size": "512x512", "filename": "icon_512x512.png"},
            {"idiom": "mac", "scale": "2x", "size": "512x512", "filename": "icon_512x512@2x.png"},
        ],
        "info": {"author": "xcode", "version": 1}
    }

    import json
    contents_path = os.path.join(output_dir, "Contents.json")
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    print("Updated Contents.json")

if __name__ == "__main__":
    main()
