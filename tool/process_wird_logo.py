#!/usr/bin/env python3
"""Processes WIRD.jpg from project root into all required app icon & logo assets:
  - assets/icon/icon.png (1024x1024 on cream background #EBE2CF)
  - assets/icon/icon_foreground.png (1024x1024 transparent foreground)
  - assets/icon/splash_logo.png (512x512 transparent logo for splash screen)
  - assets/icon/logo_display.png (512x512 transparent logo for UI display in About & Onboarding)
"""
from __future__ import annotations

from pathlib import Path
from PIL import Image

REPO_ROOT = Path(__file__).resolve().parent.parent
SRC_JPG = REPO_ROOT / "WIRD.jpg"
OUT_DIR = REPO_ROOT / "assets" / "icon"

CREAM_BG = (235, 226, 207, 255)  # #EBE2CF


def remove_near_white(img: Image.Image, threshold: int = 238) -> Image.Image:
    """Removes near-white pixels globally from the image, converting them to transparent RGBA."""
    rgba = img.convert("RGBA")
    data = rgba.getdata()
    new_data = []
    for item in data:
        r, g, b, a = item
        if r >= threshold and g >= threshold and b >= threshold:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
    rgba.putdata(new_data)
    return rgba


def main() -> None:
    if not SRC_JPG.exists():
        raise FileNotFoundError(f"Source image not found: {SRC_JPG}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Loading {SRC_JPG}...")
    src = Image.open(SRC_JPG)

    # 1. Create transparent version by removing near-white background
    transparent_img = remove_near_white(src)

    # 2. Resize helper with high-quality Lanczos resampling
    def resize_img(img: Image.Image, size: int) -> Image.Image:
        return img.resize((size, size), Image.Resampling.LANCZOS)

    # 3. Create icon_foreground.png (1024x1024 transparent)
    fg_1024 = resize_img(transparent_img, 1024)
    fg_path = OUT_DIR / "icon_foreground.png"
    fg_1024.save(fg_path, "PNG")
    print(f"Wrote {fg_path}")

    # 4. Create icon.png (1024x1024 composited on cream background #EBE2CF)
    icon_1024 = Image.new("RGBA", (1024, 1024), CREAM_BG)
    icon_1024.alpha_composite(fg_1024)
    icon_path = OUT_DIR / "icon.png"
    icon_1024.save(icon_path, "PNG")
    print(f"Wrote {icon_path}")

    # 5. Create splash_logo.png (512x512 transparent)
    splash_512 = resize_img(transparent_img, 512)
    splash_path = OUT_DIR / "splash_logo.png"
    splash_512.save(splash_path, "PNG")
    print(f"Wrote {splash_path}")

    # 6. Create logo_display.png (512x512 transparent)
    logo_path = OUT_DIR / "logo_display.png"
    splash_512.save(logo_path, "PNG")
    print(f"Wrote {logo_path}")

    print("All logo assets successfully updated from WIRD.jpg.")


if __name__ == "__main__":
    main()
