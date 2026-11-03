# 生成 16x16 菜单字模和查表函数。bit15 是左像素。

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
FONT = r"C:\Windows\Fonts\simhei.ttf"
CELL = 16

LABELS = [
    "转场",
    "速度",
    "亮度",
    "对比",
    "色温",
    "色调",
    "特效",
    "强度",
    "音频",
    "音色",
    "字色",
    "字速",
    "字横",
    "字纵",
]

VALUES = {
    0: ["左滑", "右滑", "对角", "对开", "棋盘", "错行", "十字"],
    1: ["慢", "中", "快"],
    6: ["原图", "灰度", "二值", "反色", "伽马"],
    8: ["关闭", "波形", "频谱"],
    9: ["绿色", "彩虹"],
    10: ["白色", "彩虹"],
    11: ["暂停", "快速", "超快速"],
}
NUMERIC = {2, 3, 4, 5, 7, 12, 13}


def unique_chars():
    text = " " + "".join(LABELS)
    for words in VALUES.values():
        text += "".join(words)
    text += "0123456789"
    seen = []
    for ch in text:
        if ch not in seen:
            seen.append(ch)
    return seen


def render(chars):
    font = ImageFont.truetype(FONT, 14)
    rows = []
    for ch in chars:
        img = Image.new("L", (CELL, CELL), 0)
        draw = ImageDraw.Draw(img)
        box = draw.textbbox((0, 0), ch, font=font)
        cw = box[2] - box[0]
        chh = box[3] - box[1]
        x = (CELL - cw) // 2 - box[0]
        y = (CELL - chh) // 2 - box[1]
        if ch != " ":
            draw.text((x, y), ch, font=font, fill=255)
        for row in range(CELL):
            bits = 0
            for col in range(CELL):
                if img.getpixel((col, row)) >= 128:
                    bits |= 1 << (15 - col)
            rows.append(bits)
    return rows


def emit(chars, rows):
    gid = {ch: i for i, ch in enumerate(chars)}
    lines = []
    lines.append("function [15:0] menu_glyph_row;")
    lines.append("    input [6:0] gid;")
    lines.append("    input [3:0] grow;")
    lines.append("    begin")
    lines.append("        case ({gid, grow})")
    for i, bits in enumerate(rows):
        if bits:
            lines.append("            11'd%-4d: menu_glyph_row = 16'h%04X;" % (i, bits))
    lines.append("            default: menu_glyph_row = 16'h0000;")
    lines.append("        endcase")
    lines.append("    end")
    lines.append("endfunction")
    lines.append("")
    lines.append("function [6:0] menu_label_gid;")
    lines.append("    input [3:0] item;")
    lines.append("    input [1:0] col;")
    lines.append("    reg [6:0] g;")
    lines.append("    begin")
    lines.append("        g = 7'd0;")
    lines.append("        case (item)")
    for item, text in enumerate(LABELS):
        cells = list(text) + [" "] * (4 - len(text))
        ids = ", ".join("7'd%d" % gid[ch] for ch in cells[:4])
        lines.append("            4'd%-2d: case (col)" % item)
        for col, ch in enumerate(cells[:4]):
            lines.append("                2'd%d: g = 7'd%d;" % (col, gid[ch]))
        lines.append("                default: g = 7'd0;")
        lines.append("            endcase")
    lines.append("            default: g = 7'd0;")
    lines.append("        endcase")
    lines.append("        menu_label_gid = g;")
    lines.append("    end")
    lines.append("endfunction")
    lines.append("")
    lines.append("function [6:0] menu_value_gid;")
    lines.append("    input [3:0] item;")
    lines.append("    input [7:0] val;")
    lines.append("    input [1:0] col;")
    lines.append("    reg [6:0] g;")
    lines.append("    reg [3:0] dig;")
    lines.append("    begin")
    lines.append("        g = 7'd0;")
    lines.append("        case (item)")
    for item, words in VALUES.items():
        lines.append("            4'd%-2d: case (val)" % item)
        for vi, word in enumerate(words):
            lines.append("                8'd%d: case (col)" % vi)
            for col in range(4):
                ch = word[col] if col < len(word) else " "
                lines.append("                    2'd%d: g = 7'd%d;" % (col, gid[ch]))
            lines.append("                    default: g = 7'd0;")
            lines.append("                endcase")
        lines.append("                default: g = 7'd0;")
        lines.append("            endcase")
    lines.append("            default: begin")
    lines.append("                case (col)")
    lines.append("                    2'd0: dig = val / 8'd100;")
    lines.append("                    2'd1: dig = (val / 8'd10) % 8'd10;")
    lines.append("                    2'd2: dig = val % 8'd10;")
    lines.append("                    default: dig = 4'd15;")
    lines.append("                endcase")
    lines.append("                case (dig)")
    for d in range(10):
        lines.append("                    4'd%d: g = 7'd%d;" % (d, gid[str(d)]))
    lines.append("                    default: g = 7'd0;")
    lines.append("                endcase")
    lines.append("            end")
    lines.append("        endcase")
    lines.append("        menu_value_gid = g;")
    lines.append("    end")
    lines.append("endfunction")
    path = HERE / "menu_font.vh"
    path.write_text("\n".join(lines) + "\n", encoding="ascii")
    print("glyphs", len(chars), "rows", len(rows), "file", path.name)


def main():
    chars = unique_chars()
    if len(chars) > 80:
        raise SystemExit("too many glyphs %d" % len(chars))
    emit(chars, render(chars))
    print("".join(chars))


if __name__ == "__main__":
    main()
