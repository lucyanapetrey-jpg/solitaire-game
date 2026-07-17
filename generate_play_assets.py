"""Regenerate Solitaire Klondike Play Store screenshots showing actual gameplay.

Google rejected the previous set for Metadata policy (screenshots didn't describe
the app's functionality). The new set renders the real Klondike Solitaire board
layout: 4 foundation piles, stock/waste in upper-left, and 7 tableau columns with
face-up and face-down cards.
"""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

ROOT = Path(r"D:\solitaire_game")
SCREENS = ROOT / "play_screenshots"

# Felt green table background (matches existing brand).
BG_TOP = (24, 110, 70)
BG_BOTTOM = (12, 78, 50)

WHITE = (252, 252, 252)
BLACK = (20, 20, 20)
RED = (200, 30, 40)
CARD_BACK = (35, 78, 142)
CARD_BACK_INNER = (62, 124, 200)
SHADOW = (0, 0, 0, 90)

W, H = 1080, 1920


def find_font(size, bold=False):
    candidates = (
        [r"C:\Windows\Fonts\segoeuib.ttf", r"C:\Windows\Fonts\arialbd.ttf"]
        if bold else
        [r"C:\Windows\Fonts\segoeui.ttf", r"C:\Windows\Fonts\arial.ttf"]
    )
    for p in candidates:
        if Path(p).exists():
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def vertical_gradient(size, top, bottom):
    w, h = size
    img = Image.new("RGB", size, top)
    px = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        r = round(top[0] + (bottom[0] - top[0]) * t)
        g = round(top[1] + (bottom[1] - top[1]) * t)
        b = round(top[2] + (bottom[2] - top[2]) * t)
        for x in range(w):
            px[x, y] = (r, g, b)
    return img


