extends Control
## Màn hình chính: HUD, bể ghép 5x6, nút hành động, hiệu ứng, popup. UI dựng bằng code.

const ItemViewScript := preload("res://scripts/item_view.gd")
const FONT := preload("res://fonts/Roboto-Bold.ttf")
const C_BG_TOP := Color("0f4c75")
const C_BG_BOTTOM := Color("071a2c")
const C_GOLD := Color("ffc94a")
const C_GREEN := Color("2fc68f")
const C_PURPLE := Color("8f6bff")
const C_PINK := Color("ff5fa8")

var coins_label: Label
var income_label: Label
var spawn_btn: Button
var bubbles: CPUParticles2D
var fx: Control
var cells: Array[Button] = []
var views: Array = []
var selected: int = -1
var shown_coins: float = 0.0
var circle_tex: ImageTexture
var slot_empty: StyleBoxFlat
var slot_full: StyleBoxFlat
var slot_sel: StyleBoxFlat
var slot_match: StyleBoxFlat
var _tick: float = 0.0
var _ticks: int = 0
var _idle: float = 0.0
var _hint_done: bool = false


func _ready() -> void:
	var t := Theme.new()
	t.default_font = FONT
	t.default_font_size = 30
	theme = t
	circle_tex = _make_circle_tex()
	slot_empty = _box(Color(1, 1, 1, 0.06), 26, 0)
	slot_full = _box(Color(1, 1, 1, 0.12), 26, 0)
	slot_sel = _box(Color(1, 1, 1, 0.24), 26, 0)
	slot_sel.set_border_width_all(5)
	slot_sel.border_color = Color.WHITE
	slot_match = _box(Color(1, 0.85, 0.3, 0.16), 26, 0)
	slot_match.set_border_width_all(4)
	slot_match.border_color = C_GOLD

	_build_bg()
	_build_ui()
	fx = Control.new()
	fx.set_anchors_preset(PRESET_FULL_RECT)
	fx.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(fx)
	resized.connect(_on_resized)

	GameState.board_changed.connect(_refresh_board)
	GameState.new_species.connect(_on_new_species)
	Monetization.ad_rewarded.connect(func(r: int): _reward_fx(r))
	Monetization.purchase_completed.connect(func(_id: String): Sfx.play("coin"))

	var earned := GameState.claim_offline_earnings()
	shown_coins = GameState.coins - earned
	_refresh_board()
	if earned > 0:
		_show_offline_popup.call_deferred(earned)


func _process(delta: float) -> void:
	_tick += delta
	if _tick >= 1.0:
		_tick -= 1.0
		_ticks += 1
		var inc := GameState.income_per_second()
		if inc > 0:
			GameState.add_coins(inc)
		if _ticks % 10 == 0:
			GameState.save_game()
	shown_coins = lerpf(shown_coins, float(GameState.coins), minf(1.0, delta * 8.0))
	if absf(shown_coins - GameState.coins) < 1.0:
		shown_coins = GameState.coins
	coins_label.text = _fmt(int(round(shown_coins)))
	income_label.text = "+%s vàng/giây" % _fmt(GameState.income_per_second())
	_idle += delta
	if _idle > 4.0 and not _hint_done:
		_show_hint()


# ---------- dựng giao diện ----------

