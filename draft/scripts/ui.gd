extends RefCounted
## Tiện ích UI dùng chung: khung bo góc, nút 3D có hiệu ứng nhấn, nhãn.


static func box(c: Color, radius: int, margin: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(margin)
	sb.anti_aliasing = true
	return sb


static func style(b: Button, c: Color) -> void:
	for st in ["normal", "hover", "pressed", "disabled"]:
		var col := c
		if st == "hover":
			col = c.lightened(0.06)
		elif st == "pressed":
			col = c.darkened(0.12)
		elif st == "disabled":
			col = c.darkened(0.45)
		var sb := box(col, 20, 12)
		sb.border_width_bottom = 2 if st == "pressed" else 6
		sb.border_color = c.darkened(0.4)
		b.add_theme_stylebox_override(st, sb)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


static func button(text: String, c: Color, min_size: Vector2, font_size: int = 28) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", font_size)
	for k in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(k, Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.4))
	style(b, c)
	b.button_down.connect(func():
		b.pivot_offset = b.size / 2.0
		b.create_tween().tween_property(b, "scale", Vector2(0.96, 0.96), 0.06))
	b.button_up.connect(func(): b.create_tween().tween_property(b, "scale", Vector2.ONE, 0.08))
	return b


static func label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l