def draw_card_face(draw, x, y, w, h, rank, suit, font_corner, font_center):
    """Draw a face-up playing card."""
    # shadow
    draw.rounded_rectangle([x + 3, y + 4, x + w + 3, y + h + 4], radius=14, fill=(0, 0, 0, 80))
    draw.rounded_rectangle([x, y, x + w, y + h], radius=14, fill=WHITE, outline=(60, 60, 60), width=2)
    color = RED if suit in "♥♦" else BLACK
    # top-left rank + suit
    draw.text((x + 8, y + 4), rank, font=font_corner, fill=color)
    draw.text((x + 8, y + 4 + font_corner.size + 2), suit, font=font_corner, fill=color)
    # center large suit
    bbox = draw.textbbox((0, 0), suit, font=font_center)
    cw = bbox[2] - bbox[0]
    ch = bbox[3] - bbox[1]
    draw.text((x + (w - cw) // 2, y + (h - ch) // 2 - 4), suit, font=font_center, fill=color)


def draw_card_back(draw, x, y, w, h):
    draw.rounded_rectangle([x + 3, y + 4, x + w + 3, y + h + 4], radius=14, fill=(0, 0, 0, 80))
    draw.rounded_rectangle([x, y, x + w, y + h], radius=14, fill=CARD_BACK, outline=(20, 30, 60), width=2)
    # diamond cross-hatch pattern
    inset = 8
    draw.rounded_rectangle([x + inset, y + inset, x + w - inset, y + h - inset], radius=8, fill=CARD_BACK_INNER)
    # decorative center diamond
    cx, cy = x + w // 2, y + h // 2
    draw.polygon([(cx, cy - 20), (cx + 14, cy), (cx, cy + 20), (cx - 14, cy)], fill=(220, 230, 250))


def draw_empty_slot(draw, x, y, w, h, label=""):
    draw.rounded_rectangle([x, y, x + w, y + h], radius=14, outline=(240, 240, 240, 120), width=2)
    if label:
        font = find_font(36, bold=True)
        bbox = draw.textbbox((0, 0), label, font=font)
        cw = bbox[2] - bbox[0]
        ch = bbox[3] - bbox[1]
        draw.text((x + (w - cw) // 2, y + (h - ch) // 2 - 4), label, font=font, fill=(255, 255, 255, 90))


def render_klondike_board(highlight_hint=False, near_win=False):
    """Render a full Klondike board state, returns RGB image at W x H."""
    img = vertical_gradient((W, H), BG_TOP, BG_BOTTOM)
    draw = ImageDraw.Draw(img, "RGBA")

    # Top status bar
    font_status = find_font(40, bold=True)
    draw.text((40, 40), "Score 1,240", font=font_status, fill=WHITE)
    draw.text((W // 2 - 60, 40), "02:18", font=font_status, fill=WHITE)
    draw.text((W - 220, 40), "Moves 47", font=font_status, fill=WHITE)

    # Card sizing
    card_w = 130
    card_h = 180
    gap = 12
    margin_x = (W - 7 * card_w - 6 * gap) // 2

    # Foundations (row 1) — 4 piles on the right
    fy = 130
    font_corner = find_font(34, bold=True)
    font_center = find_font(80, bold=True)

    # Stock + waste on the left
    stock_x = margin_x
    draw_card_back(draw, stock_x, fy, card_w, card_h)
    # waste pile shows one card peeking
    waste_x = stock_x + card_w + gap
    draw_card_face(draw, waste_x, fy, card_w, card_h, "8", "♠", font_corner, font_center)

    # Foundations: empty + A + 2 + (3 if near_win else empty)
    found_start = margin_x + 3 * (card_w + gap)
    foundations = [
        ("A" if not near_win else "K", "♥"),
        ("A" if not near_win else "Q", "♦"),
        (None, "♣"),  # empty
        ("2" if not near_win else "J", "♠"),
    ]
    if near_win:
        foundations = [("K", "♥"), ("K", "♦"), ("Q", "♣"), ("K", "♠")]
    for i, (rank, suit) in enumerate(foundations):
        x = found_start + i * (card_w + gap)
        if rank is None:
            draw_empty_slot(draw, x, fy, card_w, card_h, label=suit)
        else:
            draw_card_face(draw, x, fy, card_w, card_h, rank, suit, font_corner, font_center)

    # Tableau (7 columns)
    ty = fy + card_h + 50
    cascade = 38  # vertical offset between stacked cards
    # Each column: list of (face_up, rank, suit). First N-1 are face-down.
    columns = [
        [(True, "K", "♣")],
        [(False,), (True, "Q", "♦")],
        [(False,), (False,), (True, "J", "♠")],
        [(False,), (False,), (False,), (True, "10", "♥")],
        [(False,), (False,), (False,), (False,), (True, "9", "♠")],
        [(False,), (False,), (False,), (False,), (False,), (True, "5", "♣"), (True, "4", "♦"), (True, "3", "♠")],
        [(False,), (False,), (False,), (False,), (False,), (False,), (True, "7", "♥"), (True, "6", "♣")],
    ]
    for ci, col in enumerate(columns):
        cx = margin_x + ci * (card_w + gap)
        for ri, c in enumerate(col):
            y = ty + ri * cascade
            if c[0]:
                rank, suit = c[1], c[2]
                draw_card_face(draw, cx, y, card_w, card_h, rank, suit, font_corner, font_center)
                # highlight last card of column 6 (the runs) for hint demo
                if highlight_hint and ci == 5 and ri == len(col) - 1:
                    draw.rounded_rectangle([cx - 4, y - 4, cx + card_w + 4, y + card_h + 4],
                                           radius=18, outline=(255, 215, 0), width=5)
            else:
                draw_card_back(draw, cx, y, card_w, card_h)

    # Bottom control hints
    font_btn = find_font(36, bold=True)
    by = H - 220
    btn_w = 240
    btn_h = 90
    btns = [("Hint", margin_x), ("Undo", margin_x + 280), ("New Game", margin_x + 560)]
    for label, bx in btns:
        draw.rounded_rectangle([bx, by, bx + btn_w, by + btn_h], radius=22,
                               fill=(0, 0, 0, 130), outline=(255, 255, 255, 180), width=2)
        bbox = draw.textbbox((0, 0), label, font=font_btn)
        cw = bbox[2] - bbox[0]
        ch = bbox[3] - bbox[1]
        draw.text((bx + (btn_w - cw) // 2, by + (btn_h - ch) // 2 - 4), label, font=font_btn, fill=WHITE)

    return img


def render_stats_screen():
    """A clean stats screen showing win streak and statistics."""
    img = vertical_gradient((W, H), BG_TOP, BG_BOTTOM)
    draw = ImageDraw.Draw(img, "RGBA")

    title_font = find_font(72, bold=True)
    body_font = find_font(46, bold=True)
    label_font = find_font(36)
    big_font = find_font(120, bold=True)

    # Centered card title
    title = "Your Stats"
    bbox = draw.textbbox((0, 0), title, font=title_font)
    cw = bbox[2] - bbox[0]
    draw.text(((W - cw) // 2, 180), title, font=title_font, fill=WHITE)

    # Big win streak number
    streak = "14"
    bbox = draw.textbbox((0, 0), streak, font=big_font)
    cw = bbox[2] - bbox[0]
    draw.text(((W - cw) // 2, 360), streak, font=big_font, fill=(255, 215, 0))
    label = "Win Streak"
    bbox = draw.textbbox((0, 0), label, font=body_font)
    cw = bbox[2] - bbox[0]
    draw.text(((W - cw) // 2, 530), label, font=body_font, fill=WHITE)

    # Card-styled stats panels
    panel_y = 700
    panel_w = 460
    panel_h = 220
    gap_x = 60
    panel_x_left = (W - panel_w * 2 - gap_x) // 2
    panel_x_right = panel_x_left + panel_w + gap_x

    def panel(x, y, big, label):
        draw.rounded_rectangle([x, y, x + panel_w, y + panel_h], radius=24, fill=(255, 255, 255, 25),
                               outline=(255, 255, 255, 90), width=2)
        bbox = draw.textbbox((0, 0), big, font=big_font)
        cw = bbox[2] - bbox[0]
        draw.text((x + (panel_w - cw) // 2, y + 18), big, font=big_font, fill=WHITE)
        bbox = draw.textbbox((0, 0), label, font=label_font)
        cw = bbox[2] - bbox[0]
        draw.text((x + (panel_w - cw) // 2, y + 160), label, font=label_font, fill=(220, 230, 220))

    panel(panel_x_left, panel_y, "238", "Games Won")
    panel(panel_x_right, panel_y, "67%", "Win Rate")
    panel(panel_x_left, panel_y + panel_h + 30, "01:42", "Best Time")
    panel(panel_x_right, panel_y + panel_h + 30, "4,860", "Best Score")

    # Render a couple of decorative cards at the bottom
    by = 1480
    bx = (W - 5 * 130 - 4 * 20) // 2
    font_corner = find_font(34, bold=True)
    font_center = find_font(80, bold=True)
    cards = [("A", "♠"), ("2", "♥"), ("3", "♣"), ("4", "♦"), ("5", "♠")]
    for i, (r, s) in enumerate(cards):
        draw_card_face(draw, bx + i * (130 + 20), by, 130, 180, r, s, font_corner, font_center)
    return img


def add_headline(img, headline, subtitle=None):
    draw = ImageDraw.Draw(img, "RGBA")
    # darken top strip for readability
    overlay = Image.new("RGBA", (W, 180), (0, 0, 0, 110))
    img.paste(overlay, (0, 0), overlay)
    # also bottom strip
    overlay_b = Image.new("RGBA", (W, 120), (0, 0, 0, 110))
    img.paste(overlay_b, (0, H - 120), overlay_b)

    headline_font = find_font(74, bold=True)
    bbox = draw.textbbox((0, 0), headline, font=headline_font)
    cw = bbox[2] - bbox[0]
    draw.text(((W - cw) // 2, 60), headline, font=headline_font, fill=WHITE)

    sub_font = find_font(40)
    sub = subtitle or "by Summer Smile"
    bbox = draw.textbbox((0, 0), sub, font=sub_font)
    cw = bbox[2] - bbox[0]
    draw.text(((W - cw) // 2, H - 90), sub, font=sub_font, fill=(220, 230, 220))


def make_featured():
    """1024x500 featured graphic with a Klondike board strip + title."""
    fw, fh = 1024, 500
    img = vertical_gradient((fw, fh), BG_TOP, BG_BOTTOM)
    draw = ImageDraw.Draw(img, "RGBA")

    # Render a small Klondike preview on the left
    card_w = 80
    card_h = 110
    gap = 8
    margin = 40
    font_corner = find_font(22, bold=True)
    font_center = find_font(50, bold=True)
    # 3 piles of cards diagonally
    pile = [
        (0, "K", "♠"), (1, "Q", "♥"), (2, "J", "♣"), (3, "10", "♦"),
    ]
    for i, (off, r, s) in enumerate(pile):
        x = margin + i * 22
        y = 140 + i * 36
        draw_card_face(draw, x, y, card_w, card_h, r, s, font_corner, font_center)

    # Second pile to the right
    for i, (r, s) in enumerate([("A", "♥"), ("2", "♥"), ("3", "♥")]):
        x = margin + 60 + i * 28
        y = 90 + i * 28
        draw_card_face(draw, x, y, card_w, card_h, r, s, font_corner, font_center)

    # Title on the right
    title_font = find_font(72, bold=True)
    sub_font = find_font(34)
    draw.text((430, 170), "Solitaire", font=title_font, fill=WHITE)
    draw.text((430, 250), "Klondike", font=title_font, fill=WHITE)
    draw.text((430, 350), "by Summer Smile", font=sub_font, fill=(220, 230, 220))

    out = ROOT / "play_feature_graphic.png"
    img.save(out, "PNG", optimize=True)
    print(f"wrote {out}")


def make_phone(filename, scene_fn, headline, subtitle="by Summer Smile"):
    img = scene_fn()
    add_headline(img, headline, subtitle)
    out = SCREENS / filename
    img.save(out, "PNG", optimize=True)
    print(f"wrote {out}")


if __name__ == "__main__":
    make_featured()
    make_phone("phone_1.png", lambda: render_klondike_board(), "Authentic Klondike Solitaire")
    make_phone("phone_2.png", lambda: render_klondike_board(highlight_hint=True), "Smart Hints & Unlimited Undo")
    make_phone("phone_3.png", render_stats_screen, "Win Streaks & Statistics")
    make_phone("phone_4.png", lambda: render_klondike_board(near_win=True), "Vegas & Standard Scoring")
