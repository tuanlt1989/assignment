extends RefCounted
## UI tối giản: nền phẳng, một màu nhấn, hai độ đậm chữ.

const BOLD := preload("res://fonts/Roboto-Bold.ttf")
const REGULAR := preload("res://fonts/Roboto-Regular.ttf")
const DISPLAY := preload("res://fonts/BebasNeue.woff2")
## Phong cách sáng: nền trắng ngà, xanh sân cỏ làm màu chính, vàng làm điểm nhấn.
const BG := Color("f3f4ee")
const CARD := Color("ffffff")
const INK := Color("11261b")
const LINE := Color(0.07, 0.15, 0.1, 0.08)
const TEXT := Color("11261b")
const MUTED := Color("6b7a71")
const ACCENT := Color("1f5c3a")
const GOLD := Color("e8a20c")
const GOOD := Color("15803d")
const INFO := Color("0f766e")
const WARN := Color("c2410c")
const BAD := Color("dc2626")


static func box(c: Color, radius: int = 16, margin: int = 16) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(margin)
	sb.anti_aliasing = true
	if c == CARD:
		sb.shadow_color = Color(0, 0, 0, 0.05)
		sb.shadow_size = 8
		sb.shadow_offset = Vector2(0, 2)
		sb.set_border_width_all(1)
		sb.border_color = LINE
	return sb


## Nút phụ: nền trong suốt, viền mảnh.
static func outline_button(text: String, fg: Color, h: float = 72, fs: int = 24) -> Button:
	var b := button(text, Color(0, 0, 0, 0), fg, h, fs)
	for st in ["normal", "hover", "pressed"]:
		var sb := box(Color(1, 1, 1, 0.0 if st == "normal" else 0.05))
		sb.set_border_width_all(2)
		sb.border_color = Color(fg, 0.45)
		b.add_theme_stylebox_override(st, sb)
	return b


static func style(b: Button, bg: Color, fg: Color, radius: int = 16) -> void:
	b.add_theme_stylebox_override("normal", box(bg, radius))
	b.add_theme_stylebox_override("hover", box(bg.lightened(0.04) if bg.a > 0 else Color(INK, 0.03), radius))
	b.add_theme_stylebox_override("pressed", box(bg.darkened(0.1) if bg.a > 0 else Color(INK, 0.06), radius))
	b.add_theme_stylebox_override("disabled", box(bg.darkened(0.5) if bg.a > 0 else Color(0, 0, 0, 0), radius))
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
		click()
		b.pivot_offset = b.size / 2.0
		b.create_tween().tween_property(b, "scale", Vector2(0.98, 0.98), 0.05))
	b.button_up.connect(func(): b.create_tween().tween_property(b, "scale", Vector2.ONE, 0.08))
	return b


## Nhãn dạng viên thuốc: nền tô nhạt 12%, có thể có viền.
static func pill(text: String, color: Color, fs: int = 18, outline: bool = false, filled: bool = false) -> PanelContainer:
	var pc := PanelContainer.new()
	var sb := box(Color(color, 0.0 if outline else (0.95 if filled else 0.16)), 8, 0)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	if outline:
		sb.set_border_width_all(2)
		sb.border_color = Color(color, 0.7)
	pc.add_theme_stylebox_override("panel", sb)
	pc.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	pc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(label(text, fs, BG if filled else color))
	return pc


## Chữ tiêu đề kiểu thể thao (Bebas Neue, chữ hoa condensed).
static func display(text: String, fs: int, color: Color = TEXT) -> Label:
	var l := label(text.to_upper(), fs, color)
	l.add_theme_font_override("font", DISPLAY)
	return l


## Tiếng bấm nhẹ (qua autoload Sfx nếu có).
static func click() -> void:
	var sfx: Node = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("Sfx")
	if sfx:
		sfx.play("tap", -8.0)


static func label(text: String, fs: int, color: Color = TEXT, regular: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	if regular:
		l.add_theme_font_override("font", REGULAR)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