func _build_bg() -> void:
	var g := Gradient.new()
	g.set_color(0, C_BG_TOP)
	g.set_color(1, C_BG_BOTTOM)
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	var bg := TextureRect.new()
	bg.texture = gt
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)

	bubbles = CPUParticles2D.new()
	bubbles.texture = circle_tex
	bubbles.amount = 28
	bubbles.lifetime = 9.0
	bubbles.preprocess = 9.0
	bubbles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	bubbles.emission_rect_extents = Vector2(400, 10)
	bubbles.direction = Vector2(0, -1)
	bubbles.spread = 8.0
	bubbles.gravity = Vector2.ZERO
	bubbles.initial_velocity_min = 50.0
	bubbles.initial_velocity_max = 140.0
	bubbles.scale_amount_min = 0.15
	bubbles.scale_amount_max = 0.45
	bubbles.color = Color(1, 1, 1, 0.14)
	add_child(bubbles)


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(PRESET_FULL_RECT)
	root.offset_left = 24
	root.offset_right = -24
	root.offset_top = 40
	root.offset_bottom = -32
	root.add_theme_constant_override("separation", 20)
	add_child(root)

	# HUD
	var hud := PanelContainer.new()
	hud.add_theme_stylebox_override("panel", _box(Color(0, 0, 0, 0.28), 30, 18))
	root.add_child(hud)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 16)
	hud.add_child(hb)
	var coin := Control.new()
	coin.custom_minimum_size = Vector2(72, 72)
	coin.draw.connect(func(): _draw_coin(coin, Vector2(36, 36), 30.0))
	hb.add_child(coin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", -4)
	hb.add_child(col)
	coins_label = Label.new()
	coins_label.add_theme_font_size_override("font_size", 54)
	col.add_child(coins_label)
	income_label = Label.new()
	income_label.add_theme_font_size_override("font_size", 24)
	income_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	col.add_child(income_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	hb.add_child(spacer)
	var shop := _make_button("Shop", C_PINK, Vector2(150, 84))
	shop.size_flags_vertical = SIZE_SHRINK_CENTER
	shop.pressed.connect(_open_shop)
	hb.add_child(shop)

	# Bể ghép
	var board_panel := PanelContainer.new()
	board_panel.add_theme_stylebox_override("panel", _box(Color(1, 1, 1, 0.05), 34, 14))
	board_panel.size_flags_vertical = SIZE_EXPAND_FILL
	root.add_child(board_panel)
	var center := CenterContainer.new()
	board_panel.add_child(center)
	var grid := GridContainer.new()
	grid.columns = GameState.COLS
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	center.add_child(grid)
	for i in GameState.COLS * GameState.ROWS:
		var b := Button.new()
		b.custom_minimum_size = Vector2(118, 118)
		b.focus_mode = FOCUS_NONE
		b.pressed.connect(_on_cell_pressed.bind(i))
		var v = ItemViewScript.new()
		v.set_anchors_preset(PRESET_FULL_RECT)
		v.mouse_filter = MOUSE_FILTER_IGNORE
		b.add_child(v)
		grid.add_child(b)
		cells.append(b)
		views.append(v)

	# Hành động
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 16)
	root.add_child(actions)
	spawn_btn = _make_button("+ Thả cá  (%d)" % GameState.SPAWN_COST, C_GREEN, Vector2(0, 112))
	spawn_btn.size_flags_horizontal = SIZE_EXPAND_FILL
	spawn_btn.size_flags_stretch_ratio = 1.6
	spawn_btn.pressed.connect(_on_spawn)
	actions.add_child(spawn_btn)
	var gift := _make_button("Quà miễn phí", C_PURPLE, Vector2(0, 112))
	gift.size_flags_horizontal = SIZE_EXPAND_FILL
	gift.pressed.connect(Monetization.show_rewarded_ad)
	actions.add_child(gift)


func _on_resized() -> void:
	bubbles.position = Vector2(size.x / 2.0, size.y + 30.0)
	bubbles.emission_rect_extents = Vector2(size.x / 2.0, 10)


# ---------- logic tương tác ----------

func _refresh_board() -> void:
	var sel_lv: int = GameState.board[selected] if selected >= 0 else 0
	for i in cells.size():
		var lv: int = GameState.board[i]
		views[i].level = lv
		var sb: StyleBoxFlat = slot_empty
		if i == selected:
			sb = slot_sel
		elif sel_lv > 0 and lv == sel_lv and lv < GameState.MAX_LEVEL:
			sb = slot_match
		elif lv > 0:
			sb = slot_full
		for st in ["normal", "hover", "pressed", "disabled", "focus"]:
			cells[i].add_theme_stylebox_override(st, sb)


func _on_cell_pressed(i: int) -> void:
	_idle = 0.0
	var lv: int = GameState.board[i]
	if selected == -1:
		if lv > 0:
			selected = i
			_pop(views[i], 1.15)
			Sfx.play("select")
	elif selected == i:
		selected = -1
	else:
		var from := selected
		selected = -1
		if GameState.try_merge(from, i):
			_on_merged(i)
		elif lv == 0:
			GameState.move_item(from, i)
			_pop(views[i], 1.1)
		else:
			selected = i
			_pop(views[i], 1.15)
			Sfx.play("select")
	_refresh_board()


func _on_merged(to: int) -> void:
	var lv: int = GameState.board[to]
	var v: Control = views[to]
	v.pivot_offset = v.size / 2.0
	v.scale = Vector2(0.5, 0.5)
	var tw := v.create_tween()
	tw.tween_property(v, "scale", Vector2(1.3, 1.3), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(v, "scale", Vector2.ONE, 0.18)
	var p := _center_of(cells[to])
	var color: Color = ItemViewScript.PALETTE[lv - 1]
	_burst(p, color, 22 + lv * 3)
	_burst(p, Color.WHITE, 8)
	_float_text(p, "Cấp %d!" % lv, Color.WHITE)
	Sfx.play("merge", 0.9 + lv * 0.06)
	Input.vibrate_handheld(25)


func _on_new_species(lv: int) -> void:
	var nm: String = ItemViewScript.NAMES[lv - 1]
	_banner("Loài mới: %s!" % nm)
	Sfx.play("unlock")


func _on_spawn() -> void:
	_idle = 0.0
	var idx := GameState.spawn_item()
	if idx < 0:
		_float_text(_center_of(spawn_btn), "Thiếu vàng hoặc hết chỗ", Color("ff8a80"))
		_shake(spawn_btn)
		Sfx.play("error")
		return
	var v: Control = views[idx]
	v.pivot_offset = v.size / 2.0
	v.scale = Vector2.ZERO
	v.create_tween().tween_property(v, "scale", Vector2.ONE, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_burst(_center_of(cells[idx]), Color(0.8, 0.95, 1.0, 0.9), 10)
	Sfx.play("spawn")


func _show_hint() -> void:
	_hint_done = true
	var seen := {}
	for i in GameState.board.size():
		var lv: int = GameState.board[i]
		if lv <= 0 or lv >= GameState.MAX_LEVEL:
			continue
		if seen.has(lv):
			for j in [seen[lv], i]:
				var v: Control = views[j]
				v.pivot_offset = v.size / 2.0
				var tw := v.create_tween().set_loops(2)
				tw.tween_property(v, "scale", Vector2(1.12, 1.12), 0.2)
				tw.tween_property(v, "scale", Vector2.ONE, 0.2)
			return
		seen[lv] = i


func _reward_fx(amount: int) -> void:
	_float_text(_center_of(coins_label), "+" + _fmt(amount), C_GOLD)
	_burst(_center_of(coins_label), C_GOLD, 24)
	Sfx.play("coin")


# ---------- popup ----------

func _show_offline_popup(earned: int) -> void:
	_modal("Chào mừng trở lại!", "Đàn cá đã kiếm được\n%s vàng khi bạn vắng mặt" % _fmt(earned), [
		["Nhận", C_GREEN, func(): _reward_fx(earned)],
		# TODO: chỉ cộng thêm sau khi quảng cáo thật xem xong.
		["x2 (xem quảng cáo)", C_PURPLE, func():
			GameState.add_coins(earned)
			_reward_fx(earned * 2)],
	])


func _open_shop() -> void:
	var items: Array = []
	for id in Monetization.PRODUCTS:
		var pid: String = id
		var prod: Dictionary = Monetization.PRODUCTS[id]
		var label := "Bỏ quảng cáo" if pid == "remove_ads" else "%s vàng" % _fmt(int(prod.coins))
		var color := C_GOLD.darkened(0.15) if pid == "starter_pack" else C_PURPLE
		items.append(["%s  •  $%s" % [label, prod.price], color, func(): Monetization.purchase(pid)])
	items.append(["Đóng", Color("4a5b6e"), func(): pass])
	_modal("Cửa hàng", "Gói khởi đầu chỉ mua được 1 lần", items)


func _modal(title: String, body: String, buttons: Array) -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(PRESET_FULL_RECT)
	add_child(dim)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(PRESET_FULL_RECT)
	dim.add_child(cc)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 0)
	var pbox := _box(Color("143a5a"), 36, 32)
	pbox.set_border_width_all(3)
	pbox.border_color = Color(1, 1, 1, 0.15)
	panel.add_theme_stylebox_override("panel", pbox)
	cc.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	panel.add_child(vb)
	var tl := Label.new()
	tl.text = title
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tl.add_theme_font_size_override("font_size", 46)
	tl.add_theme_color_override("font_color", C_GOLD)
	vb.add_child(tl)
	var bl := Label.new()
	bl.text = body
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bl.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	vb.add_child(bl)
	for spec in buttons:
		var b := _make_button(spec[0], spec[1], Vector2(0, 92))
		b.pressed.connect(spec[2])
		b.pressed.connect(dim.queue_free)
		vb.add_child(b)
	dim.modulate.a = 0.0
	dim.create_tween().tween_property(dim, "modulate:a", 1.0, 0.2)


# ---------- hiệu ứng ----------

func _burst(pos: Vector2, color: Color, amount: int) -> void:
	var p := CPUParticles2D.new()
	p.texture = circle_tex
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = 0.75
	p.spread = 180.0
	p.initial_velocity_min = 180.0
	p.initial_velocity_max = 440.0
	p.gravity = Vector2(0, 800)
	p.scale_amount_min = 0.25
	p.scale_amount_max = 0.6
	var ramp := Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color, 0.0))
	p.color_ramp = ramp
	p.position = pos
	fx.add_child(p)
	p.emitting = true
	get_tree().create_timer(1.3).timeout.connect(p.queue_free)


