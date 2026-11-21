extends Control
## Vẽ nhân vật cá theo cấp bằng code (không cần art). Có bơi nhấp nhô, vẫy đuôi.

const PALETTE := [
	Color("7fd1ff"), Color("5fe3c0"), Color("a8e063"), Color("ffe066"), Color("ffb347"),
	Color("ff7f6e"), Color("ff6fb5"), Color("c58bff"), Color("8c9bff"), Color("ffd24a"),
]
const NAMES := [
	"Cá Bé", "Cá Bong Bóng", "Cá Chấm Bi", "Cá Nắng", "Cá Ngôi Sao",
	"Cá Đốm Đỏ", "Cá Hồng Ngọc", "Cá Hoàng Gia", "Cá Thiên Hà", "Cá Thần",
]
const INK := Color("1b2633")

var level: int = 0: set = _set_level
var _t: float = 0.0


func _ready() -> void:
	_t = randf() * TAU


func _set_level(v: int) -> void:
	level = v
	queue_redraw()


func _process(delta: float) -> void:
	if level > 0:
		_t += delta * 2.2
		queue_redraw()


func _draw() -> void:
	if level <= 0:
		return
	var s := minf(size.x, size.y)
	var c := size / 2.0
	var col: Color = PALETTE[clampi(level - 1, 0, PALETTE.size() - 1)]
	var r := s * (0.22 + 0.012 * level)
	var bob := sin(_t) * s * 0.025
	var wag := sin(_t * 1.7) * 0.25

	# bóng đổ
	draw_set_transform(c + Vector2(0, s * 0.37), 0.0, Vector2(1.0, 0.28))
	draw_circle(Vector2.ZERO, r * 0.9, Color(0, 0, 0, 0.22))
	draw_set_transform(c + Vector2(0, bob), 0.0, Vector2.ONE)

	if level >= 8:
		draw_circle(Vector2.ZERO, r * 1.5, Color(col, 0.16 + 0.06 * sin(_t * 2.0)))

	# đuôi
	var tb := Vector2(-r * 0.8, 0)
	draw_colored_polygon(PackedVector2Array([
		tb, tb + Vector2(-r * 0.75, -r * 0.6).rotated(wag), tb + Vector2(-r * 0.75, r * 0.6).rotated(wag),
	]), col.darkened(0.15))
	# vây lưng
	if level < 5:
		draw_colored_polygon(PackedVector2Array([
			Vector2(-r * 0.35, -r * 0.8), Vector2(r * 0.15, -r * 1.25), Vector2(r * 0.35, -r * 0.75),
		]), col.darkened(0.15))

	# thân + bụng
	draw_circle(Vector2.ZERO, r, col)
	draw_circle(Vector2(r * 0.1, r * 0.35), r * 0.6, col.lightened(0.35))
	if level in [3, 6, 9]:
		for p in [Vector2(-r * 0.45, -r * 0.2), Vector2(-r * 0.1, -r * 0.55), Vector2(-r * 0.55, r * 0.2)]:
			draw_circle(p, r * 0.13, col.darkened(0.22))
	draw_circle(Vector2(-r * 0.4, -r * 0.45), r * 0.18, Color(1, 1, 1, 0.55))

	# vây bên
	draw_colored_polygon(PackedVector2Array([
		Vector2(-r * 0.1, r * 0.1), Vector2(-r * 0.5, r * 0.45 + wag * r * 0.3), Vector2(r * 0.05, r * 0.42),
	]), col.darkened(0.1))

	# mắt, má, miệng
	var eye := Vector2(r * 0.38, -r * 0.15)
	var blink := 0.15 if fmod(_t, 9.0) < 0.15 else 1.0
	draw_set_transform(c + Vector2(0, bob) + eye, 0.0, Vector2(1.0, blink))
	draw_circle(Vector2.ZERO, r * 0.3, Color.WHITE)
	draw_circle(Vector2(r * 0.06, r * 0.03), r * 0.16, INK)
	draw_circle(Vector2(r * 0.01, -r * 0.05), r * 0.06, Color.WHITE)
	draw_set_transform(c + Vector2(0, bob), 0.0, Vector2.ONE)
	draw_circle(Vector2(r * 0.22, r * 0.3), r * 0.1, Color(1, 0.4, 0.5, 0.45))
	draw_arc(Vector2(r * 0.7, r * 0.15), r * 0.12, 0.2, PI - 0.2, 12, INK, maxf(2.0, r * 0.07))

	# phụ kiện theo cấp
	if level >= 8:
		var k := PackedVector2Array()
		for p in [Vector2(-0.45, -0.82), Vector2(-0.45, -1.28), Vector2(-0.22, -1.02), Vector2(0, -1.4),
				Vector2(0.22, -1.02), Vector2(0.45, -1.28), Vector2(0.45, -0.82)]:
			k.append(p * r)
		draw_colored_polygon(k, Color("ffd24a"))
		draw_circle(Vector2(0, -r * 0.98), r * 0.08, Color("ff5d7a"))
	elif level >= 5:
		_star(Vector2(0, -r * 1.12), r * 0.32, r * 0.14, Color("ffe066"))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# huy hiệu cấp
	var bc := Vector2(size.x - s * 0.17, size.y - s * 0.17)
	draw_circle(bc, s * 0.12, Color(0, 0, 0, 0.45))
	var fs := int(s * 0.15)
	draw_string(get_theme_default_font(), bc + Vector2(-s * 0.12, fs * 0.36), str(level),
		HORIZONTAL_ALIGNMENT_CENTER, s * 0.24, fs, Color.WHITE)


func _star(center: Vector2, ro: float, ri: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2.0 + i * PI / 5.0
		pts.append(center + Vector2(cos(a), sin(a)) * (ro if i % 2 == 0 else ri))
	draw_colored_polygon(pts, color)
