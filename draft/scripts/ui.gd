extends RefCounted
## UI tối giản: nền phẳng, một màu nhấn, hai độ đậm chữ.

const BOLD := preload("res://fonts/Roboto-Bold.ttf")
const REGULAR := preload("res://fonts/Roboto-Regular.ttf")
const BG := Color("0b1220")
const CARD := Color("141c2f")
const LINE := Color(1, 1, 1, 0.08)
const TEXT := Color("f1f5f9")
const MUTED := Color("a3adbf")
const ACCENT := Color("ffb020")
const GOOD := Color("4ade80")
const BAD := Color("f87171")


static func box(c: Color, radius: int = 16, margin: int = 16) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(margin)
	sb.anti_aliasing = true
	return sb


static func style(b: Button, bg: Color, fg: Color) -> void:
	b.add_theme_stylebox_override("normal", box(bg))
	b.add_theme_stylebox_override("hover", box(bg.lightened(0.04) if bg.a > 0 else Color(1, 1, 1, 0.03)))
	b.add_theme_stylebox_override("pressed", box(bg.darkened(0.1) if bg.a > 0 else Color(1, 1, 1, 0.06)))
	b.add_theme_stylebox_override("disabled", box(bg.darkened(0.5) if bg.a > 0 else Color(0, 0, 0, 0)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(k, fg)
	b.add_theme_color_override("font_disabled_color", Color(fg, 0.35))


static func button(text: String, bg: Color, fg: Color, h: float = 88, fs: int = 28) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, h)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", fs)
	style(b, bg, fg)
	b.button_down.connect(func():
		b.pivot_offset = b.size / 2.0
		b.create_tween().tween_property(b, "scale", Vector2(0.98, 0.98), 0.05))
	b.button_up.connect(func(): b.create_tween().tween_property(b, "scale", Vector2.ONE, 0.08))
	return b


static func label(text: String, fs: int, color: Color = TEXT, regular: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	if regular:
		l.add_theme_font_override("font", REGULAR)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
