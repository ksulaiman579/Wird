#!/usr/bin/env python3
"""Generates the app icon + splash mark: an 8-pointed geometric star (two
overlapping squares, the classic "rub el hizb" motif used throughout
Islamic geometric art — purely abstract, no calligraphy or figures) in the
app's gold accent on its emerald primary, per the plan's "emerald-green &
gold theme... subtle geometric Islamic-pattern... no imagery of living
beings" design guardrail.

Produces:
  - assets/icon/icon.png            (1024x1024, emerald bg + gold star — the
                                      full app icon for flutter_launcher_icons)
  - assets/icon/icon_foreground.png (1024x1024, transparent bg + gold star —
                                      Android adaptive-icon foreground layer)
  - assets/icon/splash_logo.png     (512x512, transparent bg + gold star —
                                      flutter_native_splash's centered logo)

Run: python3 tool/generate_icon.py
"""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

REPO_ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = REPO_ROOT / "assets" / "icon"

EMERALD = (4, 106, 56, 255)  # #046A38
GOLD = (201, 162, 39, 255)  # #C9A227


def _square_points(cx: float, cy: float, size: float, rotation_deg: float) -> list[tuple[float, float]]:
    half = size / 2
    corners = [(-half, -half), (half, -half), (half, half), (-half, half)]
    rad = math.radians(rotation_deg)
    cos_r, sin_r = math.cos(rad), math.sin(rad)
    return [
        (cx + x * cos_r - y * sin_r, cy + x * sin_r + y * cos_r)
        for x, y in corners
    ]


def draw_star(draw: ImageDraw.ImageDraw, cx: float, cy: float, size: float, color: tuple[int, ...]) -> None:
    """An 8-pointed star as the union outline of two squares 45deg apart,
    filled via the even-odd overlap producing the classic 8-point shape."""
    square_a = _square_points(cx, cy, size, 0)
    square_b = _square_points(cx, cy, size, 45)

    # Approximate the 8-point star by drawing both squares as a single
    # polygon path isn't straightforward with simple fills, so instead we
    # rasterize each square onto its own mask and union them — a clean,
    # exact 8-point star silhouette.
    mask_a = Image.new("L", draw.im.size, 0)
    mask_b = Image.new("L", draw.im.size, 0)
    ImageDraw.Draw(mask_a).polygon(square_a, fill=255)
    ImageDraw.Draw(mask_b).polygon(square_b, fill=255)
    from PIL import ImageChops

    union = ImageChops.lighter(mask_a, mask_b)
    draw.bitmap((0, 0), union, fill=color)


def build_icon(size: int, background: tuple[int, ...] | None, star_scale: float) -> Image.Image:
    img = Image.new("RGBA", (size, size), background or (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_star(draw, size / 2, size / 2, size * star_scale, GOLD)
    return img


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    build_icon(1024, EMERALD, 0.56).save(OUT_DIR / "icon.png")
    build_icon(1024, None, 0.62).save(OUT_DIR / "icon_foreground.png")
    build_icon(512, None, 0.7).save(OUT_DIR / "splash_logo.png")

    print(f"Wrote icon.png, icon_foreground.png, splash_logo.png to {OUT_DIR}")


if __name__ == "__main__":
    main()