func _float_text(pos: Vector2, text: String, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(400, 0)
	l.add_theme_font_size_override("font_size", 40)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("outline_size", 10)
	fx.add_child(l)
	l.position = pos - Vector2(200, 40)
	var tw := l.create_tween().set_parallel()
	tw.tween_property(l, "position:y", l.position.y - 100, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.5).set_delay(0.45)
	tw.chain().tween_callback(l.queue_free)


func _banner(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 58)
	l.add_theme_color_override("font_color", C_GOLD)
	l.add_theme_color_override("font_outline_color", Color("3a2200"))
	l.add_theme_constant_override("outline_size", 14)
	fx.add_child(l)
	l.size = Vector2(size.x, 140)
	l.position = Vector2(0, size.y * 0.38)
	l.pivot_offset = l.size / 2.0
	l.scale = Vector2(0.3, 0.3)
	var tw := l.create_tween()
	tw.tween_property(l, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.3)
	tw.tween_property(l, "modulate:a", 0.0, 0.4)
	tw.tween_callback(l.queue_free)
	_burst(Vector2(size.x / 2.0, size.y * 0.38 + 70), C_GOLD, 40)


func _pop(v: Control, s: float) -> void:
	v.pivot_offset = v.size / 2.0
	var tw := v.create_tween()
	tw.tween_property(v, "scale", Vector2(s, s), 0.08)
	tw.tween_property(v, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _shake(n: Control) -> void:
	var x := n.position.x
	var tw := n.create_tween()
	for k in [12.0, -10.0, 6.0, -3.0, 0.0]:
		tw.tween_property(n, "position:x", x + k, 0.04)


# ---------- tiện ích ----------

func _make_button(text: String, color: Color, min_size: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.focus_mode = FOCUS_NONE
	b.add_theme_font_size_override("font_size", 32)
	b.add_theme_stylebox_override("normal", _btn_box(color, false))
	b.add_theme_stylebox_override("hover", _btn_box(color.lightened(0.08), false))
	b.add_theme_stylebox_override("pressed", _btn_box(color.darkened(0.1), true))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(k, Color.WHITE)
	b.add_theme_color_override("font_outline_color", color.darkened(0.5))
	b.add_theme_constant_override("outline_size", 6)
	b.button_down.connect(func(): _squash(b, 0.94))
	b.button_up.connect(func(): _squash(b, 1.0))
	return b


func _btn_box(c: Color, pressed: bool) -> StyleBoxFlat:
	var sb := _box(c, 28, 16)
	sb.border_width_bottom = 2 if pressed else 8
	sb.border_color = c.darkened(0.35)
	sb.shadow_color = Color(0, 0, 0, 0.3)
	sb.shadow_size = 4 if pressed else 10
	sb.shadow_offset = Vector2(0, 4)
	return sb


func _box(c: Color, radius: int, margin: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(margin)
	sb.anti_aliasing = true
	return sb


func _squash(n: Control, s: float) -> void:
	n.pivot_offset = n.size / 2.0
	n.create_tween().tween_property(n, "scale", Vector2(s, s), 0.08)


func _center_of(c: Control) -> Vector2:
	return c.global_position + c.size / 2.0


func _draw_coin(ctrl: Control, c: Vector2, r: float) -> void:
	ctrl.draw_circle(c + Vector2(0, 3), r, Color("b8860b"))
	ctrl.draw_circle(c, r, C_GOLD)
	ctrl.draw_circle(c, r * 0.68, Color("ffdf7e"))
	ctrl.draw_arc(c, r * 0.68, 0, TAU, 32, Color("e0a82e"), 3.0, true)
	ctrl.draw_circle(c + Vector2(-r * 0.35, -r * 0.35), r * 0.15, Color(1, 1, 1, 0.8))


func _make_circle_tex() -> ImageTexture:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for y in 32:
		for x in 32:
			var d := Vector2(x + 0.5 - 16.0, y + 0.5 - 16.0).length()
			img.set_pixel(x, y, Color(1, 1, 1, clampf(16.0 - d, 0.0, 1.0)))
	return ImageTexture.create_from_image(img)


func _fmt(n: int) -> String:
	if n < 1000:
		return str(n)
	if n < 1000000:
		return "%.1fK" % (n / 1000.0)
	if n < 1000000000:
		return "%.1fM" % (n / 1000000.0)
	return "%.1fB" % (n / 1000000000.0)
